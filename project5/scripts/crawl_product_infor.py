import asyncio
import aiohttp
import pandas as pd
import json
import re
from bs4 import BeautifulSoup
import time
from datetime import datetime, UTC
import csv
import os
from datetime import datetime
from pymongo import MongoClient
import csv


# =====================================================================
# CẤU HÌNH CHUNG
# =====================================================================

# Giới hạn số request chạy song song (để không "đập" website quá mạnh)
SEM = asyncio.Semaphore(30)

# Header giả lập browser thật để giảm nguy cơ bị chặn
HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    )
}

# Các key quan tâm trong react_data (hiện tại chưa dùng hết,
# nhưng là danh sách các field product có thể muốn lấy sau này)
wanted_keys = [
    "name", "sku",
    "attribute_set_id", "attribute_set",
    "type_id", "price", "min_price", "max_price",
    "min_price_format", "max_price_format",
    "gold_weight", "none_metal_weight", "fixed_silver_weight",
    "material_design", "qty", "collection", "collection_id",
    "product_type", "product_type_value",
    "category", "category_name", "store_code",
    "platinum_palladium_info_in_alloy",
    "bracelet_without_chain",
    "show_popup_quantity_eternity",
    "visible_contents",
    "gender",
    "configure_mode",
    "included_chain_weight",
]

# Danh sách toàn bộ domain Glamira sẽ thử lần lượt
# → Product nào xuất hiện ở domain nào thì lấy ở domain đó
list_domains = [
    'www.glamira.co.uk', 'www.glamira.com', 'www.glamira.ae', 'www.glamira.africa',
    'www.glamira.al', 'www.glamira.at', 'www.glamira.az', 'www.glamira.be',
    'www.glamira.bg', 'www.glamira.ca', 'www.glamira.ch', 'www.glamira.cl',
    'www.glamira.cn', 'www.glamira.co.cr', 'www.glamira.co.id', 'www.glamira.co.nz',
    'www.glamira.co.th', 'www.glamira.co.za', 'www.glamira.com.ar',
    'www.glamira.com.au', 'www.glamira.com.bo', 'www.glamira.com.br',
    'www.glamira.com.co', 'www.glamira.com.do', 'www.glamira.com.ec',
    'www.glamira.com.gt', 'www.glamira.com.kw', 'www.glamira.com.mt',
    'www.glamira.com.mx', 'www.glamira.com.my', 'www.glamira.com.pa',
    'www.glamira.com.pe', 'www.glamira.com.ph', 'www.glamira.com.pr',
    'www.glamira.com.py', 'www.glamira.com.sv', 'www.glamira.com.tr',
    'www.glamira.com.tw', 'www.glamira.com.ua', 'www.glamira.com.uy',
    'www.glamira.cz', 'www.glamira.de', 'www.glamira.dk', 'www.glamira.ee',
    'www.glamira.es', 'www.glamira.fi', 'www.glamira.fr', 'www.glamira.hk',
    'www.glamira.hn', 'www.glamira.hr', 'www.glamira.hu', 'www.glamira.ie',
    'www.glamira.in', 'www.glamira.is', 'www.glamira.it', 'www.glamira.jp',
    'www.glamira.kr', 'www.glamira.lt', 'www.glamira.lv', 'www.glamira.md',
    'www.glamira.nl', 'www.glamira.no', 'www.glamira.pl', 'www.glamira.pt',
    'www.glamira.ro', 'www.glamira.rs', 'www.glamira.se', 'www.glamira.sg',
    'www.glamira.si', 'www.glamira.sk', 'www.glamira.store', 'www.glamira.vn'
]


# =====================================================================
# 1. LẤY DANH SÁCH PRODUCT_ID TỪ MONGODB
# =====================================================================
def extract_product_list(mongo_port, db_name, col_name):
    """
    Kết nối vào MongoDB, đọc collection summary,
    chạy aggregation để lấy danh sách product_id unique
    từ các event liên quan tới product.
    """
    # 1. Kết nối MongoDB
    client = MongoClient(mongo_port)
    db = client[db_name]
    col = db[col_name]

    # 2. Danh sách event liên quan đến product detail
    event = [
        "view_product_detail",
        "select_product_option",
        "select_product_option_quality",
        "add_to_cart_action",
        "product_detail_recommendation_visible",
        "product_detail_recommendation_noticed",
        "product_view_all_recommend_clicked",
    ]

    # 3. Pipeline aggregate để lấy danh sách product_id unique
    pipeline = [
        # Lọc đúng event
        {
            "$match": {
                "collection": {"$in": event}
            }
        },

        # Chuẩn hóa product_id:
        # nếu product_id null => fallback sang viewing_product_id
        {
            "$project": {
                "_id": 0,
                "product_id": {
                    "$ifNull": ["$product_id", "$viewing_product_id"]
                }
            }
        },

        # Loại null, rỗng, false
        {
            "$match": {
                "product_id": {"$nin": [None, "", False]}
            }
        },

        # Group để lấy unique product_id
        {
            "$group": {
                "_id": "$product_id"
            }
        },

        # Sort product_id tăng dần
        {
            "$sort": {"_id": 1}
        }
    ]

    # 4. Chạy aggregate với allowDiskUse để tránh lỗi RAM khi data lớn
    cursor = col.aggregate(pipeline, allowDiskUse=True)
    all_ids = []

    # Convert _id (product_id) từ cursor thành list[int]
    for i in cursor:
        all_ids.append(int(i.get("_id")))

    return all_ids


# =====================================================================
# 2. FORMAT URL TỪ DOMAIN + PRODUCT_ID
# =====================================================================
def build_url(domain, product_id):
    """
    Tạo URL product detail theo format chung của Glamira.
    Ví dụ:
    https://www.glamira.fr/catalog/product/view/id/12345
    """
    return f"https://{domain}/catalog/product/view/id/{product_id}"


# =====================================================================
# 3. FETCH MỘT URL SẢN PHẨM → PARSE REACT_DATA
# =====================================================================
async def fetch_one(session, product_id, url, log_data: list, delay=0.05):
    """
    Gửi 1 HTTP request tới URL sản phẩm,
    tìm script chứa 'var react_data = {...}',
    parse JSON, trích 1 số field cơ bản.
    Đồng thời log lại toàn bộ quá trình vào log_data.
    """
    async with SEM:  # Giới hạn concurrency
        start = time.time()  # Đo thời gian cho từng request

        try:
            # Gửi request HTTP (timeout 15s)
            async with session.get(url, timeout=15) as resp:
                status = resp.status
                html = None

                # Ghi log ngay sau khi nhận response (dù thành công hay fail)
                log_data.append({
                    "timestamp": datetime.now(UTC).isoformat(),
                    "product_id": product_id,  # log raw cho an toàn
                    "url": url,
                    "stage": "request",        # stage: request
                    "status": status,          # HTTP status code
                    "elapsed_ms": round((time.time() - start) * 1000, 1),
                })

                # Nếu không phải 200 => không parse nữa, trả None
                if status != 200:
                    await asyncio.sleep(delay)
                    return None

                # Đọc toàn bộ HTML để parse bằng BeautifulSoup
                html = await resp.text()

        except Exception as e:
            # Log các lỗi network / timeout / connection
            log_data.append({
                "timestamp": datetime.now(UTC).isoformat(),
                "product_id": product_id,
                "url": url,
                "stage": "request",
                "status": f"{type(e).__name__}: {e}",
                "elapsed_ms": round((time.time() - start) * 1000, 1),
            })
            return None

        # Nếu tới đây tức là đã có HTML, bắt đầu parse
        try:
            soup = BeautifulSoup(html, "html.parser")

            # Tìm thẻ <script> có chứa chuỗi "var react_data"
            # string=lambda s: s and "var react_data" in s
            #   - s là nội dung text của từng <script>
            #   - điều kiện "s and ..." để tránh s = None
            script = soup.find("script", string=lambda s: s and "var react_data" in s)
            if not script:
                # Không tìm thấy script chứa react_data
                log_data.append({
                    "timestamp": datetime.now(UTC).isoformat(),
                    "product_id": product_id,
                    "url": url,
                    "stage": "parse",
                    "status": "miss_react_data",
                    "elapsed_ms": round((time.time() - start) * 1000, 1),
                })
                return None

            # Dùng regex để bắt đoạn "var react_data = {...};"
            # re.DOTALL: cho phép regex match xuống nhiều dòng (do JSON thường dài)
            m = re.search(
                r"var\s+react_data\s*=\s*(\{.*?\});",
                script.string,
                re.DOTALL
            )
            if not m:
                # Không match được pattern → log lỗi regex
                log_data.append({
                    "timestamp": datetime.now(UTC).isoformat(),
                    "product_id": product_id,
                    "url": url,
                    "stage": "parse",
                    "status": "regex_fail",
                    "elapsed_ms": round((time.time() - start) * 1000, 1),
                })
                return None

            # m.group(1) là phần nội dung JSON trong ngoặc {}
            data = json.loads(m.group(1))

            # Chỉ lấy 1 số field cơ bản để lưu ra CSV
            result = {
                "product_id": int(product_id),
                "url": url,
                "name": data.get("name"),
                "sku": data.get("sku"),
                "price": data.get("price"),
                "category_name": data.get("category_name"),
            }

            # Log parse thành công
            log_data.append({
                "timestamp": datetime.now(UTC).isoformat(),
                "product_id": product_id,
                "url": url,
                "stage": "parse",
                "status": "success",
                "elapsed_ms": round((time.time() - start) * 1000, 1),
            })

            return result

        except Exception as e:
            # Bất kỳ lỗi parse nào khác (JSON, BeautifulSoup, ...)
            log_data.append({
                "product_id": int(product_id),
                "url": url,
                "stage": "parse",
                "status": f"{type(e).__name__}: {e}",
            })
            await asyncio.sleep(delay)
            return None


# =====================================================================
# 4. THỬ FETCH THEO TỪNG DOMAIN CHO 1 PRODUCT_ID
# =====================================================================
async def fetch_by_domain(session, product_id, log_data, delay):
    """
    Với mỗi product_id:
    - Lần lượt build URL trên từng domain trong list_domains
    - Gọi fetch_one() để thử lấy dữ liệu
    - Domain nào trả về result đầu tiên sẽ dùng luôn
    """
    for domain in list_domains:
        url = build_url(domain, product_id)
        result = await fetch_one(session, product_id, url, log_data, delay)
        if result:
            # Nếu thành công ở domain nào thì dừng ngay tại đó
            return result

    # Nếu thử hết domain mà không được → trả None
    return None


# =====================================================================
# 5. CRAWL ASYNC TOÀN BỘ DANH SÁCH PRODUCT_ID
# =====================================================================
async def crawl_products(product_list, output_file, log_file):
    """
    Chạy crawl bất đồng bộ cho 1 list product_id:
    - Tạo task cho từng product_id (fetch_by_domain)
    - Lưu kết quả (result) vào CSV
    - Lưu toàn bộ log (log_data) vào CSV log_file
    """
    log_data = []   # Lưu log chi tiết từng request/parse
    results = []    # Lưu các product crawl thành công

    print("Crawling infor:")
    async with aiohttp.ClientSession() as session:
        # Tạo list task async cho từng product_id
        tasks = [
            asyncio.create_task(
                fetch_by_domain(session, pid, log_data, 0.05)
            )
            for pid in product_list
        ]

        done = 0

        # asyncio.as_completed: trả kết quả theo thứ tự task hoàn thành
        for i in asyncio.as_completed(tasks):
            res = await i
            if res:
                results.append(res)

            done += 1
            # In progress mỗi 100 product
            if done % 100 == 0:
                print(f"Crawl number of product: {done}")

    # Sau khi crawl xong: nếu có kết quả thì lưu CSV
    if results:
        output_df = pd.DataFrame(results)
        output_df.to_csv(output_file, index=False, encoding="utf-8")
        print(f"Save results to {output_file}, total products: {len(results)}")
    else:
        print("No product crawl. Result is empty")

    # Log luôn được lưu lại (kể cả khi results rỗng)
    log_df = pd.DataFrame(log_data)
    log_df.to_csv(log_file, index=False, encoding="utf-8")
    print(f"Save log to {log_file}")

    return results


# =====================================================================
# 6. HỖ TRỢ TÌM DANH SÁCH PRODUCT BỊ FAIL ĐỂ RETRY
# =====================================================================
def get_fail_products(total_product, ok_products):
    """
    Nhận:
      - total_product: list tất cả product_id dự kiến crawl
      - ok_products: list dict kết quả crawl thành công (có field product_id)
    Trả:
      - fail_ids: list product_id bị fail (chưa có trong ok_products)
    """
    ok_ids = [d["product_id"] for d in ok_products]
    fail_ids = [x for x in total_product if x not in ok_ids]
    return fail_ids


# =====================================================================
# 7. MAIN FLOW: CRAWL + RETRY FAIL
# =====================================================================
async def main():
    # Biến này hiện chưa dùng (có thể dùng nếu muốn đọc list product từ file CSV)
    input_file = "test_product_list.csv"

    print("=== Get list products ===")
    # Lấy toàn bộ danh sách product_id từ MongoDB
    all_ids = extract_product_list(
        mongo_port="mongodb://localhost:27017/",
        db_name="countly",
        col_name="summary"
    )

    print("=== FIRST RUN ===")
    # Lần crawl đầu tiên cho toàn bộ product_id
    result1 = await crawl_products(
        all_ids,
        "product_infor.csv",
        "log_infor.csv"
    )

    print("=== Retry Failed Product ===")
    # Tìm các product bị fail ở lần 1 để retry
    fail_ids = get_fail_products(all_ids, result1)
    if not fail_ids:
        print("No failed product to retry. Finish!")
        return

    # Crawl lại riêng cho danh sách fail_ids
    results2 = await crawl_products(
        fail_ids,
        "product_infor_retry.csv",
        "log_infor_retry.csv"
    )


# =====================================================================
# 8. ENTRY POINT
# =====================================================================
if __name__ == "__main__":
    # Chạy event loop async
    asyncio.run(main())

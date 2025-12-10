from pymongo import MongoClient
import json
import IP2Location
import time
from google.cloud import storage


#Lưu output vào Google Storage

def upload_to_gcs(local_path, bucket_name,gcs_path):
    client=storage.Client()
    bucket=client.bucket(bucket_name)
    blob=bucket.blob(gcs_path)

    blob.upload_from_filename(local_path)
    print(f"[GCS] Upload file {local_path} to gs://{bucket_name}/{gcs_path}")

#process IP location
def process_ip_locations(mongo_port, db_name, col_name):
    print("Start proccessing")
    start_time = time.time()
    #1. Config: Kết nối MongoDB & Variables & Output
    client=MongoClient(mongo_port)
    db=client[db_name]
    col=db[col_name]
    count_row_ok=0
    count_row_bad=0
    processed=0
    batch_log_step=10000
    output_file= "/home/thien-nam/data_engineer/GCP/Project6/data/ip_location.jsonl"

    #2. Pipeline: lấy IP unique, là string, not Null
    pipeline=[
        {"$match": {
            "ip": {
                "$type": "string",
                "$nin": ["",None," "]
              }
           }
        },
        {"$group": {"_id": "$ip"}}
    ]

    #3. Khởi tạo IP2Location
    print("Load BIN cho IP2Location...")
    ip2_dp=IP2Location.IP2Location("/home/thien-nam/data_engineer/GCP/Project6/IP-COUNTRY-REGION-CITY.BIN")

    #4. Chạy aggregate với batchsize + allowDiskUse
    print("Chạy MongoDB aggregate...")
    cursor=col.aggregate(pipeline, allowDiskUse=True,batchSize=5000)
    data=list(cursor)
    #5. Ước tổng số  IP ban đầu
    total_ip=len(data)   
    print(f"Total IP cần processing: {total_ip}")



    #5. Viết file jsonl xuất file ip có location và ip không co infor:
    with open(output_file, "w", encoding="utf-8") as f:
        print("> Start processing mapping locations...")
        for i in data:
            processed +=1
            try:
                #Lọc ip null/empty
                ip=i.get("_id")
                if not ip or str(ip).strip() == "":
                    row= {'ip': ip, "status":"fail","reason": "Null_or_empty"}
                    f.write(json.dumps(row) + "\n")
                    count_row_bad+=1        
                    continue
                #Lookup IP2Location
                rec=ip2_dp.get_all(ip)
                if rec.country_short in ("-","ZZ","N/A"):
                    row={'ip': ip, "status":"fail","reason": "No_Data_From_DB"}
                    f.write(json.dumps(row) + "\n")
                    count_row_bad+=1        
                    continue

                row={
                    "ip": rec.ip,
                    "status": "success",
                    "country_short": rec.country_short,
                    "country_long": rec.country_long,
                    "region": rec.region,
                    "city": rec.city
                }
                f.write(json.dumps(row) + "\n")
                count_row_ok+=1

            except Exception as e:
                row={
                    "ip": ip,
                    "status":"fail",
                    "reason": f"ERROR: {e}"}
                f.write(json.dumps(row) + "\n")
                count_row_bad+=1
            run_rate= processed/total_ip *100
        #Log mỗi 10k rows
            if processed % batch_log_step==0:
                print(f"> Processed {processed:,} IPs, scan được {run_rate:.2f}% total IPs ")
                print(f"IPs with infors: {count_row_ok}")
                print(f"IPs without infors: {count_row_bad}")

        print("=== DONE Process ===")
        print(f"Total IPs with infors: {count_row_ok:,}")
        print(f"Total IPs no infors: {count_row_bad:,}")
        print(f"Total IPs processed: {processed:,}")

        print("=== Upload to Google Storage ===")
        upload_to_gcs(output_file, "raw_ip_location", "ip_location.jsonl")

    
    print(f"All done. Executed Time: {time.time() - start_time:.2f}s")
if __name__ == "__main__":
    process_ip_locations(
        mongo_port="mongodb://localhost:27017/",
        db_name="countly",
        col_name="summary"
    )

from pymongo import MongoClient
import csv
import time
import json
from concurrent.futures import ThreadPoolExecutor
import time
import logging
from pathlib import Path
import logging
from google.cloud import bigquery, storage
from google.api_core.exceptions import BadRequest
import time
import os


LOG_FILE = "/home/thien-nam/data_engineer/GCP/Project6/logs/export_summary.log"
open(LOG_FILE, "w").close()
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(LOG_FILE, encoding="utf-8")
    ]
)

logger=logging.getLogger(__name__)


def upload_to_gcs(bucket,output_path, gcs_path,batch_id,bucket_name,batch_size,executor):
    start=time.time()
    try:
        blob=bucket.blob(gcs_path)
        blob.upload_from_filename(output_path)
        logger.info(
            "[GCS] Done upload batch %d -> gs://%s/%s (size=%d, time=%.2f s)",
            batch_id,bucket_name,gcs_path, batch_size, time.time()-start
            
        )
    except Exception as e:
        logger.error("[GCS] Batch %d upload error: %s: %s",
            batch_id, type(e).__name__, str(e)
        )

def normalize_item(item):
    # 1) Trường hợp key phẳng: "option.category id"
    if "option.category id" in item:
        item["option.category_id"] = item.pop("option.category id")

    # 2) Trường hợp option là OBJECT và bên trong có "category id"
    opt = item.get("option")
    if isinstance(opt, dict) and "category id" in opt:
        opt["category_id"] = opt.pop("category id")

    # 3) Chuẩn hoá cart_products.option (giữ như cũ của mình)
    cart = item.get("cart_products")
    if isinstance(cart, list):
        for product in cart:
            if not isinstance(product, dict):
                continue

            v = product.get("option")

            if v is None or v == "":
                product["option"] = []
            elif not isinstance(v, list):
                product["option"] = [v]

    return item


def process_batch(batch,bucket,output_dir,batch_id,bucket_name,batch_size,executor):
    output_path=f"{output_dir}/batch_{batch_id}.jsonl"
    first_doc_id=batch[0].get("_id", None)
    logger.info(
        "[Local] Start batch %d (size%d, first_doc=%s)",
        batch_id, len(batch),first_doc_id
    )
    
    ###==ghi file==
    try:
        with open(output_path, "w", encoding="utf-8") as f:
            for item in batch:
                item=normalize_item(item)
                f.write(json.dumps(item, ensure_ascii=False, default=str)+"\n")
        logger.info("[Local] Done batch %d -> %s", batch_id, output_path)
    except Exception as e:
        logger.error(
            "[Local] Batch %d write error: %s: %s -> skip batch",
            batch_id, type(e).__name__,str(e)
        )
        return

    #==Upload==
    gcs_path=f"batch_{batch_id}.jsonl"
    logger.info("[GCS] Start upload batch %d", batch_id)
    executor.submit(upload_to_gcs,bucket,output_path, gcs_path,batch_id,bucket_name,batch_size,executor)


def upload_gcs(
mongo_url="mongodb://localhost:27017/",
db_name='countly',
col_name='summary',
bucket_name="raw_summary",
max_workers=10,
batch_size=10_000,
output_dir="/home/thien-nam/data_engineer/GCP/Project6/data/summary"
):
    start_time = time.time()
    #==Connect Mongo==
    try:
        client=MongoClient(mongo_url)
        db=client[db_name]
        col=db[col_name]
        logger.info("Connected Mongodb: OK")   
    except Exception as e:
        logger.error("MongoDB error: %s: %s", type(e).__name__, str(e))
        logger.info("Stop process")
        return
    
    
    #==Connect GCS ==
    try:
        gcs_client=storage.Client()
        bucket=gcs_client.bucket(bucket_name)
        logger.info("Connected GCS bucket: OK")
    except Exception as e:
        logger.error("GCS error: %s: %s", type(e).__name__, str(e))
        logger.info("Stop process")
        return
    
    #==Create thread==
    executor = ThreadPoolExecutor(max_workers=max_workers)
   
    logger.info("Start process")
    #==Read Cursor==
    try:
        cursor=col.find({}).limit(10000).batch_size(3000)
        logger.info("Start reading MongoDB...")
    except Exception as e:
        logger.error("Cursor error: %s: %s", type(e).__name__, str(e))
        logger.info("Stop process")
        return
        
    #==Loop Batch==
    batch = []
    batch_id = 0
    total_docs=0
    
    
    for doc in cursor:
        
        batch.append(doc)
        total_docs +=1
        if len(batch)==batch_size:
            batch_id +=1
            process_batch(batch,bucket,output_dir,batch_id,bucket_name,batch_size,executor)
            batch=[]
        
    # ==last batch ===
    if batch:
        batch_id +=1
        process_batch(batch,bucket,output_dir,batch_id,bucket_name,batch_size,executor)

    executor.shutdown(wait=True)
    elapsed= (time.time()-start_time)/60
    logger.info(
        "Export done -> total batch=%d, total_docs=%d, time=%.2f minutes",
        batch_id, total_docs, elapsed
    )
            

if __name__=="__main__":
    upload_gcs()



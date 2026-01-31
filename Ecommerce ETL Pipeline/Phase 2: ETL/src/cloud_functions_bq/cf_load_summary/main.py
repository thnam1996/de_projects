import logging
from google.cloud import bigquery
from google.api_core.exceptions import BadRequest
import time
import os

#==Cấu hình==
PROJECT_ID=os.getenv("PROJECT_ID")
DATASET_ID=os.getenv("DATASET_ID")
TABLE_ID=os.getenv("TABLE_ID")
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)  

#==hàm chạy chính==
def summary_bq(event,context):
    #==1. ĐỌC THÔNG TIN FILE từ event ==
    bucket_name=event["bucket"]
    file_name=event["name"]
    
    logger.info(f"[GCS] New object: gs://{bucket_name}/{file_name}")

    
    ##==2. Chuẩn bị thông tin load vào Bigquery==
    uri=f"gs://{bucket_name}/{file_name}"
    table_ref=f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"
    logger.info(f"[BQ] Start load from: {uri}")
    logger.info(f"[BQ] Target table: {table_ref}")
    
    client= bigquery.Client(project=PROJECT_ID)
    
    job_config=bigquery.LoadJobConfig(
    source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
    write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
    autodetect=False,
    ignore_unknown_values= False)
   
    start=time.time()
    
    try:

        load_job=client.load_table_from_uri(
            uri,
            table_ref,
            job_config=job_config
        )
        
        logger.info(f"[BQ] Started job_id: {load_job.job_id}")

        load_job.result()
        
        elapsed= time.time()-start
        
        logger.info(f"[BQ] Load success in {elapsed:.2f}s")
        
        table=client.get_table(table_ref)
        logger.info(f"[BQ] Table row count: {table.num_rows}")


    except BadRequest as e:
        # 1. Log tổng quan
        logger.error("[BQ] Load failed (BadRequest)")
        logger.error(f"[BQ] Raw error: {str(e)}")

        # 2. Log chi tiết từng lỗi trong errors[]
        if "load_job" in locals() and load_job and load_job.errors:
            logger.error("[BQ] --- Error details per file ---")
            for idx, err in enumerate(load_job.errors, start=1):
                location = err.get("location")
                reason = err.get("reason")
                message = err.get("message", "")

                logger.error(f"[BQ] Error #{idx}")
                logger.error(f"       File   : {location}")
                logger.error(f"       Reason : {reason}")


        else:
            logger.error("[BQ] No additional error info from load_job.errors")        
    except Exception as e:
        logger.error(f"[BQ] Unexpected error: {e}")





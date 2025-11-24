from pymongo import MongoClient
import csv
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
    output_ip_with_location= "/home/thiennam1996_gmail_com/de-project/data/ip_location/ip_with_location.csv"
    output_ip_no_infor= "/home/thiennam1996_gmail_com/de-project/data/ip_location/ip_no_info.csv"

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
    ip2_dp=IP2Location.IP2Location("/home/thiennam1996_gmail_com/de-project/ingest/IP-COUNTRY-REGION-CITY.BIN")

    #4. Chạy aggregate với batchsize + allowDiskUse
    print("Chạy MongoDB aggregate...")
    cursor=col.aggregate(pipeline, allowDiskUse=True,batchSize=5000)
    
    #5. Ước tổng số  IP ban đầu
    total_ip=len(list(cursor))   
    print(f"Total IP cần processing: {total_ip}")



    #5. Viết file csv xuất file ip có location và ip không co infor:
    with open(output_ip_with_location, mode="w", newline="",encoding="utf-8") as f_ok, open(output_ip_no_infor, mode="w",newline="", encoding="utf-8") as f_bad:
        ok_writer=csv.writer(f_ok)
        bad_writer=csv.writer(f_bad)

        ok_writer.writerow([
            "ip",
            "country_short",
            "country_long",
            "region",
            "city"
        ])
        bad_writer.writerow([
            "ip",
            "reason"
        ])
        
        print("> Start processing mapping locations...")



        for i in cursor:
            processed +=1
            try:
                #Lọc ip null/empty
                ip=i.get("_id")
                if not ip or str(ip).strip() == "":
                    bad_writer.writerow([ip,"Null_OR_Empty"])
                    count_row_bad+=1
                    continue
                #Lookup IP2Location
                rec=ip2_dp.get_all(ip)
                if rec.country_short in ("-","ZZ","N/A"):
                    bad_writer.writerow([ip,"No_Data_From_DB"])
                    count_row_bad+=1
                    continue

                ok_writer.writerow([
                    rec.ip,
                    rec.country_short,
                    rec.country_long,
                    rec.region,
                    rec.city
                ])
                count_row_ok+=1

            except Exception as e:
                bad_writer.writerow([
                    ip,
                    f"ERROR: {e}"
                ]
                )
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
    upload_to_gcs(output_ip_with_location, "de-nam-output", "ip_locations/ip_with_location.csv")
    upload_to_gcs(output_ip_no_infor, "de-nam-output", "ip_locations/ip_with_no_location.csv")
    
    print(f"All done. Executed Time: {time.time() - start_time:.2f}s")
if __name__ == "__main__":
    process_ip_locations(
        mongo_port="mongodb://localhost:27017/",
        db_name="countly",
        col_name="summary"
    )

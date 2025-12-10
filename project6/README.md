# 📦 ETL Pipeline: VM/MongoDB → Google Cloud Storage → BigQuery  
### Automated Multi-Table ETL Pipeline using Cloud Functions

## 1. Learning Objectives
This project demonstrates core data engineering concepts:
- Implementing ETL processes  
- Transferring data from VM/MongoDB to Google Cloud Storage   
- Building table schemas on BigQuery programmatically  
- Loading structured data into BigQuery  
- Creating automated ingestion using Cloud Functions
- Monitoring logs and applying data profiling 

## 2. Project Overview
This pipeline extracts data from VM/MongoDB, writes formatted `.jsonl` files to Google Cloud Storage, and uses Cloud Functions to automatically load the data into BigQuery.

Supported datasets:

| Dataset | Export Script | Cloud Function | BigQuery Table |
|---------|----------------|----------------|----------------|
| IP Locations | `export_iplocations.py` | `cf_load_iplocations` | `ip_locations` |
| Product Info | `export_product_infor.py` | `cf_load_productinfor` | `product_infor` |
| Summary | `export_summary_to_gcs.py` | `cf_load_summary` | `raw.summary` |

## 3. Architecture
```
VM / MongoDB  
       ↓
Python Exporters
       ↓
Local JSONL files (/data)
       ↓
Uploaded to Google Cloud Storage
       ↓ (Trigger)
Cloud Functions
       ↓
BigQuery Raw Tables
```

## 4. Repository Structure
```
.project
├── data
│   ├── ip_location.jsonl
│   ├── product_infor
│   │   └── product_infor.jsonl
│   ├── summary
│   │   └── batch_1.jsonl
│   └── summary_sample
├── logs
│   ├── product_infor
│   │   ├── log_infor.jsonl
│   │   └── log_infor_retry.jsonl
│   └── summary
│       └── export_summary.log
├── poetry.lock
├── pyproject.toml
├── README.md
└── src
    ├── cf_deploy.sh
    ├── cloud_functions_bq
    │   ├── cf_load_iplocations
    │   │   ├── main.py
    │   │   └── requirements.txt
    │   ├── cf_load_productinfor
    │   │   ├── main.py
    │   │   └── requirements.txt
    │   ├── cf_Load_productinfors
    │   │   ├── main.py
    │   │   └── requirements.txt
    │   └── cf_load_summary
    │       ├── main.py
    │       └── requirements.txt
    ├── create_schema.py
    └── exporters_to_gcs
        ├── export_iplocations.py
        ├── export_product_infor.py
        └── export_summary_to_gcs.py
```

## 5. Export Process
Each exporter script:
- Loads raw data  
- Cleans / normalizes fields  
- Converts to JSONL  
- Saves to `/data/<dataset>/`  
- Uploads to GCS  
- Logs activity under `/logs/`  

## 6. Cloud Functions
Each Cloud Function loads data from GCS → BigQuery:
- Setup config, code in src/cloud_functions_bq
- Deployment, code in src/cf_deploy.sh

Deployment example:
```
gcloud functions deploy cf_load_summary   
--gen2   
--runtime=python311
--region=asia-southeast1   
--source=src/cloud_functions_bq/cf_load_summary   
--entry-point=gcs_to_bq   
--trigger-event="google.cloud.storage.object.v1.finalized"   
--trigger-resource="raw_summary"   
--set-env-vars=PROJECT_ID=your_project,DATASET_ID=raw,TABLE_ID=summary
```

## 7. BigQuery Integration
Schemas created via:
- `create_schema.py`  

Raw tables:
- `ip_locations`
- `product_infor`
- `summary`.

## 8. Monitoring
- Cloud Logging  
- BigQuery job logs  
- Local log files  in logs/

## 10. Running the Pipeline
Install dependencies:
```
poetry install
```

Run exporters:
```
python src/exporters_to_gcs/export_iplocations.py
python src/exporters_to_gcs/export_product_infor.py
python src/exporters_to_gcs/export_summary_to_gcs.py
```

Deploy all Cloud Functions:
```
bash src/cf_deploy.sh
```

Validate tables in BigQuery.

## 11. Conclusion
This fully automated multi-table ETL pipeline demonstrates scalable workflow orchestration on GCP—exporting data, uploading to GCS, auto-triggering Cloud Functions, and loading into BigQuery with monitoring and profiling capabilities.

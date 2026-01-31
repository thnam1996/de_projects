# 📦 ETL Pipeline: VM/MongoDB → Google Cloud Storage → BigQuery  


## 1. Project Overview
- Batch export from MongoDB (Phase 1), writes formatted `.jsonl` files to Google Cloud Storage  
- Event-driven ingestion using Cloud Functions  
- Raw tables created and loaded into BigQuery  (build schema firstfirst)
- Logging implemented for monitoring and debugging  


Supported datasets:
| Dataset | Export Script | Cloud Function | BigQuery Table |
|---------|----------------|----------------|----------------|
| IP Locations | `export_iplocations.py` | `cf_load_iplocations` | `ip_locations` |
| Product Info | `export_product_infor.py` | `cf_load_productinfor` | `product_infor` |
| Summary | `export_summary_to_gcs.py` | `cf_load_summary` | `summary` |

## 2. Architecture
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
│       └── batch_1.jsonl
│  
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

## 5. Running the Pipeline
#### 1. Install dependencies:
```
poetry install
```
#### 2. Create table & schema in Bigquery:

Raw tables:
- `ip_locations`
- `product_infor`
- `summary`.


```
python src/create_schema.py

```

#### 3. Deploy all Cloud Functions:
- Setup config, code in src/cloud_functions_bq
- Deployment, code in src/cf_deploy.sh

```
bash src/cf_deploy.sh
```

#### 4. Run exporters to GSC -> automate load to Bigquery through Cloud Functions:

Each exporter script:
- Converts data from Phase 1 to JSONL  
- Saves to `/data/<dataset>/`  
- Uploads to GCS  
- Logs activity under `/logs/` 


```
python src/exporters_to_gcs/export_iplocations.py
python src/exporters_to_gcs/export_product_infor.py
python src/exporters_to_gcs/export_summary_to_gcs.py

```
#### 5. Monitoring
- Cloud Logging
- BigQuery job logs
- Local log files in logs/



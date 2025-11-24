# Project 05 – Data Collection & Storage Foundation

## Overview

This project builds a small end-to-end data infrastructure on **Google Cloud Platform (GCP)** to collect, store, and enrich data. The workflow includes:

- Uploading raw dataset files to **Google Cloud Storage (GCS)**
- Creating a **Compute Engine VM** and installing MongoDB
- Importing a large web-tracking dataset (~41M events)
- Exploring MongoDB collections and creating a **Data Dictionary**
- Writing Python pipelines to:
  - Perform **IP geolocation** using ip2location
  - Extract and crawl **product names** for each `product_id`
- Storing processed results into CSV files and MongoDB collections

**Goal:** Build a practical foundation for data ingestion and enrichment following Data Engineering best practices.

---

## Architecture / Data Flow

```
Raw dataset (local)
        ↓
Google Cloud Storage (raw bucket)
        ↓
GCP VM + MongoDB
        ↓
Data exploration → Data Dictionary
        ↓
IP Location Pipeline (Python) → CSV (ip_locations)
        ↓
Product Infor Pipeline (Python + Async crawler) → CSV (crawl_product_infor)
```

---

## Project Structure

```
project5/
├── data
│   ├── crawl_product_infor
│   │   ├── log_infor.csv
│   │   ├── log_infor_retry.csv
│   │   └── product_infor.csv
│   └── ip_locations
│       ├── ip_no_info.csv
│       └── ip_with_location.csv
│   
├── doc
│   └── data_summary.md
├── infra
│   ├── 1.gcs_setup.sh
│   ├── 2.upload_file_gcs.sh
│   ├── 3.vm_setup.sh
│   ├── 4.mongo_install.sh
│   ├── 5.copy_file_gcs_to_vm.sh
│   ├── 6.restore_mongo.sh
│   └── README.md
├── poetry.lock
├── pyproject.toml
├── README.md
└── scripts
    ├── crawl_product_infor.py
    └── ip_locations.py
```

---

## How to Run This Project

### 1. Set up Google Storage & VM & MongoDB & Database:

- Check folder infra (detail set up in `Infrastructure Scripts`)
- Note: raw data need to contact owner to receive


### 2. Prepare Python environment in VM

- Install Python
- Use poetry.lock to set venv

### Run Pipelines

### 3. Run the IP Location Pipeline

```bash
python scripts/ip_location.py
```

This pipeline:

- Extracts unique IPs from the `summary` collection of `countly` DB
- Performs geolocation using `ip2location.bin`
- Writes output to GCP:
- Can check output in:
  - `data/ip_with_location.csv` >> IPs have infors
  - `data/ip_no_info.csv` >> IPs not have infors



### 4. Run the Product Infor Pipeline

```bash
python scripts/crawl_product_infor.py
```

This pipeline:

- Extracts `product_id` from several product-related collections
- Deduplicates the product list
- Uses `asyncio`, `aiohttp`, and `BeautifulSoup` to crawl product infors
- Outputs:
  - `data/product_infor.csv` >> list product_ids with infor
  - `data/log_infor.csv` & `data/log_infor_retry.csv` >> log pipeline


---

## Infrastructure Scripts

The `infra/` directory includes helper scripts:

- create a GCS bucket & upload files
- create a Compute Engine VM
- install MongoDB on VM
- download data from GCS to VM & restore in Mongodb

More details in:

```
infra/README.md
```


---


## Documentation

Details about the `summary` collection can be found here:

```
doc/data_summary.md
```

---

## Deliverables

| Output                    | Format | Purpose                                  |
|---------------------------|--------|------------------------------------------|
| data_summary.md           | md     | Data Dictionary for `summary` collection |
| ip_locations.csv          | CSV    | IP → Country, City                       |
| product_names.csv         | CSV    | Map `product_id` → product informations  |

---

## Key Learnings

- Setting up GCP infrastructure: Storage → VM → Firewall → SSH  
- Loading and exploring a large dataset using MongoDB  
- Building a Data Dictionary for semi-structured JSON data  
- Implementing async crawling with aiohttp + BeautifulSoup  
- Designing ingestion + enrichment pipelines  
- Organizing a clean and professional GitHub repository
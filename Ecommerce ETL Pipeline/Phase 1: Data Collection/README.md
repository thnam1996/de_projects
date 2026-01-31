# Phase 1: Data Collection & Storage Foundation

## Overview

This project builds a small end-to-end data infrastructure on **Google Cloud Platform (GCP)** to collect, store, and enrich data. The workflow includes:

- Set up GCP included GCS, VM (for computing), MongoDB on VM
- Push Raw e-commerce event data (DB name 'summary') stored in MongoDB on a GCP VM  
- Enrichment pipelines for:
  - IP address → geographic location  
  - Product ID → crawl web to get full product information  

**Goal:** datasets prepared for downstream ETL and analytics included:
1. Ecommerce Events (41M)
2. Product Informations (19K)
3. IP Locations (3.2M)


## Architecture

```
Raw dataset (local)
        ↓
Google Cloud Storage (raw bucket)
        ↓
GCP VM + MongoDB
        ↓
Data exploration → Data Dictionary 
        ↓
Enrichment IP Location Pipeline (Python) → CSV (ip_locations)
        ↓
Enrichment Product Infor Pipeline (Python + Async crawler) → CSV (crawl_product_infor)
```

---

## Repository Structure

```
project/
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

### 1. Set up GCP & Google Storage & VM & MongoDB:

- Check folder infra (detail set up in `Infrastructure Scripts`)
- create a GCS bucket & upload files
- create a Compute Engine VM
- install MongoDB on VM
- download data from GCS to VM & restore in Mongodb


### 2. Prepare Python environment in VM

- Install Python
- Use poetry.lock to set venv

### Run Pipelines

### 3. Run the IP Location Pipeline

```bash
python scripts/ip_location.py
```

This pipeline:

- Extracts unique IPs from the `summary` collection of DB `summary` in MongoDB
- Performs geolocation using `ip2location.bin`
- Writes output to GCP & backup in VM local 
- Can check output in:
  - `data/ip_with_location.csv` >> IPs have infors
  - `data/ip_no_info.csv` >> IPs not have infors



### 4. Run the Product Infor Pipeline

```bash
python: scripts/crawl_product_infor.py
```

This pipeline:

- Extracts and deduplicates `product_id` values from multiple product-related collectionssummary
- Crawls product pages **asynchronously** using `asyncio` and `aiohttp` to improve performance
- Parses HTML responses with **BeautifulSoup** to extract product information
- Separates successful results and failed requests into logs to support retry and reprocessing
- Outputs:
  - `data/product_infor.csv` >> list product_ids with infor
  - `data/log_infor.csv` & `data/log_infor_retry.csv` >> log pipeline



## Documentation

Details about the `summary` database can be found here:

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
- Organizing a clean and professional GitHub repositorydatabase
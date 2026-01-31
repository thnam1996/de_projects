# End-to-End E-Commerce Data Platform (GCP)

## Project Overview

**Data Context**  
E-commerce event data exists only as raw, semi-structured records without a defined data pipeline & important informations are missing (product information, users location), making the data unsuitable for analytics and reporting.

**Platform Scope**  
Build an end-to-end e-commerce data platform that converts raw event data into analytics-ready datasets for reporting and dashboards.

**Implementation Approach**  
The platform is built in three phases: data collection and enrichment in GCS, automated ingestion into BigQuery, and analytics modeling with dbt and Looker Studio.

**Outcome**
The final output is analytics-ready data in BigQuery and Looker Dashboard that can be directly consumed by BI tools for reporting and analysis.

---

## High-Level Architecture

```
Raw Event Data
     ↓
MongoDB (GCP VM)
     ↓
Data Enrichment
     ↓
Google Cloud Storage
     ↓
Cloud Functions
     ↓
BigQuery
     ↓
dbt Analytics Models
     ↓
Looker Studio Dashboard
```

---

## Phase 1 — Data Collection & Enrichment
- Set up GCP included GCS, VM (for computing), MongoDB on VM
- Push Raw e-commerce event data stored in MongoDB on a GCP VM  
- Enrichment pipelines for:
  - IP address → geographic location  
  - Product ID → crawl web to get full product information  
- Output datasets prepared for downstream ETL and analytics  

---

## Phase 2 — Automated ETL to BigQuery

- Batch export from MongoDB (after enrichment in Phase 1) to Google Cloud Storage  
- Event-driven ingestion using Cloud Functions  
- Raw tables created and loaded into BigQuery  
- Logging implemented for monitoring and debugging  

---

## Phase 3 — Analytics Engineering & Visualization

- Data transformation using **dbt** on BigQuery  
- Staging models for data cleaning and standardization  
- Analytics models designed with a **star schema**  
- Incremental fact tables and data quality tests  
- Data prepared for direct BI consumption  
- Make a **Looker Studio Dashboard** to visualize Ecommerce Performance

**Dashboard includes:**
- Total orders, revenue, average basket size, and total customers  
- Daily trends for orders, revenue, and customers  
- Revenue breakdown by product category  
- Top products by revenue  
- Revenue distribution by country  

🔗 **Live dashboard:**  
https://lookerstudio.google.com/u/0/reporting/44b51f96-7ee7-4eb1-8aa4-03148535665e/

---

## Technologies

- Google Cloud Compute Engine  
- MongoDB  
- Google Cloud Storage  
- Cloud Functions  
- BigQuery  
- dbt  
- Looker Studio  
- Python, SQL  

---

## Summary

This project shows how an e-commerce data platform can be built incrementally, starting from raw data ingestion and enrichment, moving through automated cloud-native ETL, and ending with analytics-ready warehouse models and business-facing dashboards for reporting and analysis.




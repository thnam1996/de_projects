# 📦 Phase 3 — Analytics Engineering & Visualization  


## 1. Project Overview
- Data transformation using **dbt** on BigQuery  
- Staging models for data cleaning and standardization  
- Analytics models designed with a **star schema**  
- Incremental fact tables and data quality tests  
- Data prepared for direct BI consumption  
- Make a **Looker Studio Dashboard** to visualize Ecommerce Performance

**Supported datasets**:

| Layer | Model | Materialization | Description |
|------|-------|------------------|-------------|
| **Seed** | `exchange_rate_usd` | **table (seed)** | Static reference data containing currency → USD exchange rates, versioned via Git and loaded using `dbt seed`. |
| **Staging** | `stg_fact_sales_order_tt` | **view** | Cleaned and standardized raw sales/order data (type casting, null handling, currency normalization). |
| **Staging** | `stg_dim_product` | **view** | Standardized product data extracted from  web crawling data
| **Staging** | `stg_dim_location` | **view** | Standardized IP/location data used to build the location dimension. |
| **Analytics (Dim)** | `dim_date` | **table** | Calendar date dimension used for time-based analysis. |
| **Analytics (Dim)** | `dim_product` | **table** | Product dimension built from staging data (may be incomplete due to crawling limitations). |
| **Analytics (Dim)** | `dim_store` | **table** | Store reference dimension. |
| **Analytics (Dim)** | `dim_location` | **table** | Location dimension derived from IP and geographic attributes. |
| **Analytics (Dim)** | `dim_user` | **table** | User dimension 
| **Analytics (Dim)** | `dim_fx_rate_usd` | **table** | Analytics wrapper over exchange rate seed to provide consistent joins in fact models. |
| **Analytics (Fact)** | `fact_sales_order_tt` | **incremental (merge)** | Sales fact table built incrementally using MERGE strategy with `unique_key = sk_fact_sales`. |



## 2. Architecture
```
    BigQuery Raw (from project6)
          ↓
      dbt Staging Models
          ↓
   dbt Analytics Models
   (Dimensions & Fact)
          ↓
   dbt Tests & Validation
          ↓
 Analytics-ready BigQuery Tables
```


## 3. Repository Structure
```
Project7/
├── models
│   ├── analytics
│   │   ├── dim_date.sql
│   │   ├── dim_fx_rate_usd.sql
│   │   ├── dim_location.sql
│   │   ├── dim_product.sql
│   │   ├── dim_store.sql
│   │   ├── dim_user.sql
│   │   ├── fact_sales_order_tt.sql
│   │   └── schema.yaml
│   └── staging
│       ├── sources.yml
│       ├── stg_dim_location.sql
│       ├── stg_dim_product.sql
│       └── stg_fact_sales_order_tt.sql
├── seeds
│   └── exchange_rate_usd.csv
│
├── dbt_project.yml
├── README.md
└── profiles.yml (or ~/.dbt/)
```



## 4. Data Transformations
Key transformations implemented in this project:
- Normalizing raw currency symbols into ISO currency codes
- Cleaning null / blank values using standardized rules
- Generating surrogate keys with `FARM_FINGERPRINT`
- Loading USD exchange rates via dbt seeds
- Converting sales amounts into USD



## 5. Data Quality Tests
The following dbt tests are implemented:

- **Primary key checks**
  - `not_null`
  - `unique`
- **Foreign key relationship tests**
  - Applied selectively for stable dimensions (date, store, location)


## 6. Looker studo dashboard
After build analytics models, I will transform into data mart models to build Looker Dashboard served for monitoring:

🔗 **Live dashboard:**  
https://lookerstudio.google.com/u/0/reporting/44b51f96-7ee7-4eb1-8aa4-03148535665e/


![alt text](<Screenshot from 2026-01-26 20-18-13.png>)




## 6. Running the Project

### Full refresh (seed + models + tests)
```bash
dbt build --full-refresh
```


## 8. Tech Tools
- BigQuery
- dbt
- SQL
- Git / GitHub


## 9. Notes
- Some foreign keys in the fact table may not exist in dimensions due to incomplete crawling data.
- Relationship tests are intentionally skipped for unstable dimensions to avoid false failures.

# 📦 Analytics Engineering with dbt: BigQuery Data Warehouse  
### End-to-End dbt Project with Seeds, Incremental Models, and Data Quality Tests

## 1. Learning Objectives
This project demonstrates core **Analytics Engineering** concepts:
- Designing a star schema (fact & dimension tables)
- Transforming raw data using dbt (SQL-based ELT)
- Managing static reference data using dbt seeds
- Implementing incremental models with merge strategy
- Ensuring data quality using dbt tests (not_null, unique, relationships)
- Converting multi-currency sales data into USD using exchange rates


## 2. Project Overview
This project builds an **analytics-ready E-Commerce data warehouse** on **BigQuery** using **dbt**.

The pipeline transforms staging data into clean dimension and fact tables, applies data quality checks, and enriches sales data with **USD exchange rates** via dbt seeds.

Supported datasets:

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



## 3. Architecture
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


## 4. Repository Structure
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



## 5. Data Transformations
Key transformations implemented in this project:
- Normalizing raw currency symbols into ISO currency codes
- Cleaning null / blank values using standardized rules
- Generating surrogate keys with `FARM_FINGERPRINT`
- Loading USD exchange rates via dbt seeds
- Converting sales amounts into USD



## 6. Data Quality Tests
The following dbt tests are implemented:

- **Primary key checks**
  - `not_null`
  - `unique`
- **Foreign key relationship tests**
  - Applied selectively for stable dimensions (date, store, location)
- **Exchange rate validation**
  - Ensures each currency has a valid USD rate



## 7. Running the Project

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

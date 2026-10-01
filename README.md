# 🏗️ SQL Data Warehouse + dbt Transformation Layer

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge)

> End-to-end data warehouse built on SQL Server using Medallion Architecture
> (Bronze → Silver → Gold), with dbt managing all transformation and testing logic.

---

## 📌 What This Project Does

Takes raw CRM and ERP data from 6 CSV source files, loads it into a SQL Server
data warehouse, transforms and cleans it through three architectural layers,
and delivers a business-ready star schema — all transformation logic managed by dbt.

**The problem it solves:** CRM and ERP systems hold overlapping, inconsistent customer
and product data. Raw records have duplicate IDs, integer-encoded dates, mismatched
gender/country codes, and broken price calculations. This pipeline resolves all of
that and produces a single analytical layer ready for Power BI or any BI tool.

---

## 🏛️ Architecture

```
┌──────────────┐   BULK INSERT    ┌──────────────┐   dbt run    ┌──────────────┐   dbt run   ┌─────────────┐
│  CSV Sources │ ──────────────▶  │    BRONZE    │ ──────────▶  │   STAGING    │ ──────────▶ │    MARTS    │
│              │                  │  (Raw Layer) │              │ (Silver dbt) │             │ (Gold  dbt) │
│ CRM: 3 files │                  │ 6 raw tables │              │ 6 views      │             │ 2 dims +    │
│ ERP: 3 files │                  │ schema:bronze│              │ schema:      │             │ 1 fact      │
└──────────────┘                  └──────────────┘              │ silver_dbt   │             │ schema:     │
                                                                 └──────────────┘             │ gold_dbt    │
                                                                                              └─────────────┘
```

| Layer | Tool | Schema | Purpose |
|---|---|---|---|
| Bronze | T-SQL Stored Procedure | `bronze` | Raw ingestion — no transformation |
| Staging | dbt (views) | `silver_dbt` | Cleaning, standardization, type conversion |
| Marts | dbt (tables) |

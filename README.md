# TechPulse_5Nation 🌐
### Cross-Country Technology Adoption & AI Analytics (1990–2030)

An end-to-end data analytics portfolio project analysing 35 years of technology 
evolution, AI adoption, media consumption, and digital transformation across 
5 countries — **India, USA, China, Japan, and Germany** — with forecasting to 2030.

---

## 📊 Dashboard Preview

> 5-page interactive Power BI dashboard covering AI Adoption, Media Consumption,
> Digital Transformation, Country Competitiveness, and Forecasting to 2030.

---

---
## 📄 Dashboard PDF
[View Full Dashboard PDF](Dashboard/TechPulse_Dashboard.pdf)
---

## 🔍 Project Overview

| Attribute | Detail |
|---|---|
| Domain | Technology & Media Analytics |
| Countries | India, USA, China, Japan, Germany |
| Time Period | 1990 – 2030 (35 years historical + forecast) |
| Total Rows | ~3.6 Million |
| Tables | 4 fact tables |
| Dashboard Pages | 5 pages |
| KPIs Calculated | 27 |

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| Python (Faker, Pandas, Matplotlib, Seaborn) | Data generation, EDA, KPI calculation |
| MySQL + MySQL Workbench | Data storage and SQL cleaning |
| SQLAlchemy + PyMySQL | Python-MySQL connection |
| Power BI Desktop | Dashboard and forecasting |
| Jupyter Notebook | EDA and KPI notebooks |
| GitHub | Version control and portfolio hosting |

---

## 📁 Project Structure

```
TechPulse_5Nation/
│
├── Data Generator/
│   └── 01_data_generation_and_cleaning.ipynb
│       — Synthetic data generation using Faker
│       — Country + sector specific bias injection
│       — Direct MySQL push via SQLAlchemy
│
├── Source/
│   ├── 02_EDA_Media.ipynb        — media_tech_usage analysis
│   ├── 03_EDA_App.ipynb          — app_download_comparison analysis
│   ├── 04_EDA_AI.ipynb           — ai_transformation_2026 analysis
│   ├── 05_EDA_Comp.ipynb         — company_adaptation analysis
│   ├── 06_KPI_Calculation_CCTA.ipynb
│   │   — 27 KPIs calculated across 4 dashboard pages
│   │   — MinMaxScaler composite competitiveness score
│   ├── 01_cleaning_media_tech_usage.sql
│   ├── 01_cleaning_app_download_comparison.sql
│   ├── 01_cleaning_ai_transformation_2026.sql
│   └── 01_cleaning_company_adaptation.sql
│
├── Visuals/
│   └── 32 EDA charts saved as PNG
│       ├── media_01 to media_08
│       ├── app_01 to app_08
│       ├── ai_01 to ai_08
│       └── comp_01 to comp_08
│
├── TechPulse_5Nation_Dashboard.pbix
└── README.md
```

---

## 📊 EDA Visuals

**Media Tech Usage — Avg Daily Usage Hours by Platform**
![Media EDA](visuals/media_usage/media_02_avg_usage_by_country.png)

**App Download Comparison — Retention vs Uninstall Rate by Country**
![App EDA](visuals/app_download/app_05_retention_vs_uninstall_by_country.png)

**AI Transformation 2026 — AI Adoption Rate by Country**
![AI EDA](visuals/ai_transform/ai_01_adoption_rate_by_country.png)

**Company Adaptation — Avg Digital Maturity Score by Industry**
![Comp EDA](visuals/company_adaption/comp_01_maturity_score_by_industry.png)

---

## 🔄 Analyst Workflow

Raw Data Generation (Python Faker)
↓
MySQL Import (SQLAlchemy batched push)
↓
SQL Cleaning (4 scripts — NULLs, duplicates, standardisation)
↓
Python EDA (bias injection, rolling imputation, visuals)
↓
KPI Calculation (27 KPIs validated in Python)
↓
Power BI Dashboard (5 pages + forecasting to 2030)

---

## 📋 Data Tables

| Table | Rows | Period | Key Metrics |
|---|---|---|---|
| media_tech_usage | ~891K | 1990–2025 | Daily usage hrs, penetration rate, ad spend |
| app_download_comparison | ~891K | 1990–2025 | Downloads, retention, uninstall rate, revenue |
| ai_transformation_2026 | ~891K | 2026 only | AI adoption rate, productivity gain, investment |
| company_adaptation | ~891K | 1990–2025 | Digital maturity, revenue growth, tech investment |

---

## 📈 Key Findings

**AI Adoption**
- USA leads at **68%** adoption vs India at **44.5%**
- Finance sector highest at **70%** vs Government at **47.9%**
- Claude delivers highest productivity gain at **70%**
- Jobs displaced (23K avg) outpace jobs created (15K avg) across all countries

**Media Consumption**
- Americans average **8 hrs/day** vs Indians at **3.5 hrs**
- Japan highest retention rate at **75%**
- India highest uninstall rate at **42.5%**
- Netflix dominates USA/Germany | WeChat owns China | Hotstar leads India

**Digital Transformation**
- Technology industry digital maturity **7.55/10** vs Manufacturing **5.67**
- USA and Japan tied at top with **7.14** maturity score
- Technology companies show **67.5%** revenue growth vs Other at **-2.5%**
- Technology digital revenue **89.5%** vs Manufacturing **21.5%**

**Country Competitiveness**
- USA and Japan lead on AI readiness and digital maturity
- India lowest customer satisfaction at **2.25/5**
- China highest app downloads at **350M avg**

**Forecasting to 2030**
- Daily media usage projected to reach **9+ hours**
- Digital revenue % to accelerate sharply post-2025
- App downloads showing sustained upward trajectory

---

## ⚙️ Setup Instructions

### Prerequisites
```bash
pip install pandas numpy faker sqlalchemy pymysql matplotlib seaborn scikit-learn
```

### MySQL Setup
```sql
CREATE DATABASE IF NOT EXISTS tech_ai_1990_2030;
```

### Configuration
Replace credentials in all notebooks before running:
```python
password = quote_plus("YOUR_PASSWORD")
engine   = create_engine(
    f"mysql+pymysql://YOUR_USERNAME:{password}@127.0.0.1/tech_ai_1990_2030"
)
visuals_path   = r"YOUR_VISUALS_PATH"
finalized_path = r"YOUR_FINALIZED_PATH"
```

### Run Order

1. 01_data_generation_and_cleaning.ipynb
2. Run SQL cleaning scripts (in Source folder)
3. 02_EDA_Media.ipynb
4. 03_EDA_App.ipynb
5. 04_EDA_AI.ipynb
6. 05_EDA_Comp.ipynb
7. 06_KPI_Calculation_CCTA.ipynb
8. Open TechPulse_5Nation_Dashboard.pbix in Power BI
9. Refresh data from Finalized folder

---

## 📌 Data Note

> Raw data is synthetically generated using Python Faker with realistic
> country-specific and sector-specific bias injection. Run
> `01_data_generation_and_cleaning.ipynb` to reproduce the dataset.
> Finalized CSVs are not included in this repository due to file size.

---

## 👤 Author

**Abishek**
Customer Service Representative → Aspiring Data Analyst
📍 Gurgaon, India

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/abishek28m/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black)](https://github.com/Shadow-Monarch28?tab=repositories)

---

## 🏷️ Tags

`#DataAnalytics` `#PowerBI` `#Python` `#MySQL` `#AIAdoption`
`#DigitalTransformation` `#MediaConsumption` `#Forecasting`
`#PortfolioProject` `#DataScience` `#BusinessIntelligence`

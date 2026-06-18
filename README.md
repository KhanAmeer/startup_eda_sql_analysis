# Startup Funding Analysis — SQL + Power BI

## Overview

This project performs Exploratory Data Analysis (EDA) on a startup funding dataset using Microsoft SQL Server, with findings visualised in a Power BI report. The objective is to analyze funding trends, investment patterns, sector performance, investor activity, and funding concentration within the Indian startup ecosystem.

The analysis goes beyond basic aggregations by incorporating statistical measures, funding distribution analysis, concentration metrics, and trend evaluation to generate business-oriented insights from funding data.

This project was developed to demonstrate SQL proficiency, analytical thinking, and business analysis skills relevant to Data Analyst and Business Intelligence roles.

---

## Business Objectives

The analysis aims to answer the following business questions:

* How has startup funding changed over time?
* Which sectors attract the highest levels of investment?
* Which cities receive the most startup funding?
* How concentrated is funding among startups?
* Which investors participate most actively in startup funding?
* How evenly is capital distributed across startups?
* What funding patterns exist across different investment stages?
* How does 2025 compare to prior years at the same point in time?

---

## Dataset

Source: Kaggle Startup Funding Dataset

This project uses a publicly available sample startup funding dataset obtained from Kaggle for educational and portfolio purposes.

Dataset Link: https://www.kaggle.com/datasets/vagdevititikshag/indian-startup-funding-dataset-20202025

The dataset contains information such as:

* Startup Name
* Industry Vertical
* City
* Investors
* Investment Type
* Funding Date
* Investment Amount (USD)

### Dataset Scope

To ensure fair comparisons and avoid distortion from incomplete yearly data:

* Trend analysis was performed on complete years (2020–2024)
* Partial 2025 data was analyzed separately
* Investor and funding concentration analyses used all available records

---

## Project Workflow

### 1. Data Quality Assessment

Performed checks for:

* Missing values
* Duplicate records
* Data completeness
* Funding amount availability

### 2. Exploratory Data Analysis

Analyzed:

* Funding trends
* Startup concentration
* Funding distribution
* Sector performance
* Geographic distribution
* Investor activity
* Funding stage activity

### 3. Statistical Analysis

Calculated:

* Average funding
* Median funding
* Funding distribution metrics
* Funding concentration measures
* Gini coefficient for inequality analysis
* Sensitivity and robustness testing

### 4. Power BI Dashboard

Key SQL findings were visualised across four report pages:

* **Overview** — Headline KPIs, yearly funding trend, Gini coefficient
* **Sector and Ecosystem Analysis** — Industry funding rankings and investment stage breakdown
* **Investor, Startup and Geographical Analysis** — Top investors, top startups, city-level funding, dominant sector per city
* **2025 Snapshot** — Partial year overview, projected full-year funding, H1 2024 vs H1 2025 comparison

---

## Dashboard Preview

### Overview
![Overview](dashboard/screenshots/overview.png)

### Sector and Ecosystem Analysis
![Sector Analysis](dashboard/screenshots/sector_analysis.png)

### Investor, Startup and Geographical Analysis
![Geo Analysis](dashboard/screenshots/investor_geo_analysis.png)

### 2025 Snapshot
![2025 Snapshot](dashboard/screenshots/snapshot_2025.png)

---

## SQL Skills Demonstrated

### Data Analysis

* Exploratory Data Analysis (EDA)
* Trend Analysis
* Distribution Analysis
* Statistical Analysis
* Business Metric Development
* Data Validation

### SQL Techniques

* Window functions (`ROW_NUMBER`, `DENSE_RANK`, `LAG`, `PERCENTILE_CONT`)
* CTEs and subqueries
* Conditional aggregation (`CASE WHEN`)
* Year-over-year growth calculations
* Gini coefficient implementation in SQL
* Sensitivity and robustness testing

---

## Key Findings

### Funding Concentration

Top 10 startups absorbed a disproportionate share of total capital. The pattern mirrors the investor-level concentration seen across the dataset — a small group of participants dominated both sides of the funding table.

### Funding Distribution

Median deal size ($1.1M) was substantially lower than the mean ($24.88M), with standard deviation roughly 3x the mean. The average is an unreliable central measure for this dataset; median is used throughout the analysis.

### Power Law Dynamics

Deals over $100M were small in number but accounted for the majority of total funding — a classic power law distribution confirmed by the concentration checks.

### Sector Performance

FoodTech received the highest total funding across 2020–2024, supported by consistently large deal sizes. Sector rankings shifted each year — no single industry dominated all five years. In 2025, Consumer Electronics emerged as the leading sector, a notable shift from the prior period.

### Geographic Concentration

Pune led total funding across the period. Bengaluru recorded strong deal volume but lower total capital, suggesting a higher frequency of smaller deals. Each city showed a clear dominant sector.

### Funding Inequality

Gini coefficient of 0.87 across 2020–2024, with per-year values ranging 0.85–0.89 — consistent across both the 2021 boom and the 2022–2023 slowdown. Removing the top 5 deals reduced the Gini by only 0.006, confirming the inequality is structural rather than outlier-driven.

### 2025 Snapshot

84 deals recorded in H1 2025 with the highest median deal size across all years ($1.65M), suggesting a quality-over-quantity shift. Projected full-year funding of $5.70bn — slightly below 2024's $5.98bn but well above 2023.

---

## Project Structure

```text
Startup_eda_project.sql

├── Data Quality Assessment
├── Funding Overview
├── Funding Distribution Analysis
├── Startup Concentration Analysis
├── Funding Inequality Analysis (Gini Coefficient)
├── Sensitivity Testing
├── Robustness Check
├── Year-over-Year Trend Analysis
├── Per-Year Gini Analysis
├── Sector Analysis
├── City Analysis
├── Investor Analysis
├── Funding Stage Analysis
└── 2025 Partial Year Analysis
    ├── Mid-Year Overview
    ├── Leading Industries 2025
    ├── Annualised Projection
    └── H1 2024 vs H1 2025 Comparison
```

---

## Business Value

This analysis demonstrates how SQL can be used to transform startup funding data into actionable business insights, and how those insights can be communicated clearly through a structured Power BI report.

The project helps evaluate:

* Capital allocation patterns
* Funding concentration
* Investor participation trends
* Sector attractiveness
* Geographic funding distribution
* Startup ecosystem characteristics
* Forward-looking funding trajectory

---

## Tools Used

* Microsoft SQL Server
* Power BI Desktop
* GitHub

---

## Repository Structure

```text
startup-funding-analysis/
│
├── README.md
├── Startup_eda_project.sql
│
└── dashboard/
    ├── Funding_dashboard.pbix
    └── screenshots/
        ├── overview.png
        ├── sector_analysis.png
        ├── investor_geo_analysis.png
        └── snapshot_2025.png
```

---

## Author

Ameer Khan S

LinkedIn: https://www.linkedin.com/in/ameer-khans

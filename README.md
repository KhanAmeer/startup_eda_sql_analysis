# Startup Funding Analysis Using SQL

## Overview

This project performs Exploratory Data Analysis (EDA) on a sample startup funding dataset using Microsoft SQL Server. The objective is to analyze funding trends, investment patterns, sector performance, investor activity, and funding concentration within the startup ecosystem.

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

---

## Dataset

Source: Kaggle Startup Funding Dataset

Dataset Link:

https://www.kaggle.com/datasets/vagdevititikshag/indian-startup-funding-dataset-20202025

This project uses a publicly available sample startup funding dataset obtained from Kaggle for educational and portfolio purposes.

The primary objective of this project is to demonstrate SQL-based exploratory data analysis, analytical thinking, and business insight generation. The findings should be interpreted within the context of the sample dataset and are not intended to represent actual startup funding activity or market conditions.

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

---

## SQL Skills Demonstrated

### Data Analysis

* Exploratory Data Analysis (EDA)
* Trend Analysis
* Distribution Analysis
* Statistical Analysis
* Business Metric Development
* Data Validation

---

## Key Findings

### Funding Concentration

Funding was highly concentrated among a relatively small number of startups within the sample dataset, indicating that a significant share of capital was allocated to a limited group of companies.

### Funding Distribution

Median funding values were substantially lower than average funding values, suggesting the presence of large funding outliers and an uneven distribution of capital.

### Sector Performance

Investment activity was concentrated in a small number of sectors, highlighting sector-specific funding patterns within the dataset.

### Geographic Concentration

Funding activity was concentrated within a small number of startup hubs represented in the dataset.

### Investor Participation

A limited group of investors accounted for a significant share of investment activity across the analyzed records.

### Funding Inequality

Gini coefficient analysis revealed a highly unequal distribution of funding among startups in the dataset, demonstrating significant capital concentration.

---

## Project Structure

```text
Startup_eda_project.sql

├── Data Quality Assessment
├── Funding Overview
├── Funding Distribution Analysis
├── Startup Concentration Analysis
├── Funding Inequality Analysis
├── Sensitivity Testing
├── Year-over-Year Trend Analysis
├── Sector Analysis
├── City Analysis
├── Investor Analysis
└── Funding Stage Analysis
```

---

## Business Value

This project demonstrates how SQL can be used to transform raw business data into meaningful insights through exploratory analysis, statistical evaluation, and trend identification.

The analysis helps evaluate:

* Capital allocation patterns
* Funding concentration
* Investor participation trends
* Sector attractiveness
* Geographic funding distribution
* Startup ecosystem characteristics

---

## Future Enhancements

Power BI dashboard development is currently in progress and will include:

* Executive KPI Dashboard
* Funding Trend Visualizations
* Sector Performance Dashboard
* Investor Analysis Dashboard
* Geographic Funding Analysis
* Funding Distribution Visualizations

---

## Tools Used

* Microsoft SQL Server
* SQL Server Management Studio
* GitHub

---

## Repository Structure

```text
startup-funding-analysis-sql/
│
├── README.md
└── Startup_eda_project.sql
```

---

## Author

Ameer Khan S

LinkedIn: https://www.linkedin.com/in/ameer-khans

# Retail-Analytic-Project

# Retail Analytics & CRM Strategy Optimization

## 📌 Project Overview
This project focuses on leveraging point-of-sale (POS) data from a leading retail chain in India to extract actionable, data-driven insights. The core objective is to analyze business performance across multiple dimensions—customer behavior, product performance, store dynamics, and channel efficiency. These insights are utilized to design robust CRM, marketing, campaign, and sales strategies, as well as to measure and manage overall business performance for the upcoming fiscal year.

---

## 🌐 Interactive Dashboards & Applications
Explore the live deployments of this project to see the predictive model and data insights in action:

* **Executive Business Intelligence Dashboard:** [Power BI Service Dashboard](https://app.powerbi.com/view?r=eyJrIjoiMGVhNTNkZjgtYTNiYy00ZjE5LWJkMDQtN2YwNWNmM2YwNjE2IiwidCI6ImU4ZmJjNjdmLTQyN2MtNGU3Ni04MzJjLTc1M2U4OTA0YmQ4OCJ9&pageName=57ddfc8499680194f028) – Comprehensive cohort analysis, hospital resource KPIs, demographic trends, and diagnostic insights tailored for healthcare stakeholders and clinical managers.

---

## 🏢 Business Context & Objectives
The client seeks to transition toward a highly data-driven approach to optimize their sales and marketing operations. As the Analyst on this project, the core objectives include:
* **Customer Insights:** Analyze customer segments, behavioral patterns, and customer satisfaction (CSAT) scores.
* **Product Performance:** Evaluate product and category-level performance, seasonality impacts, and cross-selling opportunities.
* **Operational Efficiency:** Perform store-level and channel-level analysis to understand geographical and operational dynamics.
* **Strategic Planning:** Conduct cohort analysis and sales trend forecasting to build a roadmap for increasing sales in the upcoming year.

---

## 📊 Data Architecture & Relational Schema
The dataset spans from **September 2021 to October 2023**, covering a randomized sample of 39 stores and specific product categories. 

The data was audited, cleaned, and transformed into an optimized relational schema with the following core entity relationships:
* **One-to-Many ($1:N$):** One Customer $\rightarrow$ Multiple Orders.
* **One-to-Many ($1:N$):** One Order $\rightarrow$ Multiple Line Items.

### Analytical Data Marts (Derived Master Tables)
To optimize reporting performance, three comprehensive master tables were engineered directly within the database:
1.  `Customer_Master_Table`: Granular customer-level metrics (one record per customer, including total spend, frequency, recency, and segment).
2.  `Order_Master_Table`: Aggregated transaction-level details (one record per unique Order ID).
3.  `Store_Master_Table`: Store-level performance KPIs (one record per store location).

---

## 🛠️ Tech Stack & Tools
* **Database Management:** SQL Server Management Studio (SSMS) – used for data auditing, cleaning, ETL operations, and advanced analytical querying.
* **Business Intelligence:** Power BI Desktop – used for data modeling, DAX measurements, and interactive dashboard development.
* **Cloud Deployment:** Power BI Service – used for publishing, sharing, and managing dashboards.
* **Documentation & Reporting:** Microsoft PowerPoint – used for compiling executive-level insights, methodology presentation, and strategic recommendations.

---

## 🚀 Project Workflow

### 1. Data Auditing & Cleaning (SSMS)
Prior to analysis, a rigorous data quality audit was conducted in SSMS to handle real-world data anomalies:
* **Handling Anomalies:** Identified and resolved missing values, duplicate transaction entries, and data type inconsistencies.
* **Business Logic Imputation:** Outliers in pricing or quantities were managed based on logical business assumptions.
* **Schema Enforcement:** Established primary and foreign key constraints to ensure strict referential integrity across the 6 source files.

### 2. Advanced Analytical Frameworks (SQL)
The following specialized analyses were written natively using T-SQL in SSMS:
* **Cohort Analysis:** Tracked customer retention and lifetime value (LTV) over time based on initial purchase months.
* **Cross-Selling (Market Basket Analysis):** Identified frequently co-purchased product categories to inform promotional bundling.
* **Seasonality & Trend Analysis:** Isolated cyclical sales spikes, holiday impacts, and monthly growth rates.

### 3. Dashboard Development & Deployment (Power BI)
Interactive dashboards were developed and published via Power BI Service, organized into strategic themes:
* **Executive Summary Dashboard:** High-level KPIs (Revenue, Margin, Total Orders, Store Rankings).
* **Customer & CRM Insights Dashboard:** RFM segmentation, cohort retention matrices, and channel preferences.
* **Product & Merchandising Dashboard:** Category performance, cross-selling matrices, and seasonality trends.

---

## 📂 Repository Structure
```directory
├── SQL_Scripts/
│   ├── 01_data_auditing_&_cleaning.sql  # Data quality checks and transformation logic in SSMS
│   ├── 02_analytical_tables_creation.sql # Scripts for Customer, Order, and Store master tables
│   └── 03_business_analysis_queries.sql  # Complex queries (Cohorts, Cross-selling, Seasonality)
├── Dashboards/
│   └── Retail_Insights_Dashboard.pbix    # Power BI Desktop report file
├── Documentation/
│   └── Executive_Presentation.pptx       # PowerPoint business insights & recommendations deck
└── README.md

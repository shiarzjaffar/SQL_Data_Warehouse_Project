
🧠 Data Warehouse and Analytics Project

Welcome to the Data Warehouse and Analytics Project repository! 🚀
This project demonstrates a complete end-to-end data warehousing and analytics solution, from raw data ingestion to business-ready insights. It serves as a portfolio project to showcase modern data engineering, architecture design, and analytical reporting best practices.

🏗️ Data Architecture

The project adopts the Medallion Architecture, which organizes data into Bronze, Silver, and Gold layers for scalability and clarity.

Bronze Layer — Raw data storage.

Ingests CSV files from ERP and CRM source systems into a SQL Server database.

Silver Layer — Data transformation and standardization.

Cleanses, validates, and normalizes data for accuracy and consistency.

Gold Layer — Analytics-ready layer.

Implements a star schema with fact and dimension tables optimized for BI and reporting.

📖 Project Overview

This project highlights the full data pipeline lifecycle:

Data Architecture — Designing a scalable data warehouse using Medallion principles.

ETL Pipelines — Building extraction, transformation, and loading processes in SQL.

Data Modeling — Creating optimized fact and dimension models.

Analytics & Reporting — Generating SQL-based insights and dashboards for decision-making.

🎯 Skills Demonstrated

SQL Development

Data Architecture Design

ETL Pipeline Development

Data Modeling

Data Analytics and Reporting

🧰 Tools and Resources

Everything in this project uses free tools for accessibility and reproducibility:

Datasets
: Raw CSV files (ERP & CRM sources)

SQL Server Express
: Lightweight local database server

SQL Server Management Studio (SSMS)
: SQL Server GUI for development and testing

Draw.io
: For data flow, architecture, and schema diagrams

Notion
: Used for project documentation and planning

Notion Project Steps
: Detailed guide for each project phase

🚀 Project Requirements
🧩 Part 1: Building the Data Warehouse (Data Engineering)

Objective
Design a SQL Server–based data warehouse to integrate and consolidate sales data for advanced analytics and reporting.

Specifications

Data Sources: Two CSV systems — ERP (sales data) and CRM (customer data)

Data Quality: Handle missing values, duplicates, and inconsistencies

Integration: Merge both systems into a unified analytical model

Scope: Focus on current data (no historization required)

Documentation: Maintain a clear and accessible data model reference

📊 Part 2: Business Intelligence and Analytics

Objective
Deliver insights through SQL analytics focusing on:

Customer segmentation and behavior

Product performance and profitability

Sales trends and regional patterns

These analyses empower stakeholders to make data-driven business decisions.

For detailed analytics requirements, see: docs/requirements.md

📁 Repository Structure

data-warehouse-project/
│
├── datasets/                           # Raw ERP and CRM datasets (CSV files)
│
├── docs/                               # Project documentation and diagrams
│   ├── etl.drawio                      # ETL flow design
│   ├── data_architecture.drawio        # Architecture diagram
│   ├── data_catalog.md                 # Dataset descriptions and metadata
│   ├── data_flow.drawio                # Data flow diagram
│   ├── data_models.drawio              # Star schema and relationships
│   ├── naming-conventions.md           # Standardized naming rules
│
├── scripts/                            # SQL scripts
│   ├── bronze/                         # Raw data ingestion
│   ├── silver/                         # Data cleaning and transformation
│   ├── gold/                           # Star schema and analytics
│
├── tests/                              # Data validation and QA scripts
│
├── README.md                           # Project documentation (this file)
├── LICENSE                             # Repository license
├── .gitignore                          # Git ignore configuration
└── requirements.txt                    # Dependencies and environment setup


🧾 License

This project is distributed under the MIT License
You are free to use, modify, and share it with proper attribution.

# Financial AI Market Tracker 📈🤖

## About The Project
This repository contains the backend and data pipeline infrastructure for our Financial AI Agent. Developed by a 5-person computer engineering student team, this educational project aims to aggregate real-time financial news and analyze market sentiment using Large Language Models (LLMs). 

The primary goal of this project is to build a robust data engineering pipeline and explore the integration of AI agents in financial data processing.

## System Architecture
The project is decoupled into three main architectural components:

1. **Data Pipeline (Python):** A Python-based service that fetches real-time updates from verified financial institutions and market analysts using the official X API (Read-Only access).
2. **Database & Storage (PostgreSQL / Neon.tech):** A cloud-native PostgreSQL database that safely stores the raw text data to prevent duplicate processing, ensuring a clean queue for the AI agent.
3. **AI Agent & Frontend (n8n & Flutter):** An automated n8n workflow pulls the unprocessed text from the database, feeds it into an LLM for sentiment analysis (Positive/Negative/Neutral), and serves the summarized insights to a cross-platform mobile application built with Flutter & Dart.

## Tracked Data Sources
To maintain high data quality and avoid noise, the pipeline strictly monitors a curated list of reliable, public financial and economic accounts:
* `@ForeksTurkey`
* `@BloombergHT`
* `@matrikstrader`
* `@borsaistanbul`
* `@MertBasaran_inv`
* `@ArzHaber`
* `@borsambogasi`
* `@blackrock`
* `@bondvigilantes`
* `@BBVAResearch`



#  E-Commerce Executive Analytics Case Study

  **Live Interactive Dashboard:** [Click Here to View Live Application](https://ecommerce-analytics-sql-oncnpwpqcznfmwedfgky9m.streamlit.app/)

---

##  Project Overview
This project is an end-to-end data analytics solution designed to extract high-level executive insights from a relational e-commerce dataset containing over **11,000+ orders (25,000+ transactional rows)**. 

Instead of presenting raw SQL queries, this project packages advanced database logic into a **live production-ready Streamlit application** powered by an in-memory SQLite database engine.

---

##  Core Business Frameworks Implemented

### 1. RFM Customer Segmentation (Recency, Frequency, Monetary)
* **Logic:** Utilizes SQL Window functions (`NTILE`) to rank users across three dimensions and segment them into tactical marketing buckets (Champions, At-Risk, Loyal, Lost).
* **Business Value:** Helps marketing teams target retention campaigns precisely, optimizing ad-spend.

### 2. Month-on-Month Cohort Retention Matrix
* **Logic:** Implements complex SQL Common Table Expressions (CTEs) and time-deltas (`STRFTIME` & indexing) to track user retention based on their sign-up month.
* **Business Value:** Measures true product-market fit and customer loyalty over a 4-month rolling period.

### 3. MoM Revenue Growth Trends
* **Logic:** Employs analytical lead/lag window functions (`LAG() OVER()`) to calculate sequential revenue shifts and growth percentages.

---

##  Technical Architecture & Stack

* **Database Engine:** SQLite / SQL (Advanced CTEs, Window Functions, Joins, Aggregations)
* **Backend Pipeline:** Python (`pandas`, `sqlite3` for in-memory DB script execution)
* **Front-End UI:** Streamlit Web Framework (Interactive widgets, native caching via `@st.cache_resource`)
* **Deployment:** Hosted live on Streamlit Community Cloud

---

##  Repository Structure

```text
├── app.py                      # Main Streamlit application frontend/backend logic
├── requirements.txt            # Production dependencies (streamlit, pandas)
├── ecommerce_dataset.sql       # Raw relational SQL database dump (11k+ records)
├── query.sql                   # Clean repository of all core analytics SQL queries
└── sql_translator.ipynb        # Source Jupyter Notebook tracking data pipeline lineage

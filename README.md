# 🎵 Spotify Top Artists Data Analysis (PostgreSQL)

An Exploratory Data Analysis (EDA) and advanced SQL project analyzing global streaming metrics, artist demographics, genre performance, and collaboration strategies among top artists on Spotify.

---

## 📌 Project Overview

The goal of this project is to extract actionable business insights from Spotify streaming data using **PostgreSQL**. The analysis progresses from foundational data exploration to intermediate metric breakdowns, concluding with advanced analytics using CTEs (Common Table Expressions) and window functions.

Key focus areas include:
* **Geographic & Linguistic Trends:** Identifying top-performing countries and language markets.
* **Collaboration Dynamics:** Analyzing the ratio of solo streams vs. feature streams (`feature_streams`).
* **Genre Efficiency:** Uncovering niche genres with low competition but high average streams.
* **Benchmarking:** Identifying "Collaboration Specialists" whose feature reliance exceeds the industry average.

---

## 🛠️ Tech Stack & Database Setup

* **Database Engine:** PostgreSQL
* **Tooling:** pgAdmin 4 / Query Tool
* **Key SQL Features Used:** Aggregations (`GROUP BY`, `SUM`, `AVG`), Subqueries, Filtering (`HAVING`), PostgreSQL Extensions (`DISTINCT ON`), Window Functions (`OVER()`), and Common Table Expressions (`WITH`).

### Schema
```sql
CREATE TABLE public.spotify (
    artist TEXT,
    sex TEXT,
    country TEXT,
    language TEXT,
    genre TEXT,
    artist_type TEXT,
    total_streams NUMERIC,
    lead_streams NUMERIC,
    feature_streams NUMERIC,
    solo_streams NUMERIC
);

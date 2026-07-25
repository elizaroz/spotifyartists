# Spotify Artists Analysis

Exploratory SQL analysis of artist-level Spotify streaming data — solo vs. featured streams, broken down by country, genre, language, and artist type.

## Table Structure

```sql
CREATE TABLE spotify (
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
```

## Tech Stack

PostgreSQL

## Analysis Overview

**1. Basic EDA**
- Top 3 countries by total streams
- Top 5 genres by total streams
- Top 5 languages by total streams
- Solo artists' streams by sex
- Top-streaming bands (`artist_type = 'Group'`)

**2. Intermediate EDA**
- Artists whose feature streams exceed their solo streams
- Genres with few artists but high average streams per artist
- Top artist per country, solved two ways: `DISTINCT ON` and a correlated subquery

**3. Advanced Analytics**
- A CTE calculates each artist's collaboration percentage (feature streams as a share of solo + feature streams), then compares it against the database-wide average using a window function (`AVG() OVER()`), and filters for artists above that average.

## Techniques Used

- Aggregation with `GROUP BY`
- Window functions (`AVG() OVER()`)
- CTEs
- Two approaches to the same "top per group" problem: `DISTINCT ON` vs. correlated subquery
- `NULLIF` to guard against division by zero

## How to Run

1. Create the `spotify` table (schema above) and load the dataset.
2. Run the queries individually, or top to bottom — they're grouped into three sections of increasing complexity (`1. Basic EDA`, `2. Intermediate EDA`, `3. Advanced analytics`) in `spotify_artists_analysis.sql`.

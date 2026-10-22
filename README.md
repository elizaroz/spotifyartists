# Spotify Artists Analysis (SQL)

Exploratory analysis of artist-level Spotify streaming data in **PostgreSQL**. The analysis looks at which markets, genres and languages generate the most streams, and how much artists rely on solo releases compared with features (collaborations on other artists' tracks).

The queries progress from simple aggregations to CTEs and window functions.

---

## Business questions

1. Which countries, genres and languages generate the most streams?
2. How do streams of solo artists compare by sex?
3. Which bands (group artists) are streamed the most?
4. Which artists get more streams from features than from their own solo work?
5. Which genres have few artists but a very high average number of streams per artist?
6. Who is the most-streamed artist in each country?
7. Which artists depend on collaborations more than the average artist in the dataset?

---

## Data

A public dataset of artist-level Spotify streaming statistics, loaded into one PostgreSQL table with one row per artist:

| Column | Description |
|---|---|
| `artist` | Artist name |
| `sex` | Sex of a solo artist |
| `country` | Artist's country |
| `language` | Main language of the artist's songs |
| `genre` | Main genre |
| `artist_type` | Solo artist or `Group` |
| `total_streams` | All streams of the artist |
| `lead_streams` | Streams of tracks where the artist is the lead |
| `feature_streams` | Streams of tracks where the artist is featured |
| `solo_streams` | Streams of the artist's solo tracks |

```sql
CREATE TABLE spotify (
    artist          TEXT,
    sex             TEXT,
    country         TEXT,
    language        TEXT,
    genre           TEXT,
    artist_type     TEXT,
    total_streams   NUMERIC,
    lead_streams    NUMERIC,
    feature_streams NUMERIC,
    solo_streams    NUMERIC
);
```

---

## Analysis

The script [`spotify artists analysis.sql`](spotify%20artists%20analysis.sql) is split into three sections.

### 1. Basic EDA
- Top 3 countries by total streams, with the number of artists per country
- Top 5 genres and top 5 languages by total streams
- Total and solo streams of solo artists by sex (groups excluded)
- Top 10 most-streamed bands

### 2. Intermediate EDA
- **Features vs. solo:** artists whose feature streams exceed their solo streams, ranked by the size of the difference
- **Reliable genre ranking:** genres with at least 5 artists (`HAVING COUNT(artist) >= 5`), so a single big artist doesn't inflate a small genre
- **Niche but strong genres:** average streams per artist by genre, to find genres with few artists but high average reach
- **Top artist per country**, solved in two ways:

```sql
-- PostgreSQL-specific: one row per country
SELECT DISTINCT ON (country) country, artist, total_streams
FROM spotify
ORDER BY country, total_streams DESC;

-- Portable SQL: subquery with MAX per country
SELECT country, artist, total_streams
FROM spotify
WHERE (country, total_streams) IN (
    SELECT country, MAX(total_streams)
    FROM spotify
    GROUP BY country
)
ORDER BY country;
```

`DISTINCT ON` is shorter but works only in PostgreSQL. It also always returns exactly one artist per country. The subquery version works in any SQL database and returns all artists if two of them tie for first place.

### 3. Advanced analytics: dependence on collaborations

For every artist, a CTE calculates the share of streams coming from features. A window function then adds the dataset-wide average to every row, so each artist can be compared with it without a separate join:

```sql
WITH stats_per_artist AS (
    SELECT
        artist,
        total_streams,
        ROUND((feature_streams / NULLIF(solo_streams + feature_streams, 0)) * 100, 2) AS feature_pct,
        ROUND(AVG((feature_streams / NULLIF(solo_streams + feature_streams, 0)) * 100) OVER (), 2)
            AS avg_database_feature_pct
    FROM spotify
)
SELECT artist, total_streams, feature_pct, avg_database_feature_pct
FROM stats_per_artist
WHERE feature_pct > avg_database_feature_pct
ORDER BY feature_pct DESC;
```

`NULLIF(..., 0)` prevents a division-by-zero error for artists with no solo or feature streams.

---

## SQL techniques

- Aggregation with `GROUP BY` and filtering groups with `HAVING`
- Common Table Expressions (CTE)
- Window functions: `AVG() OVER ()`
- `DISTINCT ON` vs. a subquery with tuple comparison (`(a, b) IN (...)`) for "top N per group"
- Safe division with `NULLIF`
- Calculated metrics: feature advantage, collaboration percentage

---

## How to run

1. Create a PostgreSQL database and run the `CREATE TABLE` statement above.
2. Load the dataset, e.g. in psql:
   ```sql
   \copy spotify FROM 'path/to/spotify_artists.csv' WITH (FORMAT csv, HEADER true);
   ```
3. Run the queries in [`spotify artists analysis.sql`](spotify%20artists%20analysis.sql) one by one or top to bottom.

## Tools

PostgreSQL · SQL

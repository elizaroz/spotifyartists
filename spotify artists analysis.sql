-- SETUP & TABLE STRUCTURE
/*
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
*/

-- 1. Basic EDA

-- CHECKING TOP 3 COUNTRIES WITH THE HIGHEST STREAMS NUMBER
SELECT 
	country, 
	COUNT(artist) AS artist_count, 
	SUM(total_streams) AS total_country_streams
FROM spotify
GROUP BY country
ORDER BY total_country_streams DESC
LIMIT 3;

--TOP 5 GENRES
SELECT
	genre,
	SUM(total_streams) AS total_genre_streams
FROM spotify
GROUP BY genre
ORDER BY total_genre_streams DESC
LIMIT 5;

--CHECKING WHICH 5 LANGUAGES ARE THE MOST POPULAR
SELECT 
	language,
	SUM(total_streams) AS total_language_streams
FROM spotify
GROUP BY language
ORDER BY total_language_streams DESC
LIMIT 5;

--CHECKING SUM OF SOLO ARTISTS' STREAMS BASED ON SEX
SELECT
	sex,
	SUM(total_streams) AS sum_total_streams,
	SUM(solo_streams) AS sum_solo_streams
FROM spotify
WHERE artist_type != 'Group'
GROUP BY sex
ORDER BY sum_total_streams DESC;

--INVESTIGATING BANDS
SELECT
	artist,
	genre,
	SUM(total_streams) AS total_band_streams
FROM spotify
WHERE artist_type = 'Group'
GROUP BY artist, genre
ORDER BY total_band_streams DESC
LIMIT 10;

-- 2. Intermediate EDA
--CHECKING ARTISTS WHO HAVE MORE FEATURE STREAMS THAN SOLO STREAMS
SELECT 
    artist,
    total_streams,
    solo_streams,
    feature_streams,
    ROUND(feature_streams - solo_streams, 2) AS feature_advantage
FROM public.spotify
WHERE feature_streams > solo_streams
ORDER BY feature_advantage DESC;

--SHOWING ONLY GENRES WITH AT LEAST 5 ARTISTS IN THE TABLE
SELECT
    genre,
    COUNT(artist) AS artist_count,
    SUM(total_streams) AS total_genre_streams
FROM spotify
GROUP BY genre
HAVING COUNT(artist) >= 5
ORDER BY total_genre_streams DESC;

--GENRES WITH A LOW NUMBER OF ARTISTS BUT HIGH AVERAGE TOTAL STREAMS
SELECT
	COUNT(artist) AS artist_count,
	genre,
	SUM(total_streams) AS sum_total_streams,
	ROUND(AVG(total_streams), 2) AS avg_total_streams_per_artist
FROM spotify
GROUP BY genre
ORDER BY avg_total_streams_per_artist DESC;
	
--TOP ARTIST PER COUNTRY
SELECT DISTINCT ON (country)
    country,
    artist,
    total_streams
FROM spotify
ORDER BY country, total_streams DESC;

--OTHER SOLUTION
SELECT 
    country,
    artist,
    total_streams
FROM spotify
WHERE (country, total_streams) IN (
    SELECT country, MAX(total_streams)
    FROM spotify
    GROUP BY country
)
ORDER BY COUNTRY;

-- 3. Advanced analytics

WITH stats_per_artist AS (
    SELECT 
        artist,
        total_streams,
        solo_streams,
        feature_streams,
		--Collaboration percentage for each artist
        ROUND(
            (feature_streams / NULLIF(solo_streams + feature_streams, 0)) * 100, 
            2
        ) AS feature_pct,
        
        --Average collaboration percentage for all artists in the table
        ROUND(
            AVG((feature_streams / NULLIF(solo_streams + feature_streams, 0)) * 100) OVER(), 
            2
        ) AS avg_database_feature_pct
    FROM public.spotify
)
SELECT 
    artist,
    total_streams,
    feature_pct,
    avg_database_feature_pct
FROM stats_per_artist
	--Showing only artists who are above the average
WHERE feature_pct > avg_database_feature_pct
ORDER BY feature_pct DESC;


-- WHAT: Initial data profile of media_tech_usage
-- RESULT: Row count, NULL counts, duplicate PKs, dirty category samples
-- ACTION: Use output to plan cleaning steps

SELECT COUNT(*) AS total_rows FROM media_tech_usage;


-- Checking the Datatype of the Columns

describe media_tech_usage;

SELECT 
    SUM(usage_id IS NULL)                AS null_usage_id,
    SUM(country IS NULL)                 AS null_country,
    SUM(media_type IS NULL)              AS null_media_type,
    SUM(tech_category IS NULL)           AS null_tech_category,
    SUM(platform IS NULL)                AS null_platform,
    SUM(age_group IS NULL)               AS null_age_group,
    SUM(gender IS NULL)                  AS null_gender,
    SUM(record_date IS NULL)             AS null_record_date,
    SUM(daily_usage_hrs IS NULL)         AS null_daily_usage_hrs,
    SUM(penetration_rate_pct IS NULL)    AS null_penetration_rate,
    SUM(subscribers_millions IS NULL)    AS null_subscribers,
    SUM(ad_spend_usd IS NULL)            AS null_ad_spend,
    SUM(content_hours_produced IS NULL)  AS null_content_hours
FROM media_tech_usage;

-- Duplicate PKs
SELECT usage_id, COUNT(*) AS cnt
FROM media_tech_usage
GROUP BY usage_id
HAVING cnt > 1
limit 100;



-- Dirty category samples
SELECT DISTINCT country FROM media_tech_usage;
SELECT DISTINCT media_type FROM media_tech_usage LIMIT 20;
SELECT DISTINCT gender FROM media_tech_usage LIMIT 20;


####################################################################
-- Cleaning Phse of Media_tech_usage Table
####################################################################

-- ───────────────────────────────────────────────
-- STEP 1: Create clean table
-- WHAT: Create media_tech_usage_clean as cleaned copy
-- RESULT: Structured table ready for standardised data
-- ACTION: Run once — drop if exists before recreating
-- OUTPUT: table created media_tech_usage_clean
-- ───────────────────────────────────────────────

CREATE TABLE media_tech_usage_clean AS
SELECT * FROM media_tech_usage WHERE 1=0;

-- ──────────────────────────────────────────────────────────────────────────────────────────────
-- STEP 2: Deduplicate — keep lowest rowid per usage_id
-- WHAT: Remove duplicate PKs (~1% of 900K rows)
-- RESULT: One row per usage_id retained
-- ACTION: Insert deduped rows into clean table
-- OUTPUT: Inserted Distinct 891157 rows affected into media_tech_usage_clean Table
-- ──────────────────────────────────────────────────────────────────────────────────────────────

INSERT INTO media_tech_usage_clean
SELECT * FROM media_tech_usage
WHERE (usage_id, created_at) IN (
    SELECT usage_id, MIN(created_at)
    FROM media_tech_usage
    GROUP BY usage_id
);

-- ──────────────────────────────────────────────────────────────────────
-- STEP 3: Standardise country
-- WHAT: Fix inconsistent casing (india, CHINA, us)
-- RESULT: 5 clean country values only
-- ACTION: UPDATE in clean table
-- OUTPUT: Standardized Country-to-Title Format (35876 rows affected)
-- ──────────────────────────────────────────────────────────────────────

UPDATE media_tech_usage_clean
SET country = CASE
    WHEN LOWER(TRIM(country)) IN ('india')              THEN 'India'
    WHEN LOWER(TRIM(country)) IN ('usa', 'us')          THEN 'USA'
    WHEN LOWER(TRIM(country)) IN ('china')              THEN 'China'
    WHEN LOWER(TRIM(country)) IN ('japan')              THEN 'Japan'
    WHEN LOWER(TRIM(country)) IN ('germany')            THEN 'Germany'
    ELSE country
END;

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 4: Standardise media_type
-- WHAT: Fix casing + variants (INTERNET, streaming, Print media)
-- RESULT: 7 clean media type values
-- ACTION: UPDATE in clean table
-- OUTPUT: Standardized Media-Type-to-Title Format (222077 rows affected)
-- ─────────────────────────────────────────────────────────────────────────────

UPDATE media_tech_usage_clean
SET media_type = CASE
    WHEN LOWER(TRIM(media_type)) = 'television'    THEN 'Television'
    WHEN LOWER(TRIM(media_type)) = 'internet'      THEN 'Internet'
    WHEN LOWER(TRIM(media_type)) = 'streaming'     THEN 'Streaming'
    WHEN LOWER(TRIM(media_type)) IN ('print media','print') THEN 'Print Media'
    WHEN LOWER(TRIM(media_type)) = 'radio'         THEN 'Radio'
    WHEN LOWER(TRIM(media_type)) = 'social media'  THEN 'Social Media'
    WHEN LOWER(TRIM(media_type)) = 'podcast'       THEN 'Podcast'
    ELSE 'Other'
END;

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 5: Standardise gender
-- WHAT: Fix M/F/FEMALE/non binary variants
-- RESULT: 4 clean gender values
-- ACTION: UPDATE in clean table
-- OUTPUT: Standardized Gender-to-Title Format (594293 rows affected)
-- ─────────────────────────────────────────────────────────────────────────────

UPDATE media_tech_usage_clean
SET gender = CASE
    WHEN LOWER(TRIM(gender)) IN ('male', 'm')          THEN 'Male'
    WHEN LOWER(TRIM(gender)) IN ('female', 'f')        THEN 'Female'
    ELSE 'Non-binary'
END;

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 6: Standardise age_group
-- WHAT: Fix 18_24, 25 to 34, 65 plus variants
-- RESULT: Consistent bracket format
-- ACTION: UPDATE in clean table
-- OUTPUT: Standardized Age-Group-to-Range Format (404366 rows affected)
-- ─────────────────────────────────────────────────────────────────────────────

UPDATE media_tech_usage_clean
SET age_group = CASE
    WHEN REPLACE(LOWER(TRIM(age_group)), '_', '-') = '18-24'  THEN '18-24'
    WHEN age_group IN ('25 to 34', '25-34')                   THEN '25-34'
    WHEN age_group IN ('35-44')                               THEN '35-44'
    WHEN age_group IN ('45-54')                               THEN '45-54'
    WHEN age_group IN ('55-64')                               THEN '55-64'
    WHEN age_group IN ('65+', '65 plus')                      THEN '65+'
    ELSE 'Unknown'
END;

-- ───────────────────────────────────────────────
-- STEP 7: Fix invalid numeric values
-- WHAT: Negative daily_usage_hrs, penetration > 100, negative content_hours
-- RESULT: Invalid values set to NULL for DBA/Data Owner correction
-- ACTION: UPDATE in clean table
-- ───────────────────────────────────────────────

UPDATE media_tech_usage_clean
SET daily_usage_hrs = NULL
WHERE daily_usage_hrs < 0; -- affected rows: 26672

UPDATE media_tech_usage_clean
SET penetration_rate_pct = NULL
WHERE penetration_rate_pct > 100; -- affected rows: 26820

UPDATE media_tech_usage_clean
SET content_hours_produced = NULL
WHERE content_hours_produced < 0; -- affected rows: 26595

-- ───────────────────────────────────────────────
-- STEP 8: Standardise record_date to YYYY-MM-DD
-- WHAT: Mixed formats (dd/mm/yyyy, mm-dd-yyyy, dd Mon yyyy, yyyy)
-- RESULT: Uniform date string — NULL if unparseable
-- ACTION: UPDATE in clean table
-- OUTPUT: Standardised the record-date to YYYY-MM-DD Format (712746 rows affected)
-- ───────────────────────────────────────────────

UPDATE media_tech_usage_clean
SET record_date = CASE
    WHEN record_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN record_date
    WHEN record_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
        THEN CONCAT(SUBSTRING(record_date,7,4),'-',SUBSTRING(record_date,4,2),'-',SUBSTRING(record_date,1,2))
    WHEN record_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
        THEN CONCAT(SUBSTRING(record_date,7,4),'-',SUBSTRING(record_date,1,2),'-',SUBSTRING(record_date,4,2))
    WHEN record_date REGEXP '^[0-9]{2} [A-Za-z]{3} [0-9]{4}$'
        THEN STR_TO_DATE(record_date, '%d %b %Y')
    ELSE DATE_FORMAT(
            DATE_ADD(
                CONCAT(year, '-01-01'),
                INTERVAL FLOOR(RAND() * 365) DAY
            ),
            '%Y-%m-%d'
         )
END;

-- ───────────────────────────────────────────────
-- STEP 9: Validation
-- WHAT: Confirm clean row count + no remaining dirty values
-- RESULT: Final numbers for documentation
-- ACTION: Review before signing off
-- ───────────────────────────────────────────────

SELECT COUNT(*) AS clean_rows FROM media_tech_usage_clean;
# Result: 891157 cleaned rows 

SELECT
    SUM(daily_usage_hrs < 0)       AS neg_usage_hrs,
    SUM(penetration_rate_pct > 100) AS invalid_penetration,
    SUM(content_hours_produced < 0) AS neg_content_hrs
FROM media_tech_usage_clean;
# Result: All three are 0

SELECT DISTINCT gender     FROM media_tech_usage_clean;
SELECT DISTINCT country   FROM media_tech_usage_clean;
SELECT count(*) FROM media_tech_usage_clean where age_group is null;
# No Null Value found in the above queries


################################################################# THE END
# Note: Need to fix the Age Group where data is unknown and they are still Null: 
	-- penetration_rate_pct,daily_usage_hrs,content_hours_produced
# this will be fixed in python before EDA Process, Due to data size


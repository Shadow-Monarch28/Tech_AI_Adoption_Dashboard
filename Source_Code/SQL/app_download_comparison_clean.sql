-- WHAT: Initial data profile of app_download_comparison
-- RESULT: NULL counts, duplicate PKs, dirty category samples
-- ACTION: Use output to plan cleaning steps

SELECT COUNT(*) AS total_rows FROM app_download_comparison;

describe app_download_comparison;

SELECT
    SUM(download_id IS NULL)             AS null_download_id,
    SUM(country IS NULL)                 AS null_country,
    SUM(app_name IS NULL)                AS null_app_name,
    SUM(app_category IS NULL)            AS null_app_category,
    SUM(platform IS NULL)                AS null_platform,
    SUM(store IS NULL)                   AS null_store,
    SUM(age_group IS NULL)               AS null_age_group,
    SUM(downloads_millions IS NULL)      AS null_downloads,
    SUM(active_users_millions IS NULL)   AS null_active_users,
    SUM(revenue_usd IS NULL)             AS null_revenue,
    SUM(avg_rating IS NULL)              AS null_avg_rating,
    SUM(retention_rate_pct IS NULL)      AS null_retention,
    SUM(uninstall_rate_pct IS NULL)      AS null_uninstall
FROM app_download_comparison;

-- Duplicate PKs
SELECT download_id, COUNT(*) AS cnt
FROM app_download_comparison
GROUP BY download_id
HAVING cnt > 1
LIMIT 10;

-- Dirty category samples
SELECT DISTINCT country      FROM app_download_comparison LIMIT 20;
SELECT DISTINCT app_category FROM app_download_comparison LIMIT 20;
SELECT DISTINCT platform     FROM app_download_comparison LIMIT 20;
SELECT DISTINCT store        FROM app_download_comparison LIMIT 20;

######################################################################
-- Cleaning Phase of app_download_comparison Table
######################################################################


-- STEP 1: Create clean table
-- WHAT: Create app_download_comparison_clean as cleaned copy
-- RESULT: Structured table ready for standardised data
-- ACTION: Run once — drop if exists before recreating

CREATE TABLE app_download_comparison_clean AS
SELECT * FROM app_download_comparison WHERE 1=0;

-- ───────────────────────────────────────────────
-- STEP 2: Deduplicate
-- WHAT: Remove duplicate PKs (~1% of 900K rows)
-- RESULT: One row per download_id retained
-- ACTION: Insert deduped rows into clean table
-- OUTCOME: Inserted Distinct 891180 rows into app_download_comparison_clean Table
-- ───────────────────────────────────────────────

INSERT INTO app_download_comparison_clean
SELECT * FROM app_download_comparison
WHERE (download_id, created_at) IN (
    SELECT download_id, MIN(created_at)
    FROM app_download_comparison
    GROUP BY download_id
);

-- ───────────────────────────────────────────────
-- STEP 3: Standardise country
-- WHAT: Fix inconsistent casing (india, CHINA, us)
-- RESULT: 5 clean country values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised Country to Title Format (178337 rows affected)
-- ───────────────────────────────────────────────

UPDATE app_download_comparison_clean
SET country = CASE
    WHEN LOWER(TRIM(country)) = 'india'             THEN 'India'
    WHEN LOWER(TRIM(country)) IN ('usa', 'us')      THEN 'USA'
    WHEN LOWER(TRIM(country)) = 'china'             THEN 'China'
    WHEN LOWER(TRIM(country)) = 'japan'             THEN 'Japan'
    WHEN LOWER(TRIM(country)) = 'germany'           THEN 'Germany'
    ELSE country
END;

-- ───────────────────────────────────────────────
-- STEP 4: Standardise app_category
-- WHAT: Fix variants (Ecommerce, health and fitness)
-- RESULT: 7 clean category values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised app_category to Title Format (178105 rows affected)
-- ───────────────────────────────────────────────

UPDATE app_download_comparison_clean
SET app_category = CASE
    WHEN LOWER(TRIM(app_category)) = 'social media'                    THEN 'Social Media'
    WHEN LOWER(TRIM(app_category)) IN ('health & fitness','health and fitness') THEN 'Health & Fitness'
    WHEN LOWER(TRIM(app_category)) IN ('e-commerce','ecommerce')        THEN 'E-Commerce'
    WHEN LOWER(TRIM(app_category)) = 'gaming'                          THEN 'Gaming'
    WHEN LOWER(TRIM(app_category)) = 'education'                       THEN 'Education'
    WHEN LOWER(TRIM(app_category)) = 'finance'                         THEN 'Finance'
    WHEN LOWER(TRIM(app_category)) = 'entertainment'                   THEN 'Entertainment'
    ELSE 'Other'
END;

-- ───────────────────────────────────────────────
-- STEP 5: Standardise platform
-- WHAT: Fix ANDROID, IOS, Windows Phone, Harmonyos
-- RESULT: 4 clean platform values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised platform to Title Format (187533 rows affected)
-- ───────────────────────────────────────────────

UPDATE app_download_comparison_clean
SET platform = CASE
    WHEN LOWER(TRIM(platform)) = 'android'                      THEN 'Android'
    WHEN LOWER(TRIM(platform)) IN ('ios', 'iphone os')          THEN 'iOS'
    WHEN LOWER(TRIM(platform)) IN ('windows', 'windows phone')  THEN 'Windows'
    WHEN LOWER(TRIM(platform)) = 'harmonyos'                    THEN 'HarmonyOS'
    ELSE 'Other'
END;

-- ───────────────────────────────────────────────
-- STEP 6: Standardise store
-- WHAT: Fix play store, APP STORE, Apple store variants
-- RESULT: 3 clean store values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised platform to Title Format (667966 rows affected)
-- ───────────────────────────────────────────────

UPDATE app_download_comparison_clean
SET store = CASE
    WHEN LOWER(TRIM(store)) IN ('google play', 'play store')            THEN 'Google Play'
    WHEN LOWER(TRIM(store)) IN ('apple app store','app store','apple store') THEN 'Apple App Store'
    WHEN LOWER(TRIM(store)) = 'huawei appgallery'                       THEN 'Huawei App Gallery'
    ELSE 'Other'
END;

-- ───────────────────────────────────────────────
-- STEP 7: Standardise age_group
-- WHAT: Fix 18_24, 25 to 34 variants
-- RESULT: Consistent bracket format
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised age_group to Range Format (357032 rows affected)
-- ───────────────────────────────────────────────

UPDATE app_download_comparison_clean
SET age_group = CASE
    WHEN REPLACE(LOWER(TRIM(age_group)),'_','-') = '13-17' THEN '13-17'
    WHEN REPLACE(LOWER(TRIM(age_group)),'_','-') = '18-24' THEN '18-24'
    WHEN age_group IN ('25 to 34','25-34')                 THEN '25-34'
    WHEN age_group = '35-44'                               THEN '35-44'
    WHEN age_group = '45-54'                               THEN '45-54'
    WHEN age_group IN ('55+','55 plus')                    THEN '55+'
    ELSE 'Unknown'
END;

-- ───────────────────────────────────────────────
-- STEP 8: Fix invalid numeric values
-- WHAT: Negative downloads, invalid ratings (>5), retention/uninstall > 100
-- RESULT: Invalid values set to NULL
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised age_group to Range Format (356159 rows affected)
-- ───────────────────────────────────────────────

UPDATE app_download_comparison_clean SET downloads_millions = NULL WHERE downloads_millions < 0;
UPDATE app_download_comparison_clean SET avg_rating = NULL WHERE avg_rating > 5;
UPDATE app_download_comparison_clean SET retention_rate_pct = NULL WHERE retention_rate_pct > 100;
UPDATE app_download_comparison_clean SET uninstall_rate_pct = NULL WHERE uninstall_rate_pct < 0;

-- ───────────────────────────────────────────────
-- STEP 9: Fix NULL record_date from year column
-- WHAT: Reconstruct unparseable dates using year
-- RESULT: Dates defaulted to Jan 1 of that year
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised the date to 'YYYY-MM-DD' format (713043 rows affected)
-- ───────────────────────────────────────────────

UPDATE app_download_comparison_clean
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
-- STEP 10: Handle NULL app_name
-- WHAT: Standardise app_name dirty variants
-- RESULT: Clean consistent app names (95210 rows affected)
-- ACTION: UPDATE in clean table
-- ───────────────────────────────────────────────
UPDATE app_download_comparison_clean
SET app_name = CASE
    WHEN LOWER(TRIM(app_name)) IN ('tiktok','tik tok')          THEN 'TikTok'
    WHEN LOWER(TRIM(app_name)) IN ('youtube','you tube','u-tube') THEN 'YouTube'
    WHEN LOWER(TRIM(app_name)) = 'whatsapp'                     THEN 'WhatsApp'
    WHEN LOWER(TRIM(app_name)) = 'instagram'                    THEN 'Instagram'
    WHEN LOWER(TRIM(app_name)) = 'netflix'                      THEN 'Netflix'
    WHEN LOWER(TRIM(app_name)) = 'amazon'                       THEN 'Amazon'
    WHEN LOWER(TRIM(app_name)) = 'wechat'                       THEN 'WeChat'
    WHEN LOWER(TRIM(app_name)) = 'paytm'                        THEN 'Paytm'
    WHEN LOWER(TRIM(app_name)) = 'line'                         THEN 'Line'
    WHEN LOWER(TRIM(app_name)) = 'twitter'                      THEN 'Twitter'
    WHEN LOWER(TRIM(app_name)) = 'hotstar'                      THEN 'Hotstar'
    WHEN LOWER(TRIM(app_name)) = 'paypay'                       THEN 'PayPay'
    WHEN LOWER(TRIM(app_name)) = 'alipay'                       THEN 'Alipay'
    WHEN LOWER(TRIM(app_name)) = 'baidu'                        THEN 'Baidu'
    WHEN LOWER(TRIM(app_name)) = 'niconico'                     THEN 'NicoNico'
    WHEN LOWER(TRIM(app_name)) = 'spotify'                      THEN 'Spotify'
    ELSE app_name
END;


-- ───────────────────────────────────────────────
-- STEP 11: Validation
-- WHAT: Confirm clean row count + no remaining issues
-- RESULT: Final numbers for documentation
-- ACTION: Review before signing off
-- ───────────────────────────────────────────────

SELECT COUNT(*) AS clean_rows FROM app_download_comparison_clean;
# Outcome: 891180 cleaned rows 

SELECT
    SUM(downloads_millions < 0)    AS neg_downloads,
    SUM(avg_rating > 5)            AS invalid_rating,
    SUM(retention_rate_pct > 100)  AS invalid_retention,
    SUM(uninstall_rate_pct < 0)    AS neg_uninstall
FROM app_download_comparison_clean;
# OUTCOME: all 4 have zero Null Values

SELECT DISTINCT country      FROM app_download_comparison_clean;
SELECT DISTINCT app_category FROM app_download_comparison_clean;
SELECT DISTINCT platform     FROM app_download_comparison_clean;
SELECT DISTINCT store        FROM app_download_comparison_clean;
SELECT DISTINCT app_name	 FROM app_download_comparison_clean;


################################################################# THE END
# Note: Need to fix the Age Group where data is unknown and they are still Null:
	-- downloads_millions,avg_rating,retention_rate_pct,uninstall_rate_pct
# this will be fixed in python before EDA Process, Due to data size

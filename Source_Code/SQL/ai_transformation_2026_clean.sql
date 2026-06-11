-- WHAT: Initial data profile of ai_transformation_2026
-- RESULT: NULL counts, duplicate PKs, dirty category samples
-- ACTION: Use output to plan cleaning steps

SELECT COUNT(*) AS total_rows FROM ai_transformation_2026;

describe ai_transformation_2026;

SELECT
    SUM(transformation_id IS NULL)      AS null_id,
    SUM(country IS NULL)                AS null_country,
    SUM(sector IS NULL)                 AS null_sector,
    SUM(ai_tool IS NULL)                AS null_ai_tool,
    SUM(use_case IS NULL)               AS null_use_case,
    SUM(adoption_stage IS NULL)         AS null_adoption_stage,
    SUM(company_size IS NULL)           AS null_company_size,
    SUM(ai_adoption_rate_pct IS NULL)   AS null_adoption_rate,
    SUM(productivity_gain_pct IS NULL)  AS null_productivity,
    SUM(cost_reduction_pct IS NULL)     AS null_cost_reduction,
    SUM(investment_usd IS NULL)         AS null_investment,
    SUM(jobs_displaced IS NULL)         AS null_jobs_displaced,
    SUM(jobs_created IS NULL)           AS null_jobs_created,
    SUM(ai_error_rate_pct IS NULL)      AS null_error_rate
FROM ai_transformation_2026;

-- Duplicate PKs
SELECT transformation_id, COUNT(*) AS cnt
FROM ai_transformation_2026
GROUP BY transformation_id
HAVING cnt > 1
LIMIT 10;

-- Dirty category samples
SELECT DISTINCT country        FROM ai_transformation_2026 LIMIT 20;
SELECT DISTINCT sector         FROM ai_transformation_2026 LIMIT 20;
SELECT DISTINCT ai_tool        FROM ai_transformation_2026 LIMIT 20;
SELECT DISTINCT adoption_stage FROM ai_transformation_2026 LIMIT 20;
SELECT DISTINCT use_case       FROM ai_transformation_2026 LIMIT 20;
SELECT DISTINCT company_size   FROM ai_transformation_2026 LIMIT 20;


######################################################################
-- Cleaning Phase of ai_transformation_2026 Table
######################################################################


-- STEP 1: Create clean table
-- WHAT: Create ai_transformation_2026_clean as cleaned copy
-- RESULT: Structured table ready for standardised data
-- ACTION: Run once — drop if exists before recreating

CREATE TABLE ai_transformation_2026_clean AS
SELECT * FROM ai_transformation_2026 WHERE 1=0;

-- ───────────────────────────────────────────────
-- STEP 2: Deduplicate
-- WHAT: Remove duplicate PKs (~1% of 900K rows)
-- RESULT: One row per transformation_id retained
-- ACTION: Insert deduped rows into clean table
-- RETURNED: Inserted Distinct 891179 rows into ai_transformation_2026_clean Table
-- ───────────────────────────────────────────────

INSERT INTO ai_transformation_2026_clean
SELECT * FROM ai_transformation_2026
WHERE (transformation_id, created_at) IN (
    SELECT transformation_id, MIN(created_at)
    FROM ai_transformation_2026
    GROUP BY transformation_id
);

-- ───────────────────────────────────────────────
-- STEP 3: Standardise country
-- WHAT: Fix inconsistent casing (india, CHINA, us)
-- RESULT: 5 clean country values
-- ACTION: UPDATE in clean table
-- RETURNED: Standardised Country name to Title Format (178404 rows affected)
-- ───────────────────────────────────────────────

UPDATE ai_transformation_2026_clean
SET country = CASE
    WHEN LOWER(TRIM(country)) = 'india'           THEN 'India'
    WHEN LOWER(TRIM(country)) IN ('usa', 'us')    THEN 'USA'
    WHEN LOWER(TRIM(country)) = 'china'           THEN 'China'
    WHEN LOWER(TRIM(country)) = 'japan'           THEN 'Japan'
    WHEN LOWER(TRIM(country)) = 'germany'         THEN 'Germany'
    ELSE country
END;

-- ───────────────────────────────────────────────
-- STEP 4: Standardise sector
-- WHAT: Fix variants (Edu, retail & ecommerce, FINANCE)
-- RESULT: 8 clean sector values
-- ACTION: UPDATE in clean table
-- RETURNED: Standardised Sectors to Title Formet (177861 rows affected)
-- ───────────────────────────────────────────────

UPDATE ai_transformation_2026_clean
SET sector = CASE
    WHEN LOWER(TRIM(sector)) = 'healthcare'                        THEN 'Healthcare'
    WHEN LOWER(TRIM(sector)) IN ('retail','retail & ecommerce')    THEN 'Retail & E-Commerce'
    WHEN LOWER(TRIM(sector)) IN ('edu','education')                THEN 'Education'
    WHEN LOWER(TRIM(sector)) = 'manufacturing'                     THEN 'Manufacturing'
    WHEN LOWER(TRIM(sector)) = 'government'                        THEN 'Government'
    WHEN LOWER(TRIM(sector)) = 'finance'                           THEN 'Finance'
    WHEN LOWER(TRIM(sector)) = 'media'                             THEN 'Media'
    WHEN LOWER(TRIM(sector)) = 'logistics'                         THEN 'Logistics'
    ELSE 'Other'
END;

-- ───────────────────────────────────────────────
-- STEP 5: Standardise ai_tool
-- WHAT: Fix Co-pilot, Mid Journey, GEMINI variants
-- RESULT: 9 clean AI tool values
-- ACTION: UPDATE in clean table
-- RETURNED: Standardised ai_tool name (342597 rows affected)
-- ───────────────────────────────────────────────

UPDATE ai_transformation_2026_clean
SET ai_tool = CASE
    WHEN LOWER(TRIM(ai_tool)) = 'chatgpt'                          THEN 'ChatGPT'
    WHEN LOWER(TRIM(ai_tool)) = 'gemini'                           THEN 'Gemini'
    WHEN LOWER(TRIM(ai_tool)) IN ('copilot','co-pilot')            THEN 'Copilot'
    WHEN LOWER(TRIM(ai_tool)) IN ('midjourney','mid journey')      THEN 'MidJourney'
    WHEN LOWER(TRIM(ai_tool)) = 'stable diffusion'                 THEN 'Stable Diffusion'
    WHEN LOWER(TRIM(ai_tool)) = 'claude'                           THEN 'Claude'
    WHEN LOWER(TRIM(ai_tool)) = 'grok'                             THEN 'Grok'
    WHEN LOWER(TRIM(ai_tool)) = 'perplexity'                       THEN 'Perplexity'
    ELSE 'Other'
END;

-- ───────────────────────────────────────────────
-- STEP 6: Standardise adoption_stage
-- WHAT: Fix full adoption, SCALING, In Progress + NULL
-- RESULT: 6 clean adoption stage values
-- ACTION: UPDATE in clean table
-- RETURNED: Stardardised Adoption Stage to Title Format (356881 rows affected)
-- ───────────────────────────────────────────────

UPDATE ai_transformation_2026_clean
SET adoption_stage = CASE
    WHEN LOWER(TRIM(adoption_stage)) = 'pilot'                     THEN 'Pilot'
    WHEN LOWER(TRIM(adoption_stage)) = 'scaling'                   THEN 'Scaling'
    WHEN LOWER(TRIM(adoption_stage)) IN ('fully adopted','full adoption') THEN 'Fully Adopted'
    WHEN LOWER(TRIM(adoption_stage)) = 'evaluating'                THEN 'Evaluating'
    WHEN LOWER(TRIM(adoption_stage)) = 'rejected'                  THEN 'Rejected'
    WHEN LOWER(TRIM(adoption_stage)) = 'in progress'               THEN 'In Progress'
    ELSE 'Shadow Adoption'
END;

-- ───────────────────────────────────────────────
-- STEP 7: Standardise use_case
-- WHAT: Fix code gen, fraud-detection, CUSTOMER SUPPORT + NULL
-- RESULT: 8 clean use case values
-- ACTION: UPDATE in clean table
-- Returned: Standardised use_case's Value to Title Format (370696 rows affected)
-- ───────────────────────────────────────────────

UPDATE ai_transformation_2026_clean
SET use_case = CASE
    WHEN LOWER(TRIM(use_case)) IN ('content generation')           THEN 'Content Generation'
    WHEN LOWER(TRIM(use_case)) IN ('customer support','customer support') THEN 'Customer Support'
    WHEN LOWER(TRIM(use_case)) IN ('fraud detection','fraud-detection')   THEN 'Fraud Detection'
    WHEN LOWER(TRIM(use_case)) = 'drug discovery'                  THEN 'Drug Discovery'
    WHEN LOWER(TRIM(use_case)) = 'predictive maintenance'          THEN 'Predictive Maintenance'
    WHEN LOWER(TRIM(use_case)) IN ('code generation','code gen')   THEN 'Code Generation'
    WHEN LOWER(TRIM(use_case)) = 'hr automation'                   THEN 'HR Automation'
    ELSE 'Cybersecurity & Threat Intel'
END;

-- ───────────────────────────────────────────────
-- STEP 8: Standardise company_size
-- WHAT: Fix startup, Mid-size, Large Corp + NULL
-- RESULT: 6 clean company size values
-- ACTION: UPDATE in clean table
-- Returned: Standardised Company_size to Title Format (495602 rows affected)
-- ───────────────────────────────────────────────

UPDATE ai_transformation_2026_clean
SET company_size = CASE
    WHEN LOWER(TRIM(company_size)) IN ('startup')                  THEN 'Startup'
    WHEN LOWER(TRIM(company_size)) IN ('sme','small')              THEN 'SME'
    WHEN LOWER(TRIM(company_size)) IN ('enterprise','large','large corp') THEN 'Enterprise'
    WHEN LOWER(TRIM(company_size)) = 'mid-size'                    THEN 'Mid-size'
    ELSE 'Micro'
END;

-- ───────────────────────────────────────────────
-- STEP 9: Fix invalid numeric values
-- WHAT: adoption > 100, productivity < 0, cost_reduction > 100, error_rate > 100
-- RESULT: Invalid values set to NULL
-- ACTION: UPDATE in clean table
-- ───────────────────────────────────────────────

UPDATE ai_transformation_2026_clean SET ai_adoption_rate_pct  = NULL WHERE ai_adoption_rate_pct > 100;
UPDATE ai_transformation_2026_clean SET productivity_gain_pct = NULL WHERE productivity_gain_pct < 0;
UPDATE ai_transformation_2026_clean SET cost_reduction_pct    = NULL WHERE cost_reduction_pct > 100;
UPDATE ai_transformation_2026_clean SET ai_error_rate_pct     = NULL WHERE ai_error_rate_pct > 100;
UPDATE ai_transformation_2026_clean SET jobs_displaced        = NULL WHERE jobs_displaced < 0;

-- ───────────────────────────────────────────────
-- STEP 10: Fix NULL record_date from year column
-- WHAT: Reconstruct unparseable dates using year column
-- RESULT: Dates defaulted to Jan 1 of that year
-- ACTION: UPDATE in clean table (712674 affected rows)
-- ───────────────────────────────────────────────

UPDATE ai_transformation_2026_clean
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
-- STEP 11: Validation
-- WHAT: Confirm clean row count + no remaining issues
-- RESULT: Final numbers for documentation
-- ACTION: Performing clearning check on ai_transformation_2026_clean 
-- ───────────────────────────────────────────────

SELECT COUNT(*) AS clean_rows FROM ai_transformation_2026_clean;
# Result: 891179 cleaned rows

SELECT
    SUM(ai_adoption_rate_pct > 100)   AS invalid_adoption_rate,
    SUM(productivity_gain_pct < 0)    AS neg_productivity,
    SUM(cost_reduction_pct > 100)     AS invalid_cost_reduction,
    SUM(ai_error_rate_pct > 100)      AS invalid_error_rate,
    SUM(jobs_displaced < 0)           AS neg_jobs_displaced
FROM ai_transformation_2026_clean;

SELECT DISTINCT country        FROM ai_transformation_2026_clean;
SELECT DISTINCT sector         FROM ai_transformation_2026_clean;
SELECT DISTINCT ai_tool        FROM ai_transformation_2026_clean;
SELECT DISTINCT adoption_stage FROM ai_transformation_2026_clean;
SELECT DISTINCT use_case       FROM ai_transformation_2026_clean;
SELECT DISTINCT company_size   FROM ai_transformation_2026_clean;

################################################################# THE END
# Note: Need to fix the Age Group where data is unknown and they are still Null: 
	-- ai_adoption_rate_pct,productivity_gain_pct,cost_reduction_pct,ai_error_rate_pct,jobs_displaced
# These will be fixed in python before EDA Process, Due to data size
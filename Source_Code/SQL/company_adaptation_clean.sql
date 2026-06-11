-- WHAT: Initial data profile of company_adaptation
-- RESULT: NULL counts, duplicate PKs, dirty category samples
-- ACTION: Use output to plan cleaning steps

SELECT COUNT(*) AS total_rows FROM company_adaptation;

describe company_adaptation;

SELECT
    SUM(adaptation_id IS NULL)           AS null_id,
    SUM(country IS NULL)                 AS null_country,
    SUM(industry IS NULL)                AS null_industry,
    SUM(company_size IS NULL)            AS null_company_size,
    SUM(adaptation_type IS NULL)         AS null_adaptation_type,
    SUM(tech_stack IS NULL)              AS null_tech_stack,
    SUM(strategy IS NULL)                AS null_strategy,
    SUM(digital_maturity_score IS NULL)  AS null_maturity_score,
    SUM(revenue_growth_pct IS NULL)      AS null_revenue_growth,
    SUM(tech_investment_usd IS NULL)     AS null_tech_investment,
    SUM(employee_count IS NULL)          AS null_employee_count,
    SUM(digital_revenue_pct IS NULL)     AS null_digital_revenue,
    SUM(customer_satisfaction IS NULL)   AS null_csat,
    SUM(market_share_pct IS NULL)        AS null_market_share
FROM company_adaptation;

-- Duplicate PKs
SELECT adaptation_id, COUNT(*) AS cnt
FROM company_adaptation
GROUP BY adaptation_id
HAVING cnt > 1
LIMIT 10;

-- Dirty category samples
SELECT DISTINCT country         FROM company_adaptation LIMIT 20;
SELECT DISTINCT industry        FROM company_adaptation LIMIT 20;
SELECT DISTINCT company_size    FROM company_adaptation LIMIT 20;
SELECT DISTINCT adaptation_type FROM company_adaptation LIMIT 20;
SELECT DISTINCT tech_stack      FROM company_adaptation LIMIT 20;
SELECT DISTINCT strategy        FROM company_adaptation LIMIT 20;


######################################################################
-- Cleaning Phase of company_adaptation Table
######################################################################

-- STEP 1: Create clean table
-- WHAT: Create company_adaptation_clean as cleaned copy
-- RESULT: Structured table ready for standardised data
-- ACTION: Run once — drop if exists before recreating

CREATE TABLE company_adaptation_clean AS
SELECT * FROM company_adaptation WHERE 1=0;

-- ───────────────────────────────────────────────
-- STEP 2: Deduplicate
-- WHAT: Remove duplicate PKs (~1% of 900K rows)
-- RESULT: One row per adaptation_id retained
-- ACTION: Insert deduped rows into clean table
-- OUTCOME: Inserted 891169 rows into company_adaptation_clean Table
-- ───────────────────────────────────────────────

INSERT INTO company_adaptation_clean
SELECT * FROM company_adaptation
WHERE (adaptation_id, created_at) IN (
    SELECT adaptation_id, MIN(created_at)
    FROM company_adaptation
    GROUP BY adaptation_id
);

-- ───────────────────────────────────────────────
-- STEP 3: Standardise country
-- WHAT: Fix inconsistent casing (india, CHINA, us)
-- RESULT: 5 clean country values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised the Country (178715 rows affected)
-- ───────────────────────────────────────────────

UPDATE company_adaptation_clean
SET country = CASE
    WHEN LOWER(TRIM(country)) = 'india'           THEN 'India'
    WHEN LOWER(TRIM(country)) IN ('usa', 'us')    THEN 'USA'
    WHEN LOWER(TRIM(country)) = 'china'           THEN 'China'
    WHEN LOWER(TRIM(country)) = 'japan'           THEN 'Japan'
    WHEN LOWER(TRIM(country)) = 'germany'         THEN 'Germany'
    ELSE country
END;

-- ───────────────────────────────────────────────
-- STEP 4: Standardise industry
-- WHAT: Fix health care, Edu, MEDIA variants + NULL
-- RESULT: 9 clean industry values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised the Industry (88850 rows affected)
-- ───────────────────────────────────────────────

UPDATE company_adaptation_clean
SET industry = CASE
    WHEN LOWER(TRIM(industry)) = 'technology'                      THEN 'Technology'
    WHEN LOWER(TRIM(industry)) IN ('healthcare','health care')     THEN 'Healthcare'
    WHEN LOWER(TRIM(industry)) IN ('education','edu')              THEN 'Education'
    WHEN LOWER(TRIM(industry)) = 'retail'                          THEN 'Retail'
    WHEN LOWER(TRIM(industry)) = 'manufacturing'                   THEN 'Manufacturing'
    WHEN LOWER(TRIM(industry)) = 'banking'                         THEN 'Banking'
    WHEN LOWER(TRIM(industry)) = 'telecom'                         THEN 'Telecom'
    WHEN LOWER(TRIM(industry)) = 'media'                           THEN 'Media'
    ELSE 'Other'
END;

-- ───────────────────────────────────────────────
-- STEP 5: Standardise company_size
-- WHAT: Fix Large Corp, Mid-size, Small + NULL
-- RESULT: 6 clean company size values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised the company_size (495219 rows affected)
-- ───────────────────────────────────────────────

UPDATE company_adaptation_clean
SET company_size = CASE
    WHEN LOWER(TRIM(company_size)) = 'startup'                     THEN 'Startup'
    WHEN LOWER(TRIM(company_size)) IN ('sme','small')              THEN 'SME'
    WHEN LOWER(TRIM(company_size)) IN ('enterprise','large corp','large') THEN 'Enterprise'
    WHEN LOWER(TRIM(company_size)) = 'mid-size'                    THEN 'Mid-size'
    ELSE 'Micro'
END;

-- ───────────────────────────────────────────────
-- STEP 6: Standardise adaptation_type
-- WHAT: Fix cloud-migration, AI integration, E-Commerce Shift + NULL
-- RESULT: 7 clean adaptation type values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised the adaptation_type (405629 rows affected)
-- ───────────────────────────────────────────────

UPDATE company_adaptation_clean
SET adaptation_type = CASE
    WHEN LOWER(TRIM(adaptation_type)) = 'digital transformation'   THEN 'Digital Transformation'
    WHEN LOWER(TRIM(adaptation_type)) IN ('cloud migration','cloud-migration') THEN 'Cloud Migration'
    WHEN LOWER(TRIM(adaptation_type)) IN ('ai integration','ai integration')   THEN 'AI Integration'
    WHEN LOWER(TRIM(adaptation_type)) = 'agile adoption'           THEN 'Agile Adoption'
    WHEN LOWER(TRIM(adaptation_type)) = 'remote work'              THEN 'Remote Work'
    WHEN LOWER(TRIM(adaptation_type)) = 'e-commerce shift'         THEN 'E-Commerce Shift'
    ELSE 'Legacy Modernisation'
END;

-- ───────────────────────────────────────────────
-- STEP 7: Standardise tech_stack
-- WHAT: Fix iot, 5g network, AI variants + NULL
-- RESULT: 7 clean tech stack values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised the tech_stack (445933 rows affected)
-- ───────────────────────────────────────────────

UPDATE company_adaptation_clean
SET tech_stack = CASE
    WHEN LOWER(TRIM(tech_stack)) = 'cloud'                         THEN 'Cloud'
    WHEN LOWER(TRIM(tech_stack)) IN ('ai/ml','ai')                 THEN 'AI/ML'
    WHEN LOWER(TRIM(tech_stack)) = 'blockchain'                    THEN 'Blockchain'
    WHEN LOWER(TRIM(tech_stack)) = 'iot'                           THEN 'IoT'
    WHEN LOWER(TRIM(tech_stack)) IN ('5g','5g network')            THEN '5G'
    WHEN LOWER(TRIM(tech_stack)) = 'big data'                      THEN 'Big Data'
    ELSE 'Other'
END;

-- ───────────────────────────────────────────────
-- STEP 8: Standardise strategy
-- WHAT: Fix invest and grow, M&A, partnership variants + NULL
-- RESULT: 6 clean strategy values
-- ACTION: UPDATE in clean table
-- OUTCOME: Standardised the strategy (446232 rows affected)
-- ───────────────────────────────────────────────

UPDATE company_adaptation_clean
SET strategy = CASE
    WHEN LOWER(TRIM(strategy)) IN ('invest & grow','invest and grow') THEN 'Invest & Grow'
    WHEN LOWER(TRIM(strategy)) = 'cost cutting'                       THEN 'Cost Cutting'
    WHEN LOWER(TRIM(strategy)) IN ('partnerships','partnership')      THEN 'Partnerships'
    WHEN LOWER(TRIM(strategy)) IN ('acquisitions','m&a')              THEN 'Acquisitions'
    WHEN LOWER(TRIM(strategy)) = 'organic growth'                     THEN 'Organic Growth'
    ELSE 'Other'
END;

-- ───────────────────────────────────────────────
-- STEP 9: Fix invalid numeric values
-- WHAT: maturity > 10, revenue < -100, employee < 0,
--       digital_revenue > 100, csat > 5, market_share NULL
-- RESULT: Invalid values set to NULL
-- ACTION: UPDATE in clean table
-- ───────────────────────────────────────────────

UPDATE company_adaptation_clean SET digital_maturity_score = NULL WHERE digital_maturity_score > 10;
UPDATE company_adaptation_clean SET revenue_growth_pct     = NULL WHERE revenue_growth_pct < -100;
UPDATE company_adaptation_clean SET employee_count         = NULL WHERE employee_count < 0;
UPDATE company_adaptation_clean SET digital_revenue_pct    = NULL WHERE digital_revenue_pct > 100;
UPDATE company_adaptation_clean SET customer_satisfaction  = NULL WHERE customer_satisfaction > 5;

-- ───────────────────────────────────────────────
-- STEP 10: Fix NULL record_date from year column
-- WHAT: Reconstruct unparseable dates using year column
-- RESULT: Dates defaulted to Jan 1 of that year
-- ACTION: UPDATE in clean table (713105 affected rows)
-- ───────────────────────────────────────────────

UPDATE company_adaptation_clean
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
-- ACTION: Review before signing off
-- ───────────────────────────────────────────────

SELECT COUNT(*) AS clean_rows FROM company_adaptation_clean;
# Result: 891169 cleaned rows

SELECT
    SUM(digital_maturity_score > 10)  AS invalid_maturity,
    SUM(revenue_growth_pct < -100)    AS invalid_revenue,
    SUM(employee_count < 0)           AS neg_employees,
    SUM(digital_revenue_pct > 100)    AS invalid_digital_rev,
    SUM(customer_satisfaction > 5)    AS invalid_csat
FROM company_adaptation_clean;

SELECT DISTINCT country         FROM company_adaptation_clean;
SELECT DISTINCT industry        FROM company_adaptation_clean;
SELECT DISTINCT company_size    FROM company_adaptation_clean;
SELECT DISTINCT adaptation_type FROM company_adaptation_clean;
SELECT DISTINCT tech_stack      FROM company_adaptation_clean;
SELECT DISTINCT strategy        FROM company_adaptation_clean;


################################################################# THE END
# Note: Need to fix the Age Group where data is unknown and they are still Null: 
	-- digital_maturity_score,revenue_growth_pct,employee_count,digital_revenue_pct,customer_satisfaction
# These will be fixed in python before EDA Process, Due to data size
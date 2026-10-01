-- Cleans ERP location data
-- Standardizes inconsistent country codes to full names

WITH source AS (
    SELECT * FROM {{ source('bronze_erp', 'erp_loc_a101') }}
),

cleaned AS (
    SELECT
        cid AS customer_number,

        CASE UPPER(TRIM(cntry))
            WHEN 'US'             THEN 'United States'
            WHEN 'USA'            THEN 'United States'
            WHEN 'DE'             THEN 'Germany'
            WHEN 'GERMANY'        THEN 'Germany'
            WHEN 'UK'             THEN 'United Kingdom'
            WHEN 'UNITED KINGDOM' THEN 'United Kingdom'
            WHEN ''               THEN 'N/A'
            ELSE ISNULL(TRIM(cntry), 'N/A')
        END AS country

    FROM source
)

SELECT * FROM cleaned
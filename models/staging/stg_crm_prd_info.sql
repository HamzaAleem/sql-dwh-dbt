-- Cleans CRM product data
-- Extracts category ID from compound key, standardizes product line, derives SCD end dates

WITH source AS (
    SELECT * FROM {{ source('bronze_crm', 'crm_prd_info') }}
),

cleaned AS (
    SELECT
        prd_id                                          AS product_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '')     AS category_id,
        SUBSTRING(prd_key, 7, LEN(prd_key))            AS product_number,
        prd_nm                                          AS product_name,
        ISNULL(prd_cost, 0)                             AS product_cost,
        CAST(prd_start_dt AS DATE)                      AS start_date,

        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'N/A'
        END AS product_line,

        CAST(
            DATEADD(DAY, -1,
                LEAD(prd_start_dt) OVER (
                    PARTITION BY SUBSTRING(prd_key, 7, LEN(prd_key))
                    ORDER BY prd_start_dt
                )
            )
        AS DATE) AS end_date

    FROM source
)

SELECT * FROM cleaned
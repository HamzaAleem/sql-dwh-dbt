-- Cleans CRM customer data
-- Deduplicates by cst_id, standardizes gender + marital status, trims names

WITH source AS (
    SELECT * FROM {{ source('bronze_crm', 'crm_cust_info') }}
),

deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS row_num
    FROM source
    WHERE cst_id IS NOT NULL
),

cleaned AS (
    SELECT
        cst_id                      AS customer_id,
        cst_key                     AS customer_number,
        TRIM(cst_firstname)         AS first_name,
        TRIM(cst_lastname)          AS last_name,
        cst_create_date             AS create_date,

        CASE UPPER(TRIM(cst_martial_status))
            WHEN 'S' THEN 'Single'
            WHEN 'M' THEN 'Married'
            ELSE 'N/A'
        END AS marital_status,

        CASE UPPER(TRIM(cst_gender))
            WHEN 'M'      THEN 'Male'
            WHEN 'MALE'   THEN 'Male'
            WHEN 'F'      THEN 'Female'
            WHEN 'FEMALE' THEN 'Female'
            ELSE 'N/A'
        END AS gender

    FROM deduplicated
    WHERE row_num = 1
)

SELECT * FROM cleaned
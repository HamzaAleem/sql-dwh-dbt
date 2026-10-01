-- Cleans ERP customer supplement
-- Strips NAS- prefix from cid, nulls impossible birth dates, standardizes gender

WITH source AS (
    SELECT * FROM {{ source('bronze_erp', 'erp_cust_az12') }}
),

cleaned AS (
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
            ELSE cid
        END AS customer_number,

        CASE
            WHEN bdate > GETDATE()    THEN NULL
            WHEN bdate < '1924-01-01' THEN NULL
            ELSE bdate
        END AS birthdate,

        CASE UPPER(TRIM(gen))
            WHEN 'M'      THEN 'Male'
            WHEN 'MALE'   THEN 'Male'
            WHEN 'F'      THEN 'Female'
            WHEN 'FEMALE' THEN 'Female'
            ELSE 'N/A'
        END AS gender

    FROM source
)

SELECT * FROM cleaned
-- Cleans CRM sales transactions
-- Converts INT dates to DATE, fixes sales/price inconsistencies

WITH source AS (
    SELECT * FROM {{ source('bronze_crm', 'crm_sales_details') }}
),

date_converted AS (
    SELECT
        sls_ord_num     AS order_number,
        sls_prd_key     AS product_number,
        sls_cust_id     AS customer_id,
        sls_quantity    AS quantity,
        sls_price       AS raw_price,
        sls_sales       AS raw_sales,

        CASE
            WHEN sls_order_dt = 0
              OR sls_order_dt IS NULL
              OR LEN(CAST(sls_order_dt AS VARCHAR)) != 8
            THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
        END AS order_date,

        CASE
            WHEN sls_ship_dt = 0
              OR sls_ship_dt IS NULL
              OR LEN(CAST(sls_ship_dt AS VARCHAR)) != 8
            THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
        END AS ship_date,

        CASE
            WHEN sls_due_dt = 0
              OR sls_due_dt IS NULL
              OR LEN(CAST(sls_due_dt AS VARCHAR)) != 8
            THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
        END AS due_date

    FROM source
),

sales_fixed AS (
    SELECT
        order_number,
        product_number,
        customer_id,
        order_date,
        ship_date,
        due_date,
        quantity,

        -- Recalculate sales where it doesn't match qty x price
        CASE
            WHEN raw_sales IS NULL
              OR raw_sales <= 0
              OR raw_sales != quantity * ABS(raw_price)
            THEN quantity * ABS(raw_price)
            ELSE raw_sales
        END AS sales_amount,

        -- Fix price using already-corrected sales value
        CASE
            WHEN raw_price IS NULL OR raw_price <= 0
            THEN (
                CASE
                    WHEN raw_sales IS NULL
                      OR raw_sales <= 0
                      OR raw_sales != quantity * ABS(raw_price)
                    THEN quantity * ABS(raw_price)
                    ELSE raw_sales
                END
            ) / NULLIF(quantity, 0)
            ELSE raw_price
        END AS unit_price

    FROM date_converted
)

SELECT * FROM sales_fixed
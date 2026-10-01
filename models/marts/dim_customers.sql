-- Dimension: customers
-- Joins CRM customer base with ERP birthdate/gender supplement and location
-- CRM gender takes priority over ERP gender when both exist

WITH crm_customers AS (
    SELECT * FROM {{ ref('stg_crm_cust_info') }}
),

erp_customers AS (
    SELECT * FROM {{ ref('stg_erp_cust_az12') }}
),

erp_locations AS (
    SELECT * FROM {{ ref('stg_erp_loc_a101') }}
),

joined AS (
    SELECT
        c.customer_id,
        c.customer_number,
        c.first_name,
        c.last_name,
        c.marital_status,
        c.create_date,

        CASE
            WHEN c.gender != 'N/A' THEN c.gender
            ELSE ISNULL(e.gender, 'N/A')
        END                          AS gender,

        e.birthdate,
        ISNULL(l.country, 'N/A')    AS country

    FROM crm_customers c
    LEFT JOIN erp_customers e ON c.customer_number = e.customer_number
    LEFT JOIN erp_locations l ON c.customer_number = l.customer_number
)

SELECT * FROM joined
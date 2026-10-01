-- Dimension: products
-- Joins CRM product info with ERP category data
-- Filtered to current products only (end_date IS NULL = active version)

WITH products AS (
    SELECT * FROM {{ ref('stg_crm_prd_info') }}
),

categories AS (
    SELECT * FROM {{ ref('stg_erp_px_cat_g1v2') }}
),

joined AS (
    SELECT
        p.product_id,
        p.product_number,
        p.product_name,
        p.product_cost,
        p.product_line,
        p.start_date,
        c.category,
        c.subcategory,
        c.maintenance

    FROM products p
    LEFT JOIN categories c ON p.category_id = c.category_id
    WHERE p.end_date IS NULL
)

SELECT * FROM joined
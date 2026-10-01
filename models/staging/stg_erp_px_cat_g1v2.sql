-- Cleans ERP product categories
-- Trims whitespace only — no structural issues in source

WITH source AS (
    SELECT * FROM {{ source('bronze_erp', 'erp_px_cat_g1v2') }}
)

SELECT
    TRIM(id)          AS category_id,
    TRIM(cat)         AS category,
    TRIM(subcat)      AS subcategory,
    TRIM(maintenance) AS maintenance

FROM source
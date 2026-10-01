-- Fact: sales transactions
-- Looks up customer_id and product_number from dims to create clean joins
-- No surrogate key generation here — using natural keys for reliability

WITH sales AS (
    SELECT * FROM {{ ref('stg_crm_sales_details') }}
),

customers AS (
    SELECT customer_id, customer_number
    FROM {{ ref('dim_customers') }}
),

products AS (
    SELECT product_id, product_number
    FROM {{ ref('dim_products') }}
)

SELECT
    c.customer_id       AS customer_key,
    p.product_id        AS product_key,
    s.order_date,
    s.ship_date,
    s.due_date,
    s.order_number,
    s.quantity,
    s.unit_price,
    s.sales_amount

FROM sales s
LEFT JOIN customers c ON s.customer_id     = c.customer_id
LEFT JOIN products  p ON s.product_number  = p.product_number
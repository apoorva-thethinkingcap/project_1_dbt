WITH sales AS (
    SELECT
        sales_id,
        product_sk,
        customer_sk,
        unit_price * quantity AS calculated_gross_amount,
        gross_amount,
        payment_method
    FROM
        `dbt_project`.`bronze`.`bronze_sales`
)
, products AS (
    SELECT
        product_sk,
        category
    FROM
        `dbt_project`.`bronze`.`bronze_product`
)
, customer AS (
    SELECT
        customer_sk,
        gender
    FROM
        `dbt_project`.`bronze`.`bronze_customer`
)
, joined_query AS (
    SELECT
        s.sales_id,
        s.gross_amount,
        -- s.calculated_gross_amount,
        s.payment_method,
        p.category,
        c.gender
    FROM sales s
    JOIN products p ON s.product_sk = p.product_sk
    JOIN customer c ON s.customer_sk = c.customer_sk 
)
SELECT
    category,
    gender,
    SUM(gross_amount) AS total_sales
FROM joined_query
GROUP BY
    category,
    gender
ORDER BY
    total_sales DESC
SELECT * 
FROM portfolio..df_orders 

ALTER TABLE portfolio..df_orders
DROP COLUMN order_Date2

-- find top 10 highest revenue generating products
SELECT top 10 product_id, CAST(ROUND(SUM(sales_price), 2) AS DECIMAL(18, 3)) AS sales
FROM portfolio..df_orders
group by product_id
order by sales desc


--find top 5 highest selling products in each region
with cte as(
SELECT region, product_id, CAST(ROUND(SUM(sales_price), 2) AS DECIMAL(18, 3)) AS sales
FROM portfolio..df_orders
group by region,product_id)
select * ,
ROW_NUMBER() over(partition by region order by sales desc) as rn
from cte


--find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year, 
        MONTH(order_date) AS order_month, 
        SUM(sales_price) AS sales
    FROM portfolio..df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;


-- 6. Finding the Month with Highest Sales for Each Category
WITH cte AS (
    SELECT 
        category,
        FORMAT(order_date, 'yyyyMM') AS order_year_month,
        SUM(sales_price) AS sales
    FROM portfolio..df_orders
    GROUP BY category, FORMAT(order_date, 'yyyyMM')
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;


-- 7. Finding Which Sub-Category Had the Highest Growth by Profit in 2023 Compared to 2022
WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sales_price) AS sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT TOP 1 
    *,
    (sales_2023 - sales_2022) AS profit_growth
FROM cte2
ORDER BY profit_growth DESC;

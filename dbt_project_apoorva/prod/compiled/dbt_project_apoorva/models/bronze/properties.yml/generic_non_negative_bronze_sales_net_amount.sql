

SELECT
    *
FROM
    `dbt_project`.`bronze`.`bronze_sales`
WHERE
    net_amount < 0 


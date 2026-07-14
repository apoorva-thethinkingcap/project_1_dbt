

SELECT
    *
FROM
    `dbt_project`.`bronze`.`bronze_sales`
WHERE
    gross_amount < 0 


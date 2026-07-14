
  
  
  create or replace view `dbt_project`.`bronze`.`bronze_sales`
  
  as (
    -- Takes precedence over both properties.yml and dbt_project.yml

SELECT
    *
FROM
    `dbt_project`.`source`.`fact_sales`
  )

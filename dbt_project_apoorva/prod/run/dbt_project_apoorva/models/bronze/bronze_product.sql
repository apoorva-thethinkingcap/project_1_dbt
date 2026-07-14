
  
  
  create or replace view `dbt_project`.`bronze`.`bronze_product`
  
  as (
    SELECT
    *
FROM
    `dbt_project`.`source`.`dim_product`
  )

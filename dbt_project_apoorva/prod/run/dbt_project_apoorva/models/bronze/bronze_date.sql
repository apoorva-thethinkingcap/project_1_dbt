
  
  
  create or replace view `dbt_project`.`bronze`.`bronze_date`
  
  as (
    SELECT
    *
FROM
    `dbt_project`.`source`.`dim_date`
  )

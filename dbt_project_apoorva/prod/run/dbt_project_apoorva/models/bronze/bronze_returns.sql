
  
    
        create or replace table `dbt_project`.`bronze`.`bronze_returns`
      
      
  using delta
      
      
      
      
      
      
      
      as
      SELECT
    *
FROM
    `dbt_project`.`source`.`fact_returns`
  
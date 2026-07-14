
  
    
        create or replace table `dbt_project`.`bronze`.`bronze_store`
      
      
  using delta
      
      
      
      
      
      
      
      as
      SELECT
    *
FROM
    `dbt_project`.`source`.`dim_store`
  
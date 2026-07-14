
  
    
        create or replace table `dbt_project`.`bronze`.`bronze_customer`
      
      
  using delta
      
      
      
      
      
      
      
      as
      SELECT
    *
FROM
    `dbt_project`.`source`.`dim_customer`
  
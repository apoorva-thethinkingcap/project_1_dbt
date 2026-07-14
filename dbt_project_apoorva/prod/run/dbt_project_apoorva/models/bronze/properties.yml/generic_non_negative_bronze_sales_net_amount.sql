
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

SELECT
    *
FROM
    `dbt_project`.`bronze`.`bronze_sales`
WHERE
    net_amount < 0 


  
  
      
    ) dbt_internal_test
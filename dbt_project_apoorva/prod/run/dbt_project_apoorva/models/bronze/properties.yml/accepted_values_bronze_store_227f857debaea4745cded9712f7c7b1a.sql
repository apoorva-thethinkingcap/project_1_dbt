
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        store_name as value_field,
        count(*) as n_records

    from `dbt_project`.`bronze`.`bronze_store`
    group by store_name

)

select *
from all_values
where value_field not in (
    'MegaMart Manhattan','MegaMart Brooklyn','MegaMart San Jose','MegaMart Toronto','MegaMart Austin'
)



  
  
      
    ) dbt_internal_test
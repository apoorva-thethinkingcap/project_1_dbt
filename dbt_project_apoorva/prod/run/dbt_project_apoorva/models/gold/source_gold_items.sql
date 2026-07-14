
  
    
        create or replace table `dbt_project`.`gold`.`source_gold_items`
      
      
  using delta
      
      
      
      
      
      
      
      as
      WITH dedupe_query AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY id ORDER BY updateDate DESC) as deduplication_id
    FROM `dbt_project`.`source`.`items`
)
SELECT
    id, name, category, updateDate
FROM dedupe_query
WHERE deduplication_id = 1
  
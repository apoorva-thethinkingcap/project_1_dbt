{{config(materialized='view')}}     -- Takes precedence over both properties.yml and dbt_project.yml

SELECT
    *
FROM
    {{source('source','fact_sales')}}
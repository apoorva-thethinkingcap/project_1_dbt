WITH dedupe_query AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY id ORDER BY updateDate DESC) as deduplication_id
    FROM {{ source('source', 'items') }}
)
SELECT
    id, name, category, updateDate
FROM dedupe_query
WHERE deduplication_id = 1

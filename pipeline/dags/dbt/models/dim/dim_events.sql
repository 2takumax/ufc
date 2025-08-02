{{ config(
    materialized='table'
) }}

WITH events AS (
    SELECT DISTINCT
        event_name,
        event_date,
        event_location,
        event_url
    FROM {{ ref('src_event_details') }}
),

parsed_events AS (
    SELECT
        event_name,
        TRY_TO_DATE(event_date, 'Month DD, YYYY') as event_date,
        event_location,
        SPLIT_PART(event_location, ',', -1) as country,
        SPLIT_PART(event_location, ',', 1) as city,
        event_url,
        CASE 
            WHEN event_name LIKE 'UFC %' AND NOT CONTAINS(event_name, ':') 
            THEN TRY_TO_NUMBER(REGEXP_SUBSTR(event_name, 'UFC ([0-9]+)', 1, 1, 'e', 1))
            ELSE NULL
        END as event_number,
        CASE
            WHEN CONTAINS(LOWER(event_name), 'fight night') THEN 'Fight Night'
            WHEN event_number IS NOT NULL THEN 'Numbered Event'
            ELSE 'Special Event'
        END as event_type
    FROM events
)

SELECT
    event_name,
    event_date,
    YEAR(event_date) as event_year,
    MONTH(event_date) as event_month,
    event_location,
    city,
    country,
    event_url,
    event_number,
    event_type,
    ROW_NUMBER() OVER (ORDER BY event_date DESC, event_name) as event_id
FROM parsed_events
WHERE event_date IS NOT NULL
{{ config(
    materialized='ephemeral'
) }}

SELECT
    EVENT as event_name,
    URL as event_url,
    DATE as event_date,
    LOCATION as event_location
FROM {{ source('ufc', 'event_details') }}
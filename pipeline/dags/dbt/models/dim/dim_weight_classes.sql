{{ config(
    materialized='table'
) }}

WITH weight_class_mapping AS (
    SELECT
        'Strawweight' as weight_class_name,
        'Women''s Strawweight' as full_name,
        115 as weight_limit_lbs,
        1 as sort_order,
        'W' as gender
    UNION ALL
    SELECT 'Flyweight', 'Flyweight', 125, 2, 'M'
    UNION ALL
    SELECT 'Women''s Flyweight', 'Women''s Flyweight', 125, 3, 'W'
    UNION ALL
    SELECT 'Bantamweight', 'Bantamweight', 135, 4, 'M'
    UNION ALL
    SELECT 'Women''s Bantamweight', 'Women''s Bantamweight', 135, 5, 'W'
    UNION ALL
    SELECT 'Featherweight', 'Featherweight', 145, 6, 'M'
    UNION ALL
    SELECT 'Women''s Featherweight', 'Women''s Featherweight', 145, 7, 'W'
    UNION ALL
    SELECT 'Lightweight', 'Lightweight', 155, 8, 'M'
    UNION ALL
    SELECT 'Welterweight', 'Welterweight', 170, 9, 'M'
    UNION ALL
    SELECT 'Middleweight', 'Middleweight', 185, 10, 'M'
    UNION ALL
    SELECT 'Light Heavyweight', 'Light Heavyweight', 205, 11, 'M'
    UNION ALL
    SELECT 'Heavyweight', 'Heavyweight', 265, 12, 'M'
    UNION ALL
    SELECT 'Catch Weight', 'Catch Weight', NULL, 13, 'X'
    UNION ALL
    SELECT 'Open Weight', 'Open Weight', NULL, 14, 'X'
),

all_weight_classes AS (
    SELECT DISTINCT weight_class
    FROM {{ ref('src_fight_results') }}
)

SELECT
    wc.weight_class,
    COALESCE(wcm.full_name, wc.weight_class) as weight_class_full_name,
    wcm.weight_limit_lbs,
    ROUND(wcm.weight_limit_lbs * 0.453592, 1) as weight_limit_kg,
    wcm.gender,
    COALESCE(wcm.sort_order, 99) as sort_order,
    ROW_NUMBER() OVER (ORDER BY COALESCE(wcm.sort_order, 99), wc.weight_class) as weight_class_id
FROM all_weight_classes wc
LEFT JOIN weight_class_mapping wcm
    ON LOWER(TRIM(wc.weight_class)) = LOWER(wcm.weight_class_name)
    OR LOWER(TRIM(wc.weight_class)) = LOWER(wcm.full_name)
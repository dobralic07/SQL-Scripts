WITH months AS (
    SELECT generate_series(
        DATE_TRUNC('month', MIN(start)),
        DATE_TRUNC('month', CURRENT_DATE),
        '1 month'
    )::date AS month_start
    FROM customer_programs_placement
    WHERE site_id = '2384'
    AND placement_type IN (20, 30)
),
active_placements AS (
    SELECT
        id,
        month_start,
        CASE
            WHEN placement_type = 20 THEN 'Lecture Series'
            WHEN placement_type = 30 THEN 'Next Best Video'
            ELSE 'Other'
        END AS placement_name
    FROM months
    JOIN customer_programs_placement ON
        months.month_start BETWEEN DATE_TRUNC('month', start) AND DATE_TRUNC('month', "end")
    WHERE site_id = '2384'
        AND placement_type IN (20, 30)
)

SELECT
    month_start,
    placement_name,
    COUNT(DISTINCT id) AS active_placements
FROM active_placements
GROUP BY month_start, placement_name
ORDER BY month_start, placement_name;

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
        customer_programs_placement.id AS placement_id,
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
),
videos_per_placement AS (
    SELECT
        active_placements.month_start,
        active_placements.placement_name,
        COUNT(DISTINCT customer_programs_asset.video_id) AS video_count
    FROM active_placements
    JOIN customer_programs_asset ON active_placements.placement_id = customer_programs_asset.placement_id
    GROUP BY active_placements.month_start, active_placements.placement_name
)

SELECT
    month_start,
    placement_name,
    SUM(video_count) AS active_videos
FROM videos_per_placement
GROUP BY month_start, placement_name
ORDER BY month_start, placement_name;
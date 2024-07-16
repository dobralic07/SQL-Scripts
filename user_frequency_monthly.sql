---monthly breakdown
SELECT
    date(date_trunc('month', v.when AT TIME ZONE 'America/Los_Angeles')) AS month,
    npi_record_id,
    COUNT(DISTINCT date(v.when AT TIME ZONE 'America/Los_Angeles')) AS num_days,
    COUNT(DISTINCT object_id) AS distinct_object_id,
    ROUND(SUM(viewed_time) / 3600000.0, 2) AS total_viewed_time_hours,
    MAX(date_joined) AS date_joined
FROM
    tracking_viewed v
JOIN
    auth_user au ON au.id = v.user_id AND NOT is_staff
JOIN
    accounts_profile p ON p.user_id = au.id AND site_id = 2 AND npi_record_id IS NOT NULL
WHERE
    content_type_id = 20 AND viewed_time > 0
GROUP BY
    1, 2;
-- quarterly breakdown

SELECT
    EXTRACT(YEAR FROM v.when AT TIME ZONE 'America/Los_Angeles') AS year,
    CASE
        WHEN EXTRACT(MONTH FROM v.when AT TIME ZONE 'America/Los_Angeles') IN (4, 5, 6) THEN 'Q1'
        WHEN EXTRACT(MONTH FROM v.when AT TIME ZONE 'America/Los_Angeles') IN (7, 8, 9) THEN 'Q2'
        WHEN EXTRACT(MONTH FROM v.when AT TIME ZONE 'America/Los_Angeles') IN (10, 11, 12) THEN 'Q3'
        ELSE 'Q4'
    END AS fiscal_quarter,
    npi_record_id,
    p.site_id,
    COUNT(DISTINCT date(v.when AT TIME ZONE 'America/Los_Angeles')) AS num_days,
    COUNT(DISTINCT object_id) AS distinct_object_id,
    ROUND(SUM(viewed_time) / 3600000.0, 2) AS total_viewed_time_hours,
    MAX(date_joined) AS date_joined
FROM
    tracking_viewed v
JOIN
    auth_user au ON au.id = v.user_id AND NOT is_staff
JOIN
    accounts_profile p ON p.user_id = au.id AND p.site_id IN (2, 2384, 1) AND npi_record_id IS NOT NULL
WHERE
    content_type_id = 20 AND viewed_time > 0
GROUP BY
    year, fiscal_quarter, npi_record_id, p.site_id;




















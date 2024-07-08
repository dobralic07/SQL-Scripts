WITH earliest_date_joined AS (
    SELECT
        npi_record,
        MIN(date_joined) AS earliest_date_joined
    FROM
        analytics_denormprofile
    GROUP BY
        npi_record
)
SELECT
    date_trunc('month', v.when AT TIME ZONE 'America/Los_Angeles') AS record_date,
    p.npi_record_id,
    COUNT(DISTINCT CASE
                      WHEN v.viewed_time > 0
                      THEN DATE(v.when AT TIME ZONE 'America/Los_Angeles')
                      ELSE NULL
                   END) AS num_days,
    COUNT(DISTINCT CASE
                      WHEN v.viewed_time > 0
                      THEN v.object_id
                      ELSE NULL
                   END) AS distinct_object_ids,
    COUNT(DISTINCT l2.term_id) AS distinct_term_ids,
    ROUND(SUM(v.viewed_time) / 3600000.0, 2) AS total_viewed_time_hours,
    edj.earliest_date_joined AS date_joined
FROM
    tracking_viewed v
JOIN
    auth_user au ON au.id = v.user_id AND NOT au.is_staff
JOIN
    accounts_profile p ON p.user_id = au.id AND p.site_id = 2384 AND p.npi_record_id IS NOT NULL
JOIN
    earliest_date_joined edj ON edj.npi_record = p.npi_record_id
LEFT JOIN
    accounts_l2contentsubscription l2 ON l2.profile_id = p.id
WHERE
    v.content_type_id = 20
    AND v.when >= '2019-01-01'
GROUP BY
    1, 2, edj.earliest_date_joined
ORDER BY
    1, 2;

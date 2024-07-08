WITH user_activity AS (
    SELECT
        v.user_id,
        date_trunc('month', v.when AT TIME ZONE 'America/Los_Angeles') AS activity_month,
        COUNT(DISTINCT date(v.when AT TIME ZONE 'America/Los_Angeles')) AS active_days_per_month
    FROM tracking_viewed v
    JOIN auth_user au ON au.id = v.user_id AND NOT au.is_staff
    JOIN accounts_profile p ON p.user_id = au.id AND p.npi_record_id IS NOT NULL
    WHERE v.content_type_id = 20 AND v.viewed_time > 0 AND v.when >= '2024-01-01'
    GROUP BY v.user_id, activity_month
),
user_details AS (
    SELECT
        au.id AS user_id,
        p.npi_record_id,
        au.email,
        au.first_name,
        au.last_name,
        p.affiliation,
        p.last_opened_email::date
    FROM auth_user au
    JOIN accounts_profile p ON p.user_id = au.id
    JOIN accounts_l2contentsubscription l2 ON l2.profile_id = p.id AND l2.term_id = '2112'
    WHERE p.npi_record_id IS NOT NULL AND NOT au.is_staff
)
SELECT
    ud.npi_record_id,
    ud.email,
    ud.first_name,
    ud.last_name,
    ud.affiliation,
    ud.last_opened_email,
    AVG(ua.active_days_per_month) AS avg_active_days_per_month
FROM user_activity ua
JOIN user_details ud ON ua.user_id = ud.user_id
GROUP BY
    ud.npi_record_id,
    ud.email,
    ud.first_name,
    ud.last_name,
    ud.affiliation,
    ud.last_opened_email
ORDER BY avg_active_days_per_month DESC;
Whitelist average conversion rate
WITH Whitelists AS (
    SELECT
        date(aw.added) as added_date,
        aw.source,
        aw.group_id,
        g.name,
        count(distinct aw.id) as num_whitelists,
        count(distinct aw.npi_record_id) as num_whitelist_npis
    FROM
        accounts_whitelist aw
        JOIN auth_group g ON aw.group_id = g.id
    WHERE
        aw.npi_record_id IS NOT NULL
        AND aw.site_id = 2
        AND date(aw.added) >= '2022-01-01'
    GROUP BY
        date(aw.added),
        aw.group_id,
        g.name,
        aw.source
),
Users AS (
    SELECT
        date(aw.added) as added_date,
        aw.source,
        aw.group_id,
        count(distinct u.id) as num_users
    FROM
        accounts_whitelist aw
        JOIN auth_user u ON aw.email = u.email
        AND u.date_joined >= aw.added
    WHERE
        aw.npi_record_id IS NOT NULL
        AND aw.site_id = 2951
        AND date(aw.added) >= '2022-01-01'
    GROUP BY
        date(aw.added),
        aw.group_id,
        aw.source
),
NPIs AS (
    SELECT
        date(aw.added) as added_date,
        aw.source,
        aw.group_id,
        count(distinct ap.npi_record_id) as num_npis
    FROM
        accounts_whitelist aw
        JOIN auth_user u ON aw.email = u.email
            AND u.date_joined >= aw.added
        JOIN accounts_profile ap ON u.id = ap.user_id
            AND ap.site_id = 2951
    WHERE
        aw.npi_record_id IS NOT NULL
        AND aw.site_id = 2951
        AND date(aw.added) >= '2022-01-01'
    GROUP BY
        date(aw.added),
        aw.group_id,
        aw.source
)
SELECT
    w.added_date,
    w.source,
    w.group_id,
    w.name,
    w.num_whitelists,
    w.num_whitelist_npis,
    COALESCE(u.num_users, 0) as num_users,
    COALESCE(n.num_npis, 0) as num_npis
FROM
    Whitelists w
    LEFT JOIN Users u ON w.added_date = u.added_date AND w.group_id = u.group_id
    LEFT JOIN NPIs n ON w.added_date = n.added_date AND w.group_id = n.group_id
ORDER BY
    w.added_date DESC;
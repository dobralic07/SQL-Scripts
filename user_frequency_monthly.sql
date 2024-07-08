---monthly breakdown
select date(date_trunc('month', v.when at time zone 'America/Los_Angeles'))
    , npi_record_id
    , count(distinct date(v.when at time zone 'America/Los_Angeles')) as num_days
from tracking_viewed v
join auth_user au on au.id = v.user_id and not is_staff
join accounts_profile p on p.user_id = au.id and site_id = 2384 and npi_record_id is not null
where content_type_id = 20 and viewed_time > 0
group by 1,2
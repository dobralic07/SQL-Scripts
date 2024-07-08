with pla as
  (select pl.id,
          pl.title as placement,
          video_id ,
          coalesce(a.start, pl.start) as start, coalesce(a.end, pl.end) as end ,
                                                placement_type,
                                                site_id,
                                                b.target_list_id as tlid
   from customer_programs_placement pl
   join customer_programs_program pr on pr.id=pl.program_id
   join customer_programs_brand b on b.id=pr.brand_id
   join customer_programs_asset a on a.placement_id = pl.id
   and video_id is not null
   where pl.end > '2020-01-01'
     and pl.start <= now()),
     pl as
  (select distinct id,
                   placement,
                   min(pla.start) as start, min(pla.end) as end,
                                            placement_type,
                                            site_id,
                                            tlid
   from pla
   group by 1,
            2,
            5,
            6,
            7),
     tl as
  (select distinct source_id as tlid,
                   npi
   from listmatch_candidate
   where npi > 99
     and source_id in
       (select distinct tlid
        from pl
        union select distinct source_id
        from customer_programs_placementsource
        where placement_id in
            (select distinct id
             from pl) ) ),
     v as
  (select v.id,
          v.when,
          v.user_id,
          p.site_id,
          npi_record_id as npi,
          v.object_id as video_id,
          v.viewed_time ,
          pla.id as placement_id ,
          case
              when category = 16 then 'bulk'
              when category = 17 then 'bet'
              when category = 21 then 'autoplay'
              else 'other'
          end as channel -- TLUQs are incremental if rownum=1
 ,
          row_number() over (partition by pla.id,
                                          p.npi_record_id
                             order by v.when) as rownum
   from tracking_viewed v
   join auth_user au on au.id = v.user_id
   and not is_staff
   join accounts_profile p on p.user_id = au.id
   and site_id = 2384
   and npi_record_id is not null
   join pla on pla.video_id = v.object_id
   and date(v.when at time zone 'America/Los_Angeles') between pla.start and pla.end
   left join customer_programs_placementsource ps on ps.placement_id = pla.id
   and date(v.when at time zone 'America/Los_Angeles') between ps.start_date and ps.end_date
   join tl on tl.npi = npi_record_id
   and tl.tlid = coalesce(ps.source_id, pla.tlid)
   join tracking_viewedreferrer vr on vr.viewed_id = v.id
   where v.content_type_id = 20
     and viewed_time > 0
     and date(v.when at time zone 'America/Los_Angeles') >=
       (select min
          (start)
        from pla) )
select date(date_trunc('week', v.when)) as mo,
       channel ,
       count(1) as TL_starts ,
       count(distinct case
                          when rownum = 1 then npi
                      end) as TLUQ
from v
group by 1,
         2
Order by 1 DESC;
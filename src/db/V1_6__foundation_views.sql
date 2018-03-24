create or replace view api.identity as (
  select
    i.id, i.tenant_id,
    im.member_id,
    m.name, m.display_name, m.mrn, m.slug, m.tenant_oid
  from iam.identity_member im
    inner join iam.identity i on im.identity_id = i.id
    inner join membership.member m on m.id = im.member_id
);
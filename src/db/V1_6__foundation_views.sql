create or replace view api.identity as (
  select
    i.id, i.tenant_id,
    im.member_id,
    m.name, m.display_name, m.mrn, m.slug, m.tenant_oid
  from iam.identity i
    inner join iam.identity_member im on im.identity_id = i.id
    inner join membership.member m on m.id = im.member_id
);

insert into platform.tenant (id, name, slug) values
  (1, 'System', 'system'),
  (1000, 'Veridian Dynamics', 'veridian'),
  (1001, 'Wayne Enterprises', 'wayne');

select setval('platform.tenant_id_seq', 1002);


select api.register_identity(1, 'root', 'changeme');
select api.authenticate(1, 'root', 'changeme');




with md as (
  INSERT INTO membership.member (tenant_id, name, display_name, slug, tenant_oid, mrn, contact_email)
  values (
    1001,
    'David Welch',
    'Welchy',
    'welch',
    '1',
    1,
    'david@davidwelch.co'
  )
  returning id as member_id, tenant_id, slug
), i as (
    SELECT api.register_identity(md.tenant_id, md.slug, 'changeme') as identity_id
    FROM md
)
insert into iam.identity_member (identity_id, member_id)
  select i.identity_id, md.member_id
  from i
    cross join md
RETURNING *;

-- verify we get anonymous
select api.principal();

-- verify we get authenticated
-- ROLLBACK;
START TRANSACTION;
set local jwt.claims.identity_id to 1;
set local jwt.claims.username to 'root';
select * from api.principal();
COMMIT;



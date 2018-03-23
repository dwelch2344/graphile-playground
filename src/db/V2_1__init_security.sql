
alter role system_postgraphile with SUPERUSER;

-- expose the public API
grant usage on schema api to system_anonymous, system_authenticated;
grant usage on type api.jwt_token to system_anonymous, system_authenticated;
grant usage on type api.principal to system_anonymous, system_authenticated;
grant usage on type api.permission to system_anonymous, system_authenticated;

grant execute on function api.authenticate(BIGINT, TEXT, TEXT) to system_anonymous, system_authenticated;
grant execute on function api.principal() to system_anonymous, system_authenticated;


revoke all PRIVILEGES on all tables in schema api FROM system_anonymous;

grant usage on schema api to system_authenticated;
grant usage on schema iam to system_authenticated;
grant usage on schema membership to system_authenticated;
grant usage on schema platform to system_authenticated;


grant all PRIVILEGES on all tables in schema api to system_authenticated;
grant all PRIVILEGES on all tables in schema iam to system_authenticated;
grant all PRIVILEGES on all tables in schema membership to system_authenticated;
grant all PRIVILEGES on all tables in schema platform to system_authenticated;








-- TODO: row-level security here
/*
create policy update_person on forum_example.person for update to forum_example_person
  using (id = current_setting('jwt.claims.person_id')::integer);

create policy delete_person on forum_example.person for delete to forum_example_person
  using (id = current_setting('jwt.claims.person_id')::integer);
 */
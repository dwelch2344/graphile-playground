CREATE ROLE system_postgraphile LOGIN PASSWORD 'changeme';

CREATE ROLE system_anonymous;
GRANT system_anonymous TO system_postgraphile;


CREATE ROLE system_authenticated;
GRANT system_authenticated TO system_postgraphile;

create schema api;

CREATE TYPE api.PERMISSION AS ENUM (
  'admin', 'superadmin'
);

-- DROP TYPE IF EXISTS api.JWT_TOKEN CASCADE;
CREATE TYPE api.JWT_TOKEN AS (
  role         TEXT,
  display_name VARCHAR,
  username     VARCHAR,
  identity_id  BIGINT,
  tenant_id    BIGINT,
  permissions  api.PERMISSION []
);

CREATE TYPE api.PRINCIPAL AS (
  jwt          api.JWT_TOKEN,
  role         TEXT,
  display_name VARCHAR,
  username     VARCHAR,
  identity_id  BIGINT,
  tenant_id    BIGINT,
  permissions  api.PERMISSION []
);


CREATE OR REPLACE FUNCTION api.authenticate(
  p_tenant_id BIGINT,
  p_username  TEXT,
  p_password  TEXT
)
  RETURNS api.JWT_TOKEN AS $$

DECLARE
  v_creds iam.IDENTITY_CREDENTIAL;

BEGIN

  raise notice 'running auth';

  SELECT c.*
  FROM iam.identity_credential AS c
    INNER JOIN iam.identity i ON i.id = c.identity_id
  WHERE c.username = p_username AND i.tenant_id = p_tenant_id
  INTO v_creds;

  IF v_creds.encrypted_password = crypt(p_password, v_creds.encrypted_password)
  THEN
    -- TODO actually load permissions? actually show display_name as param 2
    RETURN ('system_authenticated', v_creds.username, v_creds.username, v_creds.identity_id, p_tenant_id, ARRAY [] :: api.PERMISSION []) :: api.JWT_TOKEN;
  ELSE
    RETURN NULL;
  END IF;
END;
$$
LANGUAGE plpgsql
STRICT
SECURITY DEFINER;

COMMENT ON FUNCTION api.authenticate(BIGINT, TEXT,
                                     TEXT) IS 'Creates a JWT token that will securely identify a principal and give them certain permissions.';


CREATE OR REPLACE FUNCTION api.principal()
  RETURNS api.PRINCIPAL AS $$

DECLARE
  v_result api.JWT_TOKEN;
  v_identity_id BIGINT;
  v_username VARCHAR;
BEGIN

  raise notice 'Begin Auth';

  v_identity_id := current_setting('jwt.claims.identity_id') :: BIGINT;
  v_username := current_setting('jwt.claims.username') :: VARCHAR;


  raise notice 'Attempting: % %', v_identity_id, v_username;

  -- TODO: actually just pull it from the current_settings (so we don't hammer the DB)
  SELECT
    'system_authenticated', c.username, c.username, c.identity_id, i.tenant_id, ARRAY [] :: api.PERMISSION []
  FROM iam.identity_credential c
    INNER JOIN iam.identity i on i.id = c.identity_id
  WHERE c.identity_id = v_identity_id AND c.username = v_username
  LIMIT 1
  INTO v_result;

  raise notice 'Got this: % ', v_result;
  return (v_result, 'system_authenticated', v_result.display_name, v_result.display_name, v_result.identity_id, v_result.tenant_id, v_result.permissions) :: api.PRINCIPAL;

exception when others then
  IF SQLSTATE != '42704' THEN
    raise notice 'Could not fetch principal: % – %', SQLERRM, SQLSTATE;
  END IF;
  return (null, 'system_anonymous', null, null, null, null, ARRAY [] :: api.PERMISSION []) :: api.PRINCIPAL;
END;
$$
LANGUAGE plpgsql
STABLE
SECURITY DEFINER;

COMMENT ON FUNCTION api.principal() IS 'Gets the current principal.';
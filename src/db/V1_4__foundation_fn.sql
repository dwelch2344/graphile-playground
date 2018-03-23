CREATE OR REPLACE FUNCTION api.register_identity(
  p_tenant_id BIGINT,
  p_username  VARCHAR,
  p_password  VARCHAR
) RETURNS INT AS $$

DECLARE
  v_id BIGINT;

BEGIN
  INSERT INTO iam.identity (tenant_id) VALUES
    (p_tenant_id)
  RETURNING id
    INTO v_id;

  INSERT INTO iam.identity_credential (identity_id, username, encrypted_password) VALUES
    (v_id, p_username, crypt(p_password, gen_salt('bf')));

  RETURN v_id;
END;
$$
LANGUAGE plpgsql STRICT SECURITY DEFINER;

COMMENT ON FUNCTION api.register_identity(BIGINT, VARCHAR, VARCHAR) IS
  'Creates a new credential ';
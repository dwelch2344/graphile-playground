-- DROP SCHEMA platform CASCADE ;
-- DROP SCHEMA membership CASCADE ;
-- DROP SCHEMA iam CASCADE ;

create extension if not exists "pgcrypto";

-- PLATFORM
CREATE SCHEMA IF NOT EXISTS platform;
CREATE TABLE IF NOT EXISTS platform.tenant (
  id   BIGSERIAL   NOT NULL PRIMARY KEY,
  name VARCHAR(60) NOT NULL,
  slug VARCHAR(20) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS platform.legal_locale (
  id   BIGSERIAL   NOT NULL PRIMARY KEY,
  code VARCHAR(3)  NOT NULL UNIQUE,
  name VARCHAR(60) NOT NULL
);


-- MEMBERSHIP


CREATE SCHEMA IF NOT EXISTS membership;
CREATE TABLE IF NOT EXISTS membership.member (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  tenant_id     BIGINT    NOT NULL REFERENCES platform.tenant (id),
  name          VARCHAR(60),
  display_name  VARCHAR(60),
  slug          VARCHAR(20),
  tenant_oid    VARCHAR NOT NULL,
  sponsor_oid   VARCHAR NULL,
  mrn           BIGINT,
  contact_email VARCHAR NOT NULL,
  UNIQUE (tenant_id, tenant_oid),
  UNIQUE (tenant_id, sponsor_oid)
);

ALTER TABLE membership.member
  ADD FOREIGN KEY (tenant_id, sponsor_oid)
  REFERENCES membership.member(tenant_id, tenant_oid);



-- IAM

CREATE SCHEMA IF NOT EXISTS iam;
CREATE TABLE IF NOT EXISTS iam.identity (
  id        BIGSERIAL NOT NULL PRIMARY KEY,
  tenant_id BIGINT    NOT NULL REFERENCES platform.tenant (id)
);

CREATE TABLE IF NOT EXISTS iam.identity_credential (
  id                 BIGSERIAL   NOT NULL PRIMARY KEY,
  identity_id        BIGINT      NOT NULL REFERENCES iam.identity (id),
  username           VARCHAR(60) NOT NULL,
  encrypted_password VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS iam.identity_member (
  id          BIGSERIAL NOT NULL PRIMARY KEY,
  identity_id BIGINT    NOT NULL REFERENCES iam.identity (id),
  member_id   BIGINT    NOT NULL REFERENCES membership.member (id)
);
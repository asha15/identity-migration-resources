ALTER TABLE IDN_SAML2_ASSERTION_STORE ADD ASSERTION BLOB
/

ALTER TABLE IDN_OAUTH_CONSUMER_APPS MODIFY CALLBACK_URL VARCHAR(2048)
/

ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN MODIFY CALLBACK_URL VARCHAR(2048)
/

ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE MODIFY CALLBACK_URL VARCHAR(2048)
/

CREATE TABLE IDN_AUTH_USER (
	USER_ID VARCHAR(255) NOT NULL,
	USER_NAME VARCHAR(255) NOT NULL,
	TENANT_ID INTEGER NOT NULL,
	DOMAIN_NAME VARCHAR(255) NOT NULL,
	IDP_ID INTEGER NOT NULL,
	PRIMARY KEY (USER_ID),
	CONSTRAINT USER_STORE_CONSTRAINT UNIQUE (USER_NAME, TENANT_ID, DOMAIN_NAME, IDP_ID)
)
/

CREATE TABLE IDN_AUTH_USER_SESSION_MAPPING (
	USER_ID VARCHAR(255) NOT NULL,
	SESSION_ID VARCHAR(255) NOT NULL,
	CONSTRAINT USER_SESSION_STORE_CONSTRAINT UNIQUE (USER_ID, SESSION_ID)
)
/

CREATE OR REPLACE PROCEDURE add_column_if_not_exists (query IN VARCHAR2, cleanup IN VARCHAR2)
  IS
BEGIN
  execute immediate query;
  execute immediate cleanup;
  dbms_output.put_line( 'created' );
exception WHEN OTHERS THEN
  dbms_output.put_line( 'skipped' );
END;
/

CALL add_column_if_not_exists('ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD IDP_ID INTEGER DEFAULT -1 NOT NULL','ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE MODIFY IDP_ID INTEGER DEFAULT NULL')
/

CALL add_column_if_not_exists('ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD IDP_ID INTEGER DEFAULT -1 NOT NULL', 'ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN MODIFY IDP_ID INTEGER DEFAULT NULL')
/

CALL add_column_if_not_exists('ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN_AUDIT ADD IDP_ID INTEGER DEFAULT -1 NOT NULL', 'ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN_AUDIT MODIFY IDP_ID INTEGER DEFAULT NULL')
/

DROP PROCEDURE add_column_if_not_exists
/

CREATE OR REPLACE PROCEDURE add_index_if_not_exists (query IN VARCHAR2)
  IS
BEGIN
  execute immediate query;
  dbms_output.put_line(query);
exception WHEN OTHERS THEN
  dbms_output.put_line( 'skipped' );
END;
/

CALL add_index_if_not_exists('CREATE INDEX IDX_USER_ID ON IDN_AUTH_USER_SESSION_MAPPING (USER_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_SESSION_ID ON IDN_AUTH_USER_SESSION_MAPPING (SESSION_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_OCA_UM_TID_UD_APN ON IDN_OAUTH_CONSUMER_APPS (USERNAME,TENANT_ID,USER_DOMAIN, APP_NAME)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_SPI_APP ON SP_INBOUND_AUTH(APP_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_IOP_TID_CK ON IDN_OIDC_PROPERTY(TENANT_ID,CONSUMER_KEY)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AT_AU_TID_UD_TS_CKID ON IDN_OAUTH2_ACCESS_TOKEN(AUTHZ_USER, TENANT_ID, USER_DOMAIN, TOKEN_STATE, CONSUMER_KEY_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AT_AT ON IDN_OAUTH2_ACCESS_TOKEN(ACCESS_TOKEN)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AT_AU_CKID_TS_UT ON IDN_OAUTH2_ACCESS_TOKEN(AUTHZ_USER, CONSUMER_KEY_ID, TOKEN_STATE, USER_TYPE)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AT_RTH ON IDN_OAUTH2_ACCESS_TOKEN(REFRESH_TOKEN_HASH)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AT_RT ON IDN_OAUTH2_ACCESS_TOKEN(REFRESH_TOKEN)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AC_CKID ON IDN_OAUTH2_AUTHORIZATION_CODE(CONSUMER_KEY_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AC_TID ON IDN_OAUTH2_AUTHORIZATION_CODE(TOKEN_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AC_AC_CKID ON IDN_OAUTH2_AUTHORIZATION_CODE(AUTHORIZATION_CODE, CONSUMER_KEY_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_SC_TID ON IDN_OAUTH2_SCOPE(TENANT_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_SC_N_TID ON IDN_OAUTH2_SCOPE(NAME, TENANT_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_SB_SCPID ON IDN_OAUTH2_SCOPE_BINDING(SCOPE_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_OROR_TID ON IDN_OIDC_REQ_OBJECT_REFERENCE(TOKEN_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_ATS_TID ON IDN_OAUTH2_ACCESS_TOKEN_SCOPE(TOKEN_ID)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AUTH_USER_UN_TID_DN ON IDN_AUTH_USER (USER_NAME, TENANT_ID, DOMAIN_NAME)')
/

CALL add_index_if_not_exists('CREATE INDEX IDX_AUTH_USER_DN_TOD ON IDN_AUTH_USER (DOMAIN_NAME, TENANT_ID)')
/

DROP PROCEDURE add_index_if_not_exists
/

CREATE OR REPLACE PROCEDURE add_idp_id_to_con_app_key
IS
  BEGIN
    declare
      column_count INTEGER;
    begin
      select count(*) INTO column_count
      from all_ind_columns
      where INDEX_OWNER IN (select user from dual)
        AND TABLE_NAME = 'IDN_OAUTH2_ACCESS_TOKEN'
        AND INDEX_NAME = 'CON_APP_KEY'
        AND COLUMN_NAME = 'TOKEN_ID';
      IF (column_count > 0)
      THEN
        execute immediate 'ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP CONSTRAINT CON_APP_KEY';
        execute immediate 'ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_ID, USER_DOMAIN, USER_TYPE, TOKEN_SCOPE_HASH, TOKEN_STATE, TOKEN_STATE_ID, IDP_ID)';
      END IF;
    end;
  END;
/

CALL add_idp_id_to_con_app_key()
/

DROP PROCEDURE add_idp_id_to_con_app_key
/

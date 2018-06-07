ALTER TABLE IDN_OAUTH_CONSUMER_APPS ADD ID_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600000
/
CREATE TABLE IDN_AUTH_TEMP_SESSION_STORE (
            SESSION_ID VARCHAR (100) NOT NULL,
            SESSION_TYPE VARCHAR(100) NOT NULL,
            OPERATION VARCHAR(10) NOT NULL,
            SESSION_OBJECT BLOB,
            TIME_CREATED NUMBER(19),
            TENANT_ID INTEGER DEFAULT -1,
            EXPIRY_TIME BIGINT,
            PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
)
/
CREATE TABLE SP_CLAIM_DIALECT (
	    	ID INTEGER,
	    	TENANT_ID INTEGER NOT NULL,
	    	SP_DIALECT VARCHAR (512) NOT NULL,
	   		APP_ID INTEGER NOT NULL,
        PRIMARY KEY (ID))
/
CREATE SEQUENCE SP_CLAIM_DIALECT_SEQ START WITH 1 INCREMENT BY 1 CACHE 20 ORDER
/
CREATE OR REPLACE TRIGGER SP_CLAIM_DIALECT_SEQ
            BEFORE INSERT
            ON SP_CLAIM_DIALECT
            REFERENCING NEW AS NEW
            FOR EACH ROW
               BEGIN
                   SELECT SP_CLAIM_DIALECT_SEQ.nextval INTO :NEW.ID FROM dual;
               END;
/
ALTER TABLE SP_CLAIM_DIALECT ADD CONSTRAINT DIALECTID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE
/
ALTER TABLE IDN_AUTH_SESSION_STORE ADD EXPIRY_TIME BIGINT;
/

CREATE TABLE IF NOT EXISTS IDN_FED_USER_TOTP_SECRET_KEY  (
            USER_ID VARCHAR (255) NOT NULL,
            SECRET_KEY VARCHAR(1024) NOT NULL,
            PRIMARY KEY (USER_ID)
)ENGINE NDB;

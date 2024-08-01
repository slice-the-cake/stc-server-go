-- Create "user" table
CREATE TABLE "public"."user" (
  "username" character varying(16) NOT NULL,
  "password_hash" bytea NOT NULL,
  "password_salt" bytea NOT NULL,
  PRIMARY KEY ("username") INCLUDE ("password_hash", "password_salt"),
  CONSTRAINT "user_password_hash_size_ch" CHECK (length(password_hash) = 32),
  CONSTRAINT "user_password_salt_size_ch" CHECK (length(password_salt) = 32),
  CONSTRAINT "user_username_size_ch" CHECK (1 <= length((username)::text))
);

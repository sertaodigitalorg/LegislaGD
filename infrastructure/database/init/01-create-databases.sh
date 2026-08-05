#!/bin/sh
set -eu

create_user() {
  user_name="$1"
  user_password="$2"

  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${user_name}') THEN
    CREATE ROLE ${user_name} LOGIN PASSWORD '${user_password}';
  ELSE
    ALTER ROLE ${user_name} WITH LOGIN PASSWORD '${user_password}';
  END IF;
END
\$\$;
EOSQL
}

create_database() {
  db_name="$1"
  db_owner="$2"

  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
SELECT 'CREATE DATABASE ${db_name} OWNER ${db_owner}'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${db_name}')\gexec
EOSQL
}

create_user "$SAPL_DB_USER" "$SAPL_DB_PASSWORD"
create_user "$SIGI_DB_USER" "$SIGI_DB_PASSWORD"
create_user "$CHATWOOT_DB_USER" "$CHATWOOT_DB_PASSWORD"

create_database "$SAPL_DB_NAME" "$SAPL_DB_USER"
create_database "$SIGI_DB_NAME" "$SIGI_DB_USER"
create_database "$CHATWOOT_DB_NAME" "$CHATWOOT_DB_USER"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$SIGI_DB_NAME" <<-EOSQL
CREATE EXTENSION IF NOT EXISTS vector;
EOSQL

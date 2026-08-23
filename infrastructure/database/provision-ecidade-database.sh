#!/bin/sh
set -eu

: "${LEGISLAGD_POSTGRES_USER:=legislagd}"
: "${LEGISLAGD_POSTGRES_DB:=legislagd}"
: "${ECIDADE_DB_NAME:=ecidade}"
: "${ECIDADE_DB_USER:=dbseller}"
: "${ECIDADE_DB_PASSWORD:=dbseller}"
: "${ECIDADE_PLUGIN_DB_USER:=plugin}"
: "${ECIDADE_PLUGIN_DB_PASSWORD:=plugin}"
: "${ECIDADE_LEGACY_DB_USER:=dbseller}"
: "${ECIDADE_LEGACY_DB_PASSWORD:=dbseller}"

create_user() {
  user_name="$1"
  user_password="$2"

  psql -v ON_ERROR_STOP=1 --username "$LEGISLAGD_POSTGRES_USER" --dbname "$LEGISLAGD_POSTGRES_DB" <<-EOSQL
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

  psql -v ON_ERROR_STOP=1 --username "$LEGISLAGD_POSTGRES_USER" --dbname "$LEGISLAGD_POSTGRES_DB" <<-EOSQL
SELECT 'CREATE DATABASE ${db_name} OWNER ${db_owner}'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${db_name}')\gexec
EOSQL
}

create_user "$ECIDADE_DB_USER" "$ECIDADE_DB_PASSWORD"
create_user "$ECIDADE_PLUGIN_DB_USER" "$ECIDADE_PLUGIN_DB_PASSWORD"
create_user "$ECIDADE_LEGACY_DB_USER" "$ECIDADE_LEGACY_DB_PASSWORD"
create_database "$ECIDADE_DB_NAME" "$ECIDADE_DB_USER"

psql -v ON_ERROR_STOP=1 --username "$LEGISLAGD_POSTGRES_USER" --dbname "$ECIDADE_DB_NAME" <<-EOSQL
GRANT ALL PRIVILEGES ON DATABASE ${ECIDADE_DB_NAME} TO ${ECIDADE_DB_USER};
GRANT ALL PRIVILEGES ON SCHEMA public TO ${ECIDADE_DB_USER};
GRANT ALL PRIVILEGES ON SCHEMA public TO ${ECIDADE_PLUGIN_DB_USER};
GRANT CONNECT ON DATABASE ${ECIDADE_DB_NAME} TO ${ECIDADE_LEGACY_DB_USER};
EOSQL

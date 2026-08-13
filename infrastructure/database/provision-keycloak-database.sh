#!/bin/sh
set -eu

KEYCLOAK_DB_NAME="${KEYCLOAK_DB_NAME:-keycloak}"
KEYCLOAK_DB_USER="${KEYCLOAK_DB_USER:-keycloak}"
KEYCLOAK_DB_PASSWORD="${KEYCLOAK_DB_PASSWORD:-keycloak_dev_password}"
POSTGRES_DB="${POSTGRES_DB:-legislagd}"
POSTGRES_USER="${POSTGRES_USER:-legislagd}"

tries=0
until pg_isready --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"; do
  tries=$((tries + 1))
  if [ "$tries" -ge 30 ]; then
    echo "PostgreSQL central nao ficou pronto a tempo." >&2
    exit 1
  fi
  sleep 2
done

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${KEYCLOAK_DB_USER}') THEN
    CREATE ROLE ${KEYCLOAK_DB_USER} LOGIN PASSWORD '${KEYCLOAK_DB_PASSWORD}';
  ELSE
    ALTER ROLE ${KEYCLOAK_DB_USER} WITH LOGIN PASSWORD '${KEYCLOAK_DB_PASSWORD}';
  END IF;
END
\$\$;

SELECT 'CREATE DATABASE ${KEYCLOAK_DB_NAME} OWNER ${KEYCLOAK_DB_USER}'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${KEYCLOAK_DB_NAME}')\gexec
EOSQL

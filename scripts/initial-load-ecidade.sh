#!/bin/sh
set -eu

cd /var/www/html

: "${DB_HOST:?DB_HOST is required}"
: "${DB_PORT:?DB_PORT is required}"
: "${DB_DATABASE:?DB_DATABASE is required}"
: "${DB_USERNAME:?DB_USERNAME is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${ECIDADE_SCHEMA_OWNER_USER:=ecidade}"
: "${ECIDADE_SCHEMA_OWNER_PASSWORD:=ecidade}"

chmod -R 775 /var/www/html

if [ -f docker/database/ecidade_base.sql.gz ]; then
  gunzip -kf docker/database/ecidade_base.sql.gz
fi

if [ -f docker/ecidade_base.sql.gz ]; then
  gunzip -kf docker/ecidade_base.sql.gz
fi

cp -arf .env.example .env
cp -arf libs/db_conn.php.dist libs/db_conn.php

if [ -f config/ecidade_config.php.dist ] && [ ! -f config/ecidade_config.php ]; then
  cp -arf config/ecidade_config.php.dist config/ecidade_config.php
fi

if [ -f config/application.default.php ] && [ ! -f config/application.php ]; then
  cp -arf config/application.default.php config/application.php
fi

if [ -f config/require_extensions.xml.dist ] && [ ! -f config/require_extensions.xml ]; then
  cp -arf config/require_extensions.xml.dist config/require_extensions.xml
fi

sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST}/g" .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/g" .env
sed -i "s/DB_PORT=.*/DB_PORT=${DB_PORT}/g" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/g" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/g" .env

sed -i "s/\$DB_BASE.*/\$DB_BASE = \"${DB_DATABASE}\";/g" libs/db_conn.php
sed -i "s/\$DB_SERVIDOR.*/\$DB_SERVIDOR = \"${DB_HOST}\";/g" libs/db_conn.php
sed -i "s/\$DB_PORTA.*/\$DB_PORTA = \"${DB_PORT}\";/g" libs/db_conn.php
sed -i "s/\$DB_USUARIO.*/\$DB_USUARIO = \"${DB_USERNAME}\";/g" libs/db_conn.php
sed -i "s/\$DB_SENHA.*/\$DB_SENHA = \"${DB_PASSWORD}\";/g" libs/db_conn.php
sed -i "s/DB_VALIDA_REQUISITOS.*/DB_VALIDA_REQUISITOS = false;/g" libs/db_conn.php

sed -E \
  -e '/^[[:space:]]*SET default_with_oids[[:space:]]*=/d' \
  -e '/^[[:space:]]*WITH OIDS;[[:space:]]*$/d' \
  -e '/^[[:space:]]*WITHOUT OIDS;[[:space:]]*$/d' \
  -e 's/[[:space:]]+WITH OIDS;$/;/' \
  -e 's/[[:space:]]+WITHOUT OIDS;$/;/' \
  -e "s/OWNER TO postgres;/OWNER TO ${ECIDADE_SCHEMA_OWNER_USER};/g" \
  -e "s/OWNER TO \"postgres\";/OWNER TO \"${ECIDADE_SCHEMA_OWNER_USER}\";/g" \
  -e "s/TO postgres;/TO ${ECIDADE_SCHEMA_OWNER_USER};/g" \
  -e "s/TO \"postgres\";/TO \"${ECIDADE_SCHEMA_OWNER_USER}\";/g" \
  docker/ecidade_base.sql > /tmp/ecidade_base.pg16.sql

PGPASSWORD="${ECIDADE_SCHEMA_OWNER_PASSWORD}" psql -v ON_ERROR_STOP=1 \
  -U "${ECIDADE_SCHEMA_OWNER_USER}" \
  -h "${DB_HOST}" \
  -p "${DB_PORT}" \
  -d "${DB_DATABASE}" \
  -f /tmp/ecidade_base.pg16.sql

PGPASSWORD="${ECIDADE_SCHEMA_OWNER_PASSWORD}" psql -v ON_ERROR_STOP=1 \
  -U "${ECIDADE_SCHEMA_OWNER_USER}" \
  -h "${DB_HOST}" \
  -p "${DB_PORT}" \
  -d "${DB_DATABASE}" \
  -f docker/pos.sql

composer install
composer install-desktop || true
composer configure-desktop
php artisan cache:clear
php artisan key:generate
php artisan passport:keys
php artisan passport:install

#!/bin/sh
set -eu

cd /var/www/html

export PATH="${PATH:-/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin}"

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
  -e '/^[[:space:]]*GRANT SELECT ON TABLE pg_catalog[.]pg_pltemplate TO /d' \
  -e 's/[[:space:]]+WITH OIDS;$/;/' \
  -e 's/[[:space:]]+WITHOUT OIDS;$/;/' \
  -e "s/to_ascii\(\(z01_v_nome\)::text\)/to_ascii((z01_v_nome)::text, 'LATIN1'::name)/g" \
  -e "s/to_ascii\(([A-Za-z_][A-Za-z0-9_.]*)\)/to_ascii(\1, 'LATIN1'::name)/g" \
  -e '/CREATE AGGREGATE public[.]array_accum\(any(element|compatible)\)/,/^[[:space:]]*\);/ s/CREATE AGGREGATE public[.]array_accum\(anyelement\)/CREATE AGGREGATE public.array_accum(anycompatible)/' \
  -e '/CREATE AGGREGATE public[.]array_accum\(any(element|compatible)\)/,/^[[:space:]]*\);/ s/STYPE = anyarray,/STYPE = anycompatiblearray,/' \
  -e 's/ALTER AGGREGATE public[.]array_accum\(anyelement\)/ALTER AGGREGATE public.array_accum(anycompatible)/g' \
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

sed -E \
  -e 's/^[[:space:]]*GRANT all ON plugins TO /GRANT ALL ON SCHEMA plugins TO /' \
  docker/pos.sql > /tmp/ecidade_pos.pg16.sql

PGPASSWORD="${ECIDADE_SCHEMA_OWNER_PASSWORD}" psql -v ON_ERROR_STOP=1 \
  -U "${ECIDADE_SCHEMA_OWNER_USER}" \
  -h "${DB_HOST}" \
  -p "${DB_PORT}" \
  -d "${DB_DATABASE}" \
  -f /tmp/ecidade_pos.pg16.sql

export COMPOSER_HOME="${COMPOSER_HOME:-/tmp/composer-home}"
export COMPOSER_CACHE_DIR="${COMPOSER_CACHE_DIR:-/tmp/composer-cache}"
export COMPOSER_MAX_PARALLEL_DOWNLOADS="${COMPOSER_MAX_PARALLEL_DOWNLOADS:-1}"
export COMPOSER_RUNTIME_BIN="${COMPOSER_RUNTIME_BIN:-/tmp/composer-runtime-bin}"
mkdir -p "${COMPOSER_HOME}" "${COMPOSER_CACHE_DIR}" "${COMPOSER_RUNTIME_BIN}"
ln -sf /usr/bin/php "${COMPOSER_RUNTIME_BIN}/php"
ln -sf /usr/bin/php5.6 "${COMPOSER_RUNTIME_BIN}/php5.6"
ln -sf /usr/bin/which "${COMPOSER_RUNTIME_BIN}/which"
if command -v git >/dev/null 2>&1; then
  ln -sf "$(command -v git)" "${COMPOSER_RUNTIME_BIN}/git"
fi

if [ -d vendor/composer ]; then
  find vendor/composer -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
fi

COMPOSER_ORIGINAL_PATH="${PATH}"
PATH="${COMPOSER_RUNTIME_BIN}:/usr/local/bin" php /usr/local/bin/composer install --prefer-dist --no-progress --no-interaction --no-scripts
PATH="${COMPOSER_ORIGINAL_PATH}"
composer install-desktop || true
composer configure-desktop
php artisan cache:clear
php artisan key:generate
php artisan passport:keys
php artisan passport:install

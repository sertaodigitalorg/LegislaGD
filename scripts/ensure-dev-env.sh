#!/usr/bin/env sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
ENV_EXAMPLE="${ROOT_DIR}/.env.example"

make_secret() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 32
  elif command -v sha256sum >/dev/null 2>&1; then
    date +%s%N | sha256sum | awk '{print $1}'
  else
    date +%s%N
  fi
}

make_chatwoot_password() {
  printf 'Cw%s1!' "$(make_secret)"
}

set_env_default() {
  key="$1"
  value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    current="$(sed -n "s/^${key}=//p" "$ENV_FILE" | tail -n 1)"
    case "$current" in
      "" | "\"\"" | "''")
        tmp_file="$(mktemp)"
        awk -v key="$key" -v value="$value" '
          BEGIN { replaced = 0 }
          $0 ~ "^" key "=" && replaced == 0 {
            print key "=" value
            replaced = 1
            next
          }
          { print }
        ' "$ENV_FILE" > "$tmp_file"
        mv "$tmp_file" "$ENV_FILE"
        echo "definido: ${key}"
        ;;
      *)
        echo "preservado: ${key}"
        ;;
    esac
  else
    printf '\n%s=%s\n' "$key" "$value" >> "$ENV_FILE"
    echo "adicionado: ${key}"
  fi
}

set_env_value() {
  key="$1"
  value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    tmp_file="$(mktemp)"
    awk -v key="$key" -v value="$value" '
      BEGIN { replaced = 0 }
      $0 ~ "^" key "=" && replaced == 0 {
        print key "=" value
        replaced = 1
        next
      }
      { print }
    ' "$ENV_FILE" > "$tmp_file"
    mv "$tmp_file" "$ENV_FILE"
  else
    printf '\n%s=%s\n' "$key" "$value" >> "$ENV_FILE"
  fi
}

normalize_plain_env_value() {
  key="$1"
  value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    current="$(sed -n "s/^${key}=//p" "$ENV_FILE" | tail -n 1)"
    case "$current" in
      *\"* | *\'*)
        set_env_value "$key" "$value"
        echo "corrigido: ${key}"
        ;;
    esac
  fi
}

if [ ! -f "$ENV_FILE" ]; then
  if [ ! -f "$ENV_EXAMPLE" ]; then
    echo ".env ausente e .env.example nao encontrado." >&2
    exit 1
  fi

  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo ".env criado a partir de .env.example"
fi

normalize_plain_env_value CHATWOOT_OIDC_UI_LOCALES pt-BR
normalize_plain_env_value SAPL_OIDC_UI_LOCALES pt-BR
normalize_plain_env_value ECIDADE_OIDC_UI_LOCALES pt-BR
set_env_default LEGISLAGD_ENABLE_ECIDADE 1
set_env_default CHATWOOT_OIDC_CLIENT_SECRET "$(make_secret)"
set_env_default CHATWOOT_SSO_PASSWORD "$(make_chatwoot_password)"
set_env_default ECIDADE_OIDC_ENABLED true
set_env_default ECIDADE_OIDC_ISSUER http://id.legislagd.localhost/realms/legislagd
set_env_default ECIDADE_OIDC_WELL_KNOWN_URL http://id.legislagd.localhost/realms/legislagd/.well-known/openid-configuration
set_env_default ECIDADE_OIDC_CLIENT_ID ecidade
set_env_default ECIDADE_OIDC_CLIENT_SECRET "$(make_secret)"
set_env_default ECIDADE_OIDC_REDIRECT_URI http://ecidade.legislagd.localhost/extension/legislagdsso/auth/callback
set_env_default ECIDADE_OIDC_UI_LOCALES pt-BR
set_env_default ECIDADE_OIDC_ALLOW_EMAIL_LINK true
set_env_default ECIDADE_OIDC_ALLOW_LOGIN_LINK true
set_env_default ECIDADE_SSO_USER dbseller
set_env_default ECIDADE_SSO_PASSWORD ecidade_dev_password
set_env_default ECIDADE_SSO_EMAIL dbseller@legislagd.localhost

echo ".env pronto para desenvolvimento local."

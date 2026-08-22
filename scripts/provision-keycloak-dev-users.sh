#!/usr/bin/env sh
set -eu

KEYCLOAK_CONTAINER="${KEYCLOAK_CONTAINER:-legislagd-keycloak}"
KEYCLOAK_REALM="${KEYCLOAK_REALM:-legislagd}"
KEYCLOAK_ADMIN_USER="${KEYCLOAK_ADMIN_USER:-admin}"
KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-admin_dev_password}"

SAPL_SSO_USER="${SAPL_SSO_USER:-sapl.operador}"
SAPL_SSO_PASSWORD="${SAPL_SSO_PASSWORD:-sapl_dev_password}"
SAPL_SSO_EMAIL="${SAPL_SSO_EMAIL:-sapl.operador@legislagd.localhost}"
SAPL_OIDC_CLIENT_ID="${SAPL_OIDC_CLIENT_ID:-sapl}"
SAPL_SD_URL="${SAPL_SD_URL:-http://sapl.legislagd.localhost}"

SIGI_OIDC_CLIENT_ID="${SIGI_OIDC_CLIENT_ID:-sigi}"
LEGISLAGD_SIGI_SD_URL="${LEGISLAGD_SIGI_SD_URL:-http://sigi.legislagd.localhost}"
SIGI_ADMIN_USER="${SIGI_ADMIN_USER:-sigi.admin}"
SIGI_ADMIN_PASSWORD="${SIGI_ADMIN_PASSWORD:-sigi_dev_password}"
SIGI_ADMIN_EMAIL="${SIGI_ADMIN_EMAIL:-sigi.admin@legislagd.localhost}"
SIGI_ATENDENTE_USER="${SIGI_ATENDENTE_USER:-sigi.atendente}"
SIGI_ATENDENTE_PASSWORD="${SIGI_ATENDENTE_PASSWORD:-sigi_dev_password}"
SIGI_ATENDENTE_EMAIL="${SIGI_ATENDENTE_EMAIL:-sigi.atendente@legislagd.localhost}"

CHATWOOT_SSO_USER="${CHATWOOT_SSO_USER:-chatwoot.agent}"
CHATWOOT_SSO_PASSWORD="${CHATWOOT_SSO_PASSWORD:-}"
CHATWOOT_SSO_EMAIL="${CHATWOOT_SSO_EMAIL:-john@acme.inc}"
CHATWOOT_OIDC_CLIENT_ID="${CHATWOOT_OIDC_CLIENT_ID:-chatwoot}"
CHATWOOT_OIDC_CLIENT_SECRET="${CHATWOOT_OIDC_CLIENT_SECRET:-}"
LEGISLAGD_SIGI_SD_CHAT_URL="${LEGISLAGD_SIGI_SD_CHAT_URL:-http://chat.sigi.legislagd.localhost}"

kc() {
  docker exec "$KEYCLOAK_CONTAINER" /opt/keycloak/bin/kcadm.sh "$@"
}

client_internal_id() {
  client_id="$1"
  kc get clients \
    -r "$KEYCLOAK_REALM" \
    -q "clientId=$client_id" \
    --fields id,clientId \
    --format csv \
    --noquotes | awk -F, -v client_id="$client_id" '$2 == client_id { print $1; exit }'
}

user_internal_id() {
  username="$1"
  kc get users \
    -r "$KEYCLOAK_REALM" \
    -q "username=$username" \
    --fields id,username \
    --format csv \
    --noquotes | awk -F, -v username="$username" '$2 == username { print $1; exit }'
}

client_scope_id() {
  scope_name="$1"
  kc get client-scopes \
    -r "$KEYCLOAK_REALM" \
    -q "name=$scope_name" \
    --fields id,name \
    --format csv \
    --noquotes | awk -F, -v scope_name="$scope_name" '$2 == scope_name { print $1; exit }'
}

ensure_default_client_scope() {
  internal_client_id="$1"
  scope_name="$2"
  scope_id="$(client_scope_id "$scope_name")"

  if [ -z "$scope_id" ]; then
    echo "Client scope $scope_name nao encontrado no realm $KEYCLOAK_REALM." >&2
    exit 1
  fi

  if kc get "clients/$internal_client_id/default-client-scopes" \
    -r "$KEYCLOAK_REALM" \
    --fields name \
    --format csv \
    --noquotes | awk -F, -v scope_name="$scope_name" '$1 == scope_name { found = 1 } END { exit !found }'; then
    return
  fi

  kc update "clients/$internal_client_id/default-client-scopes/$scope_id" \
    -r "$KEYCLOAK_REALM" >/dev/null
}

ensure_realm_user() {
  username="$1"
  password="$2"
  email="$3"
  first_name="$4"
  last_name="$5"
  shift 5

  internal_user_id="$(user_internal_id "$username")"

  if [ -z "$internal_user_id" ]; then
    echo "Criando usuario $username..."
    kc create users \
      -r "$KEYCLOAK_REALM" \
      -s "username=$username" \
      -s enabled=true \
      -s emailVerified=true \
      -s "firstName=$first_name" \
      -s "lastName=$last_name" \
      -s "email=$email" >/dev/null

    internal_user_id="$(user_internal_id "$username")"
  else
    echo "Atualizando usuario $username..."
    kc update "users/$internal_user_id" \
      -r "$KEYCLOAK_REALM" \
      -s enabled=true \
      -s emailVerified=true \
      -s "firstName=$first_name" \
      -s "lastName=$last_name" \
      -s "email=$email" >/dev/null
  fi

  if [ -z "$internal_user_id" ]; then
    echo "Nao foi possivel localizar/criar o usuario $username." >&2
    exit 1
  fi

  echo "Definindo senha do usuario $username..."
  kc set-password \
    -r "$KEYCLOAK_REALM" \
    --username "$username" \
    --new-password "$password" >/dev/null

  for role in "$@"; do
    if ! kc get "roles/$role" -r "$KEYCLOAK_REALM" >/dev/null 2>&1; then
      kc create roles -r "$KEYCLOAK_REALM" -s "name=$role" >/dev/null
    fi

    kc add-roles \
      -r "$KEYCLOAK_REALM" \
      --uusername "$username" \
      --rolename "$role" >/dev/null 2>&1 || true
  done

  echo "Usuario SSO pronto: $username"
}

echo "Autenticando no Keycloak local..."
kc config credentials \
  --server http://localhost:8080 \
  --realm master \
  --user "$KEYCLOAK_ADMIN_USER" \
  --password "$KEYCLOAK_ADMIN_PASSWORD" >/dev/null

echo "Garantindo locale pt-BR no realm $KEYCLOAK_REALM..."
kc update "realms/$KEYCLOAK_REALM" \
  -s internationalizationEnabled=true \
  -s defaultLocale=pt-BR \
  -s 'supportedLocales=["pt-BR","en"]' >/dev/null

CLIENT_ID="$(client_internal_id "$SAPL_OIDC_CLIENT_ID")"

if [ -z "$CLIENT_ID" ]; then
  echo "Criando client OIDC $SAPL_OIDC_CLIENT_ID..."
  kc create clients \
    -r "$KEYCLOAK_REALM" \
    -s "clientId=$SAPL_OIDC_CLIENT_ID" \
    -s name=SAPL-SD \
    -s enabled=true \
    -s protocol=openid-connect \
    -s publicClient=true \
    -s clientAuthenticatorType=none \
    -s standardFlowEnabled=true \
    -s directAccessGrantsEnabled=false \
    -s serviceAccountsEnabled=false \
    -s "redirectUris=[\"$SAPL_SD_URL/*\"]" \
    -s "webOrigins=[\"$SAPL_SD_URL\"]" \
    -s 'attributes."pkce.code.challenge.method"=S256' >/dev/null

  CLIENT_ID="$(client_internal_id "$SAPL_OIDC_CLIENT_ID")"
else
  echo "Atualizando client OIDC $SAPL_OIDC_CLIENT_ID como publico com PKCE..."
  kc update "clients/$CLIENT_ID" \
    -r "$KEYCLOAK_REALM" \
    -s enabled=true \
    -s protocol=openid-connect \
    -s publicClient=true \
    -s clientAuthenticatorType=none \
    -s standardFlowEnabled=true \
    -s directAccessGrantsEnabled=false \
    -s serviceAccountsEnabled=false \
    -s "redirectUris=[\"$SAPL_SD_URL/*\"]" \
    -s "webOrigins=[\"$SAPL_SD_URL\"]" \
    -s 'attributes."pkce.code.challenge.method"=S256' >/dev/null
fi

SIGI_CLIENT_ID="$(client_internal_id "$SIGI_OIDC_CLIENT_ID")"

if [ -z "$SIGI_CLIENT_ID" ]; then
  echo "Criando client OIDC $SIGI_OIDC_CLIENT_ID..."
  kc create clients \
    -r "$KEYCLOAK_REALM" \
    -s "clientId=$SIGI_OIDC_CLIENT_ID" \
    -s name=SIGI-SD \
    -s enabled=true \
    -s protocol=openid-connect \
    -s publicClient=true \
    -s clientAuthenticatorType=none \
    -s standardFlowEnabled=true \
    -s directAccessGrantsEnabled=false \
    -s serviceAccountsEnabled=false \
    -s "redirectUris=[\"$LEGISLAGD_SIGI_SD_URL/*\"]" \
    -s "webOrigins=[\"$LEGISLAGD_SIGI_SD_URL\"]" \
    -s 'attributes."pkce.code.challenge.method"=S256' >/dev/null

  SIGI_CLIENT_ID="$(client_internal_id "$SIGI_OIDC_CLIENT_ID")"
else
  echo "Atualizando client OIDC $SIGI_OIDC_CLIENT_ID como publico com PKCE..."
  kc update "clients/$SIGI_CLIENT_ID" \
    -r "$KEYCLOAK_REALM" \
    -s enabled=true \
    -s protocol=openid-connect \
    -s publicClient=true \
    -s clientAuthenticatorType=none \
    -s standardFlowEnabled=true \
    -s directAccessGrantsEnabled=false \
    -s serviceAccountsEnabled=false \
    -s "redirectUris=[\"$LEGISLAGD_SIGI_SD_URL/*\"]" \
    -s "webOrigins=[\"$LEGISLAGD_SIGI_SD_URL\"]" \
    -s 'attributes."pkce.code.challenge.method"=S256' >/dev/null
fi

echo "Garantindo usuarios do SIGI..."
ensure_realm_user "$SIGI_ADMIN_USER" "$SIGI_ADMIN_PASSWORD" "$SIGI_ADMIN_EMAIL" Administrador SIGI legislagd.user sigi.admin
ensure_realm_user "$SIGI_ATENDENTE_USER" "$SIGI_ATENDENTE_PASSWORD" "$SIGI_ATENDENTE_EMAIL" Atendente SIGI legislagd.user sigi.atendente

if [ -z "$CHATWOOT_OIDC_CLIENT_SECRET" ]; then
  echo "CHATWOOT_OIDC_CLIENT_SECRET deve ser definido no ambiente local." >&2
  exit 1
fi

if [ -z "$CHATWOOT_SSO_PASSWORD" ]; then
  echo "CHATWOOT_SSO_PASSWORD deve ser definido no ambiente local." >&2
  exit 1
fi

CHATWOOT_CLIENT_ID="$(client_internal_id "$CHATWOOT_OIDC_CLIENT_ID")"

if [ -z "$CHATWOOT_CLIENT_ID" ]; then
  echo "Criando client OIDC $CHATWOOT_OIDC_CLIENT_ID..."
  kc create clients \
    -r "$KEYCLOAK_REALM" \
    -s "clientId=$CHATWOOT_OIDC_CLIENT_ID" \
    -s name=Chatwoot \
    -s enabled=true \
    -s protocol=openid-connect \
    -s publicClient=false \
    -s "secret=$CHATWOOT_OIDC_CLIENT_SECRET" \
    -s standardFlowEnabled=true \
    -s directAccessGrantsEnabled=false \
    -s serviceAccountsEnabled=false \
    -s "redirectUris=[\"$LEGISLAGD_SIGI_SD_CHAT_URL/*\"]" \
    -s "webOrigins=[\"$LEGISLAGD_SIGI_SD_CHAT_URL\"]" \
    -s 'attributes."pkce.code.challenge.method"=S256' >/dev/null

  CHATWOOT_CLIENT_ID="$(client_internal_id "$CHATWOOT_OIDC_CLIENT_ID")"
else
  echo "Atualizando client OIDC $CHATWOOT_OIDC_CLIENT_ID como confidencial..."
  kc update "clients/$CHATWOOT_CLIENT_ID" \
    -r "$KEYCLOAK_REALM" \
    -s enabled=true \
    -s protocol=openid-connect \
    -s publicClient=false \
    -s "secret=$CHATWOOT_OIDC_CLIENT_SECRET" \
    -s standardFlowEnabled=true \
    -s directAccessGrantsEnabled=false \
    -s serviceAccountsEnabled=false \
    -s "redirectUris=[\"$LEGISLAGD_SIGI_SD_CHAT_URL/*\"]" \
    -s "webOrigins=[\"$LEGISLAGD_SIGI_SD_CHAT_URL\"]" \
    -s 'attributes."pkce.code.challenge.method"=S256' >/dev/null
fi

echo "Garantindo client scope roles no client $CHATWOOT_OIDC_CLIENT_ID..."
ensure_default_client_scope "$CHATWOOT_CLIENT_ID" roles

USER_ID="$(user_internal_id "$SAPL_SSO_USER")"

if [ -z "$USER_ID" ]; then
  echo "Criando usuario $SAPL_SSO_USER..."
  kc create users \
    -r "$KEYCLOAK_REALM" \
    -s "username=$SAPL_SSO_USER" \
    -s enabled=true \
    -s emailVerified=true \
    -s firstName=Operador \
    -s lastName=SAPL \
    -s "email=$SAPL_SSO_EMAIL" >/dev/null

  USER_ID="$(user_internal_id "$SAPL_SSO_USER")"
else
  echo "Atualizando usuario $SAPL_SSO_USER..."
  kc update "users/$USER_ID" \
    -r "$KEYCLOAK_REALM" \
    -s enabled=true \
    -s emailVerified=true \
    -s firstName=Operador \
    -s lastName=SAPL \
    -s "email=$SAPL_SSO_EMAIL" >/dev/null
fi

if [ -z "$USER_ID" ]; then
  echo "Nao foi possivel localizar/criar o usuario $SAPL_SSO_USER." >&2
  exit 1
fi

echo "Definindo senha do usuario $SAPL_SSO_USER..."
kc set-password \
  -r "$KEYCLOAK_REALM" \
  --username "$SAPL_SSO_USER" \
  --new-password "$SAPL_SSO_PASSWORD" >/dev/null

echo "Garantindo roles do SAPL..."
for role in legislagd.user sapl.operador chatwoot.agent; do
  if ! kc get "roles/$role" -r "$KEYCLOAK_REALM" >/dev/null 2>&1; then
    kc create roles -r "$KEYCLOAK_REALM" -s "name=$role" >/dev/null
  fi

  kc add-roles \
    -r "$KEYCLOAK_REALM" \
    --uusername "$SAPL_SSO_USER" \
    --rolename "$role" >/dev/null 2>&1 || true
done

echo "Usuario SSO pronto: $SAPL_SSO_USER"

CHATWOOT_USER_ID="$(user_internal_id "$CHATWOOT_SSO_USER")"

if [ -z "$CHATWOOT_USER_ID" ]; then
  echo "Criando usuario $CHATWOOT_SSO_USER..."
  kc create users \
    -r "$KEYCLOAK_REALM" \
    -s "username=$CHATWOOT_SSO_USER" \
    -s enabled=true \
    -s emailVerified=true \
    -s firstName=Agente \
    -s lastName=Chatwoot \
    -s "email=$CHATWOOT_SSO_EMAIL" >/dev/null

  CHATWOOT_USER_ID="$(user_internal_id "$CHATWOOT_SSO_USER")"
else
  echo "Atualizando usuario $CHATWOOT_SSO_USER..."
  kc update "users/$CHATWOOT_USER_ID" \
    -r "$KEYCLOAK_REALM" \
    -s enabled=true \
    -s emailVerified=true \
    -s firstName=Agente \
    -s lastName=Chatwoot \
    -s "email=$CHATWOOT_SSO_EMAIL" >/dev/null
fi

if [ -z "$CHATWOOT_USER_ID" ]; then
  echo "Nao foi possivel localizar/criar o usuario $CHATWOOT_SSO_USER." >&2
  exit 1
fi

echo "Definindo senha do usuario $CHATWOOT_SSO_USER..."
kc set-password \
  -r "$KEYCLOAK_REALM" \
  --username "$CHATWOOT_SSO_USER" \
  --new-password "$CHATWOOT_SSO_PASSWORD" >/dev/null

echo "Garantindo roles do Chatwoot..."
for role in legislagd.user chatwoot.agent; do
  if ! kc get "roles/$role" -r "$KEYCLOAK_REALM" >/dev/null 2>&1; then
    kc create roles -r "$KEYCLOAK_REALM" -s "name=$role" >/dev/null
  fi

  kc add-roles \
    -r "$KEYCLOAK_REALM" \
    --uusername "$CHATWOOT_SSO_USER" \
    --rolename "$role" >/dev/null 2>&1 || true
done

echo "Usuario SSO pronto: $CHATWOOT_SSO_USER"

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

kc() {
  docker exec "$KEYCLOAK_CONTAINER" /opt/keycloak/bin/kcadm.sh "$@"
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

CLIENT_ID="$(kc get clients \
  -r "$KEYCLOAK_REALM" \
  -q "clientId=$SAPL_OIDC_CLIENT_ID" \
  --fields id,clientId \
  --format csv \
  --noquotes | awk -F, -v client_id="$SAPL_OIDC_CLIENT_ID" '$2 == client_id { print $1; exit }')"

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

  CLIENT_ID="$(kc get clients \
    -r "$KEYCLOAK_REALM" \
    -q "clientId=$SAPL_OIDC_CLIENT_ID" \
    --fields id,clientId \
    --format csv \
    --noquotes | awk -F, -v client_id="$SAPL_OIDC_CLIENT_ID" '$2 == client_id { print $1; exit }')"
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

USER_ID="$(kc get users \
  -r "$KEYCLOAK_REALM" \
  -q "username=$SAPL_SSO_USER" \
  --fields id,username \
  --format csv \
  --noquotes | awk -F, -v username="$SAPL_SSO_USER" '$2 == username { print $1; exit }')"

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

  USER_ID="$(kc get users \
    -r "$KEYCLOAK_REALM" \
    -q "username=$SAPL_SSO_USER" \
    --fields id,username \
    --format csv \
    --noquotes | awk -F, -v username="$SAPL_SSO_USER" '$2 == username { print $1; exit }')"
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
for role in legislagd.user sapl.operador; do
  if ! kc get "roles/$role" -r "$KEYCLOAK_REALM" >/dev/null 2>&1; then
    kc create roles -r "$KEYCLOAK_REALM" -s "name=$role" >/dev/null
  fi

  kc add-roles \
    -r "$KEYCLOAK_REALM" \
    --uusername "$SAPL_SSO_USER" \
    --rolename "$role" >/dev/null 2>&1 || true
done

echo "Usuario SSO pronto: $SAPL_SSO_USER / $SAPL_SSO_PASSWORD"

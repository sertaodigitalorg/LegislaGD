#!/usr/bin/env sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [ -f "$ENV_FILE" ]; then
  set -a
  . "$ENV_FILE"
  set +a
fi

: "${ECIDADE_SD_URL:=http://ecidade.legislagd.localhost}"
: "${ECIDADE_SSO_USER:=dbseller}"
: "${ECIDADE_SSO_PASSWORD:=ecidade_dev_password}"

cookie_jar="$(mktemp)"
headers_file="$(mktemp)"
body_file="$(mktemp)"
trap 'rm -f "$cookie_jar" "$headers_file" "$body_file"' EXIT

location_from_headers() {
  awk 'BEGIN { IGNORECASE=1 } /^Location:/ { sub(/\r$/, ""); sub(/^Location:[[:space:]]*/, ""); print; exit }' "$1"
}

cookie_header_from_set_cookie() {
  awk '
    BEGIN { IGNORECASE=1 }
    /^Set-Cookie:/ {
      sub(/\r$/, "")
      sub(/^Set-Cookie:[[:space:]]*/, "")
      split($0, parts, ";")
      if (parts[1] != "") {
        if (cookies != "") {
          cookies = cookies "; "
        }
        cookies = cookies parts[1]
      }
    }
    END { print cookies }
  ' "$1"
}

compact_body() {
  python3 - "$1" <<'PY'
import html
import re
import sys

text = open(sys.argv[1], errors="ignore").read()
text = re.sub(r"<script.*?</script>", " ", text, flags=re.S | re.I)
text = re.sub(r"<style.*?</style>", " ", text, flags=re.S | re.I)
text = re.sub(r"<[^>]+>", " ", text)
print(" ".join(html.unescape(text).split())[:400])
PY
}

curl -sS \
  -c "$cookie_jar" \
  -b "$cookie_jar" \
  -D "$headers_file" \
  -o "$body_file" \
  "${ECIDADE_SD_URL%/}/extension/legislagdsso/auth/login"

auth_url="$(location_from_headers "$headers_file")"
case "$auth_url" in
  *client_id=ecidade*) ;;
  *)
    echo "ECIDADE_SSO_SMOKE_FAILED: SSO start did not target client_id=ecidade" >&2
    compact_body "$body_file" >&2
    exit 1
    ;;
esac

curl -sS \
  -c "$cookie_jar" \
  -b "$cookie_jar" \
  -D "$headers_file" \
  -o "$body_file" \
  "$auth_url"

keycloak_cookie_header="$(cookie_header_from_set_cookie "$headers_file")"

if [ "${SMOKE_DEBUG:-}" ]; then
  awk '
    BEGIN { IGNORECASE=1; print "KEYCLOAK_AUTH_HEADERS" }
    /^HTTP\// { sub(/\r$/, ""); print }
    /^Location:/ { sub(/\r$/, ""); print }
    /^Set-Cookie:/ {
      sub(/\r$/, "")
      sub(/^Set-Cookie:[[:space:]]*/, "")
      split($0, parts, "=")
      print "Set-Cookie: " parts[1] "=<redacted>"
    }
  ' "$headers_file"
fi

login_action="$(
  python3 - "$body_file" <<'PY'
import html
import re
import sys

text = open(sys.argv[1], errors="ignore").read()
match = re.search(r'action="([^"]+)"', text)
if not match:
    sys.exit(1)
print(html.unescape(match.group(1)))
PY
)"

if [ "${SMOKE_DEBUG:-}" ]; then
  python3 - "$login_action" <<'PY'
import sys
import urllib.parse

url = urllib.parse.urlparse(sys.argv[1])
print("LOGIN_ACTION_HOST={}".format(url.netloc))
print("LOGIN_ACTION_PATH={}".format(url.path))
PY
  awk 'BEGIN { print "COOKIE_JAR_DOMAINS" } !/^#/ && NF { print $1, $3, $4, $5, $6 }' "$cookie_jar"
  printf '%s\n' "$keycloak_cookie_header" | awk '
    BEGIN { print "KEYCLOAK_COOKIE_HEADER_NAMES" }
    {
      n = split($0, cookies, /;[[:space:]]*/)
      for (i = 1; i <= n; i++) {
        split(cookies[i], pair, "=")
        if (pair[1] != "") {
          print pair[1]
        }
      }
    }
  '
fi

if [ -n "$keycloak_cookie_header" ]; then
  curl -sS \
    -c "$cookie_jar" \
    -b "$cookie_jar" \
    -H "Cookie: $keycloak_cookie_header" \
    -D "$headers_file" \
    -o "$body_file" \
    -X POST \
    --data-urlencode "username=${ECIDADE_SSO_USER}" \
    --data-urlencode "password=${ECIDADE_SSO_PASSWORD}" \
    --data-urlencode "credentialId=" \
    "$login_action"
else
  curl -sS \
    -c "$cookie_jar" \
    -b "$cookie_jar" \
    -D "$headers_file" \
    -o "$body_file" \
    -X POST \
    --data-urlencode "username=${ECIDADE_SSO_USER}" \
    --data-urlencode "password=${ECIDADE_SSO_PASSWORD}" \
    --data-urlencode "credentialId=" \
    "$login_action"
fi

callback_url="$(location_from_headers "$headers_file")"
case "$callback_url" in
  */extension/legislagdsso/auth/callback*code=*) ;;
  *)
    echo "ECIDADE_SSO_SMOKE_FAILED: Keycloak did not redirect to e-Cidade callback" >&2
    compact_body "$body_file" >&2
    exit 1
    ;;
esac

curl -sS \
  -c "$cookie_jar" \
  -b "$cookie_jar" \
  -D "$headers_file" \
  -o "$body_file" \
  "$callback_url"

desktop_url="$(location_from_headers "$headers_file")"
case "$desktop_url" in
  *extension/desktop/*) ;;
  *)
    echo "ECIDADE_SSO_SMOKE_FAILED: e-Cidade callback did not redirect to Desktop" >&2
    compact_body "$body_file" >&2
    exit 1
    ;;
esac

echo "ECIDADE_SSO_START_OK"
echo "KEYCLOAK_LOGIN_OK"
echo "ECIDADE_CALLBACK_OK"
echo "ECIDADE_DESKTOP_REDIRECT_OK"

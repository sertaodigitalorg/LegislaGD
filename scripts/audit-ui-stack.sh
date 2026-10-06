#!/usr/bin/env bash
set -euo pipefail

URLS=(
  "http://legislagd.localhost"
  "http://proxy.legislagd.localhost"
  "http://id.legislagd.localhost"
  "http://portal.legislagd.localhost"
  "http://sapl.legislagd.localhost"
  "http://plenario.legislagd.localhost"
  "http://sigi.legislagd.localhost"
  "http://chat.sigi.legislagd.localhost"
  "http://ecidade.legislagd.localhost"
)

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

for url in "${URLS[@]}"; do
  printf -- '--- %s\n' "$url"

  http_result="$(
    curl \
      --location \
      --silent \
      --show-error \
      --max-time 20 \
      --output "$tmp_file" \
      --write-out 'HTTP %{http_code} FINAL %{url_effective}' \
      "$url" || true
  )"

  printf '%s\n' "$http_result"

  title="$(grep -Eio '<title>[^<]+' "$tmp_file" | head -1 | sed -E 's/<title>//I' || true)"
  h1="$(grep -Eio '<h1[^>]*>[^<]+' "$tmp_file" | head -1 | sed -E 's/<h1[^>]*>//I' || true)"

  printf 'TITLE %s\n' "${title:-N/A}"
  printf 'H1 %s\n\n' "${h1:-N/A}"
done

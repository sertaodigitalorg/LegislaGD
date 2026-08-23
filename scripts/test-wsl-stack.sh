#!/usr/bin/env bash
set -euo pipefail

urls=(
  "http://portal.legislagd.localhost"
  "http://sapl.legislagd.localhost"
  "http://sigi.legislagd.localhost"
  "http://ecidade.legislagd.localhost"
  "http://chat.sigi.legislagd.localhost"
  "http://qdrant.sigi.legislagd.localhost/collections"
  "http://ia.sigi.legislagd.localhost/api/version"
)

for url in "${urls[@]}"; do
  code="$(curl -s -o /tmp/legislagd-check -w '%{http_code}' --max-time 20 "$url")"
  printf "%s %s\n" "$code" "$url"
done

echo "--- postgres containers ---"
docker ps --format "{{.Names}} {{.Image}}" | grep -i postgres || true

echo "--- branches ---"
git -C /mnt/c/LegislaGD/modules/PortalModelo-SD branch --show-current
git -C /mnt/c/LegislaGD/modules/SAPL-SD branch --show-current
git -C /mnt/c/LegislaGD/modules/SIGI-SD branch --show-current
git -C /mnt/c/LegislaGD/modules/SIGI-SD/apps/chatwoot-sd branch --show-current
git -C /mnt/c/LegislaGD/modules/e-Cidade-SD branch --show-current

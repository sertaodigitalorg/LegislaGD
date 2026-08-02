#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "ok: $1"
  else
    echo "faltando: $1"
  fi
}

check_cmd git
check_cmd docker
check_cmd make
check_cmd curl
check_cmd jq

if docker compose version >/dev/null 2>&1; then
  echo "ok: docker compose"
else
  echo "faltando: docker compose"
fi

if [[ -f "${ROOT_DIR}/.env" ]]; then
  echo "ok: .env"
else
  echo "aviso: .env ausente"
fi

for dir in docs infrastructure integrations scripts; do
  [[ -d "${ROOT_DIR}/${dir}" ]] && echo "ok: ${dir}" || echo "faltando: ${dir}"
done

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "${ROOT_DIR}/docs" "${ROOT_DIR}/infrastructure" "${ROOT_DIR}/integrations"

if [[ ! -f "${ROOT_DIR}/.env" && -f "${ROOT_DIR}/.env.example" ]]; then
  cp "${ROOT_DIR}/.env.example" "${ROOT_DIR}/.env"
  echo ".env criado a partir de .env.example"
else
  echo ".env preservado ou .env.example ausente"
fi

"${ROOT_DIR}/scripts/clone-components.sh"
"${ROOT_DIR}/scripts/validate-environment.sh"

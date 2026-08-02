#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
docker compose -f "${ROOT_DIR}/infrastructure/compose/docker-compose.base.yml" -f "${ROOT_DIR}/infrastructure/compose/docker-compose.dev.yml" down

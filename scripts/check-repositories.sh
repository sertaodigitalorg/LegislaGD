#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_DIR="$(cd "${ROOT_DIR}/.." && pwd)"

if [[ -f "${ROOT_DIR}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  . "${ROOT_DIR}/.env"
  set +a
fi

REPOS=("LegislaGD")

if [[ "${LEGISLAGD_ENABLE_PORTAL:-1}" == "1" || "${LEGISLAGD_ENABLE_PORTAL:-1}" == "true" || "${LEGISLAGD_ENABLE_PORTAL:-1}" == "yes" || "${LEGISLAGD_ENABLE_PORTAL:-1}" == "on" ]]; then
  REPOS+=("PortalModelo-SD")
fi

if [[ "${LEGISLAGD_ENABLE_SAPL:-1}" == "1" || "${LEGISLAGD_ENABLE_SAPL:-1}" == "true" || "${LEGISLAGD_ENABLE_SAPL:-1}" == "yes" || "${LEGISLAGD_ENABLE_SAPL:-1}" == "on" ]]; then
  REPOS+=("SAPL-SD")
fi

if [[ "${LEGISLAGD_ENABLE_SIGI:-1}" == "1" || "${LEGISLAGD_ENABLE_SIGI:-1}" == "true" || "${LEGISLAGD_ENABLE_SIGI:-1}" == "yes" || "${LEGISLAGD_ENABLE_SIGI:-1}" == "on" ]]; then
  REPOS+=("SIGI-SD")
fi

if [[ "${LEGISLAGD_INCLUDE_ECIDADE:-0}" == "1" || "${LEGISLAGD_INCLUDE_ECIDADE:-0}" == "true" || "${LEGISLAGD_INCLUDE_ECIDADE:-0}" == "yes" || "${LEGISLAGD_INCLUDE_ECIDADE:-0}" == "on" ]]; then
  REPOS+=("e-Cidade-SD")
fi

for name in "${REPOS[@]}"; do
  target="${WORKSPACE_DIR}/${name}"
  echo
  echo "== ${name} =="

  if [[ ! -d "${target}/.git" ]]; then
    echo "status: ausente ou nao e repositorio Git (${target})"
    continue
  fi

  echo "remote origin: $(git -C "${target}" remote get-url origin 2>/dev/null || echo 'nao configurado')"
  echo "remote upstream: $(git -C "${target}" remote get-url upstream 2>/dev/null || echo 'nao configurado')"
  echo "branch: $(git -C "${target}" branch --show-current 2>/dev/null || echo 'indefinida')"
  echo "ultimo commit: $(git -C "${target}" log -1 --oneline 2>/dev/null || echo 'sem commits')"
  echo "tags recentes:"
  git -C "${target}" tag --sort=-creatordate | head -n 5 || true
  echo "alteracoes locais:"
  git -C "${target}" status --short | head -n 20 || true
done

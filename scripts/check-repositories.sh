#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_DIR="$(cd "${ROOT_DIR}/.." && pwd)"
REPOS=("LegislaGD" "SAPL-SD" "PortalModelo-SD" "e-Cidade-SD" "SIGI-SD")

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

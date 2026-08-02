#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_DIR="$(cd "${ROOT_DIR}/.." && pwd)"

declare -A REPOS=(
  ["SAPL-SD"]="https://github.com/sertaodigitalorg/SAPL-SD.git"
  ["PortalModelo-SD"]="https://github.com/sertaodigitalorg/PortalModelo-SD.git"
  ["e-Cidade-SD"]="https://github.com/sertaodigitalorg/e-Cidade-SD.git"
  ["SIGI-SD"]="https://github.com/sertaodigitalorg/SIGI-SD.git"
)

declare -A UPSTREAMS=(
  ["SAPL-SD"]="https://github.com/interlegis/sapl.git"
  ["PortalModelo-SD"]="https://github.com/interlegis/portalmodelo.git"
  ["e-Cidade-SD"]="https://github.com/DBSeller/e-cidade.git"
)

declare -A BOOTSTRAP_FROM_UPSTREAM=(
  ["SAPL-SD"]="1"
  ["PortalModelo-SD"]="1"
  ["e-Cidade-SD"]="1"
)

echo "Workspace: ${WORKSPACE_DIR}"

for name in "${!REPOS[@]}"; do
  target="${WORKSPACE_DIR}/${name}"
  origin="${REPOS[$name]}"

  if [[ -d "${target}/.git" ]]; then
    echo
    echo "${name}: repositorio existente, sem alterar branch ou historico"
    git -C "${target}" branch --show-current || true
    git -C "${target}" status --short || true
  elif [[ -e "${target}" ]]; then
    echo
    echo "${name}: caminho existe mas nao e repositorio Git: ${target}"
  else
    echo
    if [[ -n "${BOOTSTRAP_FROM_UPSTREAM[$name]:-}" && -n "${UPSTREAMS[$name]:-}" ]]; then
      echo "${name}: baixando base autorizada ${UPSTREAMS[$name]}"
      git clone "${UPSTREAMS[$name]}" "${target}" || {
        echo "${name}: clone da base autorizada falhou."
        continue
      }
      git -C "${target}" remote rename origin upstream
      git -C "${target}" remote add origin "${origin}"
      echo "${name}: origin configurado como ${origin}"
      echo "${name}: upstream configurado como ${UPSTREAMS[$name]}"
    else
      echo "${name}: clonando ${origin}"
      git clone "${origin}" "${target}" || {
        echo "${name}: clone do repositorio oficial falhou."
        continue
      }
    fi
  fi

  if [[ -d "${target}/.git" && -n "${UPSTREAMS[$name]:-}" ]]; then
    if git -C "${target}" remote get-url upstream >/dev/null 2>&1; then
      echo "${name}: upstream ja configurado como $(git -C "${target}" remote get-url upstream)"
    else
      echo "${name}: upstream sugerido nao configurado automaticamente: ${UPSTREAMS[$name]}"
    fi
  fi
done

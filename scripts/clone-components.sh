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

declare -A REPOS=(
  ["SAPL-SD"]="${SAPL_SD_GIT_URL:-https://github.com/sertaodigitalorg/SAPL-SD.git}"
  ["PortalModelo-SD"]="${PORTALMODELO_SD_GIT_URL:-https://github.com/sertaodigitalorg/PortalModelo-SD.git}"
  ["SIGI-SD"]="${SIGI_SD_GIT_URL:-https://github.com/sertaodigitalorg/SIGI-SD.git}"
  ["e-Cidade-SD"]="${ECIDADE_SD_GIT_URL:-https://github.com/sertaodigitalorg/e-Cidade-SD.git}"
)

declare -A UPSTREAMS=(
  ["SAPL-SD"]="https://github.com/interlegis/sapl.git"
  ["PortalModelo-SD"]="https://github.com/interlegis/portalmodelo.git"
  ["e-Cidade-SD"]="https://github.com/DBSeller/e-cidade.git"
)

branch_from_env() {
  local env_name="${LEGISLAGD_ENV:-development}"

  case "${env_name}" in
    dev|local|development)
      echo "dev"
      ;;
    hml|homolog|homologation|staging)
      echo "hml"
      ;;
    main|prod|production)
      echo "main"
      ;;
    *)
      echo "${env_name}"
      ;;
  esac
}

component_branch() {
  local name="$1"
  local default_branch="${LEGISLAGD_COMPONENT_BRANCH:-$(branch_from_env)}"

  case "${name}" in
    SAPL-SD)
      echo "${SAPL_SD_BRANCH:-${default_branch}}"
      ;;
    PortalModelo-SD)
      echo "${PORTALMODELO_SD_BRANCH:-${default_branch}}"
      ;;
    SIGI-SD)
      echo "${SIGI_SD_BRANCH:-${default_branch}}"
      ;;
    e-Cidade-SD)
      echo "${ECIDADE_SD_BRANCH:-${default_branch}}"
      ;;
    *)
      echo "${default_branch}"
      ;;
  esac
}

selected_components() {
  local include_portal="${LEGISLAGD_ENABLE_PORTAL:-1}"
  local include_sapl="${LEGISLAGD_ENABLE_SAPL:-1}"
  local include_sigi="${LEGISLAGD_ENABLE_SIGI:-1}"
  local include_ecidade="${LEGISLAGD_INCLUDE_ECIDADE:-0}"

  if [[ "${include_portal}" == "1" || "${include_portal}" == "true" || "${include_portal}" == "yes" || "${include_portal}" == "on" ]]; then
    echo "PortalModelo-SD"
  fi

  if [[ "${include_sapl}" == "1" || "${include_sapl}" == "true" || "${include_sapl}" == "yes" || "${include_sapl}" == "on" ]]; then
    echo "SAPL-SD"
  fi

  if [[ "${include_sigi}" == "1" || "${include_sigi}" == "true" || "${include_sigi}" == "yes" || "${include_sigi}" == "on" ]]; then
    echo "SIGI-SD"
  fi

  if [[ "${include_ecidade}" == "1" || "${include_ecidade}" == "true" || "${include_ecidade}" == "yes" || "${include_ecidade}" == "on" ]]; then
    echo "e-Cidade-SD"
  fi
}

echo "Workspace: ${WORKSPACE_DIR}"
echo "Branch padrao dos componentes: ${LEGISLAGD_COMPONENT_BRANCH:-$(branch_from_env)}"
echo "PortalModelo-SD habilitado: ${LEGISLAGD_ENABLE_PORTAL:-1}"
echo "SAPL-SD habilitado: ${LEGISLAGD_ENABLE_SAPL:-1}"
echo "SIGI-SD habilitado: ${LEGISLAGD_ENABLE_SIGI:-1}"
echo "e-Cidade-SD incluido: ${LEGISLAGD_INCLUDE_ECIDADE:-0}"

while IFS= read -r name; do
  target="${WORKSPACE_DIR}/${name}"
  origin="${REPOS[$name]}"
  branch="$(component_branch "${name}")"

  echo
  echo "== ${name} =="

  if [[ -d "${target}/.git" ]]; then
    echo "repositorio existente, sem alterar branch ou historico"
    echo "origin: $(git -C "${target}" remote get-url origin 2>/dev/null || echo 'nao configurado')"
    echo "upstream: $(git -C "${target}" remote get-url upstream 2>/dev/null || echo 'nao configurado')"
    echo "branch atual: $(git -C "${target}" branch --show-current 2>/dev/null || echo 'indefinida')"
    git -C "${target}" status --short || true
  elif [[ -e "${target}" ]]; then
    echo "caminho existe mas nao e repositorio Git: ${target}"
  else
    echo "clonando origem configurada: ${origin}"
    echo "branch configurada: ${branch}"
    git clone --branch "${branch}" --single-branch "${origin}" "${target}" || {
      echo "${name}: falha ao clonar branch '${branch}' de ${origin}."
      echo "Ajuste LEGISLAGD_COMPONENT_BRANCH ou a variavel especifica do modulo no .env."
      exit 1
    }
  fi

  if [[ -d "${target}/.git" && -n "${UPSTREAMS[$name]:-}" ]]; then
    if git -C "${target}" remote get-url upstream >/dev/null 2>&1; then
      echo "upstream ja configurado como $(git -C "${target}" remote get-url upstream)"
    else
      git -C "${target}" remote add upstream "${UPSTREAMS[$name]}" || true
      echo "upstream configurado como ${UPSTREAMS[$name]}"
    fi
  fi
done < <(selected_components)

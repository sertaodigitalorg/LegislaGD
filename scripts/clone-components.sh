#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "${ROOT_DIR}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  . "${ROOT_DIR}/.env"
  set +a
fi

COMPONENTS_DIR="${LEGISLAGD_COMPONENTS_DIR:-modules}"
GIT_STATUS_TIMEOUT="${LEGISLAGD_GIT_STATUS_TIMEOUT:-60}"
if [[ "${COMPONENTS_DIR}" = /* ]]; then
  WORKSPACE_DIR="${COMPONENTS_DIR}"
else
  WORKSPACE_DIR="${ROOT_DIR}/${COMPONENTS_DIR}"
fi

declare -A REPOS=(
  ["SAPL-SD"]="${SAPL_SD_GIT_URL:-https://github.com/sertaodigitalorg/SAPL-SD.git}"
  ["PortalModelo-SD"]="${PORTALMODELO_SD_GIT_URL:-https://github.com/sertaodigitalorg/PortalModelo-SD.git}"
  ["SIGI-SD"]="${SIGI_SD_GIT_URL:-https://github.com/sertaodigitalorg/SIGI-SD.git}"
  ["Plenario-Digital-Core"]="${PLENARIO_DIGITAL_CORE_GIT_URL:-https://github.com/sertaodigitalorg/Plenario-Digital-Core.git}"
  ["Chatwoot-SD"]="${CHATWOOT_SD_GIT_URL:-https://github.com/sertaodigitalorg/Chatwoot-SD.git}"
  ["e-Cidade-SD"]="${ECIDADE_SD_GIT_URL:-https://github.com/sertaodigitalorg/e-Cidade-SD.git}"
)

declare -A UPSTREAMS=(
  ["SAPL-SD"]="https://github.com/interlegis/sapl.git"
  ["PortalModelo-SD"]="https://github.com/interlegis/portalmodelo.git"
  ["Chatwoot-SD"]="https://github.com/chatwoot/chatwoot.git"
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
    Plenario-Digital-Core)
      echo "${PLENARIO_DIGITAL_CORE_BRANCH:-main}"
      ;;
    Chatwoot-SD)
      echo "${CHATWOOT_SD_BRANCH:-${default_branch}}"
      ;;
    e-Cidade-SD)
      echo "${ECIDADE_SD_BRANCH:-main}"
      ;;
    *)
      echo "${default_branch}"
      ;;
  esac
}

component_target() {
  local name="$1"

  case "${name}" in
    Chatwoot-SD)
      echo "${WORKSPACE_DIR}/SIGI-SD/apps/chatwoot-sd"
      ;;
    *)
      echo "${WORKSPACE_DIR}/${name}"
      ;;
  esac
}

selected_components() {
  local include_portal="${LEGISLAGD_ENABLE_PORTAL:-1}"
  local include_sapl="${LEGISLAGD_ENABLE_SAPL:-1}"
  local include_sigi="${LEGISLAGD_ENABLE_SIGI:-1}"
  local include_plenario="${LEGISLAGD_ENABLE_PLENARIO:-1}"
  local include_ecidade="${LEGISLAGD_ENABLE_ECIDADE:-${LEGISLAGD_INCLUDE_ECIDADE:-1}}"

  if [[ "${include_portal}" == "1" || "${include_portal}" == "true" || "${include_portal}" == "yes" || "${include_portal}" == "on" ]]; then
    echo "PortalModelo-SD"
  fi

  if [[ "${include_sapl}" == "1" || "${include_sapl}" == "true" || "${include_sapl}" == "yes" || "${include_sapl}" == "on" ]]; then
    echo "SAPL-SD"
  fi

  if [[ "${include_sigi}" == "1" || "${include_sigi}" == "true" || "${include_sigi}" == "yes" || "${include_sigi}" == "on" ]]; then
    echo "SIGI-SD"
    echo "Chatwoot-SD"
  fi

  if [[ "${include_plenario}" == "1" || "${include_plenario}" == "true" || "${include_plenario}" == "yes" || "${include_plenario}" == "on" ]]; then
    echo "Plenario-Digital-Core"
  fi

  if [[ "${include_ecidade}" == "1" || "${include_ecidade}" == "true" || "${include_ecidade}" == "yes" || "${include_ecidade}" == "on" ]]; then
    echo "e-Cidade-SD"
  fi
}

clone_from_legacy_if_available() {
  local name="$1"
  local branch="$2"
  local target="$3"
  local legacy_target="${ROOT_DIR}/../${name}"

  if [[ ! -d "${legacy_target}/.git" ]]; then
    return 1
  fi

  if ! git -C "${legacy_target}" show-ref --verify --quiet "refs/heads/${branch}" &&
     ! git -C "${legacy_target}" show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
    echo "repositorio local antigo encontrado, mas sem a branch '${branch}': ${legacy_target}"
    return 1
  fi

  echo "clonando a partir do repositorio local existente: ${legacy_target}"
  echo "branch configurada: ${branch}"
  git clone --branch "${branch}" "${legacy_target}" "${target}"
}

echo "Workspace: ${WORKSPACE_DIR}"
echo "Diretorio dos componentes: ${COMPONENTS_DIR}"
echo "Branch padrao dos componentes: ${LEGISLAGD_COMPONENT_BRANCH:-$(branch_from_env)}"
echo "PortalModelo-SD habilitado: ${LEGISLAGD_ENABLE_PORTAL:-1}"
echo "SAPL-SD habilitado: ${LEGISLAGD_ENABLE_SAPL:-1}"
echo "SIGI-SD habilitado: ${LEGISLAGD_ENABLE_SIGI:-1}"
echo "Chatwoot-SD acompanha SIGI-SD quando SIGI esta habilitado"
echo "Plenario-Digital-Core habilitado: ${LEGISLAGD_ENABLE_PLENARIO:-1}"
echo "e-Cidade-SD incluido: ${LEGISLAGD_ENABLE_ECIDADE:-${LEGISLAGD_INCLUDE_ECIDADE:-1}}"

mkdir -p "${WORKSPACE_DIR}"

while IFS= read -r name; do
  target="$(component_target "${name}")"
  origin="${REPOS[$name]}"
  branch="$(component_branch "${name}")"

  echo
  echo "== ${name} =="

  legacy_target="${ROOT_DIR}/../${name}"
  if [[ ! -d "${target}/.git" && -d "${legacy_target}/.git" ]]; then
    echo "aviso: repositorio encontrado no layout antigo: ${legacy_target}"
    echo "       o padrao atual e: ${target}"
    echo "       o script nao move automaticamente para preservar alteracoes locais"
  fi

  if [[ -d "${target}/.git" ]]; then
    echo "repositorio existente, sem alterar branch ou historico"
    echo "origin: $(git -C "${target}" remote get-url origin 2>/dev/null || echo 'nao configurado')"
    echo "upstream: $(git -C "${target}" remote get-url upstream 2>/dev/null || echo 'nao configurado')"
    echo "branch atual: $(git -C "${target}" branch --show-current 2>/dev/null || echo 'indefinida')"
    timeout "${GIT_STATUS_TIMEOUT}" git -C "${target}" status --short -uno || echo "status local ignorado por timeout"
  elif [[ -e "${target}" ]]; then
    echo "caminho existe mas nao e repositorio Git: ${target}"
  else
    if clone_from_legacy_if_available "${name}" "${branch}" "${target}"; then
      git -C "${target}" remote set-url origin "${origin}" || true
      echo "origin configurado como ${origin}"
    else
      echo "clonando origem configurada: ${origin}"
      echo "branch configurada: ${branch}"
      git clone --branch "${branch}" --single-branch "${origin}" "${target}" || {
      echo "${name}: falha ao clonar branch '${branch}' de ${origin}."
      echo "Ajuste LEGISLAGD_COMPONENT_BRANCH ou a variavel especifica do modulo no .env."
      exit 1
      }
    fi
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

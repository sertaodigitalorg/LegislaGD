#!/usr/bin/env bash
set -euo pipefail

head_branch="${1:-${HEAD_BRANCH:-}}"
base_branch="${2:-${BASE_BRANCH:-}}"
head_repository="${3:-${HEAD_REPOSITORY:-}}"
base_repository="${4:-${BASE_REPOSITORY:-}}"

if [[ -z "$head_branch" || -z "$base_branch" ]]; then
  echo "Uso: validate-branch-flow.sh <origem> <destino> [repo-origem] [repo-destino]" >&2
  exit 2
fi

if [[ -n "$head_repository" && -n "$base_repository" && "$head_repository" != "$base_repository" ]]; then
  echo "::error::Pull Requests devem originar em '${base_repository}', nao em '${head_repository}'." >&2
  exit 1
fi

case "$base_branch" in
  dev)
    case "$head_branch" in
      feature/* | fix/* | bugfix/* | chore/* | docs/*)
        ;;
      *)
        echo "::error::Pull Requests para 'dev' devem vir de feature/*, fix/*, bugfix/*, chore/* ou docs/*, nao de '${head_branch}'." >&2
        exit 1
        ;;
    esac
    ;;
  hml)
    if [[ "$head_branch" != "dev" ]]; then
      echo "::error::Pull Requests para 'hml' devem vir de 'dev', nao de '${head_branch}'." >&2
      exit 1
    fi
    ;;
  main)
    if [[ "$head_branch" != "hml" ]]; then
      echo "::error::Pull Requests para 'main' devem vir de 'hml', nao de '${head_branch}'." >&2
      exit 1
    fi
    ;;
  *)
    echo "::error::Destino nao suportado pela politica de branches: '${base_branch}'." >&2
    exit 1
    ;;
esac

echo "Branch flow valido: ${head_branch} -> ${base_branch}."

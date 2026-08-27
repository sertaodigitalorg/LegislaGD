#!/usr/bin/env bash
set -euo pipefail

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

while IFS= read -r -d '' file; do
  if grep -nE '(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN ([A-Z0-9 ]+ )?PRIVATE KEY-----|-----BEGIN RSA PRIVATE KEY-----' "$file" |
    while IFS=: read -r line_number _; do
      printf "%s:%s: possivel token GitHub ou chave privada real\n" "$file" "$line_number"
    done; then
    :
  fi

  line_number=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_number=$((line_number + 1))

    if [[ ! "$line" =~ ^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*(PASSWORD|PASS|SECRET|TOKEN|API_KEY|APIKEY|PRIVATE_KEY)[A-Za-z0-9_]*[[:space:]]*[:=][[:space:]]* ]]; then
      continue
    fi

    value="${line#*:}"
    if [[ "$line" == *=* && ( "$line" != *:* || "$line" == *=*:* ) ]]; then
      value="${line#*=}"
    fi
    value="${value%%#*}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"
    normalized="${value,,}"

    case "$normalized" in
      "" | "\${"* | "\$"* | \<*\> | changeme | change_me | example | placeholder | dummy | fake | test | dev | null | none | true | false | interlegis | *_dev | *_dev_* | *.localhost | http://*localhost*)
        continue
        ;;
    esac

    printf "%s:%s: possivel segredo hardcoded em variavel sensivel\n" "$file" "$line_number"
  done <"$file"
done < <(find . \
  -path './.git' -prune -o \
  -path './modules' -prune -o \
  -type f \
  ! -path './scripts/scan-secrets.sh' \
  ! -name '*.png' \
  ! -name '*.jpg' \
  ! -name '*.jpeg' \
  ! -name '*.gif' \
  ! -name '*.ico' \
  ! -name '*.pdf' \
  -print0) >"$tmp_file"

if [[ -s "$tmp_file" ]]; then
  cat "$tmp_file" >&2
  exit 1
fi

echo "Nenhum segredo potencialmente real encontrado."

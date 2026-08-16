#!/usr/bin/env bash
set -euo pipefail

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

set +e
find . \
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
  -print0 |
  xargs -0 awk '
    function report(reason) {
      printf "%s:%d: %s\n", FILENAME, FNR, reason
      found = 1
    }

    BEGIN {
      token_re = "(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}|github_pat_[A-Za-z0-9_]{20,}"
      key_re = "-----BEGIN ([A-Z0-9 ]+ )?PRIVATE KEY-----|-----BEGIN RSA PRIVATE KEY-----"
      assignment_re = "^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*(PASSWORD|PASS|SECRET|TOKEN|API_KEY|APIKEY|PRIVATE_KEY)[A-Za-z0-9_]*)[[:space:]]*[:=][[:space:]]*"
    }

    $0 ~ token_re { report("possivel token GitHub real") }
    $0 ~ key_re { report("possivel chave privada real") }

    $0 ~ assignment_re {
      line = $0
      sub(assignment_re, "", line)
      sub(/[[:space:]]*#.*/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      gsub(/^["'\'']|["'\'']$/, "", line)
      normalized = tolower(line)

      if (line == "" ||
          line ~ /^\$\{/ ||
          line ~ /^\$/ ||
          line ~ /^<.*>$/ ||
          normalized ~ /^(changeme|change_me|example|placeholder|dummy|fake|test|dev|null|none|true|false|interlegis)$/ ||
          line ~ /(^|_)dev(_|$)/ ||
          line ~ /\.localhost$/ ||
          line ~ /^http:\/\/.*localhost/) {
        next
      }

      report("possivel segredo hardcoded em variavel sensivel")
    }

    END { exit found ? 1 : 0 }
  ' >"$tmp_file"
scan_status=$?
set -e

if [[ -s "$tmp_file" ]]; then
  cat "$tmp_file" >&2
  exit 1
fi

if [[ "$scan_status" -ne 0 ]]; then
  echo "Falha ao executar scanner de segredos." >&2
  exit "$scan_status"
fi

echo "Nenhum segredo potencialmente real encontrado."

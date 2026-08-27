#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
validator="${script_dir}/validate-branch-flow.sh"

pass_cases=(
  "feature/test dev"
  "fix/test dev"
  "bugfix/test dev"
  "chore/test dev"
  "docs/test dev"
  "dev hml"
  "hml main"
)

fail_cases=(
  "feature/test hml"
  "feature/test main"
  "fix/test hml"
  "fix/test main"
  "bugfix/test hml"
  "bugfix/test main"
  "chore/test hml"
  "chore/test main"
  "docs/test hml"
  "docs/test main"
  "dev main"
  "hml dev"
  "main dev"
  "main hml"
  "teste-qualquer dev"
)

for item in "${pass_cases[@]}"; do
  read -r head base <<<"$item"
  "$validator" "$head" "$base" "sertaodigitalorg/LegislaGD" "sertaodigitalorg/LegislaGD" >/dev/null
done

for item in "${fail_cases[@]}"; do
  read -r head base <<<"$item"
  if "$validator" "$head" "$base" "sertaodigitalorg/LegislaGD" "sertaodigitalorg/LegislaGD" >/dev/null 2>&1; then
    echo "Caso deveria falhar, mas passou: ${head} -> ${base}" >&2
    exit 1
  fi
done

if "$validator" "feature/test" "dev" "fork/LegislaGD" "sertaodigitalorg/LegislaGD" >/dev/null 2>&1; then
  echo "PR de fork deveria falhar, mas passou." >&2
  exit 1
fi

echo "Branch flow tests passed."

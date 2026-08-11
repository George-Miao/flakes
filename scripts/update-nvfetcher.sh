#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

shopt -s nullglob
configs=(nvfetcher/*.toml)

if ((${#configs[@]} == 0)); then
  echo "No nvfetcher configs found under nvfetcher/" >&2
  exit 1
fi

for config in "${configs[@]}"; do
  unit="$(basename "$config" .toml)"
  nix-shell -p nvfetcher --command \
    "nvfetcher -v --keep-going -c $config -o generated/$unit"
done

#!/usr/bin/env bash
set -euo pipefail

NODE="${1:-calisto}"
FLAKE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[${NODE}] Syncing flake to Pi..."
rsync -az --delete \
  --exclude='.git/' \
  --exclude='result' \
  --exclude='result-*' \
  "${FLAKE_ROOT}/" "worker@${NODE}:/tmp/nixos-flake/"

echo "[${NODE}] Rebuilding on Pi..."
ssh -t "worker@${NODE}" \
  "sudo nixos-rebuild switch --flake /tmp/nixos-flake#${NODE} --accept-flake-config"

echo "[${NODE}] Done"

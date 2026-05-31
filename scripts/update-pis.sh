#!/usr/bin/env bash
set -euo pipefail

NODES=("calisto" "europa" "ganymede")
FLAKE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Flake: ${FLAKE_ROOT}"

for node in "${NODES[@]}"; do
  echo "[${node}] Building and deploying..."
  nixos-rebuild switch \
    --flake "${FLAKE_ROOT}#${node}" \
    --target-host "worker@${node}" \
    --accept-flake-config \
    --no-reexec
  echo "[${node}] Done"
done

echo "All nodes updated"

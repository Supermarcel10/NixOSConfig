#!/usr/bin/env bash
set -euo pipefail

NODES=("calisto" "europa" "ganymede")
FAILED=()

for node in "${NODES[@]}"; do
  echo "[${node}] Pulling and rebuilding..."
  if ssh -t "worker@${node}" "
    set -euo pipefail
    cd /home/worker/.nixos
    git fetch origin || { echo 'FAILED: git fetch'; exit 1; }
    git reset --hard origin/main || { echo 'FAILED: git reset'; exit 1; }
    sudo nixos-rebuild switch --flake /home/worker/.nixos#${node} --accept-flake-config || { echo 'FAILED: nixos-rebuild'; exit 1; }
  "; then
    echo "[${node}] Done"
  else
    echo "[${node}] FAILED — see output above"
    FAILED+=("${node}")
  fi
done

if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo ""
  echo "ERROR: The following nodes failed: ${FAILED[*]}"
  exit 1
fi

echo "All nodes updated successfully"

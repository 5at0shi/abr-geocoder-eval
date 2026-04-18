#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_DIR="${ROOT_DIR}/results"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/cleanup_abr_data.sh <region|all>

Examples:
  bash scripts/cleanup_abr_data.sh chiyoda
  bash scripts/cleanup_abr_data.sh ebina
  bash scripts/cleanup_abr_data.sh all

This removes only downloaded/test data directories under results/*/data.
It keeps outputs, summaries, samples, docs, and scripts.
EOF
}

cleanup_region() {
  local region="$1"
  local target_dir="${RESULTS_DIR}/${region}/data"

  if [[ ! -d "${target_dir}" ]]; then
    echo "[skip] ${target_dir} does not exist"
    return 0
  fi

  rm -rf "${target_dir}"
  echo "[done] removed ${target_dir}"
}

main() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  case "$1" in
    chiyoda|ebina)
      cleanup_region "$1"
      ;;
    all)
      cleanup_region "chiyoda"
      cleanup_region "ebina"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"

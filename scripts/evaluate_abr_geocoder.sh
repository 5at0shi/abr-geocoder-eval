#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_DIR="${PKG_DIR:-/tmp/abrg-test2}"
ABRG_BIN="${ABRG_BIN:-${PKG_DIR}/node_modules/.bin/abrg}"
WORK_DIR="${ROOT_DIR}/results"

run_region() {
  local name="$1"
  local lg_code="$2"
  local sample_dir="$3"
  local data_dir="${WORK_DIR}/${name}/data"
  local out_dir="${WORK_DIR}/${name}/outputs"

  rm -rf "${data_dir}" "${out_dir}"
  mkdir -p "${data_dir}" "${out_dir}"

  "${ABRG_BIN}" download -c "${lg_code}" -d "${data_dir}" --silent

  for sample_file in "${sample_dir}"/*.txt; do
    local sample_name
    sample_name="$(basename "${sample_file}" .txt)"
    for target in all residential parcel; do
      "${ABRG_BIN}" "${sample_file}" -d "${data_dir}" --target "${target}" --format json --silent > "${out_dir}/${sample_name}.${target}.json"
    done
  done

  /usr/bin/python3 "${ROOT_DIR}/scripts/summarize_results.py" "${out_dir}" > "${WORK_DIR}/${name}/summary.md"
}

MODE="${1:-all}"

if [[ "${MODE}" == "all" || "${MODE}" == "chiyoda" ]]; then
  run_region "chiyoda" "131016" "${ROOT_DIR}/samples/chiyoda"
fi

if [[ "${MODE}" == "all" || "${MODE}" == "ebina" ]]; then
  run_region "ebina" "142158" "${ROOT_DIR}/samples/ebina"
fi

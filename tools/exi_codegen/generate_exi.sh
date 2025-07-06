#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CODEGEN_DIR="$ROOT_DIR/tools/exi_codegen"
CBEXIGEN_DIR="$CODEGEN_DIR/cbexigen"
SCHEMA_SRC_DIR="$CODEGEN_DIR/schemas"
SCHEMA_DST_DIR="$CBEXIGEN_DIR/src/input/schemas"

# clone cbexigen repository if not present
if [ ! -d "$CBEXIGEN_DIR" ]; then
    git clone https://github.com/EVerest/cbexigen.git "$CBEXIGEN_DIR"
fi

# copy provided schemas if available
mkdir -p "$SCHEMA_DST_DIR"
if [ -d "$SCHEMA_SRC_DIR" ]; then
    cp -a "$SCHEMA_SRC_DIR/"* "$SCHEMA_DST_DIR/" 2>/dev/null || true
fi

pushd "$CBEXIGEN_DIR" >/dev/null
python3 -m pip install -r requirements.txt

CONFIG_OPT=()
if [ -n "${EXI_CONFIG_FILE:-}" ]; then
    CONFIG_OPT+=(--config_file "${EXI_CONFIG_FILE}")
fi
python3 src/main.py --auto-download-public-xsd 1 "${CONFIG_OPT[@]}"
popd >/dev/null

# copy generated codec to repository
OUTPUT_DIR="$CBEXIGEN_DIR/src/output/c"
DEST_DIR="$ROOT_DIR/lib/v2g_exi"
rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"
cp -a "$OUTPUT_DIR/." "$DEST_DIR/"

printf '\nEXI codec written to %s\n' "$DEST_DIR"

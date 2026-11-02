#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/src/duckdb"
QUACK_SRC="$ROOT/src/duckdb-quack"
OUT="${OUT_DIR:-$ROOT/out}"
QUACK_REF="${QUACK_REF:-main}"

mkdir -p "$ROOT/src" "$OUT"

export CC=arm-linux-gnueabihf-gcc
export CXX=arm-linux-gnueabihf-g++

if [[ ! -d "$SRC/.git" ]]; then
  git clone --branch v2.0.0 --depth 1 https://github.com/duckdb/duckdb.git "$SRC"
fi

if [[ ! -d "$QUACK_SRC/.git" ]]; then
  git clone https://github.com/duckdb/duckdb-quack.git "$QUACK_SRC"
fi
git -C "$QUACK_SRC" fetch --depth 1 origin "$QUACK_REF"
git -C "$QUACK_SRC" checkout --detach FETCH_HEAD
git -C "$QUACK_SRC" submodule update --init --recursive

CONFIG="$ROOT/duckdb/extension_config.cmake"
sed "s|@QUACK_SOURCE_DIR@|$QUACK_SRC|g" \
  "$ROOT/duckdb/extension_config.cmake.in" > "$CONFIG"

printf 'DuckDB revision: '
git -C "$SRC" rev-parse HEAD
printf 'Quack revision: '
git -C "$QUACK_SRC" rev-parse HEAD

cd "$SRC"

# The explicit platform ID is custom; DuckDB does not distribute official
# linux_armv7 extension binaries. The target compiler flags are ARMv7 hard-float.
GEN=ninja \
BUILD_JEMALLOC=0 \
EXTENSION_CONFIGS="$CONFIG" \
CMAKE_VARS="-DCMAKE_TOOLCHAIN_FILE=$ROOT/cmake/armv7-linux-gnueabihf.cmake -DDUCKDB_EXPLICIT_PLATFORM=linux_armv7 -DDUCKDB_OPTIMIZATION_PROFILE=NONE -DENABLE_JEMALLOC=OFF" \
make release

# Collect outputs without stripping extension metadata.
find build/release -type f \\( -name duckdb -o -name 'libduckdb.so' -o -name '*.duckdb_extension' \\) \
  -exec cp --parents {} "$OUT/" \\;

# Diagnostic reports; these do not substitute for running on ARM hardware.
find "$OUT" -type f \\( -name duckdb -o -name 'libduckdb.so' -o -name '*.duckdb_extension' \\) \
  -exec sh -c '
    f="$1"
    echo "===== $f ====="
    file "$f" || true
    arm-linux-gnueabihf-readelf -h "$f" 2>/dev/null || true
    arm-linux-gnueabihf-readelf --version-info "$f" 2>/dev/null || true
    arm-linux-gnueabihf-readelf -d "$f" 2>/dev/null || true
  ' sh {} \\; > "$OUT/elf-report.txt"

echo "Build artifacts are in $OUT"

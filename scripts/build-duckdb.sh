#!/usr/bin/env bash
set -euo pipefail

OUT="${OUT_DIR:-/out}"
SRC="${SRC_DIR:-/work/src}"
mkdir -p "$OUT" "$(dirname "$SRC")"

if [[ ! -d "$SRC/.git" ]]; then
  git clone --branch v2.0.0 --depth 1 https://github.com/duckdb/duckdb.git "$SRC"
fi

cd "$SRC"

export CC=arm-linux-gnueabihf-gcc
export CXX=arm-linux-gnueabihf-g++

# Makefile-based DuckDB build. This is a first-pass cross-build configuration;
# inspect the configure/build logs and adjust if the pinned source revision's
# Makefile does not propagate a variable as expected.
GEN=ninja \
BUILD_JEMALLOC=0 \
DUCKDB_PLATFORM=linux_armv7 \
DUCKDB_OPTIMIZATION_PROFILE=NONE \
EXTENSION_CONFIGS=/work/extension_config.cmake \
CMAKE_VARS="-DCMAKE_TOOLCHAIN_FILE=/work/armv7-linux-gnueabihf.cmake -DDUCKDB_EXPLICIT_PLATFORM=linux_armv7 -DDUCKDB_OPTIMIZATION_PROFILE=NONE -DENABLE_JEMALLOC=OFF" \
make release

# Locate outputs defensively; layout can vary with generator/build target.
find build -type f \\( -name duckdb -o -name 'libduckdb.so' \\) -print
find build -type f \\( -name duckdb -o -name 'libduckdb.so' \\) -exec cp -v {} "$OUT/" \\;

if [[ -f "$OUT/libduckdb.so" ]]; then
  arm-linux-gnueabihf-readelf -h "$OUT/libduckdb.so" > "$OUT/libduckdb.elf-header.txt"
  arm-linux-gnueabihf-readelf --version-info "$OUT/libduckdb.so" > "$OUT/libduckdb.glibc-versions.txt"
fi

printf 'Artifacts copied to %s\n' "$OUT"

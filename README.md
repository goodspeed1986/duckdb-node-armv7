# DuckDB 2.0.0 + Node API: ARMv7 / Debian 11 Bullseye scaffold

This repository is a **cross-build scaffold**, not a verified release pipeline.
Target: Debian 11 Bullseye, `armhf` / ARMv7 hard-float, glibc 2.31, Node.js 20.

## What is included

- Bullseye-based Docker build environment with the Debian ARMHF cross compiler.
- CMake toolchain for `arm-linux-gnueabihf`.
- A DuckDB 2.0.0 build script that requests the custom platform `linux_armv7`.
- A GitHub Actions workflow that runs the build and uploads the output.
- An extension configuration file showing the intended `json` / `quack` configuration.

## Important limitations (read before relying on the output)

1. `linux_armv7` is a custom platform identifier, not an officially distributed DuckDB platform.
2. The `quack` extension must be verified against the exact DuckDB 2.0.0 source revision. The extension config is an initial attempt; the build is expected to fail if that source tree does not expose Quack as a built-in extension target.
3. The Node native binding is **not yet built by this scaffold**. The upstream `duckdb-node-neo` binding currently lacks Linux 32-bit ARM support and downloads official prebuilt DuckDB libraries for supported architectures. A real ARMv7 implementation needs changes to its loader, package metadata, `binding.gyp`, and fetch/build logic.
4. The cross compiler and target sysroot are from Debian Bullseye. Still validate the resulting binary on the actual target device; checking ELF metadata alone does not prove runtime compatibility.
5. The Docker image uses archived Debian repositories as Bullseye is now an old release. Package availability may change.

Do not publish the resulting artifacts as production binaries until the extension build, dynamic dependencies, and runtime tests have passed on ARMv7.

## Run locally

```bash
docker build -t duckdb-armv7-builder .
docker run --rm -v "$PWD/out:/out" duckdb-armv7-builder
```

The build script clones DuckDB tag `v2.0.0` and writes artifacts under `/out`.

## GitHub Actions

Push this repository to GitHub. The workflow `.github/workflows/build-armv7.yml`
runs on pushes and can also be started manually. It uploads the build directory
as a workflow artifact.

## Runtime validation on the ARMv7 device

After copying the artifacts to the Debian 11 device:

```bash
file ./duckdb
readelf -h ./libduckdb.so
readelf --version-info ./libduckdb.so
ldd ./libduckdb.so
```

Then run a minimal DuckDB query and explicitly test loading both extensions.

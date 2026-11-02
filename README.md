# DuckDB 2.0.0 ARMv7 cross-build on Ubuntu 22.04

This scaffold builds on a GitHub Actions `ubuntu-22.04` runner. It does not
install Docker, does not run Debian, and does not create a Debian sysroot.

Target CPU/ABI: 32-bit ARMv7 hard-float (`arm-linux-gnueabihf`).
Build host: Ubuntu 22.04 x86_64.

## Included

- Ubuntu 22.04 GitHub Actions workflow.
- ARMHF cross compiler installation via apt.
- DuckDB v2.0.0 source checkout and cross-build.
- JSON extension build configuration.
- Quack source checkout and out-of-tree extension configuration.
- ELF inspection of produced artifacts.

## Important: this is not a finished Node.js binary release

The workflow currently builds DuckDB and extension artifacts. It does not
produce `duckdb.node` yet. Upstream `duckdb-node-neo` does not currently ship
a Linux 32-bit ARM target; its GYP target, loader, npm platform package and
library-fetch logic need an ARM port. See `patches/NODE-ARMV7.md`.

Quack is experimental and maintained out-of-tree. This scaffold checks out
its current default branch unless `QUACK_REF` is pinned. For a reproducible
release, set `QUACK_REF` to a tested commit SHA and confirm that commit is
compatible with DuckDB v2.0.0. Quack also needs target-architecture OpenSSL;
the workflow installs Ubuntu's ARMHF OpenSSL development package.

## Run

Push this repository to GitHub and run **Actions → Build DuckDB ARMv7**.
Artifacts are uploaded as `duckdb-2.0.0-linux-armv7-ubuntu2204`.

## Output validation

The workflow records ELF headers and dynamic dependencies. Before using the
files on a device, run them on the actual ARMv7 system and test:

```sql
LOAD json;
LOAD quack;
```

Do not strip `.duckdb_extension` files: DuckDB appends compatibility metadata
to extension binaries.

# Node.js 20 ARMv7 binding — remaining implementation

This scaffold does not fabricate a `.node` binary. The native binding port must
be applied and compiled against the exact DuckDB shared library produced by the
build job.

Required changes in `duckdb-node-neo`:

1. Add a Linux 32-bit ARM (`arm`) target in `bindings/binding.gyp`.
2. Add a platform package named `@duckdb/node-bindings-linux-arm`; npm's CPU
   architecture token is `arm`, and Node reports `process.arch === 'arm'`.
3. Add that package to `@duckdb/node-bindings` optional dependencies and loader.
4. Change the GYP/fetch logic to link the local ARMHF `libduckdb.so` rather than
   downloading one of DuckDB's official x64/arm64 release archives.
5. Cross-build with Node.js 20 headers, `arm-linux-gnueabihf-g++`, and
   `-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard`.
6. Test `require('@duckdb/node-api')`, database open, query execution and
   extension loading on a real ARMv7 Linux runtime.

The Node API migration for DuckDB 2.0 has had ongoing upstream work. Do not
assume that the latest branch is a stable release API without pinning and
testing a specific commit.

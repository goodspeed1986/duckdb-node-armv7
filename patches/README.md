# Node binding patch — not yet applied

The Node.js part is deliberately not represented as a fake patch. Before it can
be built for ARMv7, the upstream `duckdb-node-neo` source needs all of these
changes, tested together:

1. Add the Linux `arm` target to `bindings/binding.gyp`.
2. Build the addon with `arm-linux-gnueabihf-g++`, Node 20 headers, and a
   consistent ARMHF sysroot.
3. Link against the ARMv7 `libduckdb.so` built in this repository instead of
   invoking the upstream fetch script for official prebuilt libraries.
4. Add `@duckdb/node-bindings-linux-arm` to the platform package set and
   optional dependencies; npm architecture metadata must use `arm`.
5. Ensure the JS loader resolves `linux-arm` to that package.
6. Test installation and `require('@duckdb/node-api')` on an actual Bullseye
   ARMv7 Node 20 runtime.

A package named `...linux-armv7` will not be selected by the default
`process.platform + '-' + process.arch` naming convention because Node reports
`process.arch === 'arm'` on 32-bit ARM.

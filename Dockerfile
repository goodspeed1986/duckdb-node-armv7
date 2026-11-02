FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN printf 'deb http://archive.debian.org/debian bullseye main\n' > /etc/apt/sources.list \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates git cmake ninja-build make python3 \
      gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
      binutils-arm-linux-gnueabihf pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY cmake/armv7-linux-gnueabihf.cmake /work/armv7-linux-gnueabihf.cmake
COPY duckdb/extension_config.cmake /work/extension_config.cmake
COPY scripts/build-duckdb.sh /work/build-duckdb.sh
RUN chmod +x /work/build-duckdb.sh

ENTRYPOINT ["/work/build-duckdb.sh"]

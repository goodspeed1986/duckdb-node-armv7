set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armv7l)

set(CMAKE_C_COMPILER arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)

set(CMAKE_C_FLAGS_INIT "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard")
set(CMAKE_CXX_FLAGS_INIT "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard")

# Use the cross compiler's Ubuntu-provided target root, not a Debian sysroot.
execute_process(
  COMMAND arm-linux-gnueabihf-gcc -print-sysroot
  OUTPUT_VARIABLE ARMHF_COMPILER_SYSROOT
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(ARMHF_COMPILER_SYSROOT AND NOT ARMHF_COMPILER_SYSROOT STREQUAL "/")
  set(CMAKE_SYSROOT "${ARMHF_COMPILER_SYSROOT}")
  set(CMAKE_FIND_ROOT_PATH "${ARMHF_COMPILER_SYSROOT}")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

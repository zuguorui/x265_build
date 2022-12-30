#! /bin/bash

SOURCE_PATH=/Users/zuguorui/work_space/x265

# compile toolchain settings
NDK=/Users/zuguorui/Library/Android/sdk/ndk/21.4.7075529
HOST_TAG=darwin-x86_64
HOST_ROOT=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
SYSROOT=$HOST_ROOT/sysroot

API=26

ARCH_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=1 -DCMAKE_SYSTEM_NAME=Linux"



# armv7
ARCH=armeabi-v7a
CPU=armv7-a
echo compile $CPU
INSTALL_PATH="$(pwd)/android/$CPU"
BIN_PREFIX=armv7a-linux-androideabi
CC=$BIN_PREFIX$API-clang
CXX=$BIN_PREFIX$API-clang++
LD=$BIN_PREFIX$API-ld
AR=$BIN_PREFIX$API-ar
AS=$BIN_PREFIX$API-as
CFLAGS="-march=$CPU -mfpu=neon -fPIC -O2 -DANDROID -D__ANDROID__ -D__ANDROID_API__=$API -I$SYSROOT/usr/include"
CXXFLAGS="-std=c++11"
LDFLAGS="-march=$CPU -lc -lm -ldl -llog -lc++_shared -L$SYSROOT/usr/lib/arm-linux-androideabi/$API"

cmake -Wno-dev \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
    -DCMAKE_SYSROOT="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/sysroot" \
    -DCMAKE_FIND_ROOT_PATH="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/sysroot" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH" \
    -DCMAKE_SYSTEM_NAME=Generic \
    -DCMAKE_C_COMPILER="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$CC" \
    -DCMAKE_CXX_COMPILER="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$CXX" \
    -DCMAKE_LINKER="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$LD" \
    -DCMAKE_AR="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$AR" \
    -DCMAKE_AS="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$AS" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
    -DSTATIC_LINK_CRT=1 \
    -DENABLE_PIC=1 \
    -DENABLE_CLI=0 \
    $ARCH_OPTIONS \
    -DCMAKE_SYSTEM_PROCESSOR="$ARCH" \
    -DENABLE_SHARED=1 $SOURCE_PATH/source || exit 1

make -j4
make install

# armv8

ARCH=arm64-v8a
CPU=armv8-a
echo compile $CPU
INSTALL_PATH="$(pwd)/android/$CPU"
BIN_PREFIX=aarch64-linux-android
CC=$BIN_PREFIX$API-clang
CXX=$BIN_PREFIX$API-clang++
LD=$BIN_PREFIX$API-ld
AR=$BIN_PREFIX$API-ar
AS=$BIN_PREFIX$API-as
CFLAGS="-march=$CPU -fPIC -O2 -DANDROID -D__ANDROID__ -D__ANDROID_API__=$API -I$SYSROOT/usr/include"
CXXFLAGS="-std=c++11"
LDFLAGS="-march=$CPU -lc -lm -ldl -llog -lc++_shared -L$SYSROOT/usr/lib/aarch64-linux-android/$API"

cmake -Wno-dev -G "Unix Makefiles" \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
    -DCMAKE_SYSROOT="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/sysroot" \
    -DCMAKE_FIND_ROOT_PATH="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/sysroot" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH" \
    -DCMAKE_SYSTEM_NAME=Generic \
    -DCMAKE_C_COMPILER="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$CC" \
    -DCMAKE_CXX_COMPILER="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$CXX" \
    -DCMAKE_LINKER="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$LD" \
    -DCMAKE_AR="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$AR" \
    -DCMAKE_AS="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$AS" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
    -DSTATIC_LINK_CRT=1 \
    -DENABLE_PIC=1 \
    -DENABLE_CLI=0 \
    $ARCH_OPTIONS \
    -DCMAKE_SYSTEM_PROCESSOR="$ARCH" \
    -DENABLE_SHARED=1 $SOURCE_PATH/source || exit 1

make -j4
make install



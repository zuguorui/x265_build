# CMake toolchain file for cross compiling x265 for ARM arch
# This feature is only supported as experimental. Use with caution.
# Please report bugs on bitbucket
# Run cmake with: cmake -DCMAKE_TOOLCHAIN_FILE=crosscompile.cmake -G "Unix Makefiles" ../../source && ccmake ../../source

set(CROSS_COMPILE_ARM 1)
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armv7-a)

# specify the cross compiler
set(CMAKE_C_COMPILER /Users/zuguorui/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi26-clang)
set(CMAKE_CXX_COMPILER /Users/zuguorui/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi26-clang++)

# libdl: /Users/zuguorui/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/arm-linux-androideabi/26/libdl.so

# pthread: /Users/zuguorui/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include

# specify the target environment
SET(CMAKE_FIND_ROOT_PATH  /Users/zuguorui/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64)
set(CMAKE_SYSROOT /Users/zuguorui/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64/sysroot)
set(CMAKE_INSTALL_PREFIX /Users/zuguorui/work_space/x265_build/android/armv7)
set(CMAKE_C_FLAG "-I/Users/zuguorui/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include")
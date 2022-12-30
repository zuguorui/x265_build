# 为Android编译x265动态链接库。

参考博客：[Android libX265库的交叉编译及x265编码，解码测试程序](https://www.jianshu.com/p/7d1aeb5dce36)，感谢作者的贡献。

## 0. 文档说明

`wasted_build_android.sh`是参考[mobile-ffmpeg](https://github.com/tanersener/mobile-ffmpeg)的配置。很可惜还不能运行。但是可以作为参考。
`mobile-ffmpeg/`下的是mobile-ffmpeg编译x265的脚本并且对其进行了一些修改。运行`android-x265.sh`可以成功编译静态库。

`build_android.sh`可以按照官方推荐的步骤编译动态库。它会将`android_armv7.cmake`或者`android_armv8.cmake`作为交叉编译配置传递给官方cmake脚本。这两个文件也是参考了官方交叉编译脚本，在`$X265_PATH/build`文件夹下，有各平台交叉编译的配置示范。

由于x265官方编译使用ccmake，这是一个配置程序，需要手动在编译时配置参数。所以比较难做到全自动脚本化。

由于Android限制，pthread并没有单独的库提供，因此在编译之前需要对官方的cmake文件做一些修改。文本方式打开`$X265_PATH/source/CMakeLists.txt`。



## 1. 准备工作

- 准备NDK，确保cmake已经安装。
- 下载x265源码。
- 下载此工程。

对于NDK，在r19版本之前需要手动提取编译工具链，可参考[NDK-standalone-toolchain](https://developer.android.google.cn/ndk/guides/standalone_toolchain?hl=zh-cn)。这里使用的是r21，不需要这个步骤。

## 2. 编译静态库

- 打开此工程下`build/androix-x265.sh`进行编辑。
- 修改`ANDROID_NDK_ROOT`为你的NDK目录。
- 修改`ARCH`为你想要的cpu架构，在mobile-ffmpeg中，架构分别为`arm-v7a`、`arm-v7a-neon`、`arm64-v8a` `x86`、`x86-64`。
- 根据系统修改`TOOLCHAIN`。
- 修改`SOURCE_PATH`为x265源码目录。
- 运行`build/androix-x265.sh`。

## 3. 编译动态库

由于x265编译出的是so库带有版本号，类似于`libx265.so.123`，FFmpeg无法识别这样的名称，在桌面平台这并不是一件困难的事，只需要一个软连接即可。但是Android由于打包无法这么操作。因此需要进行一些中间步骤，确保能够输出正确的名称。

- 由于Android限制，pthread并没有单独的库提供，因此在编译之前需要对官方的cmake文件做一些修改。文本方式打开`$X265_PATH/source/CMakeLists.txt`，去掉链接pthread库
```cmake
if(UNIX)
    # list(APPEND PLATFORM_LIBS pthread) # 注释这句
    find_library(LIBRT rt)
    if(LIBRT)
        list(APPEND PLATFORM_LIBS rt)
    endif()
    mark_as_advanced(LIBRT)
    find_library(LIBDL dl)
```
- 打开`build_android.sh`，修改`SOURCE_PATH`为x265的源码目录。将`-DCMAKE_TOOLCHAIN_FILE=../android_armv8.cmake`中的文件名改为你想要构建的cpu架构文件。
- 打开对应的cmake文件，`android_armv8.cmake`或者`android_armv7.cmake`，修改里面所有的相关路径。
- 运行`build_android.sh`，触发ccmake，你将会看到一个配置界面：
```shell
                                                    Page 1 of 1
 BIN_INSTALL_DIR                  bin
 CHECKED_BUILD                    OFF
 CMAKE_BUILD_TYPE                 Release
 CMAKE_INSTALL_PREFIX             # 这里输入你想要输出so库的位置
 CMAKE_TOOLCHAIN_FILE             /Users/zuguorui/work_space/x265_build/android_armv8.cmake
 DETAILED_CU_STATS                OFF
 ENABLE_AGGRESSIVE_CHECKS         OFF
 ENABLE_ASSEMBLY                  OFF # 关闭汇编
 ENABLE_CLI                       ON
 ENABLE_HDR10_PLUS                OFF
 ENABLE_LIBNUMA                   ON
 ENABLE_LIBVMAF                   OFF
 ENABLE_PIC                       ON # 开启位置无关
 ENABLE_PPA                       OFF
 ENABLE_SHARED                    ON
 ENABLE_SVT_HEVC                  OFF
 ENABLE_TESTS                     OFF
 ENABLE_VTUNE                     OFF
 FSANITIZE
 LIBDL                            # 这里要填写你NDK中ld可执行程序的路径，参考cmake文件中的路径。
 LIB_INSTALL_DIR                  lib
 NASM_EXECUTABLE                  NASM_EXECUTABLE-NOTFOUND
 NO_ATOMICS                       OFF
 NUMA_ROOT_DIR                    NUMA_ROOT_DIR-NOTFOUND
 STATIC_LINK_CRT                  OFF
 VMAF                             /usr/local/lib/libvmaf.a
 WARNINGS_AS_ERRORS               OFF

BIN_INSTALL_DIR: Install location of executables                                                                                       
Keys: [enter] Edit an entry [d] Delete an entry                                                                    CMake Version 3.23.3
      [l] Show log output   [c] Configure
      [h] Help              [q] Quit without generating
      [t] Toggle advanced mode (currently off)
```

按照上面的配置，完成后，按`c`生成配置，出现生成配置过程，完成后按`e`退出生成配置界面，然后按`g`生成配置并退出该界面。此时在`cmake_build`下生成了一系列配置文件。
- 打开`cmake_build/CMakeFiles/cli.dir/link.txt`，找到libx265.so.123这样的字段，去掉后面的版本号，保存。
```shell
/Users/zuguorui/work_space/x265_build/cmake_build: libx265.so.192 # 去掉版本号
```
- 打开`cmake_build/CMakeFiles/x265-shared.dir/link.txt`，找到
```shell
-shared -Wl,-soname,libx265.so.192 -o libx265.so.192
```
字段，并修改为
```shell
-shared -o libx265.so
```
- 打开`cmake_build/CMakeFiles/x265-shared.dir/build.make`，找到如下段落。
```shell
libx265.so.192: asm.S.o
libx265.so.192: cpu-a.S.o
libx265.so.192: mc-a.S.o
libx265.so.192: sad-a.S.o
libx265.so.192: pixel-util.S.o
libx265.so.192: ssd-a.S.o
libx265.so.192: blockcopy8.S.o
libx265.so.192: ipfilter8.S.o
libx265.so.192: dct-a.S.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/analysis.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/search.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/bitcost.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/motion.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/slicetype.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/frameencoder.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/framefilter.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/level.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/nal.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/sei.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/sao.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/entropy.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/dpb.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/ratecontrol.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/reference.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/encoder.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/api.cpp.o
libx265.so.192: encoder/CMakeFiles/encoder.dir/weightPrediction.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/arm/asm-primitives.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/primitives.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/pixel.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/dct.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/lowpassdct.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/ipfilter.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/intrapred.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/loopfilter.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/constants.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/cpu.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/version.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/threading.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/threadpool.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/wavefront.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/md5.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/bitstream.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/yuv.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/shortyuv.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/picyuv.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/common.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/param.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/frame.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/framedata.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/cudata.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/slice.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/lowres.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/piclist.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/predict.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/scalinglist.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/quant.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/deblock.cpp.o
libx265.so.192: common/CMakeFiles/common.dir/scaler.cpp.o
libx265.so.192: CMakeFiles/x265-shared.dir/build.make
libx265.so.192: x265.def
libx265.so.192: CMakeFiles/x265-shared.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/zuguorui/work_space/x265_build/cmake_build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_10) "Linking CXX shared library libx265.so"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/x265-shared.dir/link.txt --verbose=$(VERBOSE)
	$(CMAKE_COMMAND) -E cmake_symlink_library libx265.so.192 libx265.so.192 libx265.so

libx265.so: libx265.so.192
	@$(CMAKE_COMMAND) -E touch_nocreate libx265.so
```
将这一段中不带版本号的libx265.so加上版本号，带版本号的给它去掉，也就是颠倒一下：
```shell
libx265.so: asm.S.o
libx265.so: cpu-a.S.o
libx265.so: mc-a.S.o
libx265.so: sad-a.S.o
libx265.so: pixel-util.S.o
libx265.so: ssd-a.S.o
libx265.so: blockcopy8.S.o
libx265.so: ipfilter8.S.o
libx265.so: dct-a.S.o
libx265.so: encoder/CMakeFiles/encoder.dir/analysis.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/search.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/bitcost.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/motion.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/slicetype.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/frameencoder.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/framefilter.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/level.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/nal.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/sei.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/sao.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/entropy.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/dpb.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/ratecontrol.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/reference.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/encoder.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/api.cpp.o
libx265.so: encoder/CMakeFiles/encoder.dir/weightPrediction.cpp.o
libx265.so: common/CMakeFiles/common.dir/arm/asm-primitives.cpp.o
libx265.so: common/CMakeFiles/common.dir/primitives.cpp.o
libx265.so: common/CMakeFiles/common.dir/pixel.cpp.o
libx265.so: common/CMakeFiles/common.dir/dct.cpp.o
libx265.so: common/CMakeFiles/common.dir/lowpassdct.cpp.o
libx265.so: common/CMakeFiles/common.dir/ipfilter.cpp.o
libx265.so: common/CMakeFiles/common.dir/intrapred.cpp.o
libx265.so: common/CMakeFiles/common.dir/loopfilter.cpp.o
libx265.so: common/CMakeFiles/common.dir/constants.cpp.o
libx265.so: common/CMakeFiles/common.dir/cpu.cpp.o
libx265.so: common/CMakeFiles/common.dir/version.cpp.o
libx265.so: common/CMakeFiles/common.dir/threading.cpp.o
libx265.so: common/CMakeFiles/common.dir/threadpool.cpp.o
libx265.so: common/CMakeFiles/common.dir/wavefront.cpp.o
libx265.so: common/CMakeFiles/common.dir/md5.cpp.o
libx265.so: common/CMakeFiles/common.dir/bitstream.cpp.o
libx265.so: common/CMakeFiles/common.dir/yuv.cpp.o
libx265.so: common/CMakeFiles/common.dir/shortyuv.cpp.o
libx265.so: common/CMakeFiles/common.dir/picyuv.cpp.o
libx265.so: common/CMakeFiles/common.dir/common.cpp.o
libx265.so: common/CMakeFiles/common.dir/param.cpp.o
libx265.so: common/CMakeFiles/common.dir/frame.cpp.o
libx265.so: common/CMakeFiles/common.dir/framedata.cpp.o
libx265.so: common/CMakeFiles/common.dir/cudata.cpp.o
libx265.so: common/CMakeFiles/common.dir/slice.cpp.o
libx265.so: common/CMakeFiles/common.dir/lowres.cpp.o
libx265.so: common/CMakeFiles/common.dir/piclist.cpp.o
libx265.so: common/CMakeFiles/common.dir/predict.cpp.o
libx265.so: common/CMakeFiles/common.dir/scalinglist.cpp.o
libx265.so: common/CMakeFiles/common.dir/quant.cpp.o
libx265.so: common/CMakeFiles/common.dir/deblock.cpp.o
libx265.so: common/CMakeFiles/common.dir/scaler.cpp.o
libx265.so: CMakeFiles/x265-shared.dir/build.make
libx265.so: x265.def
libx265.so: CMakeFiles/x265-shared.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/zuguorui/work_space/x265_build/cmake_build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_10) "Linking CXX shared library libx265.so"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/x265-shared.dir/link.txt --verbose=$(VERBOSE)
	$(CMAKE_COMMAND) -E cmake_symlink_library libx265.so libx265.so libx265.so.192 # 注意这里

libx265.so.192: libx265.so # 这里
	@$(CMAKE_COMMAND) -E touch_nocreate libx265.so.192 #这里
```
- 在`cmake_build`下执行`make`开始构造，完成之后执行`make install`，编译出的库就会在你刚才在ccmake中配置`CMAKE_INSTALL_PREFIX`的路径里了。



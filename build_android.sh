#! /bin/bash

SOURCE_PATH=/Users/zuguorui/work_space/x265

rm -r cmake_build

mkdir cmake_build

cd cmake_build

cmake -DCMAKE_TOOLCHAIN_FILE=../android_armv8.cmake -G "Unix Makefiles" $SOURCE_PATH/source && ccmake $SOURCE_PATH/source
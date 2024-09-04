#!/bin/bash

#rm -rf ./cmake-build/*

# QiuChenly Automatic Build System Shell
# Powered By CLion & Ninja & Ollvm16 & Apple Clang
# ------------ Catalog ------------
# 2024.04.05 Init Configuration.
# 2024.04.07 修复多架构编译与混淆打包符号表抹除。
# ------------ Catalog End --------
# Note:
# 1. 本Shell只可以在源码文件夹根目录运行,千万不要在任何其他地方编译

# 如果想用CLion带的cmake和ninja 需要指定二进制路径 并且要屏蔽最下面的ccmake和cninja变量

# arm64 for other developers
#clion_bin="/Applications/CLion.app/Contents/bin"
#ccmake="${clion_bin}/cmake/mac/aarch64/bin/"
#cninja="${clion_bin}/ninja/mac/aarch64/"

# x86 for QiuChenly
clion_bin="/Users/qiuchenly/Applications/CLion.app/Contents/bin"
ccmake="${clion_bin}/cmake/mac/x64/bin/"
cninja="${clion_bin}/ninja/mac/x64/"
# 如果只想用苹果开发者工具的版本 可以保持下面的变量为默认即可
ccmake=""
cninja=""

# 默认使用系统开发者工具版本的Clang版本
export CC="cc"
export CXX="c++"

# 我配置了两种编译方式
# Debug 无混淆Debug / Release OLLVM混淆的发布版本 均测试通过
BUILD_TYPE="Debug"

build_tmp="./cmake-build/Build/${BUILD_TYPE}"
#rm -rf "${build_tmp}" # 删除编译缓存文件夹 但是一般不用删 加速编译
# 如果想保证目标输出目录干净 可以先删除
#rm -rf "./cmake-build/BuildOut/"
#mkdir -p "./cmake-build/BuildOut/${BUILD_TYPE}"

# ================= OLLVM16 混淆设置 ===================
# 如果设置了ollvm16强力混淆的clang16 需要加上环境变量来编译 CMakeLists中的混淆标记才会被加入到编译链中
# ================ OLLVM16 混淆设置结束 =====================

# 编译系统,启动!
"${ccmake}cmake" "-DCMAKE_C_COMPILER=${CC}" "-DCMAKE_CXX_COMPILER=${CXX}" "${BUILD_SYSTEM}" "-DCMAKE_BUILD_TYPE=${BUILD_TYPE}" -S . -B "${build_tmp}"
"${ccmake}cmake" --build "${build_tmp}" --target all --target install --config ${BUILD_TYPE} -v -j 128
# 另一种调用xcode编译的方式
#xcodebuild -project "${build_tmp}/91QiuChenly.xcodeproj" -scheme 91QiuChenly -configuration Release
#if [ "$BUILD_TYPE" = "Release" ]; then
#  cp -r ${build_tmp}/${BUILD_TYPE}/* ${build_tmp}/../../BuildOut/${BUILD_TYPE}
#fi
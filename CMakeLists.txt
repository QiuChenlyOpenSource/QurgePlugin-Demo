cmake_minimum_required(VERSION 3.20)

project(DemoPlugin)

enable_language(ASM)
enable_language(C)
enable_language(CXX)
enable_language(OBJC)
enable_language(OBJCXX)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")

set(COMPILE_OPTION
        -Wno-int-conversion
        -Wno-nullability-completeness
        -Wno-incompatible-pointer-types
        -Wno-int-to-void-pointer-cast
        -Wno-unguarded-availability-new # is only available on macOS 10.15 or newer
)

set(LINK_OPTION
        -Xlinker
        -x
)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")

file(GLOB UtilsHeader ${CMAKE_SOURCE_DIR}/src/Utils/*.h)

include_directories(
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/src/Utils
        ${UtilsHeader}
)

add_library(${PROJECT_NAME} SHARED
        src/MyPlugin.mm
)

# 检查环境变量是否存在OLLVM 如果是就加上混淆

# 去掉lib前缀
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

target_compile_options(${PROJECT_NAME} PRIVATE ${COMPILE_OPTION})

target_link_options(${PROJECT_NAME} PRIVATE ${LINK_OPTION})

# Xcode 在引入这些库的头文件时会自动加入编译，但是CLion不会，所以需要手动设置一下这个库。
target_link_libraries(${PROJECT_NAME} PUBLIC
        "-framework Foundation"
        "-framework CoreFoundation"
        "-framework AppKit"
        "-framework Cocoa"
        "-framework IOKit"
        "-framework CloudKit"
        "-framework AppKit"
        "-framework Security"

        # 加入额外的库
        objc
        c++
)

# 2024.04.05 QiuChenly 设置不同的编译输出目录以便区分
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/cmake-build/BuildOut/Debug)
    add_definitions(-DDEBUG)
elseif (CMAKE_BUILD_TYPE STREQUAL "Release")
    #    add_definitions(-DDEBUG)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/cmake-build/BuildOut/Release)
else ()
    set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/cmake-build/BuildOut/${CMAKE_BUILD_TYPE})
endif ()

# 目标安装目录 为了方便调试我就扔在了这里
#set(TARGET_DIR "/Volumes/data/SurgeConfig/Plugins")
set(TARGET_DIR ./)

install(TARGETS ${PROJECT_NAME} DESTINATION ${TARGET_DIR})
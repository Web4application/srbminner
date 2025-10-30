cmake_minimum_required(VERSION 3.20)
project(srbminner VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB_RECURSE SRC_FILES src/*.cpp src/*.h)
add_executable(srbminner ${SRC_FILES})

cmake_minimum_required(VERSION 3.0)
project(kaleidodbg)

find_package(LLVM REQUIRED CONFIG)
message(STATUS "LLVM_DIR = ${LLVM_DIR}")
message(STATUS "LLVM_PACKAGE_VERSION = ${LLVM_PACKAGE_VERSION}")

message(STATUS "LLVM_DEFINITIONS = ${LLVM_DEFINITIONS}")
add_definitions(${LLVM_DEFINITIONS})

message(STATUS "LLVM_INCLUDE_DIRS = ${LLVM_INCLUDE_DIRS}")
include_directories(${LLVM_INCLUDE_DIRS})

add_executable(kaleidodbg
  ${CMAKE_SOURCE_DIR}/src/toy.cpp
  ${CMAKE_SOURCE_DIR}/src/KaleidoscopeJIT.h)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-rtti")

llvm_map_components_to_libnames(LLVM_LIBS
  Core
  ExecutionEngine
  Object
  OrcJIT
  Support
  native)

message(STATUS "LLVM_LIBS = ${LLVM_LIBS}")
target_link_libraries(kaleidodbg ${LLVM_LIBS})

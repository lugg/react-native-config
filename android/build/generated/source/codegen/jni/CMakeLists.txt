# Minimal stub CMakeLists for missing codegen outputs.
# This defines the react_codegen_RNCConfigModule target so native builds
# that expect generated code can link against a placeholder library.
cmake_minimum_required(VERSION 3.4.1)

# Create a small static library with a trivial source file so CMake has a target to link.
add_library(react_codegen_RNCConfigModule STATIC "${CMAKE_CURRENT_SOURCE_DIR}/empty.cpp")

# Expose the current source dir (if other CMake code expects include dirs)
target_include_directories(react_codegen_RNCConfigModule PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# Prevent warnings when linked against: set an empty interface
target_compile_definitions(react_codegen_RNCConfigModule INTERFACE "REACT_NATIVE_CONFIG_STUB")

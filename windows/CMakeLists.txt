# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(church LANGUAGES CXX)

# Third-party Flutter plugins currently pull older CMake projects during the
# Windows build. Keep our output focused on actionable app warnings.
set(CMAKE_WARN_DEPRECATED OFF CACHE BOOL "" FORCE)
set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS ON CACHE BOOL "" FORCE)

# Suppress benign MSVC warnings from third-party C++ (the WebView2 SDK
# headers and the flutter_soloud / melty dependencies ship hundreds of
# them). These categories are noise from vendored code we do not own:
#   C4996 strdup/_strdup, C4244/C4245/C4267 narrowing, C4018 signedness,
#   C4456/C4458/C4459 name hiding, C4189 unused local, C4127 constant
#   condition, C4702 unreachable code.
if(MSVC)
  add_compile_options(
    /wd4996 /wd4244 /wd4245 /wd4267 /wd4018
    /wd4456 /wd4458 /wd4459 /wd4189 /wd4127 /wd4702
  )

  # flutter_inappwebview_windows 0.7.0-beta.3 still consumes the legacy
  # <experimental/coroutine> compatibility header. VS 2026 turns Microsoft's
  # deprecation diagnostic for that header into a hard static_assert. Keep the
  # vendored plugin buildable until it migrates to std::coroutine; this define
  # is intentionally global so it also reaches plugin subdirectories that do
  # not use our APPLY_STANDARD_SETTINGS helper.
  add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)
endif()

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "church")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100" /wd"4458" /wd"4244")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
set(_ORIGINAL_CMAKE_COMMAND "${CMAKE_COMMAND}")
set(CMAKE_COMMAND
  "powershell.exe;-NoProfile;-ExecutionPolicy;Bypass;-File;${CMAKE_CURRENT_SOURCE_DIR}/cmake_silent.ps1;${_ORIGINAL_CMAKE_COMMAND}")
include(flutter/generated_plugins.cmake)
set(CMAKE_COMMAND "${_ORIGINAL_CMAKE_COMMAND}")


# === Installation ===
# Support files are copied into place next to the executable, so that building
# and running from within Visual Studio will work.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
# Make the "install" step default, as it's required to run.
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# pdfrx/pdfium_dart writes the Windows PDFium DLL through Dart native-assets,
# but Flutter's Windows install step does not currently copy it next to the
# executable for this project. Keep the native PDF renderer self-contained.
set(PDFIUM_NATIVE_ASSET
  "${CMAKE_CURRENT_SOURCE_DIR}/../build/native_assets/windows/pdfium.dll")
if(EXISTS "${PDFIUM_NATIVE_ASSET}")
  install(FILES "${PDFIUM_NATIVE_ASSET}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# sqlite3 (via sqflite_common_ffi) also writes its native library through Dart
# native-assets; Flutter's Windows install step does not copy it next to the
# executable either. Without it every openDatabase of a downloaded (non-TB)
# bible version fails with "Failed to load dynamic library 'sqlite3.dll'"
# (error 126) and the Bible pane loads empty on desktop.
set(SQLITE3_NATIVE_ASSET
  "${CMAKE_CURRENT_SOURCE_DIR}/../build/native_assets/windows/sqlite3.dll")
if(EXISTS "${SQLITE3_NATIVE_ASSET}")
  install(FILES "${SQLITE3_NATIVE_ASSET}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)

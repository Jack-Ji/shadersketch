#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "SDL3_shadercross::vendored::spirv-cross-c-shared" for configuration "Release"
set_property(TARGET SDL3_shadercross::vendored::spirv-cross-c-shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SDL3_shadercross::vendored::spirv-cross-c-shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libspirv-cross-c-shared.0.64.0.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libspirv-cross-c-shared.0.dylib"
  )

list(APPEND _cmake_import_check_targets SDL3_shadercross::vendored::spirv-cross-c-shared )
list(APPEND _cmake_import_check_files_for_SDL3_shadercross::vendored::spirv-cross-c-shared "${_IMPORT_PREFIX}/lib/libspirv-cross-c-shared.0.64.0.dylib" )

# Import target "SDL3_shadercross::vendored::dxcompiler" for configuration "Release"
set_property(TARGET SDL3_shadercross::vendored::dxcompiler APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SDL3_shadercross::vendored::dxcompiler PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libdxcompiler.dylib"
  IMPORTED_NO_SONAME_RELEASE "TRUE"
  )

list(APPEND _cmake_import_check_targets SDL3_shadercross::vendored::dxcompiler )
list(APPEND _cmake_import_check_files_for_SDL3_shadercross::vendored::dxcompiler "${_IMPORT_PREFIX}/lib/libdxcompiler.dylib" )

# Import target "SDL3_shadercross::vendored::dxildll" for configuration "Release"
set_property(TARGET SDL3_shadercross::vendored::dxildll APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SDL3_shadercross::vendored::dxildll PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libdxil.dylib"
  IMPORTED_NO_SONAME_RELEASE "TRUE"
  )

list(APPEND _cmake_import_check_targets SDL3_shadercross::vendored::dxildll )
list(APPEND _cmake_import_check_files_for_SDL3_shadercross::vendored::dxildll "${_IMPORT_PREFIX}/lib/libdxil.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

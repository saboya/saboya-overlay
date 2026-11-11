get_filename_component(_nxformat_libdir "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
get_filename_component(_nxformat_prefix "${_nxformat_libdir}/.." ABSOLUTE)
set(nxformat_VERSION 1.0.3)
if(NOT TARGET nxformat::nxformat)
  add_library(nxformat::nxformat SHARED IMPORTED)
  set_target_properties(nxformat::nxformat PROPERTIES
    IMPORTED_LOCATION "${_nxformat_libdir}/libnxformat.so"
    INTERFACE_INCLUDE_DIRECTORIES "${_nxformat_prefix}/include")
  add_library(nxformat::static_nozstd STATIC IMPORTED)
  set_target_properties(nxformat::static_nozstd PROPERTIES
    IMPORTED_LOCATION "${_nxformat_libdir}/libnxformat.a"
    INTERFACE_INCLUDE_DIRECTORIES "${_nxformat_prefix}/include"
    INTERFACE_COMPILE_DEFINITIONS NXFORMAT_STATIC
    INTERFACE_LINK_LIBRARIES "pthread;dl;m")
  add_library(nxformat::reader INTERFACE IMPORTED)
  set_target_properties(nxformat::reader PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_nxformat_prefix}/include"
    INTERFACE_COMPILE_FEATURES cxx_std_17)
endif()
unset(_nxformat_libdir)
unset(_nxformat_prefix)

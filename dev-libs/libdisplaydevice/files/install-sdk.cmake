
include(GNUInstallDirs)
set_target_properties(libdisplaydevice_common PROPERTIES EXPORT_NAME common)
set_target_properties(libdisplaydevice_display_device PROPERTIES EXPORT_NAME display_device)
set_target_properties(libdisplaydevice_linux_dummy PROPERTIES EXPORT_NAME platform)
set_property(TARGET libdisplaydevice_common PROPERTY INTERFACE_INCLUDE_DIRECTORIES
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/common/include>;$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")
install(TARGETS libdisplaydevice_common libdisplaydevice_display_device libdisplaydevice_linux_dummy
    EXPORT libdisplaydeviceTargets ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")
install(DIRECTORY src/common/include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
install(EXPORT libdisplaydeviceTargets NAMESPACE libdisplaydevice::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/libdisplaydevice")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/libdisplaydeviceConfig.cmake"
    "include(CMakeFindDependencyMacro)\nfind_dependency(nlohmann_json 3.11 CONFIG)\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/libdisplaydeviceTargets.cmake\")\n")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/libdisplaydeviceConfig.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/libdisplaydevice")

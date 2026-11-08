
include(GNUInstallDirs)
set_target_properties(enet PROPERTIES OUTPUT_NAME moonlight-enet EXPORT_NAME enet POSITION_INDEPENDENT_CODE ON)
set_property(TARGET enet PROPERTY INTERFACE_INCLUDE_DIRECTORIES
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>;$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/moonlight-enet>")
set_property(TARGET enet PROPERTY INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "")
install(TARGETS enet EXPORT moonlight-enetTargets ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")
install(DIRECTORY include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/moonlight-enet")
install(EXPORT moonlight-enetTargets NAMESPACE moonlight::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/moonlight-enet")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/moonlight-enetConfig.cmake"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/moonlight-enetTargets.cmake\")\n")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/moonlight-enetConfig.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/moonlight-enet")

# Use the separately packaged SDK; never download prebuilt libraries.
option(LICHII_ENABLE_NX_CONVERTER "Build NX archive conversion tools" ON)
if(ENABLE_QT AND LICHII_ENABLE_NX_CONVERTER)
    find_package(nxformat 1.0.3 REQUIRED CONFIG)
    if(TARGET nxformat::static_nozstd)
        set_property(TARGET nxformat::static_nozstd APPEND PROPERTY
            INTERFACE_LINK_LIBRARIES zstd::zstd)
    endif()
endif()

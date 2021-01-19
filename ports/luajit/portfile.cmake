#vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuaJIT/LuaJIT
    REF 8271c643c21d1b2f344e339f559f2de6f3663191
    SHA512 a136f15a87f92c5cab40d49dcc2441f04c14575fa31aba5bd413313ee904d3abc4ebb8f413124781d101f793058c15a07f0a47d50d4fc5a74e7b150a1d1459cf
    HEAD_REF master
    PATCHES
        003-fix-export-path.patch
        004-configure.patch
        make.patch
)
if (VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set (LJIT_STATIC "")
    else()
        set (LJIT_STATIC "static")
    endif()

    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
        message(STATUS "Building ${TARGET_TRIPLET}-dbg")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        
        vcpkg_execute_required_process_repeat(
            COUNT 1
            COMMAND "${SOURCE_PATH}/src/msvcbuild.bat" ${SOURCE_PATH}/src ${VCPKG_CRT_LINKAGE} debug ${LJIT_STATIC}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            LOGNAME build-${TARGET_TRIPLET}-dbg
        )
        
        file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/luajit.exe DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)
        file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lua51.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
        
        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lua51.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
            file(COPY ${CURRENT_PACKAGES_DIR}/debug/bin/lua51.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)
        endif()
        vcpkg_copy_pdbs()
    endif()

    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
        message(STATUS "Building ${TARGET_TRIPLET}-rel")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        
        vcpkg_execute_required_process_repeat(d8un
            COUNT 1
            COMMAND "${SOURCE_PATH}/src/msvcbuild.bat" ${SOURCE_PATH}/src ${VCPKG_CRT_LINKAGE} ${LJIT_STATIC}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            LOGNAME build-${TARGET_TRIPLET}-rel
        )
        
        file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/luajit.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
        file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lua51.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        
        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lua51.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
            vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools)
        endif()
        vcpkg_copy_pdbs()
        file(INSTALL ${SOURCE_PATH}/src/lua.h 			    DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
        file(INSTALL ${SOURCE_PATH}/src/luajit.h 	    	DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
        file(INSTALL ${SOURCE_PATH}/src/luaconf.h 		    DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
        file(INSTALL ${SOURCE_PATH}/src/lualib.h 		    DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
        file(INSTALL ${SOURCE_PATH}/src/lauxlib.h 		    DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
        file(INSTALL ${SOURCE_PATH}/src/lua.hpp 		    DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})  
    endif()
    
elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        COPY_SOURCE
    )
    vcpkg_build_make()
    
    vcpkg_install_make()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/lua" "${CURRENT_PACKAGES_DIR}/lib/lua")

endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

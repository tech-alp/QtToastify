include_guard(GLOBAL)

function(qttoastify_resolve_merce)
    if(TARGET Merce::Controls)
        return()
    endif()

    include(FetchContent)

    set(QTTOASTIFY_MERCE_SOURCE_DIR "" CACHE PATH
        "Use a local Merce checkout for the QtToastify playground"
    )
    set(QTTOASTIFY_MERCE_GIT_TAG
        "8729979c1dba012dede33199148c7786c471cf79"
        CACHE STRING
        "Pinned Merce revision used by the QtToastify playground"
    )

    block(SCOPE_FOR VARIABLES)
        set(MERCE_BUILD_NOTIFICATIONS OFF)
        set(MERCE_ENABLE_FONTAWESOME OFF)
        set(MERCE_BUILD_TESTS OFF)
        set(MERCE_ENABLE_TOKEN_BUILD OFF)
        set(MERCE_INSTALL OFF)
        set(BUILD_MERCE_PLAYGROUND OFF)

        if(QTTOASTIFY_MERCE_SOURCE_DIR)
            get_filename_component(merce_source_dir
                "${QTTOASTIFY_MERCE_SOURCE_DIR}"
                ABSOLUTE
            )
            if(NOT EXISTS "${merce_source_dir}/CMakeLists.txt")
                message(FATAL_ERROR
                    "QTTOASTIFY_MERCE_SOURCE_DIR does not contain CMakeLists.txt: "
                    "${merce_source_dir}"
                )
            endif()

            FetchContent_Declare(Merce SOURCE_DIR "${merce_source_dir}")
        else()
            FetchContent_Declare(Merce
                GIT_REPOSITORY https://github.com/tech-alp/Merce.git
                GIT_TAG "${QTTOASTIFY_MERCE_GIT_TAG}"
            )
        endif()

        FetchContent_MakeAvailable(Merce)
    endblock()

    foreach(merce_target IN ITEMS Theme Foundation Style Controls)
        if(NOT TARGET Merce::${merce_target})
            message(FATAL_ERROR
                "Merce consumer target is missing: Merce::${merce_target}"
            )
        endif()
    endforeach()
endfunction()

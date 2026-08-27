cmake_minimum_required(VERSION 3.20)

project(QtToastifyFetchContentConsumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.10 REQUIRED COMPONENTS
    Core
    Quick
    Qml
    QuickControls2
    QuickVectorImage
    QuickVectorImageHelpers
)

qt_standard_project_setup(REQUIRES 6.10)

include(FetchContent)

set(BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_PLAYGROUND OFF CACHE BOOL "" FORCE)

if(QTTOASTIFY_SOURCE_DIR)
    FetchContent_Declare(QtToastify
        SOURCE_DIR "${QTTOASTIFY_SOURCE_DIR}"
    )
else()
    set(QTTOASTIFY_GIT_TAG "v2.0.0" CACHE STRING
        "QtToastify release tag used by the consumer test"
    )
    FetchContent_Declare(QtToastify
        GIT_REPOSITORY https://github.com/tech-alp/QtToastify.git
        GIT_TAG ${QTTOASTIFY_GIT_TAG}
        GIT_SHALLOW TRUE
    )
endif()

FetchContent_MakeAvailable(QtToastify)

qt_add_executable(qttoastify_fetchcontent_consumer
    main.cpp
)

qt_add_qml_module(qttoastify_fetchcontent_consumer
    URI QtToastify.FetchContentConsumer
    VERSION 1.0
    QML_FILES
        Main.qml
    DEPENDENCIES
        TARGET Toastify
        TARGET ToastifyStyle
)

target_link_libraries(qttoastify_fetchcontent_consumer PRIVATE
    Qt6::Quick
    Toastify
    Toastifyplugin
    ToastifyStyleplugin
)

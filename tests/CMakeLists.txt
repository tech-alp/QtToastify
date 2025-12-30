cmake_minimum_required(VERSION 3.20)

find_package(Qt6 REQUIRED COMPONENTS Test Quick Qml QuickTest)

# Add test executable
qt_add_executable(tst_toast_layout
    main.cpp
)

qt_add_qml_module(tst_toast_layout
    URI ToastTests
    VERSION 1.0
    QML_FILES
        tst_container_boundary.qml
    DEPENDENCIES TARGET QtToastify
)

target_link_libraries(tst_toast_layout PRIVATE
    Qt6::Test
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickTest
    QtAwesome
    Toastifyplugin
)

# Add the parent directory to include path so we can import Toastify
target_include_directories(tst_toast_layout PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

# Enable testing
enable_testing()
add_test(NAME ContainerBoundaryTest COMMAND tst_toast_layout)

# QtToastify Playground Examples
cmake_minimum_required(VERSION 3.20)

# Create single playground executable
qt_add_executable(QtToastifyPlayground
    playground_main.cpp
)

qt_add_qml_module(QtToastifyPlayground
    URI PlaygroundExamples
    VERSION 1.0
    QML_FILES
        PlaygroundApp.qml
        StyledToastDelegate.qml
        styles/CustomStyle.qml
        styles/LightStyle.qml
        styles/CompactStyle.qml
        styles/DefaultStyle.qml

)

target_link_libraries(QtToastifyPlayground PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
    Toastifyplugin
)

# Set properties
set_target_properties(QtToastifyPlayground PROPERTIES
    QT_QML_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR}
    QT_QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}
)

# Install playground (optional)
if(CMAKE_INSTALL_PREFIX)
    install(TARGETS QtToastifyPlayground
        DESTINATION bin
    )

    install(FILES
        README.md
        StyleCustomizationGuide.md
        DESTINATION share/QtToastify/playground
    )
endif()

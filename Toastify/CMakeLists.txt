add_subdirectory(Style)

qt_add_library(Toastify STATIC)

set_source_files_properties(
    private/ColoredImage.qml
    PROPERTIES QT_QML_INTERNAL_TYPE TRUE
)

set_source_files_properties(
    private/ShadowEffect.qml
    PROPERTIES QT_QML_INTERNAL_TYPE TRUE
)

set_source_files_properties(
    resources/icons/error.svg
    PROPERTIES QT_RESOURCE_ALIAS icons/error.svg
)

set_source_files_properties(
    resources/icons/info.svg
    PROPERTIES QT_RESOURCE_ALIAS icons/info.svg
)

set_source_files_properties(
    resources/icons/warning.svg
    PROPERTIES QT_RESOURCE_ALIAS icons/warning.svg
)

set_source_files_properties(
    resources/icons/success.svg
    PROPERTIES QT_RESOURCE_ALIAS icons/success.svg
)

set_source_files_properties(
    resources/icons/xmark.svg
    PROPERTIES QT_RESOURCE_ALIAS icons/xmark.svg
)


qt_add_qml_module(Toastify
    URI Toastify
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Toastify
    QML_FILES
        Toastify.qml
        ToastifyDelegate.qml
        private/ColoredImage.qml
        private/ShadowEffect.qml
    RESOURCES
        resources/icons/error.svg
        resources/icons/info.svg
        resources/icons/warning.svg
        resources/icons/success.svg
        resources/icons/xmark.svg
    DEPENDENCIES TARGET
        ToastifyStyle
)

target_link_libraries(Toastify PUBLIC
    ToastifyStyleplugin
)

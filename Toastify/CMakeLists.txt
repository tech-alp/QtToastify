add_subdirectory(Style)

qt_add_library(Toastify STATIC)

# Never give Qt 6.8's QML compiler the Qt 6.9-only RectangularShadow type.
if(Qt6_VERSION VERSION_GREATER_EQUAL 6.9)
    set(toast_shadow_qml private/ToastShadow.qml)
else()
    set(toast_shadow_qml private/NoShadow.qml)
    set_source_files_properties(${toast_shadow_qml} PROPERTIES
        QT_RESOURCE_ALIAS private/ToastShadow.qml
        QT_QML_SOURCE_TYPENAME ToastShadow
    )
endif()

set_source_files_properties(
    ${toast_shadow_qml}
    private/InfoIcon.qml
    private/SuccessIcon.qml
    private/WarningIcon.qml
    private/ErrorIcon.qml
    private/CloseIcon.qml
    private/ToastStack.qml
    PROPERTIES QT_QML_INTERNAL_TYPE TRUE
)

qt_add_qml_module(Toastify
    URI Toastify
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Toastify
    QML_FILES
        Toastify.qml
        ToastifyDelegate.qml
        ${toast_shadow_qml}
        private/InfoIcon.qml
        private/SuccessIcon.qml
        private/WarningIcon.qml
        private/ErrorIcon.qml
        private/CloseIcon.qml
        private/ToastStack.qml
    IMPORTS
        QtQuick.Effects
        QtQuick.Shapes
    DEPENDENCIES TARGET
        ToastifyStyle
    SOURCES
        ToastFuture.cpp
        ToastFuture.h
)

target_include_directories(Toastify PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

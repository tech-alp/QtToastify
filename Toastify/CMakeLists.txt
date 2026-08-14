add_subdirectory(Style)

qt_add_library(Toastify STATIC)

set_source_files_properties(
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
)

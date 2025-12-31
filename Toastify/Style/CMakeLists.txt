qt_add_library(ToastifyStyle STATIC)

qt_add_qml_module(ToastifyStyle
    URI Toastify.Style
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Toastify/Style
    QML_FILES
        ToastifyStyleProvider.qml
        DarkStyleProvider.qml
        CompactStyleProvider.qml
        MaterialStyleProvider.qml
)

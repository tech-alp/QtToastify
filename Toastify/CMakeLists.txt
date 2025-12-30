add_subdirectory(Style)

qt_add_library(Toastify STATIC)

qt_add_qml_module(Toastify
    URI Toastify
    VERSION 1.0
    QML_FILES
        Toastify.qml
        ToastifyDelegate.qml
    DEPENDENCIES TARGET
        ToastifyStyle
)

target_link_libraries(Toastify PUBLIC
    QtAwesome
    ToastifyStyleplugin
)

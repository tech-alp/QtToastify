import QtQuick
import QtQuick.Controls
import Toastify

ApplicationWindow {
    width: 320
    height: 240
    visible: false

    Toastify {
        id: toastify
    }

    Component.onCompleted: {
        const toast = toastify.info(qsTr("FetchContent works"), {
            autoClose: 0
        })
        if (toast === null) {
            Qt.exit(1)
            return
        }
        Qt.callLater(Qt.quit)
    }
}

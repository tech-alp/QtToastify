pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit
import Merce.Style
import Merce.Theme

ApplicationWindow {
    id: root

    objectName: "playground.window"
    width: 1440
    height: 900
    minimumWidth: 900
    minimumHeight: 700
    visible: true
    title: qsTr("QtToastify Playground")

    StyleKit.style: MerceStyle {}

    PlaygroundState {
        id: playgroundModel

        toastFontFamily: Theme.typography.fontBody
    }

    PlaygroundWorkspace {
        anchors.fill: parent
        playgroundState: playgroundModel
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Style

SK.ApplicationWindow {
    id: root

    objectName: "playground.window"
    width: 1440
    height: 900
    minimumWidth: 900
    minimumHeight: 700
    visible: true
    title: qsTr("QtToastify Playground")

    SK.StyleKit.style: MerceStyle {}

    PlaygroundState {
        id: playgroundState
    }

    PlaygroundWorkspace {
        anchors.fill: parent
        playgroundState: playgroundState
    }
}

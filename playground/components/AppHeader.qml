pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root

    objectName: "playground.header"
    implicitHeight: 72

    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacing.md

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: Theme.radius.medium
            color: Theme.colors.action.primary.container

            AppIcon {
                anchors.centerIn: parent
                name: "material:notifications"
                size: Theme.icons.large
                color: Theme.colors.action.primary.content
                filled: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.xxs

            AppLabel {
                Layout.fillWidth: true
                textType: AppLabel.H3
                text: qsTr("QtToastify Playground")
                color: Theme.colors.content.primary
            }

            AppLabel {
                Layout.fillWidth: true
                textType: AppLabel.Caption
                text: qsTr("Configure and test real QML toast notifications")
                color: Theme.colors.content.secondary
                elide: Text.ElideRight
            }
        }

        MBadge {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("Qt 6 · QML")
            variant: MBadge.Primary
            size: MBadge.Small
        }

        MButton {
            objectName: "playground.header.github"
            text: qsTr("GitHub")
            iconName: "material:code"
            iconPosition: MButton.IconLeft
            variant: MButton.Ghost
            size: MButton.Medium
            Accessible.name: qsTr("Open QtToastify on GitHub")
            onClicked: Qt.openUrlExternally("https://github.com/tech-alp/QtToastify")
        }
    }
}

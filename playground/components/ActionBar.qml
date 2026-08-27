pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Surface {
    id: root

    property bool canClear: false
    property bool canShowToast: true

    signal showToastRequested()
    signal allTypesRequested()
    signal longMessageRequested()
    signal actionToastRequested()
    signal promiseSuccessRequested()
    signal promiseErrorRequested()
    signal futureSuccessRequested()
    signal futureErrorRequested()
    signal clearRequested()

    objectName: "playground.actions"
    surfaceType: Surface.Raised
    radiusValue: Theme.radius.large
    implicitHeight: 72

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Theme.spacing.md
            rightMargin: Theme.spacing.md
            topMargin: Theme.spacing.sm
            bottomMargin: Theme.spacing.sm
        }
        spacing: Theme.spacing.sm

        MButton {
            objectName: "playground.actions.showToast"
            text: qsTr("Show Toast")
            iconName: "material:notifications"
            iconPosition: MButton.IconLeft
            enabled: root.canShowToast
            onClicked: root.showToastRequested()
        }

        MButton {
            objectName: "playground.actions.allTypes"
            text: qsTr("Test All Types")
            iconName: "material:bolt"
            iconPosition: MButton.IconLeft
            variant: MButton.Outline
            onClicked: root.allTypesRequested()
        }

        MButton {
            objectName: "playground.actions.longMessage"
            text: qsTr("Long Message")
            iconName: "material:notes"
            iconPosition: MButton.IconLeft
            variant: MButton.Ghost
            onClicked: root.longMessageRequested()
        }

        Item { Layout.fillWidth: true }

        MButton {
            id: moreButton

            objectName: "playground.actions.more"
            text: qsTr("More")
            iconName: "material:more_horiz"
            iconPosition: MButton.IconRight
            variant: MButton.Ghost
            onClicked: morePopup.opened ? morePopup.close() : morePopup.open()
        }
    }

    SK.Popup {
        id: morePopup

        objectName: "playground.actions.morePopup"
        x: root.width - width - Theme.spacing.md
        y: -height - Theme.spacing.xs
        width: 250
        padding: Theme.spacing.xs
        focus: true
        closePolicy: SK.Popup.CloseOnEscape | SK.Popup.CloseOnPressOutside
        onClosed: moreButton.forceActiveFocus(Qt.PopupFocusReason)

        contentItem: ColumnLayout {
            spacing: Theme.spacing.xxs

            MButton {
                objectName: "playground.actions.actionToast"
                Layout.fillWidth: true
                fullWidth: true
                text: qsTr("Action Toast")
                iconName: "material:undo"
                variant: MButton.Ghost
                size: MButton.Medium
                onClicked: {
                    morePopup.close()
                    root.actionToastRequested()
                }
            }

            MButton {
                objectName: "playground.actions.promiseSuccess"
                Layout.fillWidth: true
                fullWidth: true
                text: qsTr("Promise Success")
                iconName: "material:hourglass_top"
                variant: MButton.Ghost
                size: MButton.Medium
                onClicked: {
                    morePopup.close()
                    root.promiseSuccessRequested()
                }
            }

            MButton {
                objectName: "playground.actions.promiseError"
                Layout.fillWidth: true
                fullWidth: true
                text: qsTr("Promise Error")
                iconName: "material:warning"
                variant: MButton.Ghost
                size: MButton.Medium
                onClicked: {
                    morePopup.close()
                    root.promiseErrorRequested()
                }
            }

            MButton {
                objectName: "playground.actions.futureSuccess"
                Layout.fillWidth: true
                fullWidth: true
                text: qsTr("QFuture Success")
                iconName: "material:memory"
                variant: MButton.Ghost
                size: MButton.Medium
                onClicked: {
                    morePopup.close()
                    root.futureSuccessRequested()
                }
            }

            MButton {
                objectName: "playground.actions.futureError"
                Layout.fillWidth: true
                fullWidth: true
                text: qsTr("QFuture Error")
                iconName: "material:error"
                variant: MButton.Ghost
                size: MButton.Medium
                onClicked: {
                    morePopup.close()
                    root.futureErrorRequested()
                }
            }

            MButton {
                objectName: "playground.actions.clear"
                Layout.fillWidth: true
                fullWidth: true
                text: qsTr("Clear Preview")
                iconName: "material:clear_all"
                variant: MButton.Ghost
                size: MButton.Medium
                enabled: root.canClear
                onClicked: {
                    morePopup.close()
                    root.clearRequested()
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Controls

ColumnLayout {
    id: root

    required property PlaygroundState playgroundState
    readonly property string messageError:
        qsTr("Enter a message before showing a toast.")

    objectName: "playground.configuration"
    spacing: Theme.spacing.md

    component FieldLabel: AppLabel {
        Layout.fillWidth: true
        textType: AppLabel.BodySmall
        color: Theme.colors.content.secondary
    }

    SectionCard {
        Layout.fillWidth: true
        title: qsTr("Toast")
        description: qsTr("Choose a style, message, and semantic type.")

        FieldLabel { text: qsTr("Style") }

        SegmentedControl {
            objectName: "playground.selector.style"
            Layout.fillWidth: true
            currentValue: root.playgroundState.styleIndex
            accessibleName: qsTr("Toast style")
            model: [
                { "text": qsTr("Default"), "value": 0 },
                { "text": qsTr("Dark"), "value": 1 },
                { "text": qsTr("Compact"), "value": 2 },
                { "text": qsTr("Material"), "value": 3 }
            ]
            onValueModified: value => root.playgroundState.styleIndex = Number(value)
        }

        FieldLabel { text: qsTr("Message") }

        SK.TextArea {
            id: messageInput

            objectName: "playground.input.message"
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            text: root.playgroundState.message
            placeholderText: qsTr("Enter a toast message")
            wrapMode: TextEdit.Wrap
            Accessible.name: qsTr("Toast message")
            Accessible.description: root.playgroundState.hasMessage
                                    ? "" : root.messageError
            onTextChanged: root.playgroundState.message = text

            Keys.onTabPressed: event => {
                const nextItem = messageInput.nextItemInFocusChain(true)
                if (nextItem)
                    nextItem.forceActiveFocus(Qt.TabFocusReason)
                event.accepted = true
            }
            Keys.onBacktabPressed: event => {
                const previousItem = messageInput.nextItemInFocusChain(false)
                if (previousItem)
                    previousItem.forceActiveFocus(Qt.BacktabFocusReason)
                event.accepted = true
            }
        }

        AppLabel {
            objectName: "playground.input.messageError"
            Layout.fillWidth: true
            visible: !root.playgroundState.hasMessage
            textType: AppLabel.Caption
            text: root.messageError
            color: Theme.colors.status.error.content
            wrapMode: Text.WordWrap
        }

        FieldLabel { text: qsTr("Type") }

        SegmentedControl {
            objectName: "playground.selector.type"
            Layout.fillWidth: true
            currentValue: root.playgroundState.toastType
            accessibleName: qsTr("Toast type")
            model: [
                { "text": qsTr("Info"), "value": "info" },
                { "text": qsTr("Success"), "value": "success" },
                { "text": qsTr("Warning"), "value": "warning" },
                { "text": qsTr("Error"), "value": "error" }
            ]
            onValueModified: value => root.playgroundState.toastType = String(value)
        }
    }

    SectionCard {
        Layout.fillWidth: true
        title: qsTr("Placement")
        description: qsTr("Select where new notifications enter the viewport.")

        PositionPicker {
            Layout.fillWidth: true
            position: root.playgroundState.position
            onPositionModified: position => root.playgroundState.position = position
        }

        FieldLabel { text: qsTr("Stack mode") }

        SegmentedControl {
            objectName: "playground.selector.stack"
            Layout.fillWidth: true
            currentValue: root.playgroundState.stackExpanded
            accessibleName: qsTr("Stack mode")
            model: [
                { "text": qsTr("Default"), "value": false },
                { "text": qsTr("Expanded"), "value": true }
            ]
            onValueModified: value => root.playgroundState.stackExpanded = Boolean(value)
        }
    }

    SectionCard {
        Layout.fillWidth: true
        title: qsTr("Behavior")

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: Theme.spacing.sm
            rowSpacing: Theme.spacing.xs

            FieldLabel { text: qsTr("Auto-close (ms)") }
            FieldLabel { text: qsTr("Visible toasts") }

            SK.SpinBox {
                objectName: "playground.input.autoClose"
                Layout.fillWidth: true
                from: 0
                to: 60000
                stepSize: 500
                editable: true
                value: root.playgroundState.autoClose
                Accessible.name: qsTr("Auto-close duration in milliseconds")
                onValueModified: root.playgroundState.autoClose = value
            }

            SK.SpinBox {
                objectName: "playground.input.visibleToasts"
                Layout.fillWidth: true
                from: 1
                to: 10
                editable: true
                value: root.playgroundState.visibleToasts
                Accessible.name: qsTr("Maximum visible toasts")
                onValueModified: root.playgroundState.visibleToasts = value
            }
        }

        SK.Switch {
            objectName: "playground.input.showCloseButton"
            Layout.fillWidth: true
            text: qsTr("Show close button")
            checked: root.playgroundState.showCloseButton
            onToggled: root.playgroundState.showCloseButton = checked
        }

        SK.Switch {
            objectName: "playground.input.closeOnClick"
            Layout.fillWidth: true
            text: qsTr("Close on click")
            checked: root.playgroundState.closeOnClick
            onToggled: root.playgroundState.closeOnClick = checked
        }

        SK.Switch {
            objectName: "playground.input.showProgressBar"
            Layout.fillWidth: true
            text: qsTr("Show progress bar")
            checked: root.playgroundState.showProgressBar
            onToggled: root.playgroundState.showProgressBar = checked
        }

        SK.Switch {
            objectName: "playground.input.newestOnTop"
            Layout.fillWidth: true
            text: qsTr("Newest on top")
            checked: root.playgroundState.newestOnTop
            onToggled: root.playgroundState.newestOnTop = checked
        }
    }

    SectionCard {
        Layout.fillWidth: true
        title: qsTr("Advanced")
        description: qsTr("Fine-tune stack spacing and compact depth.")

        MButton {
            objectName: "playground.advanced.toggle"
            Layout.fillWidth: true
            text: advancedFields.visible ? qsTr("Hide advanced settings")
                                         : qsTr("Show advanced settings")
            iconName: advancedFields.visible ? "material:expand_less"
                                              : "material:expand_more"
            iconPosition: MButton.IconRight
            variant: MButton.Ghost
            size: MButton.Medium
            onClicked: advancedFields.visible = !advancedFields.visible
        }

        GridLayout {
            id: advancedFields

            objectName: "playground.advanced.fields"
            Layout.fillWidth: true
            visible: false
            columns: 2
            columnSpacing: Theme.spacing.sm
            rowSpacing: Theme.spacing.xs

            FieldLabel { text: qsTr("Expanded spacing") }
            SK.SpinBox {
                objectName: "playground.input.toastSpacing"
                Layout.fillWidth: true
                from: 0
                to: 64
                value: Math.round(root.playgroundState.toastSpacing)
                Accessible.name: qsTr("Expanded toast spacing")
                onValueModified: root.playgroundState.toastSpacing = value
            }

            FieldLabel { text: qsTr("Collapsed offset") }
            SK.SpinBox {
                objectName: "playground.input.collapsedOffset"
                Layout.fillWidth: true
                from: 0
                to: 48
                value: Math.round(root.playgroundState.collapsedOffset)
                Accessible.name: qsTr("Collapsed toast offset")
                onValueModified: root.playgroundState.collapsedOffset = value
            }

            FieldLabel { text: qsTr("Scale step (%)") }
            SK.SpinBox {
                objectName: "playground.input.collapsedScaleStep"
                Layout.fillWidth: true
                from: 0
                to: 25
                value: Math.round(root.playgroundState.collapsedScaleStep * 100)
                Accessible.name: qsTr("Collapsed toast scale step percentage")
                onValueModified: root.playgroundState.collapsedScaleStep = value / 100
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.spacing.xxs
    }
}

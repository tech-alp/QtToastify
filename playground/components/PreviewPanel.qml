pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Toastify
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Surface {
    id: root

    required property PlaygroundState playgroundState
    readonly property int activeToastCount: _activeToasts.length
    readonly property real minimumPanelHeight: 360
                                                + Theme.spacing.lg * 2
                                                + Theme.spacing.md
                                                + Theme.icons.large
    property var _activeToasts: []

    objectName: "playground.preview"
    surfaceType: Surface.Default
    backgroundColor: Theme.colors.surface.inverse
    borderColor: Qt.alpha(Theme.colors.content.inverse, 0.16)
    borderWidth: 1
    radiusValue: Theme.radius.xlarge
    clip: true

    function typeValue(type) {
        switch (type) {
        case "success": return Toastify.Success
        case "warning": return Toastify.Warning
        case "error": return Toastify.Error
        default: return Toastify.Info
        }
    }

    function showToast(message, type) {
        const options = Object.assign({}, root.playgroundState.toastOptions(), {
            "type": root.typeValue(type)
        })
        return root.trackToast(toastHost.createMessage(message, options))
    }

    function trackToast(toast) {
        if (!toast)
            return null

        root._activeToasts = root._activeToasts.concat([toast])
        const untrackWhenHidden = function() {
            if (!toast.closing || toast.opacity > 0.001)
                return

            toast.closingChanged.disconnect(untrackWhenHidden)
            toast.opacityChanged.disconnect(untrackWhenHidden)
            root.untrackToast(toast)
        }
        toast.closingChanged.connect(untrackWhenHidden)
        toast.opacityChanged.connect(untrackWhenHidden)
        return toast
    }

    function untrackToast(toast) {
        const index = root._activeToasts.indexOf(toast)
        if (index < 0)
            return

        const remaining = root._activeToasts.slice()
        remaining.splice(index, 1)
        root._activeToasts = remaining
    }

    function clearAll() {
        const toasts = root._activeToasts.slice()
        for (let index = 0; index < toasts.length; ++index)
            toastHost.dismiss(toasts[index])
    }

    function showCurrentToast() {
        return root.showToast(root.playgroundState.message,
                              root.playgroundState.toastType)
    }

    function showAllTypes() {
        const examples = [
            { "message": qsTr("Here is some useful information."), "type": "info" },
            { "message": qsTr("Your changes were saved."), "type": "success" },
            { "message": qsTr("Review this setting before continuing."), "type": "warning" },
            { "message": qsTr("The operation could not be completed."), "type": "error" }
        ]
        for (let index = 0; index < examples.length; ++index) {
            const example = examples[index]
            Qt.callLater(function() {
                root.showToast(example.message, example.type)
            })
        }
    }

    function showActionToast() {
        const options = Object.assign({}, root.playgroundState.toastOptions(), {
            "position": root.playgroundState.position,
            "autoClose": 0,
            "closeOnClick": false,
            "type": Toastify.Info,
            "action": {
                "label": qsTr("Undo"),
                "dismiss": true,
                "onClick": function() {
                    console.log("QtToastify playground: action restored")
                }
            }
        })
        return root.trackToast(
            toastHost.createMessage(qsTr("The item was removed."), options))
    }

    function showAsync(candidate, successText, errorTemplate) {
        const options = Object.assign({}, root.playgroundState.toastOptions(), {
            "loading": qsTr("Working…"),
            "success": function(result) {
                return successText.length > 0 ? successText : String(result)
            },
            "error": function(reason) {
                return errorTemplate.arg(String(reason))
            }
        })
        return root.trackToast(toastHost.promise(candidate, options))
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: Theme.spacing.lg
        }
        spacing: Theme.spacing.md

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.sm

            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: Theme.colors.status.success.outline
                Accessible.ignored: true
            }

            AppLabel {
                Layout.fillWidth: true
                textType: AppLabel.H4
                text: qsTr("Live Preview")
                color: Theme.colors.content.inverse
            }

            MBadge {
                text: qsTr("%1 × %2")
                    .arg(Math.round(previewViewport.width))
                    .arg(Math.round(previewViewport.height))
                variant: MBadge.Neutral
                size: MBadge.Small
            }
        }

        Rectangle {
            id: previewViewport

            objectName: "playground.preview.viewport"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 360
            radius: Theme.radius.large
            color: Qt.darker(Theme.colors.surface.inverse, 1.18)
            border.width: 1
            border.color: Qt.alpha(Theme.colors.content.inverse, 0.12)
            clip: true

            AppLabel {
                objectName: "playground.preview.emptyState"
                anchors.centerIn: parent
                width: Math.min(parent.width - Theme.spacing.xl2, 420)
                textType: AppLabel.BodySmall
                text: qsTr("Your notifications will appear here.\nUse the actions below to start.")
                color: Qt.alpha(Theme.colors.content.inverse, 0.62)
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                visible: root.activeToastCount === 0
            }

            Toastify {
                id: toastHost

                objectName: "playground.toastHost"
                parent: previewViewport
                style: root.playgroundState.currentStyle
                expand: root.playgroundState.stackExpanded
                visibleToasts: root.playgroundState.visibleToasts
                newestOnTop: root.playgroundState.newestOnTop
            }
        }
    }
}

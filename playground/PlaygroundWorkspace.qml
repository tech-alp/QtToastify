pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Merce.Theme
import "components"

Item {
    id: root

    required property PlaygroundState playgroundState

    objectName: "playground.workspace"

    readonly property bool wideLayout: width >= 1100
    readonly property PreviewPanel activePreview: previewPanel
    property Item previewSlot: null
    property FocusScrollView compactScrollView: null
    property var pendingPromiseJobs: []

    function withPreview(callback) {
        if (!root.activePreview)
            return

        callback(root.activePreview)
        if (!root.wideLayout && root.compactScrollView)
            Qt.callLater(function() {
                root.compactScrollView.scrollToItem(root.activePreview)
            })
    }

    function delayedPromise(shouldReject) {
        return new Promise(function(resolve, reject) {
            root.pendingPromiseJobs = root.pendingPromiseJobs.concat([
                function() {
                    if (shouldReject)
                        reject(qsTr("The service did not respond."))
                    else
                        resolve(qsTr("The operation completed successfully."))
                }
            ])
            if (!promiseTimer.running)
                promiseTimer.start()
        })
    }

    function installPreviewSlot(slot) {
        root.previewSlot = slot
    }

    function releasePreviewSlot(slot) {
        if (root.previewSlot === slot)
            root.previewSlot = null
    }

    Timer {
        id: promiseTimer

        interval: 1500
        repeat: false
        onTriggered: {
            const jobs = root.pendingPromiseJobs.slice()
            const pendingCallback = jobs.shift()
            root.pendingPromiseJobs = jobs
            if (pendingCallback)
                pendingCallback()
            if (jobs.length > 0)
                promiseTimer.start()
        }
    }

    PreviewPanel {
        id: previewPanel

        parent: root.previewSlot ? root.previewSlot : root
        anchors.fill: parent
        visible: root.previewSlot !== null
        playgroundState: root.playgroundState
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: Theme.spacing.pagePadding
        }
        spacing: Theme.spacing.md

        AppHeader {
            Layout.fillWidth: true
        }

        Loader {
            id: workspaceLoader

            objectName: "playground.workspace.loader"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            sourceComponent: root.wideLayout ? wideWorkspace : compactWorkspace
        }

        ActionBar {
            Layout.fillWidth: true
            canShowToast: root.playgroundState.hasMessage
            canClear: root.activePreview
                      ? root.activePreview.activeToastCount > 0
                      : false

            onShowToastRequested: root.withPreview(function(preview) {
                preview.showCurrentToast()
            })
            onAllTypesRequested: root.withPreview(function(preview) {
                preview.showAllTypes()
            })
            onLongMessageRequested: root.withPreview(function(preview) {
                preview.showToast(
                    qsTr("This longer notification demonstrates wrapping, readable spacing, and how the toast adapts without leaving the preview viewport."),
                    root.playgroundState.toastType)
            })
            onActionToastRequested: root.withPreview(function(preview) {
                preview.showActionToast()
            })
            onPromiseSuccessRequested: root.withPreview(function(preview) {
                preview.showAsync(root.delayedPromise(false),
                                  qsTr("Promise completed successfully."),
                                  qsTr("Promise failed: %1"))
            })
            onPromiseErrorRequested: root.withPreview(function(preview) {
                preview.showAsync(root.delayedPromise(true), "",
                                  qsTr("Promise failed: %1"))
            })
            onFutureSuccessRequested: root.withPreview(function(preview) {
                preview.showAsync(PlaygroundFutureFactory.start(false), "",
                                  qsTr("QFuture failed: %1"))
            })
            onFutureErrorRequested: root.withPreview(function(preview) {
                preview.showAsync(PlaygroundFutureFactory.start(true), "",
                                  qsTr("QFuture failed: %1"))
            })
            onClearRequested: root.withPreview(function(preview) {
                preview.clearAll()
            })
        }
    }

    Component {
        id: wideWorkspace

        Item {
            RowLayout {
                anchors.fill: parent
                spacing: Theme.spacing.md

                FocusScrollView {
                    id: configurationScroll

                    objectName: "playground.configuration.scroll"
                    Layout.preferredWidth: 380
                    Layout.minimumWidth: 340
                    Layout.maximumWidth: 420
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    contentHeight: configurationPanel.implicitHeight

                    ConfigurationPanel {
                        id: configurationPanel

                        width: configurationScroll.availableWidth
                        playgroundState: root.playgroundState
                    }
                }

                Item {
                    id: widePreviewSlot

                    objectName: "playground.preview.slot.wide"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 520
                    Component.onCompleted: root.installPreviewSlot(widePreviewSlot)
                    Component.onDestruction: root.releasePreviewSlot(widePreviewSlot)
                }
            }
        }
    }

    Component {
        id: compactWorkspace

        Item {
            FocusScrollView {
                id: compactScroll

                objectName: "playground.compact.scroll"
                anchors.fill: parent
                contentWidth: availableWidth
                contentHeight: compactColumn.implicitHeight
                Component.onCompleted: root.compactScrollView = compactScroll
                Component.onDestruction: {
                    if (root.compactScrollView === compactScroll)
                        root.compactScrollView = null
                }

                ColumnLayout {
                    id: compactColumn

                    width: compactScroll.availableWidth
                    spacing: Theme.spacing.md

                    ConfigurationPanel {
                        Layout.fillWidth: true
                        playgroundState: root.playgroundState
                    }

                    Item {
                        id: compactPreviewSlot

                        objectName: "playground.preview.slot.compact"
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(
                                                    520,
                                                    Math.max(
                                                        root.activePreview.minimumPanelHeight,
                                                        compactScroll.availableHeight
                                                        - Theme.spacing.md))
                        Component.onCompleted: root.installPreviewSlot(compactPreviewSlot)
                        Component.onDestruction: root.releasePreviewSlot(compactPreviewSlot)
                    }
                }
            }
        }
    }
}

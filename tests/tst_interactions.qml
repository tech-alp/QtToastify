pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtTest
import Toastify 1.0
import ToastTests 1.0

TestCase {
    id: testCase

    name: "ToastInteractions"
    when: hostWindow.visible

    property var createdToasts: []
    property var createdCustomToasts: []
    property int actionCount: 0
    property int bodyActionCount: 0
    property int finallyCount: 0

    Component {
        id: customToastComponent

        Rectangle {
            property string message: ""
            property int type: Toastify.Info
            property int position: Toastify.TopLeftCorner
            property int autoClose: 0
            property bool closeOnClick: false
            property bool hideProgressBar: true
            property var clickAction: null
            property var styleProvider: null
            property bool stackCovered: false
            property bool stackPaused: false
            property real stackHeight: -1

            implicitWidth: 220
            implicitHeight: 64
            height: stackHeight >= 0 ? stackHeight : implicitHeight
        }
    }

    ApplicationWindow {
        id: hostWindow

        width: 800
        height: 600
        visible: true

        Toastify {
            id: toastify
        }

        Toastify {
            id: customToastify
            toastItem: customToastComponent
        }
    }

    function track(toast) {
        verify(toast !== null)
        createdToasts.push(toast)
        return toast
    }

    function waitForToastEntered(toast) {
        tryCompare(toast, "_entered", true,
                   toast.styleProvider.animation.enterDuration + 1000)
    }

    function cleanup() {
        mouseMove(hostWindow.contentItem,
                  hostWindow.width / 2, hostWindow.height / 2)
        wait(0)

        for (let i = 0; i < createdToasts.length; ++i) {
            const toast = createdToasts[i]
            if (toast && typeof toast.destroy === "function")
                toast.destroy()
        }
        createdToasts = []

        for (let i = 0; i < createdCustomToasts.length; ++i) {
            const toast = createdCustomToasts[i]
            if (toast && typeof toast.destroy === "function")
                toast.destroy()
        }
        createdCustomToasts = []

        const positions = [
            Toastify.TopLeftCorner,
            Toastify.TopRightCorner,
            Toastify.BottomLeftCorner,
            Toastify.BottomRightCorner,
            Toastify.TopCenter,
            Toastify.BottomCenter
        ]
        for (let i = 0; i < positions.length; ++i) {
            tryCompare(toastify.getColumn(positions[i]), "entryCount", 0)
            tryCompare(customToastify.getColumn(positions[i]),
                       "entryCount", 0)
        }

        actionCount = 0
        bodyActionCount = 0
        finallyCount = 0
    }

    function test_closeButtonIsOptionalAndLazyContentStaysInactive() {
        const toast = track(toastify.info("Persistent", {
            position: Toastify.TopLeftCorner,
            autoClose: 0,
            closeOnClick: false,
            closeButton: false
        }))
        wait(0)

        const closeIcon = findChild(toast, "closeButtonArea")
        const actionLoader = findChild(toast, "actionLoader")
        verify(closeIcon !== null)
        verify(actionLoader !== null)
        compare(closeIcon.visible, false)
        compare(toast.closeButtonReservedWidth, 0)
        compare(toast.rightPadding, toast.containerPadding)
        compare(actionLoader.active, false)
        compare(findChild(toast, "loadingIndicator"), null)
    }

    function test_actionConsumesClickAndControlsDismissal() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        const toast = track(toastify.info("Deleted", {
            position: Toastify.TopLeftCorner,
            autoClose: 0,
            closeOnClick: true,
            clickAction: function() {
                testCase.bodyActionCount += 1
            },
            action: {
                label: "Undo",
                onClick: function() {
                    testCase.actionCount += 1
                },
                dismiss: false
            }
        }))
        wait(0)

        const actionButton = findChild(toast, "actionButton")
        verify(actionButton !== null)
        verify(actionButton.width > 0)
        verify(actionButton.height > 0)

        mouseClick(actionButton,
                   actionButton.width / 2, actionButton.height / 2)
        compare(actionCount, 1)
        compare(bodyActionCount, 0)
        compare(stack.entryCount, 1)

        toast.action = {
            label: "Dismiss",
            onClick: function() {
                testCase.actionCount += 1
            },
            dismiss: true
        }
        wait(0)
        mouseClick(actionButton,
                   actionButton.width / 2, actionButton.height / 2)
        compare(actionCount, 2)
        compare(bodyActionCount, 0)
        tryCompare(stack, "entryCount", 0,
                   toastify.style.animation.exitDuration + 1000)
        createdToasts = []
    }

    function test_customDelegateIgnoresUnsupportedOptionalProperties() {
        const toast = customToastify.info("Custom", {
            position: Toastify.TopRightCorner,
            autoClose: 0,
            closeButton: false,
            isLoading: true,
            action: {
                label: "Ignored",
                onClick: function() {}
            }
        })
        verify(toast !== null)
        createdCustomToasts.push(toast)
        compare(toast.message, "Custom")
        compare(customToastify.getColumn(
                    Toastify.TopRightCorner).entryCount, 1)
    }

    function test_promiseResolvesOnSameToast() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        let resolveTask = null
        const task = new Promise(function(resolve) {
            resolveTask = resolve
        })
        const toast = track(toastify.promise(task, {
            loading: "Saving...",
            success: function(result) {
                return result.name + " saved"
            },
            error: "Save failed",
            position: Toastify.TopLeftCorner,
            autoClose: 3000,
            finally: function() {
                testCase.finallyCount += 1
            }
        }))

        compare(stack.entryCount, 1)
        compare(stack.frontEntry.toastObject, toast)
        compare(toast.message, "Saving...")
        compare(toast.isLoading, true)
        compare(toast.autoClose, 0)
        compare(toast.hideProgressBar, true)
        compare(toast.closeOnClick, false)
        compare(toast.closeButton, false)
        verify(findChild(toast, "loadingIndicator") !== null)

        resolveTask({ name: "Sensor" })
        tryCompare(toast, "message", "Sensor saved")
        compare(toast.type, Toastify.Success)
        compare(toast.isLoading, false)
        compare(toast.autoClose, 3000)
        compare(toast.hideProgressBar, false)
        compare(toast.closeOnClick, true)
        compare(toast.closeButton, true)
        compare(stack.entryCount, 1)
        compare(stack.frontEntry.toastObject, toast)
        compare(finallyCount, 1)

        waitForToastEntered(toast)
        tryVerify(function() {
            return toast.progressValue > 0
        }, 1000)
    }

    function test_promiseRejectsAndSupportsPendingAlias() {
        let rejectTask = null
        const task = new Promise(function(resolve, reject) {
            rejectTask = reject
        })
        const toast = track(toastify.promise(task, {
            pending: "Connecting...",
            success: "Connected",
            error: function(error) {
                return "Offline: " + error
            },
            position: Toastify.BottomRightCorner,
            autoClose: 0
        }))

        compare(toast.message, "Connecting...")
        rejectTask("timeout")
        tryCompare(toast, "message", "Offline: timeout")
        compare(toast.type, Toastify.Error)
        compare(toast.isLoading, false)
        compare(toast.autoClose, 0)
    }

    function test_qFutureResolvesAndRejects() {
        const resolvedToast = track(toastify.promise(
            FutureTestFactory.resolveAfter("QFuture ready", 20), {
                loading: "Waiting for QFuture...",
                success: function(result) { return result },
                error: "QFuture failed",
                position: Toastify.TopLeftCorner,
                autoClose: 0
            }))

        compare(resolvedToast.isLoading, true)
        tryCompare(resolvedToast, "message", "QFuture ready")
        compare(resolvedToast.type, Toastify.Success)
        compare(resolvedToast.isLoading, false)

        const rejectedToast = track(toastify.promise(
            FutureTestFactory.rejectAfter("device offline", 20), {
                loading: "Connecting device...",
                success: "Connected",
                error: function(reason) { return "Offline: " + reason },
                position: Toastify.TopRightCorner,
                autoClose: 0
            }))

        tryCompare(rejectedToast, "message", "Offline: device offline")
        compare(rejectedToast.type, Toastify.Error)
        compare(rejectedToast.isLoading, false)
        wait(0)
        compare(FutureTestFactory.activeBridgeCount(), 0)
    }

    function test_qFutureVoidResolves() {
        const toast = track(toastify.promise(
            FutureTestFactory.resolveVoidAfter(20), {
                loading: "Applying...",
                success: "Applied",
                error: "Apply failed",
                position: Toastify.BottomLeftCorner,
                autoClose: 0
            }))

        tryCompare(toast, "message", "Applied")
        compare(toast.type, Toastify.Success)
        compare(toast.isLoading, false)
        wait(0)
        compare(FutureTestFactory.activeBridgeCount(), 0)
    }

    function test_qFutureCancellationRejects() {
        const toast = track(toastify.promise(
            FutureTestFactory.cancelAfter(20), {
                loading: "Cancelable operation...",
                success: "Unexpected success",
                error: function(reason) { return "Canceled: " + reason },
                position: Toastify.BottomRightCorner,
                autoClose: 0
            }))

        tryCompare(toast, "message", "Canceled: Operation canceled")
        compare(toast.type, Toastify.Error)
        compare(toast.isLoading, false)
        wait(0)
        compare(FutureTestFactory.activeBridgeCount(), 0)
    }

    function test_promiseTimerRespectsHoveredStack() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        let resolveTask = null
        const task = new Promise(function(resolve) {
            resolveTask = resolve
        })
        const toast = track(toastify.promise(task, {
            loading: "Waiting...",
            success: "Ready",
            error: "Failed",
            position: Toastify.TopLeftCorner,
            autoClose: 3000
        }))

        waitForToastEntered(toast)
        mouseMove(stack, stack.width / 2, stack.height / 2)
        tryCompare(stack, "hovered", true)
        tryCompare(toast, "stackPaused", true)

        resolveTask(true)
        tryCompare(toast, "isLoading", false)
        const pausedProgress = toast.progressValue
        wait(250)
        fuzzyCompare(toast.progressValue, pausedProgress, 0.01)

        mouseMove(hostWindow.contentItem,
                  hostWindow.width / 2, hostWindow.height / 2)
        tryCompare(stack, "hovered", false)
        tryVerify(function() {
            return toast.progressValue > pausedProgress + 0.02
        }, 1000)
    }

    function test_closedPromiseDoesNotResurrectToast() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        let resolveTask = null
        const task = new Promise(function(resolve) {
            resolveTask = resolve
        })
        const toast = track(toastify.promise(task, {
            loading: "Working...",
            success: "Done",
            error: "Failed",
            position: Toastify.TopLeftCorner,
            finally: function() {
                testCase.finallyCount += 1
            }
        }))

        verify(toastify.dismiss(toast))
        tryCompare(stack, "entryCount", 0,
                   toastify.style.animation.exitDuration + 1000)
        createdToasts = []

        resolveTask(true)
        tryCompare(testCase, "finallyCount", 1)
        compare(stack.entryCount, 0)
    }
}

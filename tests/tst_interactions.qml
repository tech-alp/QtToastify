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
        tryVerify(function() {
            return findChild(toastify, "timeoutTimer") === null
        })
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

    function test_withTimeoutRejects_data() {
        return [
            { tag: "default-message", message: undefined,
              expected: "Operation timed out" },
            { tag: "custom-message", message: "Save took too long",
              expected: "Save took too long" }
        ]
    }

    function test_withTimeoutRejects(data) {
        const observed = { error: null, count: 0 }
        const started = Date.now()
        const task = toastify.withTimeout(new Promise(function() {}),
                                         60, data.message)
        verify(task instanceof Promise)
        task.then(function() {
            observed.count += 1
        }, function(error) {
            observed.error = error
            observed.count += 1
        })

        compare(observed.count, 0)
        tryVerify(function() { return observed.error !== null })
        verify(Date.now() - started >= 60)
        verify(observed.error instanceof Error)
        compare(observed.error.name, "TimeoutError")
        compare(observed.error.timeout, 60)
        compare(observed.error.message, data.expected)
        compare(observed.count, 1)
        tryVerify(function() {
            return findChild(toastify, "timeoutTimer") === null
        })
        compare(toastify.getColumn(Toastify.TopLeftCorner).entryCount, 0)
    }

    function test_withTimeoutIgnoresLateResult_data() {
        return [{ tag: "resolve", rejected: false },
                { tag: "reject", rejected: true }]
    }

    function test_withTimeoutIgnoresLateResult(data) {
        let settleTask = null
        const task = new Promise(function(resolve, reject) {
            settleTask = data.rejected ? reject : resolve
        })
        const observed = { count: 0, error: null, workFinished: false }
        task.then(function() { observed.workFinished = true },
                  function() { observed.workFinished = true })
        toastify.withTimeout(task, 40).then(function() {
            observed.count += 1
        }, function(error) {
            observed.error = error
            observed.count += 1
        })

        tryVerify(function() { return observed.error !== null })
        compare(observed.error.name, "TimeoutError")
        compare(observed.workFinished, false)
        const timeoutError = observed.error
        settleTask("late result")
        tryVerify(function() { return observed.workFinished })
        wait(50)
        compare(observed.count, 1)
        compare(observed.error, timeoutError)
    }

    function test_withTimeoutDisabled_data() {
        return [
            { tag: "zero-resolve", ms: 0, rejected: false },
            { tag: "negative-resolve", ms: -20, rejected: false },
            { tag: "zero-reject", ms: 0, rejected: true },
            { tag: "negative-reject", ms: -20, rejected: true }
        ]
    }

    function test_withTimeoutDisabled(data) {
        let settleTask = null
        const value = { result: "unchanged" }
        const observed = { count: 0, value: null, rejected: false }
        const task = new Promise(function(resolve, reject) {
            settleTask = data.rejected ? reject : resolve
        })
        const adapted = toastify.withTimeout(task, data.ms)
        compare(adapted, task)
        adapted.then(function(result) {
            observed.value = result
            observed.count += 1
        }, function(error) {
            observed.value = error
            observed.rejected = true
            observed.count += 1
        })

        wait(60)
        compare(observed.count, 0)
        compare(findChild(toastify, "timeoutTimer"), null)
        settleTask(value)
        tryVerify(function() { return observed.count === 1 })
        compare(observed.value, value)
        compare(observed.rejected, data.rejected)
    }

    function test_withTimeoutSettlesBeforeExpiry_data() {
        return [
            { tag: "promise-resolve", thenable: false, rejected: false, ms: 1000 },
            { tag: "promise-reject", thenable: false, rejected: true, ms: 1000 },
            { tag: "thenable-resolve", thenable: true, rejected: false, ms: 1000 },
            { tag: "thenable-reject", thenable: true, rejected: true, ms: 1000 },
            { tag: "thenable-disabled", thenable: true, rejected: false, ms: 0 }
        ]
    }

    function test_withTimeoutSettlesBeforeExpiry(data) {
        const value = data.rejected ? new Error("Original failure")
                                    : { result: "ready" }
        const observed = { count: 0, value: null, rejected: false }
        const input = data.thenable ? {
            then: function(resolve, reject) {
                if (data.rejected)
                    reject(value)
                else
                    resolve(value)
            }
        } : data.rejected ? Promise.reject(value) : Promise.resolve(value)
        const task = toastify.withTimeout(input, data.ms)
        verify(task instanceof Promise)
        if (data.ms > 0) {
            const timer = findChild(toastify, "timeoutTimer")
            verify(timer !== null)
            compare(timer.running, true)
        }
        task.then(function(result) {
            observed.value = result
            observed.count += 1
        }, function(error) {
            observed.value = error
            observed.rejected = true
            observed.count += 1
        })

        tryVerify(function() { return observed.count === 1 })
        compare(observed.value, value)
        compare(observed.rejected, data.rejected)
        tryVerify(function() {
            return findChild(toastify, "timeoutTimer") === null
        })
    }

    function test_withTimeoutQFuture_data() {
        return [
            { tag: "resolve", rejected: false, delay: 20, ms: 1000 },
            { tag: "reject", rejected: true, delay: 20, ms: 1000 },
            { tag: "timeout", rejected: false, delay: 200, ms: 40 },
            { tag: "disabled", rejected: false, delay: 20, ms: 0 }
        ]
    }

    function test_withTimeoutQFuture(data) {
        const observed = { count: 0, value: null, rejected: false,
                           workFinished: false }
        const bridge = data.rejected
                       ? FutureTestFactory.rejectAfter("device offline", data.delay)
                       : FutureTestFactory.resolveAfter("QFuture ready", data.delay)
        bridge.resolved.connect(function() { observed.workFinished = true })
        bridge.rejected.connect(function() { observed.workFinished = true })
        const task = toastify.withTimeout(bridge, data.ms)
        verify(task instanceof Promise)
        task.then(function(result) {
            observed.value = result
            observed.count += 1
        }, function(error) {
            observed.value = error
            observed.rejected = true
            observed.count += 1
        })

        tryVerify(function() { return observed.count === 1 })
        if (data.ms > 0 && data.ms < data.delay) {
            compare(observed.rejected, true)
            compare(observed.value.name, "TimeoutError")
            compare(observed.value.timeout, data.ms)
        } else {
            compare(observed.rejected, data.rejected)
            compare(observed.value, data.rejected ? "device offline" : "QFuture ready")
        }
        tryVerify(function() { return observed.workFinished })
        tryVerify(function() { return FutureTestFactory.activeBridgeCount() === 0 })
        compare(observed.count, 1)
    }

    function test_promiseWithTimeoutFinally_data() {
        return [{ tag: "visible", dismissed: false },
                { tag: "dismissed", dismissed: true }]
    }

    function test_promiseWithTimeoutFinally(data) {
        let resolveTask = null
        const task = new Promise(function(resolve) { resolveTask = resolve })
        const observed = { errorCount: 0, error: null }
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        const toast = track(toastify.promise(toastify.withTimeout(task, 80), {
            loading: "Working...",
            success: "Unexpected success",
            error: function(error) {
                observed.error = error
                observed.errorCount += 1
                return "Timed out"
            },
            autoClose: 0,
            finally: function() { testCase.finallyCount += 1 }
        }))
        if (data.dismissed)
            verify(toastify.dismiss(toast))

        tryCompare(testCase, "finallyCount", 1)
        if (data.dismissed) {
            compare(observed.errorCount, 0)
            tryCompare(stack, "entryCount", 0)
            createdToasts = []
        } else {
            compare(observed.errorCount, 1)
            compare(observed.error.name, "TimeoutError")
            compare(toast.message, "Timed out")
            compare(toast.type, Toastify.Error)
            compare(toast.isLoading, false)
        }

        resolveTask("late success")
        wait(50)
        compare(finallyCount, 1)
        compare(observed.errorCount, data.dismissed ? 0 : 1)
        if (!data.dismissed)
            compare(toast.message, "Timed out")
    }

    function test_withTimeoutDoesNotPauseOnHover() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        const toast = track(toastify.promise(
            toastify.withTimeout(new Promise(function() {}), 1000), {
                loading: "Waiting...",
                error: "Timed out",
                autoClose: 0
            }))
        waitForToastEntered(toast)
        mouseMove(stack, stack.width / 2, stack.height / 2)
        tryCompare(stack, "hovered", true)
        compare(toast.stackPaused, true)
        tryCompare(toast, "message", "Timed out", 1500)
        compare(stack.hovered, true)
        compare(toast.type, Toastify.Error)
    }

    function test_promiseMessageObjects_data() {
        return [
            { tag: "success-object", rejected: false, factory: false },
            { tag: "success-function", rejected: false, factory: true },
            { tag: "error-object", rejected: true, factory: false },
            { tag: "error-function", rejected: true, factory: true }
        ]
    }

    function test_promiseMessageObjects(data) {
        const value = data.rejected ? "device offline" : "saved result"
        const spec = {
            message: data.rejected ? "Failed" : "Saved",
            detail: "Operation detail: " + value,
            action: {
                label: data.rejected ? "Retry" : "Undo",
                onClick: function() { testCase.actionCount += 1 }
            }
        }
        const messageSpec = data.factory ? function(result) {
            compare(result, value)
            return spec
        } : spec
        const toast = track(toastify.promise(
            data.rejected ? Promise.reject(value) : Promise.resolve(value), {
                loading: "Working...",
                success: messageSpec,
                error: messageSpec,
                autoClose: 0
            }))

        tryCompare(toast, "isLoading", false)
        compare(toast.type, data.rejected ? Toastify.Error : Toastify.Success)
        compare(toast.message, spec.message)
        compare(toast.detail, spec.detail)
        compare(toast.action.label, spec.action.label)
        const detailLabel = findChild(toast, "detailLabel")
        verify(detailLabel !== null)
        compare(detailLabel.text, spec.detail)
        compare(detailLabel.visible, true)
        waitForToastEntered(toast)

        const actionButton = findChild(toast, "actionButton")
        verify(actionButton !== null)
        mouseClick(actionButton, actionButton.width / 2, actionButton.height / 2)
        compare(actionCount, 1)
        compare(toast.closing, true)
        toast.triggerAction()
        compare(actionCount, 1)
        tryCompare(toastify.getColumn(Toastify.TopLeftCorner), "entryCount", 0)
        createdToasts = []
    }

    function test_promiseLegacyMessageSpecs_data() {
        return test_promiseMessageObjects_data()
    }

    function test_promiseLegacyMessageSpecs(data) {
        const value = data.rejected ? "failure" : "result"
        const messageSpec = data.factory ? function(result) {
            return "Settled: " + result
        } : "Settled"
        const toast = track(toastify.promise(
            data.rejected ? Promise.reject(value) : Promise.resolve(value), {
                loading: "Working...",
                success: messageSpec,
                error: messageSpec,
                detail: "Existing detail",
                action: { label: "Existing action" },
                autoClose: 0,
                finally: function() { testCase.finallyCount += 1 }
            }))

        tryCompare(toast, "isLoading", false)
        compare(toast.message, data.factory ? "Settled: " + value : "Settled")
        compare(toast.type, data.rejected ? Toastify.Error : Toastify.Success)
        compare(toast.detail, "Existing detail")
        compare(toast.action.label, "Existing action")
        compare(finallyCount, 1)
    }
}

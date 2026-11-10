pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtTest
import Toastify 1.0
import Toastify.Style 1.0

TestCase {
    id: testCase

    name: "ToastOptions"
    when: hostWindow.visible

    property var createdToasts: []
    property int actionCount: 0

    ApplicationWindow {
        id: hostWindow

        width: 800
        height: 600
        visible: true

        Toastify {
            id: toastify
            visibleToasts: 1
            autoCloseByType: ({ [Toastify.Success]: 200, [Toastify.Error]: 0 })
            style: ToastifyStyleProvider {
                backgroundColors: ({ error: "#fde2e2" })
                animation: ({ enterDuration: 50, exitDuration: 50 })
                actionButton: ({ minimumHeight: 48, backgroundColor: "#1d4ed8",
                                 textColor: "#ffffff", pressedColor: "#1e3a8a" })
            }
        }
    }

    function track(toast) {
        verify(toast !== null)
        createdToasts.push(toast)
        return toast
    }

    function cleanup() {
        toastify.paused = false
        for (let i = 0; i < createdToasts.length; ++i) {
            const toast = createdToasts[i]
            if (toast && typeof toast.destroy === "function")
                toast.destroy()
        }
        createdToasts = []
        tryCompare(toastify.getColumn(Toastify.TopCenter), "entryCount", 0)
        actionCount = 0
    }

    function test_detailAndTypeBackground() {
        const toast = track(toastify.error("Fail", {
            position: Toastify.TopCenter, detail: "Fail (3)", closeOnClick: false
        }))
        tryCompare(toast, "_entered", true)
        const detail = findChild(toast, "detailLabel")
        compare(detail.visible, true)
        compare(detail.text, "Fail (3)")
        compare(findChild(toast, "toastBackground").color, Qt.color("#fde2e2"))

        verify(toastify.update(toast, { detail: "" }))
        compare(detail.visible, false)

        const info = track(toastify.info("Info", { position: Toastify.TopCenter }))
        compare(findChild(info, "toastBackground").color, toastify.style.backgroundColor)
    }

    function test_autoCloseByType() {
        compare(track(toastify.error("Fail", { position: Toastify.TopCenter })).autoClose, 0)
        compare(track(toastify.info("Info", { position: Toastify.TopCenter })).autoClose, 5000)
        compare(track(toastify.success("Done", { position: Toastify.TopCenter, autoClose: 1000 })).autoClose, 1000)
        compare(track(toastify.success("Done", { position: Toastify.TopCenter })).autoClose, 200)
    }

    function test_pausedHoldsAutoClose() {
        const stack = toastify.getColumn(Toastify.TopCenter)
        toastify.paused = true
        const toast = track(toastify.success("Done", { position: Toastify.TopCenter }))
        tryCompare(toast, "_entered", true)
        compare(toast.stackPaused, true)
        wait(400)
        compare(stack.entryCount, 1)
        toastify.paused = false
        tryCompare(stack, "entryCount", 0)
    }

    function test_pauseMidCountdownResumesRemainingTime() {
        const stack = toastify.getColumn(Toastify.TopCenter)
        const toast = track(toastify.info("Countdown", {
            position: Toastify.TopCenter, autoClose: 1200
        }))
        tryCompare(toast, "_entered", true)
        tryVerify(function() { return toast.progressValue > 0.2 }, 1000)

        toastify.paused = true
        tryCompare(toast, "stackPaused", true)
        const pausedProgress = toast.progressValue
        wait(1400)
        compare(stack.entryCount, 1)
        fuzzyCompare(toast.progressValue, pausedProgress, 0.01)

        toastify.paused = false
        tryCompare(toast, "stackPaused", false)
        verify(toast.progressValue >= pausedProgress - 0.01,
               "Resuming must not restart the countdown")
        tryVerify(function() {
            return toast.progressValue > pausedProgress + 0.05
        }, 500)
        tryCompare(stack, "entryCount", 0, 1600)
    }

    function test_promiseSettlementRespectsGlobalPause_data() {
        return [
            { tag: "resolved", reject: false, expectedType: Toastify.Success },
            { tag: "rejected", reject: true, expectedType: Toastify.Error }
        ]
    }

    function test_promiseSettlementRespectsGlobalPause(data) {
        const stack = toastify.getColumn(Toastify.TopCenter)
        let settleTask = null
        const task = new Promise(function(resolve, reject) {
            settleTask = data.reject ? reject : resolve
        })
        const toast = track(toastify.promise(task, {
            loading: "Working", success: "Done", error: "Failed",
            position: Toastify.TopCenter, autoClose: 400
        }))
        tryCompare(toast, "_entered", true)
        toastify.paused = true
        tryCompare(toast, "stackPaused", true)

        settleTask("Result")
        tryCompare(toast, "isLoading", false)
        compare(toast.type, data.expectedType)
        compare(toast.message, data.reject ? "Failed" : "Done")
        const pausedProgress = toast.progressValue
        wait(650)
        compare(stack.entryCount, 1)
        fuzzyCompare(toast.progressValue, pausedProgress, 0.01)

        toastify.paused = false
        tryCompare(stack, "entryCount", 0, 1500)
    }

    ToastifyStyleProvider {
        id: touchCloseStyle
        readonly property ToastifyStyleProvider defaults: ToastifyStyleProvider {}
        spacing: Object.assign({}, defaults.spacing, {
            closeButton: Object.assign({}, defaults.spacing.closeButton, { touchSize: 48 })
        })
        animation: ({ enterDuration: 50, exitDuration: 50 })
    }

    function test_expandedCloseHitTargetConsumesClickOutsideIcon_data() {
        return [
            { tag: "body-dismiss-disabled", closeOnClick: false },
            { tag: "body-dismiss-enabled", closeOnClick: true }
        ]
    }

    function test_expandedCloseHitTargetConsumesClickOutsideIcon(data) {
        const stack = toastify.getColumn(Toastify.TopCenter)
        const toast = track(toastify.info("Close target", {
            position: Toastify.TopCenter, autoClose: 0, closeOnClick: data.closeOnClick,
            clickAction: function() { testCase.actionCount += 1 }
        }))
        toast.styleProvider = touchCloseStyle
        tryCompare(toast, "_entered", true)
        const close = findChild(toast, "closeButtonArea")
        verify(close !== null)
        const clickX = close.x - toast.closeButtonHitMargin + 2
        verify(clickX >= 0 && clickX < close.x,
               "Click must be inside the expanded target but outside the icon")
        mouseClick(toast, clickX, close.y + close.height / 2)
        tryCompare(stack, "entryCount", 0)
        compare(actionCount, 0, "Close target must not trigger the toast body action")
    }

    function test_actionButtonUsesStyle() {
        const stack = toastify.getColumn(Toastify.TopCenter)
        const toast = track(toastify.error("Test failed", {
            position: Toastify.TopCenter,
            closeOnClick: false,
            action: { label: "Retry", onClick: function() { testCase.actionCount += 1 } }
        }))
        tryCompare(toast, "_entered", true)
        const button = findChild(toast, "actionButton")
        verify(button !== null)
        compare(button.implicitHeight, 48)
        compare(button.color, Qt.color("#1d4ed8"))
        mouseClick(button)
        compare(actionCount, 1)
        tryCompare(stack, "entryCount", 0)
    }
}

import QtQuick
import QtQuick.Controls
import QtTest
import Toastify 1.0

TestCase {
    id: testCase

    name: "ToastStackBehavior"
    when: hostWindow.visible

    property var createdToasts: []
    property var createdCustomToasts: []

    SignalSpy {
        id: stackHoverSpy
        signalName: "hoveredChanged"
    }

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
            property real requestedWidth: 240
            property real requestedHeight: message.length > 20 ? 96 : 64

            implicitWidth: 180
            implicitHeight: 48
            width: requestedWidth
            height: stackHeight >= 0 ? stackHeight : requestedHeight
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

    function createToast(message, position) {
        const toast = toastify.info(message, {
            position: position,
            autoClose: 0,
            closeOnClick: false
        })
        verify(toast !== null)
        createdToasts.push(toast)
        return toast
    }

    function createCustomToast(message) {
        const toast = customToastify.info(message, {
            position: Toastify.TopRightCorner,
            autoClose: 0,
            closeOnClick: false
        })
        verify(toast !== null)
        createdCustomToasts.push(toast)
        return toast
    }

    function waitForToastEntered(toast) {
        tryCompare(toast, "_entered", true,
                   toast.styleProvider.animation.enterDuration + 1000)
    }

    function waitForStackLayout(stack) {
        const entries = stack.entriesByAge()
        const timeout = stack.transitionDuration + 1000

        for (let i = 0; i < entries.length; ++i) {
            const entry = entries[i]
            const expectedScale = stack.expanded
                    ? 1
                    : Math.max(0.8,
                               1 - Math.max(0, entry.depth)
                               * stack.collapsedScaleStep)
            tryCompare(entry, "layoutOffset", stack.offsetFor(entry), timeout)
            tryCompare(entry, "scale", expectedScale, timeout)
        }
    }

    function cleanup() {
        stackHoverSpy.target = null
        stackHoverSpy.clear()
        mouseMove(hostWindow.contentItem,
                  hostWindow.width / 2, hostWindow.height / 2)
        wait(0)

        toastify.expand = false
        toastify.visibleToasts = 3
        toastify.newestOnTop = false
        customToastify.expand = false
        customToastify.visibleToasts = 3
        customToastify.newestOnTop = false

        for (let i = 0; i < createdToasts.length; ++i) {
            if (createdToasts[i]
                    && typeof createdToasts[i].destroy === "function") {
                createdToasts[i].destroy()
            }
        }
        createdToasts = []

        for (let i = 0; i < createdCustomToasts.length; ++i) {
            if (createdCustomToasts[i]
                    && typeof createdCustomToasts[i].destroy === "function") {
                createdCustomToasts[i].destroy()
            }
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
            tryCompare(customToastify.getColumn(positions[i]), "entryCount", 0)
        }
    }

    function test_defaultAndExpandedModes() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        const spacing = toastify.style.toastSpacing
        const compactOffset = toastify.style.collapsedToastOffset

        compare(toastify.expand, false)
        compare(toastify.visibleToasts, 3)
        compare(compactOffset, 14)

        createToast("First", Toastify.TopLeftCorner)
        createToast("Second", Toastify.TopLeftCorner)
        createToast("Third", Toastify.TopLeftCorner)
        createToast("Fourth", Toastify.TopLeftCorner)
        wait(0)

        compare(stack.entryCount, 4)
        compare(stack.visibleEntryCount, 3)
        compare(stack.expanded, false)
        compare(stack.height, stack.frontHeight)
        compare(stack.collapsedHeight,
                stack.frontHeight + 2 * compactOffset)
        compare(stack.visualHeight, stack.collapsedHeight)

        const byAge = stack.entriesByAge()
        compare(byAge[0].visible, true)
        compare(byAge[1].visible, true)
        compare(byAge[2].visible, true)
        compare(byAge[3].visible, false)
        compare(byAge[0].depth, 0)
        compare(byAge[0].scale, 1)
        waitForStackLayout(stack)
        compare(byAge[0].y, 0)
        tryCompare(byAge[1], "y", compactOffset)
        tryCompare(byAge[2], "y", 2 * compactOffset)
        verify(byAge[1].scale < byAge[0].scale)
        compare(byAge[1].transformOrigin, Item.Center)

        const frontVisualBottom = byAge[0].mapToItem(
                                    hostWindow.contentItem,
                                    0, byAge[0].height).y
        const rearVisualBottom = byAge[1].mapToItem(
                                   hostWindow.contentItem,
                                   0, byAge[1].height).y
        fuzzyCompare(rearVisualBottom - frontVisualBottom,
                     compactOffset
                     - stack.frontHeight
                     * toastify.style.collapsedToastScaleStep / 2,
                     1)

        toastify.expand = true
        compare(stack.expanded, true)
        waitForStackLayout(stack)
        compare(stack.height, stack.frontHeight)
        compare(stack.visualHeight, stack.expandedHeight)
        fuzzyCompare(byAge[2].y, 0, 0.01)
        tryCompare(byAge[1], "y", byAge[2].naturalHeight + spacing)
        tryCompare(byAge[0], "y",
                   byAge[2].naturalHeight + byAge[1].naturalHeight
                   + 2 * spacing)
        compare(byAge[0].covered, false)
        compare(byAge[1].covered, false)

        toastify.expand = false
        compare(stack.expanded, false)
        compare(stack.height, stack.frontHeight)
        compare(stack.visualHeight, stack.collapsedHeight)
        compare(byAge[1].covered, true)
    }

    function test_collapsedRearUsesFrontHeight() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)

        const tallToast = createToast(
                    "This older notification is tall enough to wrap onto "
                    + "multiple lines in the toast container.",
                    Toastify.TopLeftCorner)
        const frontToast = createToast("Newest", Toastify.TopLeftCorner)
        wait(0)

        verify(tallToast.implicitHeight > frontToast.implicitHeight)
        compare(stack.entriesByAge()[1].height,
                stack.entriesByAge()[0].height)

        toastify.expand = true
        wait(0)
        verify(stack.entriesByAge()[1].height
               > stack.entriesByAge()[0].height)
    }

    function test_customDelegateStackContract() {
        const stack = customToastify.getColumn(Toastify.TopRightCorner)
        const oldest = createCustomToast("Oldest")
        const middle = createCustomToast(
                    "A custom toast with a deliberately taller body")
        const front = createCustomToast("Newest")
        wait(0)

        compare(oldest.stackCovered, true)
        compare(middle.stackCovered, true)
        compare(front.stackCovered, false)
        compare(oldest.height, front.height)
        compare(middle.height, front.height)
        compare(stack.width, front.width)
        compare(stack.height, front.height)
        compare(stack.visualHeight, stack.collapsedHeight)

        customToastify.newestOnTop = true
        customToastify.expand = true
        tryCompare(middle, "height", middle.requestedHeight)
        tryCompare(oldest, "height", oldest.requestedHeight)
        compare(oldest.stackCovered, false)
        compare(middle.stackCovered, false)
        verify(middle.height > front.height)

        const byAge = stack.entriesByAge()
        const spacing = customToastify.style.toastSpacing
        waitForStackLayout(stack)
        compare(byAge[0].toastObject, front)
        compare(byAge[1].toastObject, middle)
        compare(byAge[2].toastObject, oldest)
        compare(byAge[0].y, 0)
        tryCompare(byAge[1], "y", front.height + spacing)
        tryCompare(byAge[2], "y",
                   front.height + middle.height + 2 * spacing)
        compare(stack.height, front.height)
        compare(stack.expandedHeight,
                front.height + middle.height + oldest.height
                + 2 * spacing)
        compare(stack.visualHeight, stack.expandedHeight)

        middle.requestedWidth = 300
        tryCompare(stack, "width", 300)

        const previousExpandedHeight = stack.expandedHeight
        const previousOldestY = byAge[2].y
        middle.requestedHeight = 120
        tryCompare(middle, "height", 120)
        tryCompare(stack, "expandedHeight", previousExpandedHeight + 24)
        tryCompare(byAge[2], "y", previousOldestY + 24,
                   customToastify.style.stackTransitionDuration + 100)
        compare(stack.height, front.height)
        compare(oldest.stackPaused, false)
        compare(middle.stackPaused, false)
        compare(front.stackPaused, false)
    }

    function test_mixedHeightAndBottomAnchor() {
        const stack = toastify.getColumn(Toastify.BottomRightCorner)

        const olderToast = createToast("Short", Toastify.BottomRightCorner)
        waitForStackLayout(stack)

        const olderEntry = stack.entriesByAge()[0]
        const baselineY = stack.y
        const olderSceneBottom = olderEntry.mapToItem(
                                     hostWindow.contentItem,
                                     0, olderEntry.height).y
        const frontToast = createToast(
                    "This is a deliberately long toast message that wraps "
                    + "onto multiple lines and verifies mixed-height stacks.",
                    Toastify.BottomRightCorner)
        wait(0)

        const byAge = stack.entriesByAge()
        verify(frontToast.height > 64)
        compare(stack.frontEntry.toastObject, frontToast)
        compare(stack.height, 0)
        compare(stack.collapsedHeight,
                frontToast.height + toastify.style.collapsedToastOffset)
        compare(stack.visualHeight, stack.collapsedHeight)
        compare(stack.y, baselineY)
        fuzzyCompare(stack.y,
                     toastify.height - toastify.style.toastOffset,
                     1)
        compare(byAge[0].y, -stack.frontHeight)
        fuzzyCompare(byAge[0].mapToItem(hostWindow.contentItem,
                                        0, byAge[0].height).y,
                     stack.y, 1)
        tryVerify(function() {
            const currentBottom = byAge[1].mapToItem(
                        hostWindow.contentItem, 0, byAge[1].height).y
            const tolerance = stack.frontHeight
                    * toastify.style.collapsedToastScaleStep / 2 + 1
            return Math.abs(currentBottom - olderSceneBottom) <= tolerance
        }, stack.transitionDuration + 1000)

        waitForStackLayout(stack)
        compare(byAge[0].y, -stack.frontHeight)
        tryCompare(byAge[1], "y",
                   -stack.frontHeight
                   - toastify.style.collapsedToastOffset)
        const frontSceneY = byAge[0].mapToItem(hostWindow.contentItem,
                                               0, 0).y

        toastify.expand = true
        waitForStackLayout(stack)
        compare(stack.height, 0)
        verify(stack.expandedHeight > frontToast.height)
        compare(stack.visualHeight, stack.expandedHeight)
        compare(byAge[0].y, -stack.frontHeight)
        tryCompare(byAge[1], "y", -stack.expandedHeight)
        fuzzyCompare(byAge[0].mapToItem(hostWindow.contentItem, 0, 0).y,
                     frontSceneY, 1)
        fuzzyCompare(stack.y,
                     toastify.height - toastify.style.toastOffset,
                     1)

        toastify.expand = false
        waitForStackLayout(stack)
        const olderBottomBeforeClose = byAge[1].mapToItem(
                                           hostWindow.contentItem,
                                           0, byAge[1].height).y

        frontToast.close()
        tryCompare(stack, "entryCount", 1,
                   toastify.style.animation.exitDuration + 1000)

        const promotedEntry = stack.entriesByAge()[0]
        const promotedBottomDuringMove = promotedEntry.mapToItem(
                                             hostWindow.contentItem,
                                             0, promotedEntry.height).y
        verify(promotedBottomDuringMove >= olderBottomBeforeClose)
        verify(promotedBottomDuringMove <= stack.y)
        waitForStackLayout(stack)
        tryVerify(function() {
            const promotedBottom = promotedEntry.mapToItem(
                        hostWindow.contentItem, 0, promotedEntry.height).y
            return Math.abs(promotedBottom - stack.y) <= 1
        }, stack.transitionDuration + 1000)
        createdToasts = [olderToast]
    }

    function test_frontPositionStableDuringHover() {
        const topStack = toastify.getColumn(Toastify.TopLeftCorner)
        const bottomStack = toastify.getColumn(Toastify.BottomRightCorner)
        const compactOffset = toastify.style.collapsedToastOffset

        createToast("Top oldest", Toastify.TopLeftCorner)
        createToast("Top older", Toastify.TopLeftCorner)
        createToast("Top front", Toastify.TopLeftCorner)
        createToast("Bottom oldest", Toastify.BottomRightCorner)
        createToast("Bottom older", Toastify.BottomRightCorner)
        createToast("Bottom front", Toastify.BottomRightCorner)
        waitForStackLayout(topStack)
        waitForStackLayout(bottomStack)

        const topEntries = topStack.entriesByAge()
        const bottomEntries = bottomStack.entriesByAge()
        compare(topEntries[0].y, 0)
        tryCompare(topEntries[1], "y", compactOffset)
        compare(topEntries[2].y, 2 * compactOffset)
        compare(bottomEntries[0].y, -bottomStack.frontHeight)
        compare(bottomEntries[1].y,
                -bottomStack.frontHeight - compactOffset)
        compare(bottomEntries[2].y,
                -bottomStack.frontHeight - 2 * compactOffset)

        const bottomFrontVisualTop = bottomEntries[0].mapToItem(
                                         hostWindow.contentItem, 0, 0).y
        const bottomRearVisualTop = bottomEntries[1].mapToItem(
                                        hostWindow.contentItem, 0, 0).y
        fuzzyCompare(bottomFrontVisualTop - bottomRearVisualTop,
                     compactOffset
                     - bottomStack.frontHeight
                     * toastify.style.collapsedToastScaleStep / 2,
                     1)

        const topFrontSceneY = topEntries[0].mapToItem(
                                   hostWindow.contentItem, 0, 0).y
        const bottomFrontSceneY = bottomEntries[0].mapToItem(
                                      hostWindow.contentItem, 0, 0).y

        mouseMove(topStack, topStack.width / 2, topStack.frontHeight / 2)
        tryCompare(topStack, "hovered", true)
        tryCompare(topStack, "expanded", true)
        waitForStackLayout(topStack)
        compare(topEntries[0].y, 0)
        fuzzyCompare(topEntries[0].mapToItem(
                         hostWindow.contentItem, 0, 0).y,
                     topFrontSceneY, 1)

        const topHoverArea = findChild(topStack, "toastStackHoverArea")
        verify(topHoverArea !== null)
        compare(topHoverArea.y, 0)
        compare(topHoverArea.height, topStack.visualHeight)

        mouseMove(toastify, toastify.width / 2, toastify.height / 2)
        tryCompare(topStack, "hovered", false)
        waitForStackLayout(topStack)
        compare(topEntries[0].y, 0)
        fuzzyCompare(topEntries[0].mapToItem(
                         hostWindow.contentItem, 0, 0).y,
                     topFrontSceneY, 1)

        mouseMove(bottomEntries[0].toastObject,
                  bottomEntries[0].width / 2,
                  bottomEntries[0].height / 2)
        tryCompare(bottomStack, "hovered", true)
        tryCompare(bottomStack, "expanded", true)
        waitForStackLayout(bottomStack)
        compare(bottomEntries[0].y, -bottomStack.frontHeight)
        fuzzyCompare(bottomEntries[0].mapToItem(
                         hostWindow.contentItem, 0, 0).y,
                     bottomFrontSceneY, 1)

        const bottomHoverArea = findChild(bottomStack,
                                          "toastStackHoverArea")
        verify(bottomHoverArea !== null)
        compare(bottomStack.height, 0)
        compare(bottomHoverArea.y, -bottomStack.visualHeight)
        compare(bottomHoverArea.height, bottomStack.visualHeight)

        mouseMove(bottomHoverArea, bottomHoverArea.width / 2, 2)
        tryCompare(bottomStack, "hovered", true)
        mouseMove(bottomHoverArea, bottomHoverArea.width / 2,
                  bottomEntries[2].naturalHeight
                  + toastify.style.toastSpacing / 2)
        tryCompare(bottomStack, "hovered", true)
    }

    function test_expandedInsertionAndHiddenPromotion() {
        const topStack = toastify.getColumn(Toastify.TopLeftCorner)
        const bottomStack = toastify.getColumn(Toastify.BottomRightCorner)
        const topToasts = []
        const bottomToasts = []

        toastify.expand = true
        toastify.newestOnTop = true

        for (let i = 0; i < 4; ++i) {
            topToasts.push(createToast("Top " + i,
                                       Toastify.TopLeftCorner))
            bottomToasts.push(createToast("Bottom " + i,
                                           Toastify.BottomRightCorner))
        }
        waitForStackLayout(topStack)
        waitForStackLayout(bottomStack)

        const topEntries = topStack.entriesByAge()
        const bottomEntries = bottomStack.entriesByAge()
        compare(topStack.entryCount, 4)
        compare(bottomStack.entryCount, 4)
        compare(topStack.visibleEntryCount, 3)
        compare(bottomStack.visibleEntryCount, 3)
        compare(topEntries[0].y, 0)
        compare(bottomEntries[0].y, -bottomStack.expandedHeight)
        compare(topEntries[3].visible, false)
        compare(bottomEntries[3].visible, false)

        topToasts[3].close()
        bottomToasts[3].close()
        tryCompare(topStack, "entryCount", 3,
                   toastify.style.animation.exitDuration + 1000)
        tryCompare(bottomStack, "entryCount", 3,
                   toastify.style.animation.exitDuration + 1000)
        compare(topEntries[3].visible, true)
        compare(bottomEntries[3].visible, true)
        waitForStackLayout(topStack)
        waitForStackLayout(bottomStack)
        compare(topStack.frontEntry.toastObject, topToasts[2])
        compare(bottomStack.frontEntry.toastObject, bottomToasts[2])
        tryCompare(topStack.entriesByAge()[0], "y", 0)
        compare(bottomStack.entriesByAge()[0].y,
                -bottomStack.expandedHeight)

        createdToasts = [
            topToasts[0], topToasts[1], topToasts[2],
            bottomToasts[0], bottomToasts[1], bottomToasts[2]
        ]
    }

    function test_hoverExpandsDefaultStack() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)

        createToast("First", Toastify.TopLeftCorner)
        createToast("Second", Toastify.TopLeftCorner)
        waitForStackLayout(stack)

        compare(stack.expanded, false)
        mouseMove(stack, stack.width / 2, stack.height / 2)
        tryCompare(stack, "hovered", true)
        compare(stack.expanded, true)

        mouseMove(toastify, toastify.width / 2, toastify.height / 2)
        tryCompare(stack, "hovered", false)
        compare(stack.expanded, false)
    }

    function test_hoverPausesAutoCloseProgress() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        const toast = toastify.info("Timed", {
            position: Toastify.TopLeftCorner,
            autoClose: 3000,
            closeOnClick: false
        })
        verify(toast !== null)
        createdToasts.push(toast)

        waitForToastEntered(toast)
        mouseMove(stack, stack.width / 2, stack.height / 2)
        tryCompare(stack, "hovered", true)

        const pausedProgress = toast.progressValue
        wait(250)
        fuzzyCompare(toast.progressValue, pausedProgress, 0.01)

        mouseMove(toastify, toastify.width / 2, toastify.height / 2)
        tryCompare(stack, "hovered", false)
        tryVerify(function() {
            return toast.progressValue > pausedProgress + 0.02
        }, 1000)
    }

    function test_closeIconHoverRemainsInteractive() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        const older = createToast("Older", Toastify.TopLeftCorner)
        const front = toastify.info("Front", {
            position: Toastify.TopLeftCorner,
            autoClose: 3000,
            closeOnClick: false
        })
        verify(front !== null)
        createdToasts.push(front)
        waitForToastEntered(front)

        const frontEntry = stack.entriesByAge()[0]
        const closeIcon = findChild(front, "closeButtonArea")
        const hoverArea = findChild(stack, "toastStackHoverArea")
        verify(closeIcon !== null)
        verify(hoverArea !== null)
        compare(closeIcon.opacity,
                front.styleProvider.closeButtonStyle.opacity)
        compare(stack.hovered, false)

        mouseMove(closeIcon, closeIcon.width / 2,
                  closeIcon.height / 2)
        tryCompare(frontEntry, "pointerHovered", true)
        tryCompare(stack, "hovered", true)
        tryCompare(stack, "expanded", true)
        tryCompare(front, "stackPaused", true)
        tryCompare(older, "stackPaused", true)
        tryCompare(closeIcon, "opacity",
                   front.styleProvider.closeButtonStyle.hoveredOpacity,
                   400)

        stackHoverSpy.target = stack
        stackHoverSpy.clear()
        mouseMove(hoverArea, hoverArea.width / 2,
                  frontEntry.naturalHeight
                  + toastify.style.toastSpacing / 2)
        tryCompare(frontEntry, "pointerHovered", false)
        tryCompare(stack, "hovered", true)
        tryCompare(stack, "expanded", true)
        tryCompare(front, "stackPaused", true)
        tryCompare(closeIcon, "opacity",
                   front.styleProvider.closeButtonStyle.opacity,
                   400)
        compare(stackHoverSpy.count, 0)

        mouseMove(closeIcon, closeIcon.width / 2,
                  closeIcon.height / 2)
        tryCompare(closeIcon, "opacity",
                   front.styleProvider.closeButtonStyle.hoveredOpacity,
                   400)
        mouseClick(closeIcon, closeIcon.width / 2,
                   closeIcon.height / 2)
        tryCompare(stack, "entryCount", 1,
                   toastify.style.animation.exitDuration + 1000)
        compare(stack.frontEntry.toastObject, older)
        createdToasts = [older]
    }

    function test_hoverAreaDoesNotBlockFrontClick() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        const toast = toastify.info("Click to close", {
            position: Toastify.TopLeftCorner,
            autoClose: 0,
            closeOnClick: true
        })
        verify(toast !== null)
        createdToasts.push(toast)
        waitForToastEntered(toast)

        mouseClick(toast, toast.width / 2, toast.height / 2)
        tryCompare(stack, "entryCount", 0,
                   toastify.style.animation.exitDuration + 1000)
        createdToasts = []
    }

    function test_frontClosePromotesNextToast() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        const older = createToast("Older", Toastify.TopLeftCorner)
        const front = createToast("Front", Toastify.TopLeftCorner)
        wait(0)

        compare(stack.frontEntry.toastObject, front)
        front.close()
        tryCompare(stack, "entryCount", 1,
                   toastify.style.animation.exitDuration + 1000)
        compare(stack.frontEntry.toastObject, older)

        createdToasts = [older]
    }

    function test_newestOnTopOnlyReordersPermanentExpandedStack() {
        const stack = toastify.getColumn(Toastify.BottomRightCorner)
        createToast("An older notification with enough content to wrap "
                    + "onto multiple lines.", Toastify.BottomRightCorner)
        const newest = createToast("New", Toastify.BottomRightCorner)
        waitForStackLayout(stack)

        const byAge = stack.entriesByAge()
        verify(byAge[1].naturalHeight > byAge[0].naturalHeight)
        compare(byAge[0].toastObject, newest)
        compare(byAge[0].depth, 0)
        compare(byAge[0].y, -stack.frontHeight)
        verify(byAge[0].z > byAge[1].z)
        const newestParent = byAge[0].parent
        const oldestParent = byAge[1].parent

        toastify.newestOnTop = true
        wait(0)

        compare(stack.frontEntry.toastObject, newest)
        compare(byAge[0].depth, 0)
        compare(byAge[0].y, -stack.frontHeight)

        mouseMove(byAge[0].toastObject,
                  byAge[0].width / 2, byAge[0].height / 2)
        tryCompare(stack, "hovered", true)
        waitForStackLayout(stack)
        compare(byAge[0].y, -stack.frontHeight)
        fuzzyCompare(byAge[1].y, -stack.expandedHeight, 0.01)

        mouseMove(toastify, toastify.width / 2, toastify.height / 2)
        tryCompare(stack, "hovered", false)
        waitForStackLayout(stack)
        compare(byAge[0].y, -stack.frontHeight)

        toastify.expand = true
        waitForStackLayout(stack)

        tryCompare(byAge[0], "y", -stack.expandedHeight)
        compare(byAge[1].y, -byAge[1].naturalHeight)
        verify(byAge[0].y < byAge[1].y)
        compare(byAge[0].parent, newestParent)
        compare(byAge[1].parent, oldestParent)
        compare(stack.entryCount, 2)

        toastify.newestOnTop = false
        waitForStackLayout(stack)

        tryCompare(byAge[0], "y", -stack.frontHeight)
        tryCompare(byAge[1], "y", -stack.expandedHeight)
    }

    function test_reparentDetachesStackBindings() {
        const stack = toastify.getColumn(Toastify.TopLeftCorner)
        const toast = createToast("Detached", Toastify.TopLeftCorner)
        wait(0)

        toast.parent = hostWindow.contentItem
        tryCompare(stack, "entryCount", 0)
        compare(toast.stackCovered, false)
        compare(toast.stackPaused, false)
        compare(toast.stackHeight, -1)

        toast.destroy()
        createdToasts = []
    }
}

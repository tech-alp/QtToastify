pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: stack

    property bool expandByDefault: false
    property bool bottomAligned: false
    property bool newestOnTop: false
    property real expandedSpacing: 0
    property real collapsedOffset: 8
    property real collapsedScaleStep: 0.05
    property int transitionDuration: 400
    property int visibleToasts: 3

    readonly property bool hovered: stackHover.hovered
    readonly property bool expanded: expandByDefault
                                     || (entryCount > 1 && hovered)
    readonly property int entryCount: {
        const revision = layoutRevision
        return entries().length
    }
    readonly property int visibleEntryCount: Math.min(entryCount,
                                                      Math.max(1, visibleToasts))
    readonly property var frontEntry: {
        const revision = layoutRevision
        const orderedEntries = entriesByAge()
        return orderedEntries.length > 0 ? orderedEntries[0] : null
    }
    readonly property real frontHeight: frontEntry ? frontEntry.naturalHeight : 0
    readonly property real expandedHeight: {
        const revision = layoutRevision
        const orderedEntries = entriesByAge()
        let result = 0

        for (let i = 0; i < visibleEntryCount; ++i)
            result += orderedEntries[i].naturalHeight

        return result + Math.max(0, visibleEntryCount - 1) * expandedSpacing
    }
    readonly property real collapsedHeight: {
        const revision = layoutRevision
        if (!frontEntry)
            return 0

        return frontHeight
                + Math.max(0, visibleEntryCount - 1) * collapsedOffset
    }
    readonly property real visualHeight: expanded
                                         ? expandedHeight
                                         : collapsedHeight
    readonly property real contentWidth: {
        const revision = layoutRevision
        const orderedEntries = entriesByAge()
        let result = 0

        for (let i = 0; i < visibleEntryCount; ++i)
            result = Math.max(result, orderedEntries[i].naturalWidth)

        return result
    }

    property int layoutRevision: 0

    implicitWidth: contentWidth
    implicitHeight: bottomAligned ? 0 : frontHeight
    width: implicitWidth
    height: implicitHeight

    onChildrenChanged: layoutRevision += 1

    function entries() {
        const result = []
        for (let i = 0; i < children.length; ++i) {
            const child = children[i]
            if (child.isToastStackEntry)
                result.push(child)
        }
        return result
    }

    function entriesByAge() {
        return entries().sort(function(left, right) {
            return right.sequence - left.sequence
        })
    }

    function depthFor(entry) {
        const revision = layoutRevision
        const orderedEntries = entriesByAge()
        for (let i = 0; i < orderedEntries.length; ++i) {
            if (orderedEntries[i] === entry)
                return i
        }
        return -1
    }

    function expandedEntries() {
        const visibleEntries = entriesByAge().slice(0, visibleEntryCount)

        // Permanently expanded stacks honor the requested physical order.
        // Compact/hover stacks keep Sonner's screen-edge anchor behavior.
        if (expandByDefault)
            return newestOnTop ? visibleEntries : visibleEntries.reverse()

        return bottomAligned ? visibleEntries.reverse() : visibleEntries
    }

    function expandedOffsetFor(entry) {
        const orderedEntries = expandedEntries()
        const index = orderedEntries.indexOf(entry)
        if (index < 0)
            return collapsedOffsetFor(entry)

        let offset = bottomAligned ? -expandedHeight : 0
        for (let i = 0; i < index; ++i)
            offset += orderedEntries[i].naturalHeight + expandedSpacing

        if (bottomAligned)
            offset += orderedEntries[index].naturalHeight

        return offset
    }

    function collapsedOffsetFor(entry) {
        const depth = Math.max(0, depthFor(entry))
        return (bottomAligned ? -1 : 1) * depth * collapsedOffset
    }

    function offsetFor(entry) {
        return expanded
                ? expandedOffsetFor(entry)
                : collapsedOffsetFor(entry)
    }

    function createEntry(sequence) {
        return entryComponent.createObject(stack, {
            "stack": stack,
            "sequence": sequence
        })
    }

    Item {
        id: hoverArea

        objectName: "toastStackHoverArea"
        x: 0
        y: stack.bottomAligned ? -stack.visualHeight : 0
        width: stack.width
        height: stack.visualHeight
        visible: width > 0 && height > 0
        z: 200000

        HoverHandler {
            id: stackHover
        }
    }

    Component {
        id: entryComponent

        Item {
            id: entry

            required property var stack
            required property int sequence
            readonly property bool isToastStackEntry: true
            readonly property int depth: stack.depthFor(entry)
            readonly property bool covered: !stack.expanded && depth > 0
            property var toastObject: null
            property bool toastAttached: false
            property bool cleanupScheduled: false
            property real naturalWidth: 0
            property real naturalHeight: 0
            property real layoutOffset: stack.offsetFor(entry)

            implicitWidth: naturalWidth
            implicitHeight: naturalHeight
            width: implicitWidth
            height: stack.expanded || depth === 0
                    ? naturalHeight
                    : stack.frontHeight
            clip: !stack.expanded && depth > 0
            visible: depth >= 0 && depth < stack.visibleEntryCount
            enabled: visible && (stack.expanded || depth === 0)
            z: stack.expanded ? sequence : 100000 - Math.max(0, depth)
            y: stack.bottomAligned ? layoutOffset - height : layoutOffset
            scale: stack.expanded
                   ? 1
                   : Math.max(0.8,
                              1 - Math.max(0, depth)
                              * stack.collapsedScaleStep)
            transformOrigin: stack.bottomAligned ? Item.Bottom : Item.Top

            Behavior on layoutOffset {
                NumberAnimation {
                    duration: entry.stack.transitionDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: entry.stack.transitionDuration
                    easing.type: Easing.OutCubic
                }
            }

            onChildrenChanged: {
                if (toastAttached && children.length === 0
                        && !cleanupScheduled) {
                    cleanupScheduled = true
                    Qt.callLater(entry.cleanupDetachedToast)
                }
            }

            function updateNaturalSize() {
                if (!toastObject)
                    return

                updateNaturalWidth()
                updateNaturalHeight()
            }

            function updateNaturalWidth() {
                if (!toastObject)
                    return

                naturalWidth = toastObject.width > 0
                               ? toastObject.width
                               : toastObject.implicitWidth
            }

            function updateNaturalHeight() {
                if (!toastObject)
                    return

                const hasStackHeight = typeof toastObject["stackHeight"]
                                       !== "undefined"
                if (hasStackHeight && toastObject["stackHeight"] >= 0)
                    return

                naturalHeight = toastObject.height > 0
                                ? toastObject.height
                                : toastObject.implicitHeight
            }

            function cleanupDetachedToast() {
                cleanupScheduled = false
                if (!toastAttached || children.length > 0)
                    return

                resetToastBindings()
                toastAttached = false
                toastObject = null
                entry.destroy()
            }

            function resetToastBindings() {
                const toast = toastObject
                if (!toast || toast.parent === entry)
                    return

                if (typeof toast["stackCovered"] !== "undefined")
                    toast["stackCovered"] = false
                if (typeof toast["stackPaused"] !== "undefined")
                    toast["stackPaused"] = false
                if (typeof toast["stackHeight"] !== "undefined")
                    toast["stackHeight"] = -1
            }

            function attachToast(toast) {
                toastObject = toast
                updateNaturalSize()
                toastAttached = true

                if (typeof toast["stackCovered"] !== "undefined") {
                    toast["stackCovered"] = Qt.binding(function() {
                        return entry.covered
                    })
                }

                if (typeof toast["stackPaused"] !== "undefined") {
                    toast["stackPaused"] = Qt.binding(function() {
                        return entry.stack.hovered
                    })
                }

                if (typeof toast["stackHeight"] !== "undefined") {
                    toast["stackHeight"] = Qt.binding(function() {
                        return entry.covered ? entry.stack.frontHeight : -1
                    })
                }
            }

            Connections {
                target: entry.toastObject
                ignoreUnknownSignals: true

                function onImplicitWidthChanged() {
                    entry.updateNaturalSize()
                }

                function onImplicitHeightChanged() {
                    entry.updateNaturalHeight()
                }

                function onWidthChanged() {
                    entry.updateNaturalWidth()
                }

                function onHeightChanged() {
                    entry.updateNaturalHeight()
                }
            }
        }
    }
}

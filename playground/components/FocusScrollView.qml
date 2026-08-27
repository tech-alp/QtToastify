pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme

SK.ScrollView {
    id: root

    readonly property Flickable flickable: root.contentItem as Flickable

    clip: true
    SK.ScrollBar.vertical.width: Theme.spacing.xxs
    SK.ScrollBar.horizontal.visible: false
    SK.ScrollBar.horizontal.height: 0

    function containsItem(item, ancestor) {
        let current = item
        while (current) {
            if (current === ancestor)
                return true
            current = current.parent
        }
        return false
    }

    function ensureFocusVisible() {
        const window = root.Window.window
        const focusItem = window ? window.activeFocusItem : null
        const flickable = root.flickable
        const contentRoot = flickable ? flickable.contentItem : null
        if (!focusItem || !flickable || !contentRoot
                || !root.containsItem(focusItem, contentRoot)) {
            return
        }

        const bounds = focusItem.mapToItem(
            contentRoot, 0, 0, focusItem.width, focusItem.height)
        const margin = Math.min(Theme.spacing.xs, flickable.height / 4)
        const viewportTop = flickable.contentY
        const viewportBottom = viewportTop + flickable.height
        let targetY = viewportTop

        if (bounds.y < viewportTop + margin)
            targetY = bounds.y - margin
        else if (bounds.y + bounds.height > viewportBottom - margin)
            targetY = bounds.y + bounds.height - flickable.height + margin

        const maximumY = Math.max(0,
                                  flickable.contentHeight - flickable.height)
        flickable.contentY = Math.max(0, Math.min(targetY, maximumY))
    }

    function scrollToItem(item) {
        const flickable = root.flickable
        const contentRoot = flickable ? flickable.contentItem : null
        if (!item || !flickable || !contentRoot
                || !root.containsItem(item, contentRoot)) {
            return
        }

        const bounds = item.mapToItem(
            contentRoot, 0, 0, item.width, item.height)
        const maximumY = Math.max(0,
                                  flickable.contentHeight - flickable.height)
        const targetY = bounds.y - Theme.spacing.xs
        flickable.contentY = Math.max(0, Math.min(targetY, maximumY))
    }

    function scrollToStart() {
        const flickable = root.flickable
        if (flickable)
            flickable.contentY = 0
    }

    Connections {
        target: root.Window.window

        function onActiveFocusItemChanged() {
            Qt.callLater(root.ensureFocusVisible)
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Toastify
import Merce.Theme

Item {
    id: root

    property int position: Toastify.TopRightCorner
    signal positionModified(int position)

    objectName: "playground.positionPicker"
    implicitHeight: pickerGrid.implicitHeight

    readonly property var positions: [
        { "label": qsTr("Top left"), "value": Toastify.TopLeftCorner,
          "horizontal": "left", "vertical": "top" },
        { "label": qsTr("Top center"), "value": Toastify.TopCenter,
          "horizontal": "center", "vertical": "top" },
        { "label": qsTr("Top right"), "value": Toastify.TopRightCorner,
          "horizontal": "right", "vertical": "top" },
        { "label": qsTr("Bottom left"), "value": Toastify.BottomLeftCorner,
          "horizontal": "left", "vertical": "bottom" },
        { "label": qsTr("Bottom center"), "value": Toastify.BottomCenter,
          "horizontal": "center", "vertical": "bottom" },
        { "label": qsTr("Bottom right"), "value": Toastify.BottomRightCorner,
          "horizontal": "right", "vertical": "bottom" }
    ]

    function selectIndex(index) {
        const boundedIndex = Math.max(0, Math.min(index, root.positions.length - 1))
        const item = positionRepeater.itemAt(boundedIndex)
        if (item)
            item.forceActiveFocus()
        root.positionModified(root.positions[boundedIndex].value)
    }

    GridLayout {
        id: pickerGrid

        anchors.fill: parent
        columns: 3
        rowSpacing: Theme.spacing.xs
        columnSpacing: Theme.spacing.xs

        Repeater {
            id: positionRepeater
            model: root.positions

            delegate: Rectangle {
                id: positionButton

                required property int index
                required property var modelData
                readonly property bool selected: root.position === modelData.value
                readonly property bool keyboardTabStop: selected

                objectName: root.objectName + ".option." + index

                Layout.fillWidth: true
                Layout.preferredHeight: 54
                Layout.minimumWidth: Theme.spacing.touchTarget
                radius: Theme.radius.medium
                color: selected
                       ? Qt.alpha(Theme.colors.action.primary.container, 0.12)
                       : positionHover.hovered
                         ? Theme.colors.surface.containerTinted
                         : Theme.colors.surface.containerSunken
                border.width: activeFocus || selected
                              ? Theme.size.outline.focus
                              : Theme.size.outline.hairline
                border.color: activeFocus || selected
                              ? Theme.colors.outline.focus
                              : Theme.colors.outline.subtle

                activeFocusOnTab: keyboardTabStop
                Accessible.role: Accessible.RadioButton
                Accessible.name: String(modelData.label)
                Accessible.checked: selected
                Accessible.onPressAction: root.selectIndex(index)

                Keys.onLeftPressed: root.selectIndex(index - 1)
                Keys.onRightPressed: root.selectIndex(index + 1)
                Keys.onUpPressed: root.selectIndex(index - 3)
                Keys.onDownPressed: root.selectIndex(index + 3)
                Keys.onSpacePressed: root.selectIndex(index)
                Keys.onEnterPressed: root.selectIndex(index)
                Keys.onReturnPressed: root.selectIndex(index)

                Rectangle {
                    width: 24
                    height: 16
                    radius: 3
                    color: positionButton.selected
                           ? Theme.colors.action.primary.container
                           : Theme.colors.content.tertiary
                    x: positionButton.modelData.horizontal === "left"
                       ? Theme.spacing.xs
                       : positionButton.modelData.horizontal === "right"
                         ? positionButton.width - width - Theme.spacing.xs
                         : (positionButton.width - width) / 2
                    y: positionButton.modelData.vertical === "top"
                       ? Theme.spacing.xs
                       : positionButton.height - height - Theme.spacing.xs
                    Accessible.ignored: true
                }

                HoverHandler {
                    id: positionHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.selectIndex(positionButton.index)
                }
            }
        }
    }
}

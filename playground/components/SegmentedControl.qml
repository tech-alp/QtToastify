pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import Merce.Theme
import Merce.Controls

Item {
    id: root

    property var model: []
    property var currentValue
    property int columns: Math.max(1, model.length)
    property string accessibleName: qsTr("Selection")

    signal valueModified(var value)

    implicitHeight: segmentGrid.implicitHeight

    function selectIndex(index) {
        if (root.model.length === 0)
            return
        const boundedIndex = Math.max(0, Math.min(index, root.model.length - 1))
        const item = segmentRepeater.itemAt(boundedIndex)
        if (item)
            item.forceActiveFocus()
        root.valueModified(root.model[boundedIndex].value)
    }

    QQC.ButtonGroup {
        id: selectionGroup

        objectName: root.objectName + ".group"
        exclusive: true
    }

    GridLayout {
        id: segmentGrid

        anchors.fill: parent
        columns: root.columns
        columnSpacing: Theme.spacing.xxs
        rowSpacing: Theme.spacing.xxs

        Repeater {
            id: segmentRepeater
            model: root.model

            delegate: MButton {
                required property int index
                required property var modelData
                readonly property bool keyboardTabStop: checked || activeFocus

                objectName: root.objectName + ".option." + index

                fullWidth: true
                Layout.minimumWidth: Theme.spacing.touchTarget
                text: String(modelData.text)
                size: MButton.Medium
                variant: MButton.Outline
                leftPadding: Theme.spacing.xs
                rightPadding: Theme.spacing.xs
                checkable: true
                checked: root.currentValue === modelData.value
                QQC.ButtonGroup.group: selectionGroup

                onClicked: root.selectIndex(index)

                focusPolicy: keyboardTabStop ? Qt.TabFocus : Qt.NoFocus
                Accessible.role: Accessible.RadioButton
                Accessible.name: qsTr("%1: %2")
                    .arg(root.accessibleName)
                    .arg(String(modelData.text))
                Accessible.checked: checked
                Accessible.onPressAction: root.selectIndex(index)

                Keys.onLeftPressed: root.selectIndex(index - 1)
                Keys.onRightPressed: root.selectIndex(index + 1)
                Keys.onUpPressed: root.selectIndex(index - root.columns)
                Keys.onDownPressed: root.selectIndex(index + root.columns)
            }
        }
    }
}

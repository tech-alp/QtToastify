pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Merce.Theme
import Merce.Foundation

Surface {
    id: root

    required property string title
    property string description: ""
    default property alias content: body.data

    surfaceType: Surface.Default
    radiusValue: Theme.radius.large
    implicitHeight: cardContent.implicitHeight + Theme.spacing.xl2

    ColumnLayout {
        id: cardContent

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.spacing.md
        }
        spacing: Theme.spacing.sm

        AppLabel {
            Layout.fillWidth: true
            textType: AppLabel.H4
            text: root.title
            color: Theme.colors.content.primary
        }

        AppLabel {
            Layout.fillWidth: true
            visible: root.description.length > 0
            textType: AppLabel.Caption
            text: root.description
            color: Theme.colors.content.secondary
            wrapMode: Text.WordWrap
        }

        ColumnLayout {
            id: body

            Layout.fillWidth: true
            spacing: Theme.spacing.sm
        }
    }
}

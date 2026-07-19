pragma ComponentBehavior:Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import Toastify 1.0
import Toastify.Style 1.0

Control {
    id: root

    property string message: ""
    property int type: Toastify.Info
    property int position: Toastify.TopLeftCorner
    property int autoClose: 5000
    property bool closeOnClick: true
    property bool hideProgressBar: false
    property var clickAction: null

    // Style provider injection - uses default ToastifyStyleProvider if null
    property ToastifyStyleProvider styleProvider: ToastifyStyleProvider {}

    // Container size constraints from styleProvider
    property int minimumWidth: root.styleProvider.containerSizes.minimum
    property int preferredWidth: root.styleProvider.containerSizes.preferred
    property int maximumWidth: root.styleProvider.containerSizes.maximum

    // Spacing consistency system - using styleProvider
    readonly property QtObject spacingConfig: QtObject {
        readonly property int mainSpacing: root.styleProvider.spacing.main
        readonly property int contentSpacing: root.styleProvider.spacing.content
        readonly property int textSpacing: root.styleProvider.spacing.text
        readonly property int containerPadding: root.styleProvider.spacing.container
        readonly property int closeButtonPadding: root.styleProvider.spacing.closeButton.padding
        readonly property int closeButtonSize: root.styleProvider.spacing.closeButton.size
        readonly property int closeButtonTotalWidth: closeButtonSize + closeButtonPadding * 2

        // Calculated spacing values using styleProvider
        readonly property int totalHorizontalSpacing: root.styleProvider.spacing.totalHorizontal()
    }

    readonly property color accentColor: {
        switch(root.type) {
            case 1: return root.styleProvider.colors.success;
            case 2: return root.styleProvider.colors.warning;
            case 3: return root.styleProvider.colors.error;
            default: return root.styleProvider.colors.info;
        }
    }

    readonly property string iconName: {
        switch(root.type) {
            case Toastify.Info: return "qrc:/qt/qml/Toastify/icons/info.svg"
            case Toastify.Success: return "qrc:/qt/qml/Toastify/icons/success.svg"
            case Toastify.Warning: return "qrc:/qt/qml/Toastify/icons/warning.svg"
            case Toastify.Error: return "qrc:/qt/qml/Toastify/icons/error.svg"
        }
        return "qrc:/qt/qml/Toastify/icons/info.svg"
    }

    function progressPath(width, height, barHeight, cornerRadius) {
        const w = Math.max(0, width)
        const h = Math.max(0, height)
        const ph = Math.min(Math.max(0, barHeight), h)
        const r = Math.min(Math.max(0, cornerRadius), w / 2, h / 2)
        const y = h - ph

        if (w <= 0 || h <= 0 || ph <= 0)
            return ""

        if (r <= 0)
            return "M 0 " + y + " L " + w + " " + y + " L " + w + " " + h + " L 0 " + h + " Z"

        if (ph < r) {
            const dy = r - ph
            const inset = r - Math.sqrt(Math.max(0, r * r - dy * dy))
            return "M " + inset + " " + y +
                   " L " + (w - inset) + " " + y +
                   " A " + r + " " + r + " 0 0 1 " + (w - r) + " " + h +
                   " L " + r + " " + h +
                   " A " + r + " " + r + " 0 0 1 " + inset + " " + y +
                   " Z"
        }

        return "M 0 " + y +
               " L " + w + " " + y +
               " L " + w + " " + (h - r) +
               " A " + r + " " + r + " 0 0 1 " + (w - r) + " " + h +
               " L " + r + " " + h +
               " A " + r + " " + r + " 0 0 1 0 " + (h - r) +
               " L 0 " + y +
               " Z"
    }

    implicitWidth: Math.max(minimumWidth, Math.min(preferredWidth, maximumWidth))
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    padding: root.spacingConfig.containerPadding
    leftPadding: root.spacingConfig.containerPadding
    rightPadding: root.spacingConfig.containerPadding + root.spacingConfig.closeButtonTotalWidth
    topPadding: root.spacingConfig.containerPadding
    bottomPadding: root.spacingConfig.containerPadding

    background: Rectangle {
        id: backgroundItem

        color: root.accentColor
        radius: root.styleProvider.cornerRadius

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.styleProvider.shadow.color
            shadowBlur: root.styleProvider.shadow.blur
            shadowOpacity: root.styleProvider.shadow.opacity
            shadowVerticalOffset: root.styleProvider.shadow.verticalOffset
        }

        // Progress Bar
        Item {
            id: progressClip

            visible: root.autoClose > 0 && !root.hideProgressBar
            anchors.left: backgroundItem.left
            anchors.top: backgroundItem.top
            height: backgroundItem.height
            width: parent.width * (1.0 - root.progressValue)
            clip: true

            Shape {
                width: backgroundItem.width
                height: backgroundItem.height
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeColor: "transparent"
                    fillColor: Qt.lighter(root.accentColor, 1.4) //Qt.rgba(255, 255, 255, 0.4)

                    PathSvg {
                        path: root.progressPath(
                                  backgroundItem.width,
                                  backgroundItem.height,
                                  root.styleProvider.progressBar.height,
                                  root.styleProvider.cornerRadius)
                    }
                }
            }
        }
    }

    contentItem: RowLayout {
        id: mainLayout
        spacing: root.spacingConfig.mainSpacing

        RowLayout {
            id: contentArea
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.maximumWidth: root.width - root.leftPadding - root.rightPadding
            Layout.minimumWidth: 100  // Ensure minimum content width
            spacing: root.spacingConfig.contentSpacing

            ColoredImage {
                id: iconImage
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: root.styleProvider.iconSize
                Layout.preferredHeight: root.styleProvider.iconSize
                Layout.minimumWidth: root.styleProvider.iconSize
                Layout.minimumHeight: root.styleProvider.iconSize
                source: root.iconName
                color: root.styleProvider.textColors.color
                sourceSize.width: root.styleProvider.iconSize
                sourceSize.height: root.styleProvider.iconSize
            }

            // Text content area with proper wrapping and expansion
            ColumnLayout {
                id: textContentArea
                Layout.fillWidth: true
                Layout.maximumWidth: contentArea.Layout.maximumWidth - iconImage.Layout.preferredWidth - contentArea.spacing
                Layout.minimumWidth: 50  // Minimum text area width
                spacing: root.spacingConfig.textSpacing  // Consistent text spacing

                Label {
                    id: messageLabel
                    text: root.message
                    color: root.styleProvider.textColors.color
                    font.family: root.styleProvider.fonts.family
                    font.pixelSize: root.styleProvider.fonts.size
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.maximumWidth: textContentArea.Layout.maximumWidth

                    // Ensure proper vertical expansion for wrapped text
                    onImplicitHeightChanged: {
                        if (implicitHeight > root.styleProvider.fonts.size * 1.5) {
                            // Multi-line text detected, ensure container expands
                            root.implicitHeight = Qt.binding(function() {
                                return contentItem.implicitHeight + root.topPadding + root.bottomPadding
                            })
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.closeOnClick
        cursorShape: Qt.PointingHandCursor
        z: 1
        onClicked: {
            if (root.clickAction) root.clickAction()
            root.close()
        }
    }

    ColoredImage {
        id: closeButton
        objectName: "closeButtonArea"
        width: root.spacingConfig.closeButtonSize
        height: root.spacingConfig.closeButtonSize
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: root.spacingConfig.closeButtonPadding * 2
        anchors.rightMargin: root.spacingConfig.closeButtonPadding * 2
        z: 2
        source: "qrc:/qt/qml/Toastify/icons/xmark.svg"
        sourceSize.width: root.spacingConfig.closeButtonSize
        sourceSize.height: root.spacingConfig.closeButtonSize
        color: root.styleProvider.textColors.color

        HoverHandler {
            margin: root.spacingConfig.closeButtonPadding
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.WithinBounds
            margin: root.spacingConfig.closeButtonPadding
            onTapped: root.close()
        }
    }

    transform: Translate { id: trans }

    Component.onCompleted: enterAnim.start()

    function close() {
        if(!exitAnim.running) {
            progressAnim.stop()
            exitAnim.start()
        }
    }

    ParallelAnimation {
        id: enterAnim
        NumberAnimation {
            target: trans
            property: "x"
            from: (root.position === Toastify.TopLeftCorner || root.position === Toastify.BottomLeftCorner) ? -50 :
                  (root.position === Toastify.TopRightCorner || root.position === Toastify.BottomRightCorner) ? 50 : 0
            to: 0
            duration: root.styleProvider.animation.enterDuration
            easing.type: Easing.OutBack
        }
        NumberAnimation {
            target: trans
            property: "y"
            from: root.position === Toastify.TopCenter ? -50 :
                  root.position === Toastify.BottomCenter ? 50 : 0
            to: 0
            duration: root.styleProvider.animation.enterDuration
            easing.type: Easing.OutBack
        }
        NumberAnimation {
            target: root
            property: "opacity"
            from: 0; to: 1
            duration: 300
        }
        onFinished: { if (root.autoClose > 0) progressAnim.start() }
    }

    property real progressValue: 0.0
    NumberAnimation {
        id: progressAnim
        target: root
        property: "progressValue"
        from: 0
        to: 1
        duration: root.autoClose
        onFinished: root.close()
    }

    SequentialAnimation {
        id: exitAnim
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 0; duration: root.styleProvider.animation.exitDuration }
            NumberAnimation { target: root; property: "scale"; to: 0.8; duration: root.styleProvider.animation.exitDuration }
        }
        NumberAnimation { target: root; property: "height"; to: 0; duration: 200; easing.type: Easing.OutCubic }
        ScriptAction { script: root.destroy() }
    }
}

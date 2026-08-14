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
    property bool stackCovered: false
    property bool stackPaused: false
    property real stackHeight: -1

    property ToastifyStyleProvider styleProvider: ToastifyStyleProvider {}

    property int minimumWidth: root.styleProvider.containerSizes.minimum
    property int preferredWidth: root.styleProvider.containerSizes.preferred
    property int maximumWidth: root.styleProvider.containerSizes.maximum
    readonly property int minimumToastHeight: root.styleProvider.containerSizes.minimumHeight ?? 0

    readonly property int mainSpacing: root.styleProvider.spacing.main
    readonly property int contentSpacing: root.styleProvider.spacing.content
    readonly property int textSpacing: root.styleProvider.spacing.text
    readonly property int containerPadding: root.styleProvider.spacing.container
    readonly property int closeButtonPadding: root.styleProvider.spacing.closeButton.padding
    readonly property int closeButtonSize: root.styleProvider.spacing.closeButton.size
    readonly property int closeButtonWidth: root.styleProvider.spacing.closeButton.width ?? root.closeButtonSize
    readonly property int closeButtonHeight: root.styleProvider.spacing.closeButton.height ?? root.closeButtonSize
    readonly property int closeButtonTotalWidth: root.closeButtonWidth + root.closeButtonPadding * 2
    readonly property real progressRadius: root.styleProvider.progressBar.radius ?? root.styleProvider.cornerRadius
    readonly property color accentColor: root.styleProvider.getColorForType(root.type)

    Component {
        id: infoIconComponent
        InfoIcon { color: root.accentColor }
    }

    Component {
        id: successIconComponent
        SuccessIcon { color: root.accentColor }
    }

    Component {
        id: warningIconComponent
        WarningIcon { color: root.accentColor }
    }

    Component {
        id: errorIconComponent
        ErrorIcon { color: root.accentColor }
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
    implicitHeight: Math.max(root.minimumToastHeight,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    height: root.stackHeight >= 0 ? root.stackHeight : implicitHeight

    padding: root.containerPadding
    leftPadding: root.containerPadding
    rightPadding: root.containerPadding + root.closeButtonTotalWidth
    topPadding: root.containerPadding
    bottomPadding: root.containerPadding

    background: Rectangle {
        id: backgroundItem

        color: root.styleProvider.backgroundColor
        radius: root.styleProvider.cornerRadius

        layer.enabled: root.styleProvider.shadow.opacity > 0
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.styleProvider.shadow.color
            shadowBlur: root.styleProvider.shadow.blur
            shadowOpacity: root.styleProvider.shadow.opacity
            shadowHorizontalOffset: root.styleProvider.shadow.horizontalOffset
            shadowVerticalOffset: root.styleProvider.shadow.verticalOffset
        }

        Shape {
            visible: root.autoClose > 0 && !root.hideProgressBar
                     && !root.stackCovered
            width: backgroundItem.width
            height: backgroundItem.height
            opacity: root.styleProvider.progressBar.backgroundOpacity ?? 0.2
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: "transparent"
                fillColor: root.accentColor

                PathSvg {
                    path: root.progressPath(
                              backgroundItem.width,
                              backgroundItem.height,
                              root.styleProvider.progressBar.height,
                              root.progressRadius)
                }
            }
        }

        Item {
            visible: root.autoClose > 0 && !root.hideProgressBar
                     && !root.stackCovered
            anchors.left: backgroundItem.left
            anchors.top: backgroundItem.top
            height: backgroundItem.height
            width: parent.width * (1.0 - root.progressValue)
            clip: true

            Shape {
                width: backgroundItem.width
                height: backgroundItem.height
                opacity: root.styleProvider.progressBar.opacity ?? 0.7
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeColor: "transparent"
                    fillColor: root.accentColor

                    PathSvg {
                        path: root.progressPath(
                                  backgroundItem.width,
                                  backgroundItem.height,
                                  root.styleProvider.progressBar.height,
                                  root.progressRadius)
                    }
                }
            }
        }
    }

    contentItem: RowLayout {
        spacing: root.mainSpacing
        opacity: root.stackCovered ? 0 : 1

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        RowLayout {
            id: contentArea
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.maximumWidth: root.width - root.leftPadding - root.rightPadding
            Layout.minimumWidth: 100
            spacing: root.contentSpacing

            Loader {
                id: iconImage
                objectName: "statusIcon"
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: root.styleProvider.iconSize
                Layout.preferredHeight: root.styleProvider.iconSize
                Layout.minimumWidth: root.styleProvider.iconSize
                Layout.minimumHeight: root.styleProvider.iconSize
                sourceComponent: {
                    switch (root.type) {
                    case Toastify.Success: return successIconComponent
                    case Toastify.Warning: return warningIconComponent
                    case Toastify.Error: return errorIconComponent
                    default: return infoIconComponent
                    }
                }
            }

            ColumnLayout {
                id: textContentArea
                objectName: "textContentArea"
                Layout.fillWidth: true
                Layout.maximumWidth: contentArea.Layout.maximumWidth - iconImage.Layout.preferredWidth - contentArea.spacing
                Layout.minimumWidth: 50
                spacing: root.textSpacing

                Label {
                    text: root.message
                    color: root.styleProvider.textColors.color
                    font.family: root.styleProvider.fonts.family
                    font.pixelSize: root.styleProvider.fonts.size
                    font.weight: root.styleProvider.fonts.weight
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.maximumWidth: textContentArea.Layout.maximumWidth

                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.closeOnClick && !root.stackCovered
        cursorShape: Qt.PointingHandCursor
        z: 1
        onClicked: {
            if (root.clickAction) root.clickAction()
            root.close()
        }
    }

    CloseIcon {
        objectName: "closeButtonArea"
        visible: !root.stackCovered
        width: root.closeButtonWidth
        height: root.closeButtonHeight
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: root.closeButtonPadding
        anchors.rightMargin: root.closeButtonPadding
        z: 2
        color: root.styleProvider.closeButtonStyle.color
        opacity: closeButtonHover.hovered
                 ? root.styleProvider.closeButtonStyle.hoveredOpacity
                 : root.styleProvider.closeButtonStyle.opacity

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        HoverHandler {
            id: closeButtonHover
            margin: root.closeButtonPadding
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.WithinBounds
            margin: root.closeButtonPadding
            onTapped: root.close()
        }
    }

    transform: Translate { id: trans }

    Component.onCompleted: enterAnim.start()

    onStackPausedChanged: updateProgressPauseState()

    function updateProgressPauseState() {
        if (!progressAnim.running)
            return

        if (root.stackPaused && !progressAnim.paused)
            progressAnim.pause()
        else if (!root.stackPaused && progressAnim.paused)
            progressAnim.resume()
    }

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
        onFinished: {
            if (root.autoClose > 0) {
                progressAnim.start()
                root.updateProgressPauseState()
            }
        }
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
        ScriptAction { script: root.destroy() }
    }
}

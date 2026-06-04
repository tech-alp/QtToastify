import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Templates as T
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
    property int minimumWidth: styleProvider.containerSizes.minimum
    property int preferredWidth: styleProvider.containerSizes.preferred
    property int maximumWidth: styleProvider.containerSizes.maximum

    // Spacing consistency system - using styleProvider
    readonly property QtObject spacingConfig: QtObject {
        readonly property int mainSpacing: styleProvider.spacing.main
        readonly property int contentSpacing: styleProvider.spacing.content
        readonly property int textSpacing: styleProvider.spacing.text
        readonly property int containerPadding: styleProvider.spacing.container
        readonly property int closeButtonPadding: styleProvider.spacing.closeButton.padding

        // Calculated spacing values using styleProvider
        readonly property int totalHorizontalSpacing: styleProvider.spacing.totalHorizontal()
        readonly property int closeButtonTotalWidth: styleProvider.spacing.closeButtonTotal()
    }

    readonly property color accentColor: {
        switch(root.type) {
            case 1: return styleProvider.colors.success;
            case 2: return styleProvider.colors.warning;
            case 3: return styleProvider.colors.error;
            default: return styleProvider.colors.info;
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

    implicitWidth: Math.max(minimumWidth, Math.min(preferredWidth, maximumWidth))
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    padding: spacingConfig.containerPadding
    leftPadding: spacingConfig.containerPadding
    rightPadding: spacingConfig.containerPadding
    topPadding: spacingConfig.containerPadding
    bottomPadding: spacingConfig.containerPadding

    background: Rectangle {
        color: root.accentColor
        topLeftRadius: styleProvider.cornerRadius
        topRightRadius: styleProvider.cornerRadius

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: styleProvider.shadow.color
            shadowBlur: styleProvider.shadow.blur
            shadowOpacity: styleProvider.shadow.opacity
            shadowVerticalOffset: styleProvider.shadow.verticalOffset
        }

        // Progress Bar
        Rectangle {
            visible: root.autoClose > 0 && !root.hideProgressBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: styleProvider.progressBar.height
            width: parent.width * (1.0 - root.progressValue)
            radius: styleProvider.progressBar.radius
            color: Qt.lighter(accentColor, 1.4) //Qt.rgba(255, 255, 255, 0.4)
        }
    }

    contentItem: RowLayout {
        id: mainLayout
        spacing: spacingConfig.mainSpacing

        RowLayout {
            id: contentArea
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.maximumWidth: root.width - spacingConfig.mainSpacing - root.leftPadding - root.rightPadding
            Layout.minimumWidth: 100  // Ensure minimum content width
            spacing: spacingConfig.contentSpacing

            ColoredImage {
                id: iconImage
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: styleProvider.iconSize
                Layout.preferredHeight: styleProvider.iconSize
                Layout.minimumWidth: styleProvider.iconSize
                Layout.minimumHeight: styleProvider.iconSize
                source: root.iconName
                color: styleProvider.textColors.color
            }

            // Text content area with proper wrapping and expansion
            ColumnLayout {
                id: textContentArea
                Layout.fillWidth: true
                Layout.maximumWidth: contentArea.Layout.maximumWidth - iconImage.Layout.preferredWidth - contentArea.spacing
                Layout.minimumWidth: 50  // Minimum text area width
                spacing: spacingConfig.textSpacing  // Consistent text spacing

                Label {
                    id: messageLabel
                    text: root.message
                    color: styleProvider.textColors.color
                    font.family: styleProvider.fonts.family
                    font.pixelSize: styleProvider.fonts.size
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.maximumWidth: textContentArea.Layout.maximumWidth

                    // Ensure proper vertical expansion for wrapped text
                    onImplicitHeightChanged: {
                        if (implicitHeight > styleProvider.fonts.size * 1.5) {
                            // Multi-line text detected, ensure container expands
                            root.implicitHeight = Qt.binding(function() {
                                return contentItem.implicitHeight + root.topPadding + root.bottomPadding
                            })
                        }
                    }
                }
            }
        }

        // Close button area (fixed width)
        T.Button {
            id: closeButton
            objectName: "closeButton"
            Layout.preferredWidth: spacingConfig.closeButtonTotalWidth
            Layout.preferredHeight: spacingConfig.closeButtonTotalWidth
            Layout.alignment: Qt.AlignTop

            background: Rectangle {
                color: "transparent"
            }

            contentItem: ColoredImage {
                source: "qrc:/qt/qml/Toastify/icons/xmark.svg"
                sourceSize.width: spacingConfig.closeButtonTotalWidth
                sourceSize.height: spacingConfig.closeButtonTotalWidth
            }

            onClicked: root.close()
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.closeOnClick
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.clickAction) root.clickAction()
            root.close()
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
            duration: styleProvider.animation.enterDuration
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
            NumberAnimation { target: root; property: "opacity"; to: 0; duration: styleProvider.animation.exitDuration }
            NumberAnimation { target: root; property: "scale"; to: 0.8; duration: styleProvider.animation.exitDuration }
        }
        NumberAnimation { target: root; property: "Layout.preferredHeight"; to: 0; duration: 200 }
        ScriptAction { script: root.destroy() }
    }
}

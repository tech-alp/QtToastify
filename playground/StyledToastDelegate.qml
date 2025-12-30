import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Control {
    id: root

    property string message: ""
    property int type: 0 // Toastify.Info equivalent
    property int position: 1 // Toastify.TopRightCorner equivalent
    property int autoClose: 5000
    property bool closeOnClick: true
    property bool hideProgressBar: false
    property var clickAction: null

    // Custom style object - injected from playground
    property var customStyle: null

    // Fallback ToastifyStyle values
    readonly property var fallbackStyle: QtObject {
        property var colors: ({
            info: "#3498db",
            success: "#07bc0c",
            warning: "#f1c40f",
            error: "#e74c3c"
        })
        property var fonts: ({
            family: "Roboto",
            size: 14,
            weight: Font.Normal
        })
        property var spacing: ({
            main: 12,
            content: 12,
            text: 4,
            container: 12,
            closeButton: { "padding": 6, "size": 24 }
        })
        property var containerSizes: ({
            minimum: 280,
            preferred: 350,
            maximum: 500
        })
        property var shadow: ({
            blur: 0.5,
            color: "#000000",
            opacity: 0.1,
            horizontalOffset: 0,
            verticalOffset: 0
        })
        property var animation: ({
            enterDuration: 500,
            exitDuration: 500
        })
        property var textColors: ({
            color: "#ffffff"
        })
        property real cornerRadius: 12
        property real iconSize: 18
        property var progressBar: ({
            height: 4,
            radius: 2
        })
    }

    // Use custom style if provided, otherwise fall back to fallbackStyle
    readonly property var activeStyle: customStyle || fallbackStyle

    // Container size constraints from active style
    property int minimumWidth: activeStyle.containerSizes ? activeStyle.containerSizes.minimum : 280
    property int preferredWidth: activeStyle.containerSizes ? activeStyle.containerSizes.preferred : 350
    property int maximumWidth: activeStyle.containerSizes ? activeStyle.containerSizes.maximum : 500

    // Spacing configuration from active style
    readonly property QtObject spacingConfig: QtObject {
        readonly property int mainSpacing: activeStyle.spacing ? activeStyle.spacing.main : 12
        readonly property int contentSpacing: activeStyle.spacing ? activeStyle.spacing.content : 12
        readonly property int textSpacing: activeStyle.spacing ? activeStyle.spacing.text : 4
        readonly property int containerPadding: activeStyle.spacing ? activeStyle.spacing.container : 12
        readonly property int closeButtonPadding: activeStyle.spacing && activeStyle.spacing.closeButton ? activeStyle.spacing.closeButton.padding : 6
        
        // Calculated spacing values
        readonly property int totalHorizontalSpacing: mainSpacing + containerPadding * 2
        readonly property int closeButtonTotalWidth: activeStyle.spacing && activeStyle.spacing.closeButton ? activeStyle.spacing.closeButton.size : 24
    }

    readonly property color accentColor: {
        if (activeStyle.colors) {
            switch(root.type) {
                case 1: return activeStyle.colors.success;
                case 2: return activeStyle.colors.warning;
                case 3: return activeStyle.colors.error;
                default: return activeStyle.colors.info;
            }
        } else {
            // Fallback to ToastifyStyle
            switch(root.type) {
                case 1: return ToastifyStyle.colors.success;
                case 2: return ToastifyStyle.colors.warning;
                case 3: return ToastifyStyle.colors.error;
                default: return ToastifyStyle.colors.info;
            }
        }
    }

    readonly property string iconName: {
        switch(root.type) {
            case 0: return "ℹ️"; // Info
            case 1: return "✅"; // Success
            case 2: return "⚠️"; // Warning
            case 3: return "❌"; // Error
        }
        return "ℹ️";
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
        radius: activeStyle.cornerRadius || 12

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: activeStyle.shadow ? activeStyle.shadow.opacity > 0 : true
            shadowColor: activeStyle.shadow ? activeStyle.shadow.color : "#000000"
            shadowBlur: activeStyle.shadow ? activeStyle.shadow.blur : 0.5
            shadowOpacity: activeStyle.shadow ? activeStyle.shadow.opacity : 0.1
            shadowVerticalOffset: activeStyle.shadow ? activeStyle.shadow.verticalOffset : 0
            shadowHorizontalOffset: activeStyle.shadow ? activeStyle.shadow.horizontalOffset : 0
        }

        // Progress Bar
        Rectangle {
            visible: root.autoClose > 0 && !root.hideProgressBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: activeStyle.progressBar ? activeStyle.progressBar.height : 4
            width: parent.width * (1.0 - root.progressValue)
            radius: activeStyle.progressBar ? activeStyle.progressBar.radius : 2
            color: Qt.lighter(accentColor, 1.4)
        }
    }

    // Content
    contentItem: RowLayout {
        id: mainLayout
        spacing: spacingConfig.mainSpacing

        // Content area (expandable)
        RowLayout {
            id: contentArea
            objectName: "contentArea"
            Layout.fillWidth: true
            Layout.maximumWidth: root.width - closeButtonArea.width - spacingConfig.mainSpacing - root.leftPadding - root.rightPadding
            Layout.minimumWidth: 100
            spacing: spacingConfig.contentSpacing

            Text {
                id: iconText
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: activeStyle.iconSize || 18
                Layout.preferredHeight: activeStyle.iconSize || 18
                Layout.minimumWidth: activeStyle.iconSize || 18
                Layout.minimumHeight: activeStyle.iconSize || 18
                text: root.iconName
                color: activeStyle.textColors ? activeStyle.textColors.color : "#ffffff"
                font.pixelSize: (activeStyle.iconSize || 18) * 0.8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // Text content area with proper wrapping and expansion
            ColumnLayout {
                id: textContentArea
                Layout.fillWidth: true
                Layout.maximumWidth: contentArea.Layout.maximumWidth - iconText.Layout.preferredWidth - contentArea.spacing
                Layout.minimumWidth: 50
                spacing: spacingConfig.textSpacing

                Label {
                    id: messageLabel
                    text: root.message
                    color: activeStyle.textColors ? activeStyle.textColors.color : ToastifyStyle.textColors.color
                    font.family: activeStyle.fonts ? activeStyle.fonts.family : ToastifyStyle.fonts.family
                    font.pixelSize: activeStyle.fonts ? activeStyle.fonts.size : ToastifyStyle.fonts.size
                    font.weight: activeStyle.fonts ? activeStyle.fonts.weight : ToastifyStyle.fonts.weight
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.maximumWidth: textContentArea.Layout.maximumWidth
                    
                    // Ensure proper vertical expansion for wrapped text
                    onImplicitHeightChanged: {
                        var baseFontSize = activeStyle.fonts ? activeStyle.fonts.size : 14
                        if (implicitHeight > baseFontSize * 1.5) {
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
        Item {
            id: closeButtonArea
            objectName: "closeButtonArea"
            Layout.preferredWidth: spacingConfig.closeButtonTotalWidth
            Layout.preferredHeight: spacingConfig.closeButtonTotalWidth
            Layout.alignment: Qt.AlignTop
            
            Rectangle {
                anchors.fill: parent
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: {
                        var baseColor = activeStyle.textColors ? activeStyle.textColors.color : ToastifyStyle.textColors.color
                        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.6)
                    }
                    font.pixelSize: Math.max(12, (activeStyle.fonts ? activeStyle.fonts.size : 14) * 1.1)
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }
        }
    }

    // Interaction
    MouseArea {
        anchors.fill: parent
        enabled: root.closeOnClick
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.clickAction) root.clickAction()
            root.close()
        }
    }

    // Animations
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
            from: (root.position === 0 || root.position === 2) ? -50 :  // TopLeft or BottomLeft
                  (root.position === 1 || root.position === 3) ? 50 : 0   // TopRight or BottomRight
            to: 0
            duration: activeStyle.animation ? activeStyle.animation.enterDuration : 500
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
            NumberAnimation { 
                target: root; 
                property: "opacity"; 
                to: 0; 
                duration: activeStyle.animation ? activeStyle.animation.exitDuration : 500
            }
            NumberAnimation { 
                target: root; 
                property: "scale"; 
                to: 0.8; 
                duration: activeStyle.animation ? activeStyle.animation.exitDuration : 500
            }
        }
        NumberAnimation { target: root; property: "Layout.preferredHeight"; to: 0; duration: 200 }
        ScriptAction { script: root.destroy() }
    }
}
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import Toastify 1.0
import Toastify.Style 1.0
import PlaygroundExamples 1.0

ApplicationWindow {
    id: window
    width: 900
    height: 700
    visible: true
    title: "QtToastify Playground - Style Showcase"
    
    Material.theme: Material.Light
    Material.accent: Material.Indigo
    
    // Available styles using new StyleProvider system
    property var availableStyles: [
        { name: "Default", provider: defaultStyleProvider, description: "React-Toastify varsayılan açık tema" },
        { name: "Dark Theme", provider: darkStyleProvider, description: "Koyu tema, büyük fontlar ve artırılmış spacing" },
        { name: "Compact", provider: compactStyleProvider, description: "Ultra-kompakt layout, minimal alan kullanımı" },
        { name: "Material", provider: materialStyleProvider, description: "Material Design 3 stil rehberi" }
    ]
    
    // Current selected style
    property int selectedStyleIndex: 0
    readonly property ToastifyStyleProvider currentStyle:
        availableStyles[selectedStyleIndex].provider
    
    // Style providers
    property ToastifyStyleProvider defaultStyleProvider: ToastifyStyleProvider {}
    property DarkStyleProvider darkStyleProvider: DarkStyleProvider {}
    property CompactStyleProvider compactStyleProvider: CompactStyleProvider {}
    property MaterialStyleProvider materialStyleProvider: MaterialStyleProvider {}
    
    // Toast settings
    property string selectedType: "info"
    property int selectedPosition: Toastify.TopRightCorner
    property bool selectedCloseOnClick: true
    property bool selectedHideProgressBar: false
    property bool selectedNewestOnTop: false
    property bool selectedExpand: false
    property int selectedVisibleToasts: 3
    property int selectedAutoClose: 5000
    
    // Background
    Rectangle {
        anchors.fill: parent
        color: selectedStyleIndex === 1 ? "#1E1E1E" : "#F5F5F5"  // Dark for custom style, light for others
        
        Behavior on color {
            ColorAnimation { duration: 300 }
        }
    }
    
    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: 20
        contentWidth: width
        contentHeight: mainColumn.height
        
        ColumnLayout {
            id: mainColumn
            width: parent.width
            spacing: 20
            
            // Header
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "QtToastify Playground"
                    font.pixelSize: 28
                    font.bold: true
                    color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "Farklı stil konfigürasyonlarını test edin ve toast davranışlarını inceleyin"
                    font.pixelSize: 14
                    color: selectedStyleIndex === 1 ? "#CCCCCC" : "#666666"
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: selectedStyleIndex === 1 ? "#444444" : "#E0E0E0"
            }
            
            // Style Selection
            GroupBox {
                id: styleBox
                title: "Style Selection"
                Layout.fillWidth: true
                
                background: Rectangle {
                    y: styleBox.topPadding - styleBox.bottomPadding
                    width: parent.width
                    height: parent.height - styleBox.topPadding + styleBox.bottomPadding

                    color: selectedStyleIndex === 1 ? "#2A2A2A" : "#FFFFFF"
                    border.color: selectedStyleIndex === 1 ? "#444444" : "#E0E0E0"
                    radius: 8
                }
                
                label: Text {
                    leftPadding: 10
                    text: parent.title
                    font.bold: true
                    color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    
                    ButtonGroup {
                        id: styleGroup
                    }
                    
                    Repeater {
                        model: availableStyles

                        RadioButton {
                            id: radioBtn
                            ButtonGroup.group: styleGroup
                            checked: index === selectedStyleIndex
                            Layout.fillWidth: true

                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                x: radioBtn.leftPadding
                                y: radioBtn.topPadding + (radioBtn.availableHeight - height) / 2
                                radius: 10
                                border.color: selectedStyleIndex === 1 ? "#666666" : "#999999"
                                border.width: 2
                                color: "transparent"

                                Rectangle {
                                    width: 10
                                    height: 10
                                    x: 5
                                    y: 5
                                    radius: 5
                                    color: selectedStyleIndex === 1 ? "#4A9EFF" : "#007BFF"
                                    visible: radioBtn.checked
                                }
                            }

                            contentItem: ColumnLayout {
                                spacing: 4
                                anchors.left: parent.indicator.right
                                anchors.right: parent.right
                                anchors.leftMargin: 8

                                Text {
                                    text: modelData.name
                                    font.bold: true
                                    color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                                }

                                Text {
                                    text: modelData.description
                                    font.pixelSize: 11
                                    color: selectedStyleIndex === 1 ? "#CCCCCC" : "#666666"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }

                            onClicked: {
                                selectedStyleIndex = index
                                // Style provider automatically updates via binding
                            }
                        }
                    }

                    // Current style info
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: styleInfoColumn.implicitHeight + 16
                        color: selectedStyleIndex === 1 ? "#333333" : "#F8F9FA"
                        radius: 6
                        border.color: selectedStyleIndex === 1 ? "#555555" : "#E9ECEF"
                        
                        ColumnLayout {
                            id: styleInfoColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8
                            spacing: 4
                            
                            Text {
                                text: "Aktif Stil: "
                                      + availableStyles[selectedStyleIndex].name
                                font.bold: true
                                color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                            }
                            
                            Text {
                                text: "Font: " + currentStyle.fonts.family + " " + currentStyle.fonts.size + "px"
                                font.pixelSize: 11
                                color: selectedStyleIndex === 1 ? "#CCCCCC" : "#666666"
                            }
                            
                            Text {
                                text: "Container: " + currentStyle.containerSizes.minimum + "-" + currentStyle.containerSizes.maximum + "px"
                                font.pixelSize: 11
                                color: selectedStyleIndex === 1 ? "#CCCCCC" : "#666666"
                            }
                            
                            Text {
                                text: "Spacing: " + currentStyle.spacing.main + "px (main), " + currentStyle.spacing.container + "px (padding)"
                                font.pixelSize: 11
                                color: selectedStyleIndex === 1 ? "#CCCCCC" : "#666666"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                                Layout.bottomMargin: 4
                                implicitHeight: 1
                                color: selectedStyleIndex === 1
                                       ? "#555555" : "#DEE2E6"
                            }

                            Text {
                                text: "Stack Style"
                                font.bold: true
                                color: selectedStyleIndex === 1
                                       ? "#FFFFFF" : "#333333"
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 4
                                columnSpacing: 12
                                rowSpacing: 8
                                Material.theme:
                                    window.selectedStyleIndex === 1
                                    ? Material.Dark : Material.Light

                                Text {
                                    text: "Expanded Gap (px):"
                                    color: selectedStyleIndex === 1
                                           ? "#CCCCCC" : "#666666"
                                }

                                SpinBox {
                                    objectName: "expandedSpacingSpinBox"
                                    from: 0
                                    to: 64
                                    editable: true
                                    value: Math.round(
                                               window.currentStyle.toastSpacing)
                                    onValueModified:
                                        window.currentStyle.toastSpacing = value
                                }

                                Text {
                                    text: "Compact Offset (px):"
                                    color: selectedStyleIndex === 1
                                           ? "#CCCCCC" : "#666666"
                                }

                                SpinBox {
                                    objectName: "collapsedOffsetSpinBox"
                                    from: 0
                                    to: 48
                                    editable: true
                                    value: Math.round(
                                               window.currentStyle
                                               .collapsedToastOffset)
                                    onValueModified:
                                        window.currentStyle
                                        .collapsedToastOffset = value
                                }

                                Text {
                                    text: "Compact Scale Step (%):"
                                    color: selectedStyleIndex === 1
                                           ? "#CCCCCC" : "#666666"
                                }

                                SpinBox {
                                    objectName: "collapsedScaleSpinBox"
                                    from: 0
                                    to: 10
                                    editable: true
                                    value: Math.round(
                                               window.currentStyle
                                               .collapsedToastScaleStep * 100)
                                    onValueModified:
                                        window.currentStyle
                                        .collapsedToastScaleStep = value / 100.0
                                }
                            }
                        }
                    }
                }
            }
            
            // Toast Configuration
            GroupBox {
                id: toastConfigBox
                title: "Toast Configuration"
                Layout.fillWidth: true
                
                background: Rectangle {
                    y: toastConfigBox.topPadding - toastConfigBox.bottomPadding
                    width: parent.width
                    height: parent.height - toastConfigBox.topPadding + toastConfigBox.bottomPadding
                    color: selectedStyleIndex === 1 ? "#2A2A2A" : "#FFFFFF"
                    border.color: selectedStyleIndex === 1 ? "#444444" : "#E0E0E0"
                    radius: 8
                }
                
                label: Text {
                    leftPadding: 10
                    text: parent.title
                    font.bold: true
                    color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                }
                
                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 15
                    
                    // Message
                    Text {
                        text: "Message:"
                        font.bold: true
                        color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                    }
                    
                    TextField {
                        id: messageField
                        Layout.fillWidth: true
                        text: "Bu bir örnek toast mesajıdır. Farklı uzunluklarda mesajları test edebilirsiniz."
                        wrapMode: TextInput.Wrap
                        
                        background: Rectangle {
                            color: selectedStyleIndex === 1 ? "#333333" : "#FFFFFF"
                            border.color: selectedStyleIndex === 1 ? "#555555" : "#CCCCCC"
                            radius: 4
                        }
                        
                        color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                    }
                    
                    // Type
                    Text {
                        text: "Type:"
                        font.bold: true
                        color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                    }
                    
                    Flow {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        ButtonGroup { id: typeGroup }
                        
                        Repeater {
                            model: ["info", "success", "warning", "error"]
                            
                            RadioButton {
                                text: modelData
                                ButtonGroup.group: typeGroup
                                checked: selectedType === modelData
                                onClicked: selectedType = modelData
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                                    leftPadding: parent.indicator.width + parent.spacing
                                }
                            }
                        }
                    }
                    
                    // Position
                    Text {
                        text: "Position:"
                        font.bold: true
                        color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                    }
                    
                    Flow {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        ButtonGroup { id: positionGroup }
                        
                        property var positions: [
                            { text: "Top-Left", value: Toastify.TopLeftCorner },
                            { text: "Top-Right", value: Toastify.TopRightCorner },
                            { text: "Bottom-Left", value: Toastify.BottomLeftCorner },
                            { text: "Bottom-Right", value: Toastify.BottomRightCorner },
                            { text: "Bottom-Center", value: Toastify.BottomCenter },
                            { text: "Top-Center", value: Toastify.TopCenter }
                        ]
                        
                        Repeater {
                            model: parent.positions
                            
                            RadioButton {
                                text: modelData.text
                                ButtonGroup.group: positionGroup
                                checked: selectedPosition === modelData.value
                                onClicked: selectedPosition = modelData.value
                                
                                contentItem: Text {
                                    verticalAlignment: Text.AlignVCenter
                                    text: parent.text
                                    color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                                    leftPadding: parent.indicator.width + parent.spacing
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                    
                    // Options
                    Text {
                        text: "Options:"
                        font.bold: true
                        color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        CheckBox {
                            text: "Close on Click"
                            checked: selectedCloseOnClick
                            onCheckedChanged: selectedCloseOnClick = checked
                            
                            contentItem: Text {
                                text: parent.text
                                color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                                leftPadding: parent.indicator.width + parent.spacing
                            }
                        }
                        
                        CheckBox {
                            text: "Hide Progress Bar"
                            checked: selectedHideProgressBar
                            onCheckedChanged: selectedHideProgressBar = checked

                            contentItem: Text {
                                text: parent.text
                                color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                                leftPadding: parent.indicator.width + parent.spacing
                            }
                        }

                        CheckBox {
                            id: newestOnTopCheckBox
                            text: "Newest on Top (Expand)"
                            checked: window.selectedNewestOnTop
                            enabled: window.selectedExpand
                            opacity: newestOnTopCheckBox.enabled ? 1 : 0.5
                            onToggled: window.selectedNewestOnTop
                                       = newestOnTopCheckBox.checked

                            contentItem: Text {
                                text: newestOnTopCheckBox.text
                                color: window.selectedStyleIndex === 1
                                       ? "#FFFFFF" : "#333333"
                                leftPadding: newestOnTopCheckBox.indicator.width
                                             + newestOnTopCheckBox.spacing
                            }
                        }

                        RowLayout {
                            spacing: 12

                            Text {
                                text: "Stack Mode:"
                                color: window.selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                            }

                            ButtonGroup {
                                id: stackModeGroup
                            }

                            RadioButton {
                                id: defaultStackMode
                                text: "Default"
                                ButtonGroup.group: stackModeGroup
                                checked: !window.selectedExpand
                                onClicked: window.selectedExpand = false

                                contentItem: Text {
                                    text: defaultStackMode.text
                                    color: window.selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                                    leftPadding: defaultStackMode.indicator.width
                                                 + defaultStackMode.spacing
                                }
                            }

                            RadioButton {
                                id: expandedStackMode
                                text: "Expand"
                                ButtonGroup.group: stackModeGroup
                                checked: window.selectedExpand
                                onClicked: window.selectedExpand = true

                                contentItem: Text {
                                    text: expandedStackMode.text
                                    color: window.selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                                    leftPadding: expandedStackMode.indicator.width
                                                 + expandedStackMode.spacing
                                }
                            }
                        }

                        RowLayout {
                            spacing: 12

                            Text {
                                text: "Visible Toasts:"
                                color: window.selectedStyleIndex === 1
                                       ? "#FFFFFF" : "#333333"
                            }

                            SpinBox {
                                objectName: "visibleToastsSpinBox"
                                from: 1
                                to: 8
                                editable: true
                                Material.theme:
                                    window.selectedStyleIndex === 1
                                    ? Material.Dark : Material.Light
                                value: window.selectedVisibleToasts
                                onValueModified:
                                    window.selectedVisibleToasts = value
                            }
                        }
                        
                        RowLayout {
                            Text {
                                text: "Auto Close (ms):"
                                color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                            }
                            
                            TextField {
                                text: selectedAutoClose.toString()
                                validator: IntValidator { bottom: 0 }
                                onTextChanged: {
                                    if (text && !isNaN(parseInt(text))) {
                                        selectedAutoClose = parseInt(text)
                                    }
                                }
                                
                                background: Rectangle {
                                    color: selectedStyleIndex === 1 ? "#333333" : "#FFFFFF"
                                    border.color: selectedStyleIndex === 1 ? "#555555" : "#CCCCCC"
                                    radius: 4
                                }
                                
                                color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                            }
                            
                            Text {
                                text: "(0 = No Auto Close)"
                                color: selectedStyleIndex === 1 ? "#CCCCCC" : "#666666"
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
            
            // Actions
            GroupBox {
                id: actionBox
                title: "Actions"
                Layout.fillWidth: true
                
                background: Rectangle {
                    y: actionBox.topPadding - actionBox.bottomPadding
                    width: parent.width
                    height: parent.height - actionBox.topPadding + actionBox.bottomPadding
                    color: selectedStyleIndex === 1 ? "#2A2A2A" : "#FFFFFF"
                    border.color: selectedStyleIndex === 1 ? "#444444" : "#E0E0E0"
                    radius: 8
                }
                
                label: Text {
                    leftPadding: 10
                    text: parent.title
                    font.bold: true
                    color: selectedStyleIndex === 1 ? "#FFFFFF" : "#333333"
                }
                
                Flow {
                    anchors.fill: parent
                    spacing: 12
                    
                    Button {
                        text: "🚀 Show Toast"
                        highlighted: true
                        Material.accent: Material.Indigo
                        
                        onClicked: {
                            // Create toast with current style
                            createStyledToast()
                        }
                    }
                    
                    Button {
                        text: "📏 Test Long Message"
                        onClicked: {
                            var longMessage = "Bu çok uzun bir mesajdır ve text wrapping özelliğini test etmek için kullanılır. " +
                                    "Farklı stil konfigürasyonlarında nasıl göründüğünü ve container sınırları içinde " +
                                    "nasıl davrandığını kontrol edebiliriz. Özellikle kompakt stil ile test etmek ilginç olacaktır."
                            
                            createStyledToast(longMessage)
                        }
                    }
                    
                    Button {
                        text: "⚡ Test All Types"
                        onClicked: {
                            var types = ["info", "success", "warning", "error"]
                            var styleName = availableStyles[
                                                selectedStyleIndex].name
                            var messages = [
                                        "Bilgi mesajı - " + styleName,
                                        "Başarılı işlem - " + styleName,
                                        "Uyarı mesajı - " + styleName,
                                        "Hata mesajı - " + styleName
                                    ]
                            
                            for (var i = 0; i < types.length; i++) {
                                (function(index) {
                                    Qt.callLater(function() {
                                        createStyledToast(messages[index], types[index])
                                    })
                                })(i)
                            }
                        }
                    }
                }
            }
            
            // Spacer
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
            }
        }
    }
    
    // Function to create styled toast
    function createStyledToast(message, type) {
        var msg = message || messageField.text
        var toastType = type || selectedType
        
        var typeEnum = 0; // Info
        if (toastType === "success") typeEnum = 1;
        else if (toastType === "warning") typeEnum = 2;
        else if (toastType === "error") typeEnum = 3;
        
        // Use Toastify with current style
        return toastify.createMessage(msg, {
                                          type: typeEnum,
                                          position: selectedPosition,
                                          autoClose: selectedAutoClose,
                                          hideProgressBar: selectedHideProgressBar,
                                          closeOnClick: selectedCloseOnClick
                                      })
    }
    
    // Toastify instance with current style
    Toastify {
        id: toastify
        style: window.currentStyle
        newestOnTop: window.selectedNewestOnTop
        expand: window.selectedExpand
        visibleToasts: window.selectedVisibleToasts
    }
}

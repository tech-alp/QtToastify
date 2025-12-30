import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Toastify 1.0

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "QtToastify - Custom Style Example"
    
    // Custom ToastifyStyle implementation
    property alias customStyle: customToastifyStyle
    
    QtObject {
        id: customToastifyStyle
        
        // Custom color palette - Dark theme
        property var colors: ({
            info: "#2196F3",      // Material Blue
            success: "#4CAF50",   // Material Green  
            warning: "#FF9800",   // Material Orange
            error: "#F44336"      // Material Red
        })

        // Custom font settings - Larger fonts
        property var fonts: ({
            family: "Arial",
            size: 16,             // Larger font
            weight: Font.Medium
        })

        // Custom layout settings - More spacing
        property real cornerRadius: 16    // More rounded corners
        property real borderMargin: 16    // More padding
        property real iconSize: 24        // Larger icons
        property real iconSpacing: 16     // More spacing

        // Enhanced spacing configuration
        property var spacing: ({
            main: 16,                    // More space between content and close button
            content: 16,                 // More space between icon and text
            text: 6,                     // More space between text lines
            container: 16,               // More container padding
            
            closeButton: {
                "padding": 8,            // More padding around close button
                "size": 24 + 8          // Larger close button
            },
            
            totalHorizontal: function() {
                return spacing.main + spacing.container * 2;
            },
            
            closeButtonTotal: function() {
                return spacing.closeButton.size;
            }
        })

        // Custom shadow settings - More prominent shadow
        property var shadow: ({
            blur: 1.0,
            color: "#000000",
            opacity: 0.3,
            horizontalOffset: 2,
            verticalOffset: 4
        })

        // Custom animation settings - Slower animations
        property var animation: ({
            enterDuration: 800,
            exitDuration: 600,
            easingType: "OutBack",
            pauseDuration: 300
        })

        // Custom progress bar settings
        property var progressBar: ({
            height: 6,               // Thicker progress bar
            radius: 3
        })

        // Dark theme text colors
        property var textColors: ({
            light: "#FFFFFF",
            dark: "#000000", 
            color: "#FFFFFF"         // White text for dark backgrounds
        })

        // Dark theme background colors
        property var backgroundColors: ({
            light: "#FFFFFF",
            dark: "#121212",
            color: "accent"
        })

        // Custom container sizes - Larger containers
        property var containerSizes: ({
            minimum: 320,
            preferred: 400,
            maximum: 600
        })
    }
    
    // Replace default ToastifyStyle with custom style
    Component.onCompleted: {
        // This would be the way to override the style in a real application
        console.log("Custom style loaded with larger fonts and spacing")
    }

    Rectangle {
        anchors.fill: parent
        color: "#1E1E1E"  // Dark background
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            
            Text {
                text: "QtToastify - Custom Style Demo"
                color: "white"
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Bu örnek özel ToastifyStyle implementasyonu gösterir:\n" +
                      "• Koyu tema renkleri\n" +
                      "• Büyük font boyutu (16px)\n" +
                      "• Artırılmış spacing değerleri\n" +
                      "• Daha büyük container boyutları\n" +
                      "• Gelişmiş gölge efektleri"
                color: "#CCCCCC"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }
            
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 15
                
                Button {
                    text: "Info Toast"
                    onClicked: {
                        // Create toast with custom style
                        var toast = toastComponent.createObject(window, {
                            message: "Bu bir bilgi mesajıdır - özel stil ile!",
                            type: Toastify.Info,
                            preferredWidth: customStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Success Toast"
                    onClicked: {
                        var toast = toastComponent.createObject(window, {
                            message: "İşlem başarıyla tamamlandı! Özel yeşil tema ile gösteriliyor.",
                            type: Toastify.Success,
                            preferredWidth: customStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Warning Toast"
                    onClicked: {
                        var toast = toastComponent.createObject(window, {
                            message: "Dikkat! Bu bir uyarı mesajıdır. Özel turuncu renk kullanılıyor.",
                            type: Toastify.Warning,
                            preferredWidth: customStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Error Toast"
                    onClicked: {
                        var toast = toastComponent.createObject(window, {
                            message: "Hata oluştu! Bu çok uzun bir hata mesajıdır ve text wrapping özelliğini test eder. Özel kırmızı tema ile gösteriliyor.",
                            type: Toastify.Error,
                            preferredWidth: customStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
            }
        }
    }
    
    // Custom toast component that uses our custom style
    Component {
        id: toastComponent
        
        ToastifyDelegate {
            // Override style properties to use custom values
            Component.onCompleted: {
                // Apply custom style values
                minimumWidth = customStyle.containerSizes.minimum
                preferredWidth = customStyle.containerSizes.preferred  
                maximumWidth = customStyle.containerSizes.maximum
            }
        }
    }
}
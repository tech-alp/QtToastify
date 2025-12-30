import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Toastify 1.0

ApplicationWindow {
    id: window
    width: 600
    height: 400
    visible: true
    title: "QtToastify - Compact Layout Example"
    
    // Compact ToastifyStyle for minimal space usage
    property alias compactStyle: compactToastifyStyle
    
    QtObject {
        id: compactToastifyStyle
        
        // Compact color palette - more saturated for small sizes
        property var colors: ({
            info: "#1976D2",      // Darker Blue
            success: "#388E3C",   // Darker Green
            warning: "#F57C00",   // Darker Orange
            error: "#D32F2F"      // Darker Red
        })

        // Very small fonts for compact layout
        property var fonts: ({
            family: "Roboto Condensed",
            size: 10,             // Very small font
            weight: Font.Medium   // Medium weight for better readability at small size
        })

        // Ultra-minimal layout settings
        property real cornerRadius: 4     // Sharp corners
        property real borderMargin: 4     // Minimal padding
        property real iconSize: 12        // Very small icons
        property real iconSpacing: 4      // Minimal spacing

        // Ultra-compact spacing configuration
        property var spacing: ({
            main: 4,                     // Minimal space between elements
            content: 4,                  // Minimal content spacing
            text: 1,                     // Almost no text spacing
            container: 4,                // Minimal container padding
            
            closeButton: {
                "padding": 2,            // Minimal close button padding
                "size": 12 + 2          // Very small close button
            },
            
            totalHorizontal: function() {
                return spacing.main + spacing.container * 2;
            },
            
            closeButtonTotal: function() {
                return spacing.closeButton.size;
            }
        })

        // No shadow for ultra-clean look
        property var shadow: ({
            blur: 0,
            color: "#000000",
            opacity: 0,
            horizontalOffset: 0,
            verticalOffset: 0
        })

        // Very fast animations
        property var animation: ({
            enterDuration: 150,
            exitDuration: 100,
            easingType: "OutQuad",
            pauseDuration: 50
        })

        // Very thin progress bar
        property var progressBar: ({
            height: 1,
            radius: 0
        })

        // High contrast text colors for small sizes
        property var textColors: ({
            light: "#000000",
            dark: "#FFFFFF",
            color: "#FFFFFF"         // White text for better contrast
        })

        // Compact backgrounds
        property var backgroundColors: ({
            light: "#FFFFFF",
            dark: "#121212",
            color: "accent"
        })

        // Very small container sizes
        property var containerSizes: ({
            minimum: 180,
            preferred: 220,
            maximum: 280
        })
    }

    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"  // Very light background
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10
            
            Text {
                text: "QtToastify - Compact Layout Demo"
                color: "#333333"
                font.pixelSize: 18
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Bu örnek ultra-kompakt ToastifyStyle implementasyonu gösterir:\n" +
                      "• Çok küçük font boyutu (10px)\n" +
                      "• Minimal spacing (4px)\n" +
                      "• Küçük container boyutları (180-280px)\n" +
                      "• Gölge efekti yok\n" +
                      "• Çok hızlı animasyonlar\n" +
                      "• Yüksek kontrast renkler"
                color: "#666666"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                text: "Mobil uygulamalar veya sınırlı alan gerektiren durumlar için idealdir."
                color: "#888888"
                font.pixelSize: 10
                font.italic: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            Flow {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 400
                spacing: 8
                
                Button {
                    text: "Compact Info"
                    font.pixelSize: 10
                    onClicked: {
                        var toast = compactToastComponent.createObject(window, {
                            message: "Kompakt bilgi mesajı",
                            type: Toastify.Info,
                            preferredWidth: compactStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Compact Success"
                    font.pixelSize: 10
                    onClicked: {
                        var toast = compactToastComponent.createObject(window, {
                            message: "Başarılı - kompakt",
                            type: Toastify.Success,
                            preferredWidth: compactStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Compact Warning"
                    font.pixelSize: 10
                    onClicked: {
                        var toast = compactToastComponent.createObject(window, {
                            message: "Uyarı - kompakt layout",
                            type: Toastify.Warning,
                            preferredWidth: compactStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Compact Error"
                    font.pixelSize: 10
                    onClicked: {
                        var toast = compactToastComponent.createObject(window, {
                            message: "Hata mesajı - çok kompakt görünüm ile",
                            type: Toastify.Error,
                            preferredWidth: compactStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Long Message Test"
                    font.pixelSize: 10
                    onClicked: {
                        var toast = compactToastComponent.createObject(window, {
                            message: "Bu çok uzun bir mesajdır ve kompakt layout'ta text wrapping özelliğini test etmek için kullanılır. Küçük boyutlarda nasıl göründüğünü kontrol edelim.",
                            type: Toastify.Info,
                            preferredWidth: compactStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
            }
        }
    }
    
    // Compact toast component
    Component {
        id: compactToastComponent
        
        ToastifyDelegate {
            Component.onCompleted: {
                // Apply compact style values
                minimumWidth = compactStyle.containerSizes.minimum
                preferredWidth = compactStyle.containerSizes.preferred
                maximumWidth = compactStyle.containerSizes.maximum
            }
        }
    }
}
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Toastify 1.0

ApplicationWindow {
    id: window
    width: 700
    height: 500
    visible: true
    title: "QtToastify - Light Theme Example"
    
    // Light theme ToastifyStyle
    property alias lightStyle: lightToastifyStyle
    
    QtObject {
        id: lightToastifyStyle
        
        // Light theme color palette
        property var colors: ({
            info: "#E3F2FD",      // Light Blue
            success: "#E8F5E8",   // Light Green
            warning: "#FFF3E0",   // Light Orange  
            error: "#FFEBEE"      // Light Red
        })

        // Smaller, clean fonts
        property var fonts: ({
            family: "Segoe UI",
            size: 12,             // Smaller font
            weight: Font.Normal
        })

        // Minimal layout settings
        property real cornerRadius: 8     // Less rounded
        property real borderMargin: 8     // Less padding
        property real iconSize: 16        // Smaller icons
        property real iconSpacing: 8      // Less spacing

        // Minimal spacing configuration
        property var spacing: ({
            main: 8,                     // Less space between elements
            content: 8,                  // Less content spacing
            text: 2,                     // Minimal text spacing
            container: 8,                // Minimal container padding
            
            closeButton: {
                "padding": 4,            // Minimal close button padding
                "size": 16 + 4          // Smaller close button
            },
            
            totalHorizontal: function() {
                return spacing.main + spacing.container * 2;
            },
            
            closeButtonTotal: function() {
                return spacing.closeButton.size;
            }
        })

        // Subtle shadow for light theme
        property var shadow: ({
            blur: 0.3,
            color: "#000000",
            opacity: 0.1,
            horizontalOffset: 0,
            verticalOffset: 2
        })

        // Quick animations
        property var animation: ({
            enterDuration: 300,
            exitDuration: 200,
            easingType: "OutQuad",
            pauseDuration: 100
        })

        // Thin progress bar
        property var progressBar: ({
            height: 2,
            radius: 1
        })

        // Light theme text colors - dark text on light backgrounds
        property var textColors: ({
            light: "#000000",
            dark: "#FFFFFF",
            color: "#333333"         // Dark text for light backgrounds
        })

        // Light theme backgrounds
        property var backgroundColors: ({
            light: "#FFFFFF",
            dark: "#121212",
            color: "accent"
        })

        // Compact container sizes
        property var containerSizes: ({
            minimum: 240,
            preferred: 300,
            maximum: 400
        })
    }

    Rectangle {
        anchors.fill: parent
        color: "#F5F5F5"  // Light gray background
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 15
            
            Text {
                text: "QtToastify - Light Theme Demo"
                color: "#333333"
                font.pixelSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Bu örnek açık tema ToastifyStyle implementasyonu gösterir:\n" +
                      "• Açık tema renkleri (pastel tonlar)\n" +
                      "• Küçük font boyutu (12px)\n" +
                      "• Minimal spacing değerleri\n" +
                      "• Kompakt container boyutları\n" +
                      "• Hafif gölge efektleri\n" +
                      "• Koyu metin renkleri"
                color: "#666666"
                font.pixelSize: 12
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }
            
            GridLayout {
                Layout.alignment: Qt.AlignHCenter
                columns: 2
                rowSpacing: 10
                columnSpacing: 15
                
                Button {
                    text: "Info"
                    onClicked: {
                        var toast = lightToastComponent.createObject(window, {
                            message: "Bilgi mesajı - açık mavi tema",
                            type: Toastify.Info,
                            preferredWidth: lightStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Success"
                    onClicked: {
                        var toast = lightToastComponent.createObject(window, {
                            message: "Başarılı işlem - açık yeşil tema",
                            type: Toastify.Success,
                            preferredWidth: lightStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Warning"
                    onClicked: {
                        var toast = lightToastComponent.createObject(window, {
                            message: "Uyarı mesajı - açık turuncu tema ile gösteriliyor",
                            type: Toastify.Warning,
                            preferredWidth: lightStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
                
                Button {
                    text: "Error"
                    onClicked: {
                        var toast = lightToastComponent.createObject(window, {
                            message: "Hata mesajı - açık kırmızı tema. Bu uzun mesaj text wrapping'i test eder.",
                            type: Toastify.Error,
                            preferredWidth: lightStyle.containerSizes.preferred
                        })
                        toast.show()
                    }
                }
            }
        }
    }
    
    // Light theme toast component
    Component {
        id: lightToastComponent
        
        ToastifyDelegate {
            Component.onCompleted: {
                // Apply light theme style values
                minimumWidth = lightStyle.containerSizes.minimum
                preferredWidth = lightStyle.containerSizes.preferred
                maximumWidth = lightStyle.containerSizes.maximum
            }
        }
    }
}
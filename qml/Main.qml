import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import Toastify
import QtQuick.Effects

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Toastify")
    Material.accent: "#3498db"
    Material.theme: Material.Light

    //Properties
    property string selectedType: "info"
    property int selectedPosition: Toastify.TopLeftCorner
    property string selectedTheme: "Light"
    property bool selectedCloseOnClick: true
    property int selectedAutoClose: 5000
    property bool selectedHideProgressBar: false

    //Dynamic content loader
    Loader{
        anchors.fill: parent
        source: "qrc:/Toastify/qml/ShowcaseSimple.qml"
    }
    //Toast display module
    Toastify {
        id: toastify

        toastItem: ToastifyDelegate {
            id: toastifyDelegate
            property string subtitle: ""
            property string buttonText: ""
            property var onButtonClick: null

            Layout.preferredWidth: 350

            background: Rectangle {
                color: "white"  // Beyaz arka plan
                radius: 8

                border.width: 1
                border.color: "#E0E0E0"  // Hafif gri border

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#000000"
                    shadowBlur: 0.6
                    shadowOpacity: 0.1
                    shadowVerticalOffset: 4
                    shadowHorizontalOffset: 0
                }
            }
            contentItem: RowLayout {
                id: mainLayout
                spacing: 12

                // Content area (expandable) - FIX: Add maximum width constraint
                RowLayout {
                    id: contentArea
                    spacing: 12

                    Image {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        source: toastifyDelegate.iconName + "?color=" + toastifyDelegate.accentColor
                    }

                    // Content text
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Label {
                            text: toastifyDelegate.message
                            color: "#1A1A1A"
                            font.family: ToastifyStyle.fonts.family
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        Label {
                            text: toastifyDelegate.subtitle
                            color: "#666666"
                            font.family: ToastifyStyle.fonts.family
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            visible: toastifyDelegate.subtitle !== ""
                            Layout.fillWidth: true
                        }

                        // Optional action button (Okay gibi)
                        Button {
                            visible: toastifyDelegate.buttonText !== ""
                            text: toastifyDelegate.buttonText

                            Layout.preferredHeight: 32
                            Layout.preferredWidth: 70
                            Layout.alignment: Qt.AlignRight

                            onClicked: {
                                if (toastifyDelegate.onButtonClick) toastifyDelegate.onButtonClick()
                                toastifyDelegate.close()
                            }

                            background: Rectangle {
                                radius: 6
                                color: parent.pressed ? "#7C4DFF" :
                                       parent.hovered ? "#9575CD" :
                                       "#B39DDB"
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // Close button area (fixed width) - FIX: Proper close button area
                Item {
                    id: closeButtonArea
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    Layout.alignment: Qt.AlignTop

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "#999999"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: toastifyDelegate.close()
                        }
                    }
                }
            }
        }
    }

    ToolButton{
        text: window.Material.theme===Material.Light ? "☀" : "☾"
        Material.foreground: window.Material.theme===Material.Light ? "black" : "white"

        onClicked: {
            if(window.Material.theme===Material.Light){
                window.Material.theme= Material.Dark
            }else{
                window.Material.theme= Material.Light
            }
            toastify.createMessage("Board deleted successfully", {
                type: Toastify.Success,
                subtitle: "'CEO Summary' has been deleted from your reports.",
                buttonText: "Okay",
                position: Toastify.TopCenter,
                autoClose: 0,  // Manuel kapatma
                onButtonClick: function() {
                    console.log("Okay clicked")
                }
            })
        }
    }
}

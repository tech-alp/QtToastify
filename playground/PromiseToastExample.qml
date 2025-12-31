import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Toastify 1.0

Page {
    id: root
    title: "Promise Toast Example"

    // Toastify container
    Toastify {
        id: toast
    }

    // Helper function to simulate async operations
    function createPromise(delay, shouldReject = false) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                if (shouldReject) {
                    reject(new Error("Promise failed!"));
                } else {
                    resolve("Promise completed successfully!");
                }
            }, delay);
        });
    }

    // Helper function for setTimeout (QML doesn't have native setTimeout)
    function setTimeout(func, interval) {
        return setTimeoutComponent.createObject(null, { 
            func: func, 
            interval: interval, 
            running: true 
        });
    }

    Component {
        id: setTimeoutComponent
        Timer {
            property var func
            onTriggered: {
                func();
                destroy();
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20

        ColumnLayout {
            width: Math.max(implicitWidth, root.width - 40)
            spacing: 20

            Text {
                text: "Promise Toast Examples"
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "React Toastify benzeri Promise desteği ile toast'lar oluşturun"
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            // React Toastify benzeri örnekler
            GroupBox {
                title: "Promise Toast Örnekleri"
                Layout.fillWidth: true
                Layout.maximumWidth: 600
                Layout.alignment: Qt.AlignHCenter

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    Button {
                        text: "✅ Promise with Success (3 seconds)"
                        Layout.fillWidth: true
                        onClicked: {
                            const resolveAfter3Sec = createPromise(3000, false);
                            toast.promise(
                                resolveAfter3Sec,
                                {
                                    pending: 'Promise is pending',
                                    success: 'Promise resolved 👌',
                                    error: 'Promise rejected 🤯'
                                }
                            );
                        }
                    }

                    Button {
                        text: "❌ Promise with Error (2 seconds)"
                        Layout.fillWidth: true
                        onClicked: {
                            const rejectAfter2Sec = createPromise(2000, true);
                            toast.promise(
                                rejectAfter2Sec,
                                {
                                    pending: 'Promise is pending',
                                    success: 'Promise resolved 👌',
                                    error: 'Promise rejected 🤯'
                                }
                            );
                        }
                    }

                    Button {
                        text: "🔄 Function that Returns Promise"
                        Layout.fillWidth: true
                        onClicked: {
                            const functionThatReturnPromise = () => createPromise(4000, false);
                            toast.promise(
                                functionThatReturnPromise,
                                {
                                    pending: 'Function promise is pending',
                                    success: 'Function promise resolved 👌',
                                    error: 'Function promise rejected 🤯'
                                }
                            );
                        }
                    }

                    Button {
                        text: "🚀 Multiple Promises"
                        Layout.fillWidth: true
                        onClicked: {
                            // İlk promise
                            toast.promise(
                                createPromise(2000, false),
                                {
                                    pending: 'First promise pending',
                                    success: 'First promise success ✅',
                                    error: 'First promise error ❌',
                                    position: Toastify.TopLeftCorner
                                }
                            );

                            // İkinci promise (farklı pozisyon)
                            toast.promise(
                                createPromise(3000, true),
                                {
                                    pending: 'Second promise pending',
                                    success: 'Second promise success ✅',
                                    error: 'Second promise error ❌',
                                    position: Toastify.TopRightCorner
                                }
                            );
                        }
                    }
                }
            }

            // Normal toast örnekleri (mevcut fonksiyonalite bozulmadığını göstermek için)
            GroupBox {
                title: "Normal Toast Örnekleri"
                Layout.fillWidth: true
                Layout.maximumWidth: 600
                Layout.alignment: Qt.AlignHCenter

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Button {
                        text: "✅ Normal Success"
                        Layout.fillWidth: true
                        onClicked: toast.success("Normal success message!")
                    }
                    Button {
                        text: "❌ Normal Error"
                        Layout.fillWidth: true
                        onClicked: toast.error("Normal error message!")
                    }
                }
            }

            // Geri dönüş butonu
            Button {
                text: "← Ana Sayfaya Dön"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    if (root.StackView.view) {
                        root.StackView.view.pop()
                    }
                }
            }
        }
    }
}
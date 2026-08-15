import QtQuick 2.15
import Toastify.Style 1.0

ToastifyStyle {
    readonly property string name: "Default"
    readonly property string description: "QtToastify'ın varsayılan stil ayarları"

    shadow: ({
        blurRadius: 16,
        spread: 0,
        color: "#000000",
        opacity: 0.1,
        horizontalOffset: 0,
        verticalOffset: 4
    })
}

import QtQml
import Toastify
import Toastify.Style

QtObject {
    id: root

    objectName: "playground.state"

    property string message: qsTr("This is a sample toast message.")
    readonly property bool hasMessage: message.trim().length > 0
    property string toastType: "info"
    property int position: Toastify.TopRightCorner
    property int styleIndex: 0
    property bool stackExpanded: false
    readonly property alias expand: root.stackExpanded
    property int autoClose: 5000
    property int visibleToasts: 3
    property bool showCloseButton: true
    property bool closeOnClick: true
    property bool showProgressBar: true
    property bool newestOnTop: false
    property real toastSpacing: 16
    property real collapsedOffset: 14
    property real collapsedScaleStep: 0.05

    property ToastifyStyleProvider defaultStyle: ToastifyStyleProvider {
        toastSpacing: root.toastSpacing
        collapsedToastOffset: root.collapsedOffset
        collapsedToastScaleStep: root.collapsedScaleStep
    }
    property DarkStyleProvider darkStyle: DarkStyleProvider {
        toastSpacing: root.toastSpacing
        collapsedToastOffset: root.collapsedOffset
        collapsedToastScaleStep: root.collapsedScaleStep
    }
    property CompactStyleProvider compactStyle: CompactStyleProvider {
        toastSpacing: root.toastSpacing
        collapsedToastOffset: root.collapsedOffset
        collapsedToastScaleStep: root.collapsedScaleStep
    }
    property MaterialStyleProvider materialStyle: MaterialStyleProvider {
        toastSpacing: root.toastSpacing
        collapsedToastOffset: root.collapsedOffset
        collapsedToastScaleStep: root.collapsedScaleStep
    }

    readonly property ToastifyStyleProvider currentStyle: {
        switch (root.styleIndex) {
        case 1:
            return root.darkStyle
        case 2:
            return root.compactStyle
        case 3:
            return root.materialStyle
        default:
            return root.defaultStyle
        }
    }

    function toastOptions() {
        return {
            position: root.position,
            autoClose: root.autoClose,
            closeOnClick: root.closeOnClick,
            closeButton: root.showCloseButton,
            hideProgressBar: !root.showProgressBar
        }
    }
}

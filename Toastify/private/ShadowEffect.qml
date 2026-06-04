import QtQuick
import QtQuick.Templates
import QtQuick.Effects
import QtQuick.Layouts

MultiEffect {
    z: -1

    property bool enabled: true
    property bool hovered: true
    property real shadowHorizontalOffset: 4
    property real shadowVerticalOffset:   4

    source: parent
    anchors.fill: parent

    shadowEnabled: enabled
    shadowColor: !enabled ? "transparent" : Qt.rgba(0, 0, 0, 0.3)
    shadowBlur: hovered ? 1.5 : 0.8

    property real __shadowHorizontalOffset: {
        if (hovered) {
            return shadowHorizontalOffset * 1.5  // %20 artır
        } else {
            return shadowHorizontalOffset
        }
    }
    
    property real __shadowVerticalOffset: {
        if (hovered) {
            return shadowVerticalOffset * 1.5
        } else {
            return shadowVerticalOffset
        }
    }
    
    Behavior on shadowColor {
        enabled: true
        ColorAnimation { duration: 200 }
    }
    
    Behavior on shadowBlur {
        enabled: true
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on __shadowHorizontalOffset {
        enabled: true
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on __shadowVerticalOffset {
        enabled: true
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}

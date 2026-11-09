import QtQuick

// Qt 6.8 has no RectangularShadow. Keep the same internal interface without
// loading an unavailable type or drawing an approximation.
Item {
    required property var shadowStyle
    required property real cornerRadius
    required property real blurRadius
}

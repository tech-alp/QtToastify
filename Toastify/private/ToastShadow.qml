pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects

Loader {
    id: root

    required property var shadowStyle
    required property real cornerRadius
    required property real blurRadius

    // Unknown is reported before scene graph initialization. Only instantiate
    // the shader effect once this item's window has a supported RHI backend.
    active: root.GraphicsInfo.api === GraphicsInfo.OpenGL
            || root.GraphicsInfo.api === GraphicsInfo.Direct3D11
            || root.GraphicsInfo.api === GraphicsInfo.Direct3D12
            || root.GraphicsInfo.api === GraphicsInfo.Vulkan
            || root.GraphicsInfo.api === GraphicsInfo.Metal

    sourceComponent: RectangularShadow {
        objectName: "nativeToastShadow"
        visible: opacity > 0
        color: root.shadowStyle.color
        opacity: root.shadowStyle.opacity
        radius: root.cornerRadius
        blur: root.blurRadius
        spread: root.shadowStyle.spread ?? 0
        offset: Qt.vector2d(root.shadowStyle.horizontalOffset,
                            root.shadowStyle.verticalOffset)
        cached: false
    }
}

// Generated from React-Toastify's warning.svg using Qt 6.11 svgtoqml -c -p.
// QtToastify customization: expose fill color and preserve the SVG aspect ratio.
import QtQuick
import QtQuick.VectorImage
import QtQuick.Shapes

Item {
    id: root

    implicitWidth: 24
    implicitHeight: 24

    property alias color: iconPath.fillColor
    readonly property real contentScale: Math.min(width / 24, height / 24)

    Shape {
        x: (root.width - 24 * root.contentScale) / 2
        y: (root.height - 24 * root.contentScale) / 2
        preferredRendererType: Shape.CurveRenderer
        transformOrigin: Item.TopLeft
        transform: Scale {
            xScale: root.contentScale
            yScale: root.contentScale
        }

        ShapePath {
            id: iconPath
            strokeColor: "transparent"
            fillColor: "#ffffffff"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles

            PathSvg { path: "M 23.32 17.191 L 15.438 2.184 Q 14.9054 1.17061 13.9832 0.585375 Q 13.0609 0 11.996 0 Q 10.931 0 10.0083 0.585375 Q 9.08552 1.17072 8.553 2.184 L 0.533 17.448 Q -0.599612 19.632 0.533 21.816 Q 1.06557 22.8294 1.98775 23.4146 Q 2.91015 24 3.975 24 L 20.025 24 Q 21.6712 24 22.8356 22.7205 Q 24 21.441 24 19.632 Q 24 18.292 23.32 17.192 L 23.32 17.191 M 13.698 18.651 Q 13.698 19.428 13.2142 19.9499 Q 12.7284 20.474 12 20.474 Q 11.2716 20.474 10.7858 19.95 Q 10.302 19.4283 10.302 18.652 L 10.302 18.609 Q 10.302 17.835 10.7858 17.3125 Q 11.2723 16.787 12 16.787 Q 12.7284 16.787 13.2142 17.311 Q 13.698 17.8327 13.698 18.609 L 13.698 18.652 L 13.698 18.651 M 13.737 6.366 L 12.897 14.426 Q 12.8544 14.8603 12.6105 15.1154 Q 12.368 15.369 12 15.369 Q 11.6323 15.369 11.3892 15.1136 Q 11.146 14.8581 11.104 14.427 L 10.264 6.362 Q 10.2207 5.88775 10.4338 5.5805 Q 10.6512 5.267 11.043 5.267 L 12.953 5.267 Q 13.3448 5.27071 13.564 5.58488 Q 13.7795 5.89373 13.737 6.367 L 13.737 6.366 " }
        }
    }
}

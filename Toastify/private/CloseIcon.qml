// Generated from React-Toastify's close icon using Qt 6.11 svgtoqml -c -p.
// QtToastify customization: expose fill color and preserve the SVG aspect ratio.
import QtQuick
import QtQuick.VectorImage
import QtQuick.Shapes

Item {
    id: root

    implicitWidth: 14
    implicitHeight: 16

    property alias color: iconPath.fillColor
    readonly property real contentScale: Math.min(width / 14, height / 16)

    Shape {
        x: (root.width - 14 * root.contentScale) / 2
        y: (root.height - 16 * root.contentScale) / 2
        preferredRendererType: Shape.CurveRenderer
        transformOrigin: Item.TopLeft
        transform: Scale {
            xScale: root.contentScale
            yScale: root.contentScale
        }

        ShapePath {
            id: iconPath
            strokeColor: "transparent"
            fillColor: "#ff000000"
            fillRule: ShapePath.OddEvenFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles

            PathSvg { path: "M 7.71 8.23 L 11.46 11.98 L 9.98 13.46 L 6.23 9.71 L 2.48 13.46 L 1 11.98 L 4.75 8.23 L 1 4.48 L 2.48 3 L 6.23 6.75 L 9.98 3 L 11.46 4.48 L 7.71 8.23 " }
        }
    }
}

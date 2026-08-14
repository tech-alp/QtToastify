// Generated from React-Toastify's error.svg using Qt 6.11 svgtoqml -c -p.
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

            PathSvg { path: "M 11.983 0 Q 6.97912 0.081919 3.473 3.653 Q -0.0815118 7.19187 0 12.207 Q -0.00581896 17.0963 3.45245 20.5525 Q 6.91072 24.0087 11.8 24 L 12.014 24 Q 17.0227 23.9485 20.5317 20.3741 Q 24.0408 16.7998 24 11.791 Q 24.0117 6.83554 20.4745 3.3649 Q 16.9373 -0.105727 11.983 0 M 10.5 16.542 Q 10.4772 15.9228 10.9033 15.4728 Q 11.3294 15.0229 11.949 15.012 L 11.976 15.012 Q 12.591 15.0132 13.0335 15.4403 Q 13.476 15.8674 13.499 16.482 Q 13.5222 17.1014 13.096 17.5515 Q 12.6698 18.0015 12.05 18.012 L 12.023 18.012 Q 11.4083 18.01 10.966 17.5831 Q 10.5237 17.1562 10.5 16.542 M 11 12.5 L 11 6.5 Q 11 6.08579 11.2929 5.79289 Q 11.5858 5.5 12 5.5 Q 12.4142 5.5 12.7071 5.79289 Q 13 6.08579 13 6.5 L 13 12.5 Q 13 12.9142 12.7071 13.2071 Q 12.4142 13.5 12 13.5 Q 11.5858 13.5 11.2929 13.2071 Q 11 12.9142 11 12.5 " }
        }
    }
}

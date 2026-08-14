// Generated from React-Toastify's success.svg using Qt 6.11 svgtoqml -c -p.
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

            PathSvg { path: "M 12 0 Q 7.02944 -3.04359e-16 3.51472 3.51472 Q 4.44089e-16 7.02944 0 12 Q -6.08718e-16 16.9706 3.51472 20.4853 Q 7.02944 24 12 24 Q 16.9706 24 20.4853 20.4853 Q 24 16.9706 24 12 Q 23.9942 7.03184 20.4812 3.51881 Q 16.9682 0.00578607 12 0 M 18.927 8.2 L 12.082 17.489 Q 11.8268 17.8276 11.4064 17.8829 Q 10.986 17.9381 10.652 17.677 L 5.764 13.769 Q 5.4405 13.5101 5.39481 13.0983 Q 5.34912 12.6865 5.608 12.363 Q 5.86688 12.0395 6.27869 11.9938 Q 6.6905 11.9481 7.014 12.207 L 11.09 15.468 L 17.317 7.017 Q 17.4701 6.78719 17.7195 6.66854 Q 17.9689 6.5499 18.2438 6.57604 Q 18.5187 6.60218 18.7413 6.7657 Q 18.9638 6.92922 19.0709 7.18377 Q 19.178 7.43832 19.1393 7.71176 Q 19.1006 7.98519 18.927 8.2 " }
        }
    }
}

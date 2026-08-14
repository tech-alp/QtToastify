// Generated from React-Toastify's info.svg using Qt 6.11 svgtoqml -c -p.
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

            PathSvg { path: "M 12 0 Q 7.02944 -3.04359e-16 3.51472 3.51472 Q 4.44089e-16 7.02944 0 12 Q -6.08718e-16 16.9706 3.51472 20.4853 Q 7.02944 24 12 24 Q 16.9706 24 20.4853 20.4853 Q 24 16.9706 24 12 Q 23.9946 7.03166 20.4815 3.51852 Q 16.9683 0.00537364 12 0 M 12.25 5 Q 12.8713 5 13.3107 5.43934 Q 13.75 5.87868 13.75 6.5 Q 13.75 7.12132 13.3107 7.56066 Q 12.8713 8 12.25 8 Q 11.6287 8 11.1893 7.56066 Q 10.75 7.12132 10.75 6.5 Q 10.75 5.87868 11.1893 5.43934 Q 11.6287 5 12.25 5 M 14.5 18.5 L 10.5 18.5 Q 10.0858 18.5 9.79289 18.2071 Q 9.5 17.9142 9.5 17.5 Q 9.5 17.0858 9.79289 16.7929 Q 10.0858 16.5 10.5 16.5 L 11.25 16.5 Q 11.3536 16.5 11.4268 16.4268 Q 11.5 16.3536 11.5 16.25 L 11.5 11.75 Q 11.5 11.6464 11.4268 11.5732 Q 11.3536 11.5 11.25 11.5 L 10.5 11.5 Q 10.0858 11.5 9.79289 11.2071 Q 9.5 10.9142 9.5 10.5 Q 9.5 10.0858 9.79289 9.79289 Q 10.0858 9.5 10.5 9.5 L 11.5 9.5 Q 12.3284 9.5 12.9142 10.0858 Q 13.5 10.6716 13.5 11.5 L 13.5 16.25 Q 13.5 16.3536 13.5732 16.4268 Q 13.6464 16.5 13.75 16.5 L 14.5 16.5 Q 14.9142 16.5 15.2071 16.7929 Q 15.5 17.0858 15.5 17.5 Q 15.5 17.9142 15.2071 18.2071 Q 14.9142 18.5 14.5 18.5 " }
        }
    }
}

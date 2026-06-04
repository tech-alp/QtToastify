import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    property color color: "white"   // Image color

    property alias asynchronous:        image.asynchronous
    property alias cache:               image.cache
    property alias fillMode:            image.fillMode
    property alias horizontalAlignment: image.horizontalAlignment
    property alias mirror:              image.mirror
    property alias paintedHeight:       image.paintedHeight
    property alias paintedWidth:        image.paintedWidth
    property alias progress:            image.progress
    property alias mipmap:              image.mipmap
    property alias source:              image.source
    property alias sourceSize:          image.sourceSize
    property alias status:              image.status
    property alias verticalAlignment:   image.verticalAlignment

    width:  image.implicitWidth
    height: image.implicitHeight

    Image {
        id:                 image
        smooth:             true
        mipmap:             true
        antialiasing:       true
        visible:            false
        fillMode:           Image.PreserveAspectFit
        anchors.fill:       parent
    }

    MultiEffect {
        anchors.fill:       image
        source:             image
        colorization:       1.0
        colorizationColor:  parent.color
    }
}

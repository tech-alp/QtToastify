import QtQuick

Item {
    id: root

    objectName: "playgroundFonts"
    width: 0
    height: 0
    visible: false

    readonly property bool ready:
        montserratLoader.status === FontLoader.Ready
        && robotoLoader.status === FontLoader.Ready
        && robotoCondensedLoader.status === FontLoader.Ready
    readonly property bool hasError:
        montserratLoader.status === FontLoader.Error
        || robotoLoader.status === FontLoader.Error
        || robotoCondensedLoader.status === FontLoader.Error

    readonly property string montserratFamily:
        montserratLoader.status === FontLoader.Ready
        ? montserratLoader.name : "Montserrat"
    readonly property string robotoFamily:
        robotoLoader.status === FontLoader.Ready
        ? robotoLoader.name : "Roboto"
    readonly property string robotoCondensedFamily:
        robotoCondensedLoader.status === FontLoader.Ready
        ? robotoCondensedLoader.name : "Roboto Condensed"

    function verify(loader, expectedFamily) {
        if (loader.status === FontLoader.Error) {
            console.warn("Playground font could not be loaded:", expectedFamily)
        } else if (loader.status === FontLoader.Ready
                   && loader.name !== expectedFamily) {
            console.warn("Playground font family mismatch:", expectedFamily,
                         "loaded as", loader.name)
        }
    }

    FontLoader {
        id: montserratLoader
        objectName: "montserratFontLoader"
        source: Qt.resolvedUrl("fonts/Montserrat.ttf")
        onStatusChanged: root.verify(montserratLoader, "Montserrat")
    }

    FontLoader {
        id: robotoLoader
        objectName: "robotoFontLoader"
        source: Qt.resolvedUrl("fonts/Roboto.ttf")
        onStatusChanged: root.verify(robotoLoader, "Roboto")
    }

    FontLoader {
        id: robotoCondensedLoader
        objectName: "robotoCondensedFontLoader"
        source: Qt.resolvedUrl("fonts/RobotoCondensed.ttf")
        onStatusChanged: root.verify(robotoCondensedLoader,
                                     "Roboto Condensed")
    }
}

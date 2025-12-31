import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import Toastify 1.0
import Toastify.Style 1.0
import PlaygroundExamples 1.0

ApplicationWindow {
    id: window
    width: 900
    height: 700
    visible: true
    title: "QtToastify Playground - Style Showcase"
    
    Material.theme: Material.Light
    Material.accent: Material.Indigo

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPage
    }

    PlaygorundMainPage {
        id: mainPage
    }

}

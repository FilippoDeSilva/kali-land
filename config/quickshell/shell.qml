import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1920
    height: 1080
    
    Text {
        anchors.centerIn: parent
        text: "Quickshell - Hello World"
        font.pixelSize: 24
    }
}

import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    // Simple bar using Quickshell framework
    PanelWindow {
        id: bar
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 40
        
        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            
            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 20
                
                // Workspace indicator
                Text {
                    text: "WS 1"
                    color: "#cdd6f4"
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                }
                
                Item { width: 1 } // Spacer
                
                // Clock
                Text {
                    text: Qt.formatDateTime(new Date(), "HH:mm")
                    color: "#cdd6f4"
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
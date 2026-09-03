import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    visible: true
    width: 1920
    height: 1080
    color: "transparent" // Let Hyprland background show through
    
    // Top Bar
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 30
        color: "#1e1e2e"
        z: 100 // Ensure it's on top
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 10
            
            // Left side - Workspace info
            Text {
                text: "WS 1"
                color: "#cdd6f4"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignLeft
            }
            
            Item { Layout.fillWidth: true } // Spacer
            
            // Right side - Time
            Text {
                text: Qt.formatDateTime(new Date(), "HH:mm")
                color: "#cdd6f4"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignRight
            }
        }
    }
    
    // Center text for now
    Text {
        anchors.centerIn: parent
        text: "Kali Omarchy Desktop"
        color: "#cdd6f4"
        font.pixelSize: 24
        z: 50
    }
}
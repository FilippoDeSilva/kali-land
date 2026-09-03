import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme" as Theme

Rectangle {
    id: root
    color: Theme.Colors.background
    height: 40
    
    property var launcherOverlay: null
    property var controlCenterOverlay: null
    
    RowLayout {
        id: layout
        anchors {
            fill: parent
            margins: 8
        }
        spacing: 16
        
        // Launcher button
        Button {
            id: launcherBtn
            text: "≡"
            font.pixelSize: 20
            background: Rectangle {
                color: launcherBtn.hovered ? Theme.Colors.surfaceElevated : "transparent"
                radius: 6
            }
            contentItem: Text {
                text: launcherBtn.text
                color: Theme.Colors.foreground
                font.pixelSize: launcherBtn.font.pixelSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                if (root.launcherOverlay) {
                    root.launcherOverlay.visible = !root.launcherOverlay.visible;
                }
            }
        }
        
        // Simple workspace indicator (placeholder)
        Text {
            text: "WS: " + activeWorkspace
            color: Theme.Colors.muted
            font.pixelSize: 14
        }
        
        Item { Layout.fillWidth: true } // Spacer
        
        // System tray
        Row {
            id: systemTray
            spacing: 12
            
            // Network status
            Button {
                id: networkBtn
                text: "🌐"
                font.pixelSize: 16
                background: Rectangle {
                    color: networkBtn.hovered ? Theme.Colors.surfaceElevated : "transparent"
                    radius: 6
                }
                onClicked: {
                    if (root.controlCenterOverlay) {
                        root.controlCenterOverlay.visible = !root.controlCenterOverlay.visible;
                    }
                }
            }
            
            // Volume
            Button {
                id: volumeBtn
                text: "🔊"
                font.pixelSize: 16
                background: Rectangle {
                    color: volumeBtn.hovered ? Theme.Colors.surfaceElevated : "transparent"
                    radius: 6
                }
                onClicked: {
                    if (root.controlCenterOverlay) {
                        root.controlCenterOverlay.visible = !root.controlCenterOverlay.visible;
                    }
                }
            }
            
            // Battery
            Button {
                id: batteryBtn
                text: "🔋"
                font.pixelSize: 16
                background: Rectangle {
                    color: batteryBtn.hovered ? Theme.Colors.surfaceElevated : "transparent"
                    radius: 6
                }
                onClicked: {
                    if (root.controlCenterOverlay) {
                        root.controlCenterOverlay.visible = !root.controlCenterOverlay.visible;
                    }
                }
            }
            
            // Clock
            Text {
                id: clock
                text: Qt.formatDateTime(new Date(), "HH:mm")
                color: Theme.Colors.foreground
                font.pixelSize: 14
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
                }
            }
        }
    }
    
    property int activeWorkspace: 1
}
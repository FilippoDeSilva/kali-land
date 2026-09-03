import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme" as Theme

Rectangle {
    id: root
    color: "transparent"
    
    // Semi-transparent background
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.5
    }
    
    // Control center box
    Rectangle {
        id: controlBox
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 50
            rightMargin: 20
        }
        width: 350
        height: 400
        color: Theme.Colors.background
        radius: 12
        border.color: Theme.Colors.border
        border.width: 1
        
        ColumnLayout {
            anchors {
                fill: parent
                margins: 20
            }
            spacing: 16
            
            // Header
            Text {
                text: "Control Center"
                color: Theme.Colors.foreground
                font.pixelSize: 18
                font.bold: true
            }
            
            // Volume control
            Column {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: "Volume"
                    color: Theme.Colors.muted
                    font.pixelSize: 14
                }
                Row {
                    spacing: 12
                    Button {
                        text: "🔇"
                        background: Rectangle {
                            color: hovered ? Theme.Colors.surfaceElevated : "transparent"
                            radius: 6
                        }
                    }
                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: 50
                    }
                    Button {
                        text: "🔊"
                        background: Rectangle {
                            color: hovered ? Theme.Colors.surfaceElevated : "transparent"
                            radius: 6
                        }
                    }
                }
            }
            
            // Brightness control
            Column {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: "Brightness"
                    color: Theme.Colors.muted
                    font.pixelSize: 14
                }
                Row {
                    spacing: 12
                    Button {
                        text: "🔅"
                        background: Rectangle {
                            color: hovered ? Theme.Colors.surfaceElevated : "transparent"
                            radius: 6
                        }
                    }
                    Slider {
                        id: brightnessSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: 75
                    }
                    Button {
                        text: "🔆"
                        background: Rectangle {
                            color: hovered ? Theme.Colors.surfaceElevated : "transparent"
                            radius: 6
                        }
                    }
                }
            }
            
            // Network toggle
            Button {
                Layout.fillWidth: true
                text: "🌐 Wi-Fi: Connected"
                background: Rectangle {
                    color: Theme.Colors.surface
                    radius: 8
                    border.color: Theme.Colors.border
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: Theme.Colors.foreground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            // Bluetooth toggle
            Button {
                Layout.fillWidth: true
                text: "📡 Bluetooth: Off"
                background: Rectangle {
                    color: Theme.Colors.surface
                    radius: 8
                    border.color: Theme.Colors.border
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: Theme.Colors.foreground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Item { Layout.fillHeight: true } // Spacer
            
            // Power menu
            Row {
                Layout.fillWidth: true
                spacing: 8
                Button {
                    Layout.fillWidth: true
                    text: "🔒"
                    background: Rectangle {
                        color: Theme.Colors.surface
                        radius: 8
                        border.color: Theme.Colors.border
                        border.width: 1
                    }
                    onClicked: {
                        // TODO: Lock screen
                        console.log("Lock screen")
                    }
                }
                Button {
                    Layout.fillWidth: true
                    text: "⏻"
                    background: Rectangle {
                        color: Theme.Colors.surface
                        radius: 8
                        border.color: Theme.Colors.border
                        border.width: 1
                    }
                    onClicked: {
                        // TODO: Show power menu
                        console.log("Power menu")
                    }
                }
            }
        }
    }
    
    // Close on escape
    Keys.onEscapePressed: root.visible = false
    
    // Close when clicking outside
    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }
}
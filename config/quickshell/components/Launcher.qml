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
    
    // Launcher box
    Rectangle {
        id: launcherBox
        anchors.centerIn: parent
        width: 600
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
            
            // Search input
            TextField {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "Search applications..."
                background: Rectangle {
                    color: Theme.Colors.surface
                    radius: 8
                    border.color: searchInput.activeFocus ? Theme.Colors.accent : Theme.Colors.border
                    border.width: searchInput.activeFocus ? 2 : 1
                }
                color: Theme.Colors.foreground
                font.pixelSize: 16
                focus: true
                onAccepted: {
                    // TODO: Launch application
                    console.log("Launch:", text)
                    root.visible = false
                }
            }
            
            // Application list
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ListModel {
                    ListElement { name: "Firefox"; icon: "🌐"; command: "firefox-esr" }
                    ListElement { name: "Terminal"; icon: "🖥️"; command: "kitty" }
                    ListElement { name: "File Manager"; icon: "📁"; command: "thunar" }
                    ListElement { name: "Geany"; icon: "📝"; command: "geany" }
                }
                delegate: ItemDelegate {
                    width: appList.width
                    height: 50
                    background: Rectangle {
                        color: hovered ? Theme.Colors.surfaceElevated : "transparent"
                        radius: 6
                    }
                    contentItem: RowLayout {
                        spacing: 12
                        Text {
                            text: icon
                            font.pixelSize: 24
                        }
                        Text {
                            text: name
                            color: Theme.Colors.foreground
                            font.pixelSize: 16
                            Layout.fillWidth: true
                        }
                    }
                    onClicked: {
                        // TODO: Launch application
                        console.log("Launch:", command)
                        root.visible = false
                    }
                }
                clip: true
            }
        }
        
        // Close on escape
        Keys.onEscapePressed: root.visible = false
    }
    
    // Close when clicking outside
    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }
}
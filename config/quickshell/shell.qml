import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1920
    height: 1080
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    
    // Launcher overlay (hidden by default)
    Launcher {
        id: launcher
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        visible: false
    }
    
    // Control center overlay (hidden by default)
    ControlCenter {
        id: controlCenter
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        visible: false
    }
    
    // Top bar
    TopBar {
        id: topBar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 40
        launcherOverlay: launcher
        controlCenterOverlay: controlCenter
    }
    
    // Global shortcuts
    Shortcut {
        sequence: "Meta+Space"
        onActivated: launcher.visible = !launcher.visible
    }
    
    Shortcut {
        sequence: "Meta+Escape"
        onActivated: controlCenter.visible = !controlCenter.visible
    }
}
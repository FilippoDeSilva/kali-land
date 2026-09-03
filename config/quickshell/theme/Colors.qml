pragma Singleton
import QtQuick

QtObject {
    // Background colors
    readonly property color background: "#1e1e2e"
    readonly property color surface: "#313244"
    readonly property color surfaceElevated: "#45475a"
    
    // Foreground colors
    readonly property color foreground: "#cdd6f4"
    readonly property color muted: "#a6adc8"
    
    // Accent colors
    readonly property color accent: "#89b4fa"
    readonly property color accentHover: "#b4befe"
    
    // Status colors
    readonly property color success: "#a6e3a1"
    readonly property color warning: "#f9e2af"
    readonly property color danger: "#f38ba8"
    
    // Border colors
    readonly property color border: "#45475a"
    readonly property color borderFocus: "#89b4fa"
}
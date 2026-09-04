# Quickshell Architecture

## Overview

Quickshell serves as the desktop shell in the kali-land environment. It provides the user-facing UI components while Hyprland handles window management.

## Current Implementation

The current Quickshell configuration uses a simple, monolithic `shell.qml` file that includes the top bar with workspace indicator and clock. This approach was chosen because:

1. **Quickshell qmldir limitations**: Quickshell has limited support for complex qmldir-based module loading
2. **Simplicity**: A single file is easier to debug and maintain for the initial implementation
3. **Reliability**: Eliminates module loading issues that can occur with complex qmldir setups

### Current Structure

```
config/quickshell/
├── shell.qml                 # Main entry point with inline components
├── qmldir                    # QML module registration (currently minimal)
└── Colors.qml                # Global color theme (singleton)
```

### shell.qml

The main entry point that contains:

- **Top Bar**: Displays workspace indicator and clock
- **Center Text**: Placeholder "kali-land Desktop" text
- **Color Theme**: Uses inline colors (can be migrated to Colors.qml later)

**Key Properties:**
- `implicitWidth`, `implicitHeight`: Modern QML sizing
- `visible`: Controls window visibility
- `color`: Background color (transparent to let Hyprland show through)

## Design Philosophy

While the current implementation is monolithic, the design principles remain:

- **Configurable**: Easy to modify behavior by editing properties
- **Maintainable**: Clear structure with commented sections
- **Scalable**: Can be refactored into modular components when Quickshell matures
- **Themeable**: Colors can be centralized when needed

## Future Modular Architecture

When Quickshell's qmldir support improves, the configuration can be refactored into:

```
config/quickshell/
├── shell.qml                 # Main entry point
├── qmldir                    # QML module registration
├── Colors.qml                # Global color theme (singleton)
└── components/
    └── bar/
        ├── TopBarConfig.qml  # Bar configuration object
        ├── WorkspaceIndicator.qml  # Workspace display component
        └── Clock.qml         # Time display component
```

### Planned Component Structure

#### 1. TopBarConfig.qml

Central configuration for the top bar:

```qml
QtObject {
    readonly property int barHeight: 30
    readonly property string backgroundColor: "#1e1e2e"
    readonly property string textColor: "#cdd6f4"
    readonly property string accentColor: "#89b4fa"
    
    property bool showWorkspace: true
    property bool showClock: true
    property bool showSystemInfo: true
}
```

#### 2. WorkspaceIndicator.qml

Displays the current workspace number with optional name.

#### 3. Clock.qml

Displays current time with configurable format and optional date.

## qmldir Module Registration

The `qmldir` file registers components for import in other QML files.

**Current Registration:**
```
singleton Colors 1.0 Colors.qml
```

**Future Registration (when modular):**
```
singleton Colors 1.0 Colors.qml
TopBarConfig 1.0 components/bar/TopBarConfig.qml
WorkspaceIndicator 1.0 components/bar/WorkspaceIndicator.qml
Clock 1.0 components/bar/Clock.qml
```

## Component Communication

### Current: Inline

Components communicate via direct property binding within the same file:

```qml
Text {
    text: "WS 1"
    color: "#cdd6f4"
}
```

### Future: Parent-Child

When modularized, components will communicate via property binding:

```qml
// Parent (shell.qml)
WorkspaceIndicator {
    workspaceNumber: "1"
    visible: barConfig.showWorkspace
}

// Child (WorkspaceIndicator.qml)
Text {
    text: "WS " + root.workspaceNumber
}
```

## Adding New Features

### Current Approach

Add features directly to `shell.qml`:

```qml
// Add new section to the bar
Text {
    text: "New Feature"
    color: "#cdd6f4"
}
```

### Future Modular Approach

When Quickshell matures:

1. Create component file in `components/`
2. Register in `qmldir`
3. Import and use in `shell.qml`

## Future Extensions

### Planned Components

1. **Launcher** - Application search and command execution
2. **Control Center** - Network, volume, brightness, battery controls
3. **Power Menu** - Lock, logout, suspend, reboot, shutdown
4. **Notification Popup** - Toast notifications and history
5. **Window Switcher** - Alt-tab window list with thumbnails

### Services Layer

Future architecture will include a services layer for system integration:

```
services/
├── HyprlandService.qml   # Hyprland IPC
├── AudioService.qml      # PulseAudio/PipeWire
├── NetworkService.qml    # NetworkManager
└── BatteryService.qml    # UPower
```

## Testing

### Manual Testing

1. Start Quickshell: `quickshell --config ~/.config/quickshell`
2. Check logs: `/run/user/1000/quickshell/by-id/*/log.qslog`
3. Verify bar visibility
4. Test features

### Common Issues

**Configuration not loading:**
- Check syntax in shell.qml
- Verify all imports are valid
- Check log file for specific errors

**Module loading errors:**
- qmldir path issues (not currently used)
- Component registration errors (not currently used)

**Deprecated warnings:**
- Use `implicitWidth`/`implicitHeight` instead of `width`/`height`
- Check QML version compatibility

## Best Practices

1. **Keep it simple** - Monolithic is fine for now
2. **Use comments** - Document each section clearly
3. **Centralize colors** - When migrating to Colors.qml
4. **Test incrementally** - Verify each change
5. **Follow naming conventions** - PascalCase for types, camelCase for properties
6. **Document changes** - Update this file when structure changes

## Migration to Modular Architecture

When Quickshell's qmldir support improves:

1. Create component files in `components/`
2. Update `qmldir` registration
3. Refactor `shell.qml` to use components
4. Test each component independently
5. Update documentation

## References

- [Quickshell Documentation](https://github.com/outfoxxed/quickshell)
- [QML Documentation](https://doc.qt.io/qt-6/qmlapplications.html)
- [Qt Quick Controls](https://doc.qt.io/qt-6/qtquickcontrols-index.html)

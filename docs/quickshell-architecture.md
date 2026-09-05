# Quickshell Architecture in kali-land

## Overview

Quickshell serves as the graphical desktop shell runtime layer in `kali-land`. It provides user-facing UI components (bars, panels, launchers, control centers, widgets) while Hyprland handles window management.

> **"kali-land owns the environment; the user owns the experience."**

`kali-land` strictly distinguishes between:
```text
Quickshell Runtime (Platform)  ≠  Quickshell Shell Configuration (Experience)
```

## Bring Your Own Shell (BYOS)

`kali-land` adopts a **Bring Your Own Shell (BYOS)** model. The platform provides a stable runtime, capability detection, service integration, and safety/rollback mechanisms, while allowing users to select or bring their preferred Quickshell shell.

Users may run:
1. **`end4-pC` (Primary Reference Integration)**: Material 3 Quickshell desktop shell.
2. **Custom / User Shells**: Personal or third-party Quickshell configurations.
3. **Future Shells**: Additional community or official integrations.

## Reference Shell Integration (`end4-pC`)

The project uses `end4-pC` as its primary reference integration proof-of-concept.

### end4-pC Structure

```text
integrations/end4-pC/
├── shell.qml                    # Main entry point
├── panelFamilies/               # Panel configurations
├── modules/                     # UI modules (vertical bar, launcher, sidebars)
├── services/                    # Backend Qt/QML service bridges
├── assets/                      # Icons, fonts, visual assets
├── defaults/                    # Default configurations
├── scripts/                     # Helper scripts
└── translations/                # i18n support
```

### Integration Guidelines

When integrating or adapting a reference shell in `kali-land`:
- **Respect Upstream Provenance**: Maintain upstream attribution and architecture.
- **Isolate Platform Adaptations**: Keep `kali-land`-specific bridges modular.
- **Capability Degradation**: Missing optional capabilities (e.g. Bluetooth, battery on desktops) must degrade gracefully without crashing the shell.

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

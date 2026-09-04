# Lua Configuration Guide

This document explains the Hyprland Lua configuration system used in this project.

## Overview

This project uses Hyprland's Lua configuration API (introduced in Hyprland 0.56.x) instead of the traditional `.conf` format. The Lua configuration provides:

- **Modularity**: Configuration split into logical modules
- **Programmability**: Conditional logic and dynamic configuration
- **Type Safety**: Better error detection through Lua syntax
- **Modern API**: Uses the latest Hyprland configuration interface

## Configuration Structure

The Lua configuration is organized as follows:

```
~/.config/hypr/
├── hyprland.lua      # Main entry point
├── config.lua        # Core Hyprland settings
├── environment.lua   # Environment variables
├── monitors.lua      # Display/monitor configuration
├── keybinds.lua      # Keyboard shortcuts
├── rules.lua         # Window rules
├── autostart.lua     # Startup applications
├── vmware.lua        # VMware-specific optimizations
└── minimal.lua       # Minimal fallback configuration
```

## Module Responsibilities

### hyprland.lua (Entry Point)

The main entry point that requires all other modules:

```lua
-- Main Hyprland Lua configuration
-- kali-land - Modern Desktop Environment
-- This is the main entry point that requires all other modules

-- Core configuration modules
require("config")
require("environment")
require("monitors")
require("keybinds")
require("rules")
require("autostart")

-- VMware-specific configuration
require("vmware")
```

### config.lua (Core Settings)

Contains core Hyprland configuration:

- Gaps and borders
- Colors and theming
- Decorations (rounding, shadows, blur)
- Animations and curves

### environment.lua (Environment Variables)

Sets environment variables for:

- Cursor theme and size
- Default applications
- GTK theme
- Qt theme
- Input method
- Language settings

### monitors.lua (Display Configuration)

Configures:

- Monitor detection
- Resolution
- Position
- Scaling
- Refresh rate

### keybinds.lua (Keyboard Shortcuts)

Defines all keybindings for:

- Window management
- Workspace navigation
- Application launching
- System controls
- Media controls

### rules.lua (Window Rules)

Defines window behavior rules:

- Floating behavior
- Size constraints
- Workspace assignment
- Initial position
- Special properties

### autostart.lua (Startup Applications)

Lists applications to start automatically:

- System services
- Desktop shell (Quickshell)
- Notification daemon
- Clipboard manager
- Idle manager

### vmware.lua (VMware Optimizations)

VMware-specific settings:

- Graphics settings
- Input handling
- Performance optimizations

## API Reference

The configuration uses the Hyprland Lua API:

### hl.config({ ... })

Set core Hyprland configuration:

```lua
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
    },
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 3,
        },
    },
})
```

### hl.env("NAME", "value")

Set environment variables:

```lua
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
```

### hl.monitor({ ... })

Configure monitors:

```lua
hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})
```

### hl.bind(modifier, key, function)

Define keybindings:

```lua
hl.bind("SUPER", "return", function()
    hl.exec("kitty")
end)
```

### hl.window_rule({ ... })

Define window rules:

```lua
hl.window_rule({
    name = "float-terminals",
    match = { class = "kitty" },
    float = true,
    size = { width = 800, height = 600 },
})
```

### hl.exec_cmd("command")

Execute a command:

```lua
hl.exec_cmd("kitty")
```

### hl.on(event, function)

Hook into Hyprland events:

```lua
hl.on("workspace", function()
    -- Handle workspace change
end)
```

### hl.curve(name, { ... })

Define custom animation curves:

```lua
hl.curve("easeOutQuint", {
    type = "bezier",
    points = { {0.23, 1}, {0.32, 1} }
})
```

### hl.animation({ ... })

Define animations:

```lua
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4.79,
    spring = "easy"
})
```

## Migration from .conf to .lua

If you're migrating from the traditional `.conf` format:

### Before (.conf)
```conf
general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
}
```

### After (.lua)
```lua
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
    },
})
```

## Validation

Validate your Lua configuration before starting Hyprland:

```bash
bash scripts/validate-lua-config.sh
```

This checks:
- All required modules are present
- No conflicting `.conf` files
- Module structure is correct
- Entry point requires all modules

## Testing

Test the configuration in a live session:

```bash
bash scripts/test-hyprland.sh
```

This will:
- Backup your current configuration
- Deploy the test configuration
- Start Hyprland safely
- Allow you to return to your current session if something goes wrong

## Troubleshooting

### Hyprland Won't Start

1. Check the log:
   ```bash
   cat ~/.local/share/hyprland/hyprland.log
   ```

2. Validate configuration:
   ```bash
   bash scripts/validate-lua-config.sh
   ```

3. Test with minimal config:
   ```bash
   cp ~/.config/hypr/minimal.lua ~/.config/hypr/hyprland.lua
   Hyprland
   ```

### Module Not Found

Ensure:
- The module file exists in `~/.config/hypr/`
- The `require()` statement matches the filename exactly
- The filename uses lowercase letters and hyphens/underscores

### Syntax Errors

Check for:
- Balanced parentheses and brackets
- Balanced quotes
- Correct comma usage in tables
- Proper function syntax

## Version Compatibility

This configuration is designed for Hyprland 0.56.2. If you're using a different version:

1. Check the Hyprland wiki for version-specific API changes:
   https://wiki.hypr.land/

2. Use the version selector to find documentation for your version:
   https://wiki.hypr.land/version-selector/

3. Test configuration changes with the `validate-lua-config.sh` script

## Further Reading

- [Hyprland Wiki](https://wiki.hypr.land/)
- [Hyprland Lua Example](https://github.com/hyprwm/Hyprland/blob/v0.56.2/example/hyprland.lua)
- [Installation Guide](installation.md)
- [Troubleshooting Guide](troubleshooting.md)

# Keybindings

This document describes the keybinding scheme for the Kali Omarchy Desktop.

## Philosophy

The keybinding system follows these principles:

- **Super modifier** as primary modifier
- **Predictable patterns** for similar actions
- **Minimal conflicts** with terminal and browser shortcuts
- **Keyboard-first** workflow
- **Discoverable** and consistent

## Primary Keybindings

### Window Management

| Keybinding | Action |
|------------|--------|
| `Super + Enter` | Open terminal |
| `Super + Q` | Close window |
| `Super + F` | Toggle fullscreen |
| `Super + V` | Toggle floating |
| `Super + Space` | Open launcher |
| `Super + Escape` | Open control center |
| `Super + L` | Lock screen |

### Navigation

| Keybinding | Action |
|------------|--------|
| `Super + H` | Focus left |
| `Super + J` | Focus down |
| `Super + K` | Focus up |
| `Super + L` | Focus right |
| `Super + Shift + H` | Move window left |
| `Super + Shift + J` | Move window down |
| `Super + Shift + K` | Move window up |
| `Super + Shift + L` | Move window right |

### Workspaces

| Keybinding | Action |
|------------|--------|
| `Super + 1` | Switch to workspace 1 |
| `Super + 2` | Switch to workspace 2 |
| `Super + 3` | Switch to workspace 3 |
| `Super + 4` | Switch to workspace 4 |
| `Super + 5` | Switch to workspace 5 |
| `Super + 6` | Switch to workspace 6 |
| `Super + 7` | Switch to workspace 7 |
| `Super + 8` | Switch to workspace 8 |
| `Super + 9` | Switch to workspace 9 |
| `Super + 0` | Switch to workspace 10 |
| `Super + Shift + 1` | Move window to workspace 1 |
| `Super + Shift + 2` | Move window to workspace 2 |
| `Super + Shift + 3` | Move window to workspace 3 |
| `Super + Shift + 4` | Move window to workspace 4 |
| `Super + Shift + 5` | Move window to workspace 5 |
| `Super + Shift + 6` | Move window to workspace 6 |
| `Super + Shift + 7` | Move window to workspace 7 |
| `Super + Shift + 8` | Move window to workspace 8 |
| `Super + Shift + 9` | Move window to workspace 9 |
| `Super + Shift + 0` | Move window to workspace 10 |

### System

| Keybinding | Action |
|------------|--------|
| `Super + Shift + Escape` | Open power menu |
| `Super + Print` | Screenshot |
| `Super + Shift + Print` | Screenshot region |
| `Super + Ctrl + Print` | Screenshot window |
| `Super + M` | Toggle mute |
| `Super + Volume Up` | Volume up |
| `Super + Volume Down` | Volume down |

## Hyprland Configuration

Keybindings are configured in `config/hypr/keybinds.conf`:

```conf
# Terminal
bind = SUPER, Return, exec, kitty

# Launcher
bind = SUPER, Space, exec, quickshell launcher

# Close window
bind = SUPER, Q, killactive,

# Fullscreen
bind = SUPER, F, fullscreen,

# Toggle floating
bind = SUPER, V, togglegroup,

# Focus movement
bind = SUPER, H, movefocus, l
bind = SUPER, J, movefocus, d
bind = SUPER, K, movefocus, u
bind = SUPER, L, movefocus, r

# Window movement
bind = SUPER SHIFT, H, movewindow, l
bind = SUPER SHIFT, J, movewindow, d
bind = SUPER SHIFT, K, movewindow, u
bind = SUPER SHIFT, L, movewindow, r

# Workspaces
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
# ... etc

# Move to workspace
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
# ... etc
```

## Quickshell Integration

Quickshell components respond to these keybindings:

- **Launcher**: `Super + Space`
- **Control Center**: `Super + Escape`
- **Power Menu**: `Super + Shift + Escape`

## Customization

To customize keybindings:

1. Edit `config/hypr/keybinds.conf`
2. Reload Hyprland: `Super + Shift + R` or `hyprctl reload`
3. Test your changes

## Conflicts

Avoid conflicts with:

- Terminal applications (kitty, foot)
- Browser shortcuts (Firefox, Chromium)
- Accessibility shortcuts
- Kali security tools

If you experience conflicts, check the application's keybinding settings and adjust accordingly.

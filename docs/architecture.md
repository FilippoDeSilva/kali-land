# Architecture

This document describes the architecture of the kali-land Desktop.

## Stack

- **OS**: Kali Linux (Debian-based)
- **Display**: Wayland
- **Compositor**: Hyprland
- **Desktop Shell**: Quickshell

## Components

### Compositor Layer (Hyprland)
- Window management
- Workspaces
- Input handling
- Monitor configuration
- Animations

### Desktop Shell Layer (Quickshell)
- Top bar
- Application launcher
- Control center
- Power menu
- Notifications

### Services Layer
- Audio (PipeWire/PulseAudio)
- Network (NetworkManager)
- Bluetooth (BlueZ)
- Notifications (dunst)
- Clipboard (cliphist)
- Idle management (swayidle)
- Lock screen (swaylock)

## Configuration Management

Repository-first approach:
- Repository contains source configuration
- Installation symlinks/copies to ~/.config
- Backups created before modifications
- Rollback supported
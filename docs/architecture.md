# Architecture of kali-land

## Overview

`kali-land` provides a modular, reproducible desktop runtime platform for Kali Linux.

> **"kali-land owns the environment; the user owns the experience."**

The architecture separates the underlying **Platform** (runtime, compositor, desktop services, capability detection, safety) from the **Experience** (user-selected Quickshell UI configuration, visual theme, and workflows).

## Conceptual Model

```text
                         KALI-LAND
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
     Runtime             Services            Shell Layer
        │                   │                   │
   Wayland              PipeWire             Quickshell
   Hyprland             NetworkManager           │
   XWayland             Portals                   ├── end4-pC (reference)
   IPC                  Notifications              ├── Custom User Shells
                        Polkit                    └── Future Shells
                        Clipboard
```

## Architectural Boundaries

### 1. Platform Layer (kali-land-owned)

- **OS Base**: Kali Linux (Debian rolling, `apt`, `dpkg`, `systemd`).
- **Display & Compositor**: Wayland session protocol, Hyprland tiling window manager, window rules, workspaces, and window IPC.
- **Desktop Services**:
  - Audio: PipeWire / WirePlumber
  - Networking: NetworkManager (`nmcli`)
  - Portals: XDG desktop portals (`xdg-desktop-portal-hyprland`)
  - Polkit: PolicyKit authentication agent
  - Clipboard: `cliphist` + `wl-clipboard`
  - Notifications: `libnotify` / desktop notification daemons
- **Platform Infrastructure**:
  - Capability detection (`wayland`, `hyprland`, `quickshell`, `pipewire`, `networkmanager`, etc.)
  - Hardware & VM Profiles (`systemd-detect-virt` profile management for VMware and bare-metal)
  - Safety & State: Timestamped backups stored in `~/.local/state/kali-land/backups/`
  - Diagnostics: `./bootstrap/doctor.sh` health inspection tool.

### 2. Experience Layer (User-owned)

- **Quickshell Integrations**: Supports a **Bring Your Own Shell (BYOS)** model. `end4-pC` is integrated as the primary reference proof-of-concept shell.
- **User Customization**: Custom bars, launchers, themes, keyboard workflows, and application selections.

## Configuration Ownership

```text
Platform Configuration:
  repository source of truth → ~/.config/hypr/, ~/.config/foot/

User Shell Configuration:
  ~/.config/quickshell/<shell>/ (Namespaced)
```

- System files are only modified when strictly necessary.
- Before modifying any user configuration, `kali-land` executes `detect → backup → change → validate`.
- Backups are stored in `~/.local/state/kali-land/backups/<timestamp>/` and can be restored offline.
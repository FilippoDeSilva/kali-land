# Architecture of kali-land

## Overview

`kali-land` provides a minimal, composable desktop foundation for Kali Linux.

> **"Kali-land owns the plumbing, not the personality."**  
> **"Kali-land provides the floor, not the furniture."**  
> **"Kali-land owns the environment; the user owns the experience."**

The architecture separates the **Platform Foundation** (runtime, compositor, desktop services, capability engine, resource ownership ledger) from the **Experience Layer** (user-selected shell, themes, dotfiles, and application choices).

## Conceptual Model

```text
                         USER LAND
┌─────────────────────────────────────────────────────┐
│  User Shell / Dotfiles / Themes / Workflows        │
└─────────────────────────────────────────────────────┘
                         ▲
                         │ optional integration
                         │
┌─────────────────────────────────────────────────────┐
│                   KALI-LAND                         │
│  Integration Contract / Capability Engine           │
│  Resource Ownership Ledger (~/.local/state/...)     │
│  Backup / Rollback / Diagnostics / Lifecycle       │
│  Platform Configuration (~/.config/hypr/kali-land/) │
└─────────────────────────────────────────────────────┘
                         ▲
                         │
┌─────────────────────────────────────────────────────┐
│                 PLATFORM LAYER                      │
│  Wayland / Hyprland / Desktop Services             │
└─────────────────────────────────────────────────────┘
                         ▲
                         │
┌─────────────────────────────────────────────────────┐
│                  KALI LINUX                         │
└─────────────────────────────────────────────────────┘
```

## Architectural Boundaries

### 1. Platform Layer (Kali-land Owned)

- **OS Base**: Kali Linux (Debian rolling, `apt`, `dpkg`, `systemd`).
- **Display & Compositor**: Wayland session protocol, Hyprland tiling window manager (`~/.config/hypr/kali-land/`), window rules, workspaces, and window IPC.
- **Desktop Services**:
  - Audio: PipeWire / WirePlumber
  - Networking: NetworkManager (`nmcli`)
  - Portals: XDG desktop portals (`xdg-desktop-portal-hyprland`)
  - Polkit: PolicyKit authentication agent
  - Clipboard: `cliphist` + `wl-clipboard`
  - Notifications: `libnotify` / desktop notification daemons
- **Platform Infrastructure**:
  - Capability engine (`wayland`, `hyprland`, `pipewire`, `networkmanager`, `quickshell`, etc.)
  - Hardware & VM Profiles (`systemd-detect-virt` management for VMware and bare-metal)
  - State & Resource Ledger: `~/.local/state/kali-land/state/installation.json` (tracks package provenance and file ownership).
  - Safety & Backups: Structured timestamped manifests in `~/.local/state/kali-land/backups/`.
  - Diagnostics: Provenance-aware `./bootstrap/doctor.sh`.

### 2. Experience Layer (User Owned)

- **Bring Your Own Setup (BYOS)**: Support for custom shells, dotfiles, and visual themes.
- **Namespace-Isolated Shells**: Shell integrations live strictly in namespaced directories (e.g. `~/.config/quickshell/end4-pC/`). The parent directory `~/.config/quickshell/` is never wiped or claimed by Kali-land.
- **User Workflows**: Terminal choices, text editors, wallpapers, hotkeys, and personal systemd user services.

## Configuration Ownership

```text
Platform Configuration:
  ~/.config/hypr/kali-land/      (Isolated platform configuration)

User Shell Integrations:
  ~/.config/quickshell/<shell>/ (Namespaced integration directories)

Resource Provenance State:
  ~/.local/state/kali-land/state/installation.json
```

- Pre-existing user dotfiles and package selections are preserved.
- Uninstallation and rollback purge ONLY resources recorded as created or installed by Kali-land in `installation.json`.
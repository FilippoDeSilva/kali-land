# Quick Start

## Warning

This project is in active development. While designed for VMware during development, it can be used on bare metal. Use on daily drivers at your own risk until stable release.

## Installation

```bash
sudo ./bootstrap/install.sh
```

The installer will:
- Detect your platform and validate requirements
- Initialize the Resource Ownership Ledger (`~/.local/state/kali-land/state/installation.json`)
- Install platform dependencies while tracking package provenance
- Configure Hyprland platform infrastructure (`~/.config/hypr/kali-land/`)
- Deploy optional shell integration (`~/.config/quickshell/end4-pC/`) without touching parent config folders
- Apply hardware/VM environment optimizations dynamically

## Requirements

- Kali Linux (Rolling)
- Sudo access
- Internet connection
- 4GB RAM minimum (8GB recommended)

## After Installation

1. Run the diagnostic:
   ```bash
   ./bootstrap/doctor.sh
   ```

2. Logout and select "Hyprland" from your display manager

3. The desktop platform and optional shell integration will start automatically

## What Gets Installed

**Platform Infrastructure (Kali-land Owned):**
- Hyprland (Wayland compositor)
- Desktop services (PipeWire audio, NetworkManager, XDG portals, Polkit, notifications)
- Resource Ownership Ledger & State Tracking (`~/.local/state/kali-land/`)

**Optional Integrations & Applications:**
- `end4-pC` Quickshell reference integration (installed into isolated `~/.config/quickshell/end4-pC/`)
- User-selectable terminal, file manager, and utilities

## Troubleshooting

Run the diagnostic:
```bash
./bootstrap/doctor.sh
```

Check logs:
```bash
~/.local/state/kali-land/logs/
```

See [Troubleshooting Guide](docs/troubleshooting.md) for detailed help.

## Rollback

To remove kali-land:
```bash
sudo ./bootstrap/uninstall.sh
```

This restores your original desktop environment.

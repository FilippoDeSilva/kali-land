# Quick Start

## Installation

```bash
sudo ./bootstrap/install.sh
```

The installer will:
- Detect your platform and validate requirements
- Install all required dependencies
- Configure Hyprland and Quickshell
- Set up the end4-pC Material 3 desktop shell
- Optimize for VMware environment

## Requirements

- Kali Linux (Rolling)
- VMware virtual machine
- Sudo access
- Internet connection

## After Installation

1. Run the diagnostic:
   ```bash
   ./bootstrap/doctor.sh
   ```

2. Logout and select "Hyprland" from your display manager

3. The Quickshell desktop shell will start automatically

## What Gets Installed

**Core:**
- Hyprland (Wayland compositor)
- Quickshell with end4-pC configuration
- Desktop services (audio, network, notifications)

**Applications:**
- Terminal (Foot/Kitty)
- File manager (Thunar)
- Browser (Firefox)
- Editor (Geany)

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

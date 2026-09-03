# Installation Guide

This guide explains how to install the Kali Omarchy-Inspired Desktop environment.

## Prerequisites

- Kali Linux (rolling release)
- VMware virtual machine (or bare metal with equivalent hardware)
- At least 4GB RAM (8GB recommended)
- At least 10GB free disk space
- Sudo access

## Quick Start

1. Run the diagnostic:
   ```bash
   ./bootstrap/doctor.sh
   ```

2. Run the installation (requires sudo):
   ```bash
   sudo ./bootstrap/install.sh
   ```

## Manual Installation Steps

Since some components (Hyprland, Quickshell) are not available in Kali repositories, some steps require manual installation.

### Phase 0-1: Foundation (Automated)

These phases are handled by the install script and don't require special intervention.

### Phase 2: Wayland Foundation (Requires Sudo)

The script will attempt to install Wayland packages. If this fails, run manually:

```bash
sudo apt update
sudo apt install -y wayland-protocols wayland-utils libwayland-dev xwayland
```

### Phase 3: Hyprland Installation (Requires Sudo)

Hyprland is available in Kali repositories. The script will attempt to install it automatically. If this fails, run manually:

```bash
sudo apt update
sudo apt install -y hyprland hyprland-guiutils
```

**Note**: `hyprland-guiutils` is a recommended runtime dependency for some Hyprland dialogs.

### Phase 4: Desktop Services (Requires Sudo)

The script will install desktop services. If this fails, run manually:

```bash
sudo apt update
sudo apt install -y \
  xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
  pipewire pipewire-audio-client-libraries pipewire-pulse wireplumber \
  pavucontrol network-manager blueman bluez bluez-firmware \
  dunst libnotify-bin cliphist swayidle swaylock wlogout
```

**Note**: `mako` is not available in Kali repositories, so we use `dunst` instead as the notification daemon.

### Phase 5: Quickshell Installation (Manual)

Quickshell is not available in Kali repositories. Installation options:

#### Option 1: Build from Source (Recommended)

1. Install Qt6 dependencies:
   ```bash
   sudo apt install -y qt6-base-dev qt6-declarative-dev qt6-wayland-dev cmake
   ```

2. Clone and build Quickshell:
   ```bash
   git clone https://github.com/prairielearner/quickshell.git /tmp/quickshell
   cd /tmp/quickshell
   mkdir build && cd build
   cmake ..
   make
   sudo make install
   ```

#### Option 2: Use Pre-built Binaries

Check the Quickshell releases for pre-built binaries that might work on Kali.

### Phase 6-10: Configuration and Theming (Automated)

These phases are handled by the install script and create the configuration structure.

**Important**: This project uses Hyprland's Lua configuration format (not the traditional `.conf` format). The installer will:

1. Remove old `.conf` files from `~/.config/hypr/`
2. Deploy modular Lua configuration files (`.lua`)
3. Set up the main entry point at `~/.config/hypr/hyprland.lua`

The Lua configuration is modular and organized as:
- `hyprland.lua` - Main entry point that requires all modules
- `config.lua` - Core Hyprland settings (gaps, borders, decorations, animations)
- `environment.lua` - Environment variables
- `monitors.lua` - Display/monitor configuration
- `keybinds.lua` - Keyboard shortcuts
- `rules.lua` - Window rules
- `autostart.lua` - Startup applications
- `vmware.lua` - VMware-specific optimizations

### Validating Lua Configuration

Before starting Hyprland, you can validate the Lua configuration structure:

```bash
bash scripts/validate-lua-config.sh
```

This script checks:
- All required Lua modules are present
- No conflicting `.conf` files remain
- Module structure is correct
- Entry point requires all modules

To test the configuration in a live session:

```bash
bash scripts/test-hyprland.sh
```

This will:
- Backup your current configuration
- Deploy the test configuration
- Start Hyprland safely
- Allow you to return to your current session if something goes wrong

### Phase 11: VMware Optimization (Optional)

If running in VMware, run the optimization script:
```bash
./scripts/vmware/optimize.sh
```

## Post-Installation

### Starting the Desktop Environment

Once everything is installed, you can start the Hyprland session:

1. Logout from your current session
2. In the display manager (lightdm), select "Hyprland" from the session menu
3. Login

If Hyprland doesn't appear in the session menu, you may need to create a session file:

```bash
sudo bash -c 'cat > /usr/share/xsessions/hyprland.desktop <<EOF
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland Compositor
Exec=Hyprland
Type=Application
EOF'
```

### Starting Quickshell

Quickshell should start automatically via Hyprland's autostart. If not, add to your Hyprland config:

```bash
echo "exec-once = quickshell" >> ~/.config/hypr/hyprland.conf
```

## Troubleshooting

### Wayland Session Not Available

If you can't select a Wayland session, ensure:
- Wayland packages are installed
- Your GPU drivers support Wayland
- The session file exists in `/usr/share/wayland-sessions/`

### Hyprland Won't Start

Check the Hyprland log:
```bash
cat ~/.local/share/hyprland/hyprland.log
```

Common issues:
- Missing dependencies
- GPU driver issues
- Configuration errors

### Quickshell Not Starting

Check Quickshell logs:
```bash
journalctl --user -u quickshell
```

Common issues:
- Qt6 dependencies missing
- Configuration errors
- Wayland integration issues

## Rollback

If you need to rollback to the original desktop:

1. Run the uninstall script:
   ```bash
   ./bootstrap/uninstall.sh
   ```

2. Restore from backup if needed:
   ```bash
   ./bootstrap/doctor.sh  # Check backup status
   ```

3. Logout and select your original desktop session

## Getting Help

- Run the doctor: `./bootstrap/doctor.sh`
- Check logs: `~/.local/state/kali-omarchy/logs/`
- See troubleshooting guide: [docs/troubleshooting.md](troubleshooting.md)

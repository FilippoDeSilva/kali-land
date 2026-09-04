# Installation Guide

This guide explains how to install the kali-land Desktop environment.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/kali-land.git
cd kali-land

# Run the installer
sudo ./bootstrap/install.sh

# Restart into Hyprland
```

**Note**: This project is in active development. While designed for VMware during development, it can be used on bare metal. Use on daily drivers at your own risk until stable release.

## What Gets Installed

The installer sets up:

- **Hyprland**: Modern Wayland compositor
- **Quickshell**: Professional desktop shell (end4-pC with Material 3 design)
- **Desktop Services**: Audio, network, notifications, clipboard
- **Applications**: Terminal, file manager, launcher
- **Configuration**: Complete modular configuration system

## Installation Process

The installer is divided into phases:

1. **Platform Detection**: Validates system requirements
2. **Repository Foundation**: Sets up project structure
3. **Wayland Foundation**: Installs Wayland dependencies
4. **Hyprland Installation**: Installs and configures Hyprland
5. **Fonts Installation**: Installs required fonts
6. **Desktop Services**: Installs audio, network, and desktop services
7. **Quickshell Installation**: Installs Quickshell with end4-pC configuration
8. **VMware Optimization**: Optimizes for VMware environment (if detected)

## Quickshell Installation

The installer uses a smart Quickshell installation strategy:

1. **Pre-built Binary Check**: First checks for pre-built Quickshell from GitHub releases
2. **Fast Installation**: If pre-built binary is available, downloads and installs it
3. **Fallback**: If no pre-built version, builds from source
4. **end4-pC Configuration**: Clones end4-pC configuration for Material 3 design
5. **Dependencies**: Installs all required Qt6 modules and dependencies

This provides:
- **Fast installation** when pre-built binaries are available
- **Reliable fallback** to source building when needed
- **Professional UI** with end4-pC Material 3 design

## Requirements

- **OS**: Kali Linux (Rolling)
- **Display**: Wayland session
- **Memory**: Minimum 4GB RAM (8GB recommended)
- **Storage**: 2GB free space for installation
- **Network**: Internet connection for package downloads

## Troubleshooting

### Quickshell Issues

If Quickshell fails to start:

1. **Check environment variables:**
   ```bash
   echo $QT_QPA_PLATFORM  # Should be "wayland"
   echo $QT_QUICK_BACKEND  # Should be "software" for VMware
   ```

2. **Check Wayland display:**
   ```bash
   echo $WAYLAND_DISPLAY  # Should be "wayland-1"
   ```

3. **Check logs:**
   ```bash
   cat /run/user/1000/quickshell/by-id/*/log.qslog
   ```

### Resolution Issues

If resolution is incorrect (4K instead of 1920x1080):

1. **Install VMware tools:**
   ```bash
   sudo apt install open-vm-tools-desktop
   ```

2. **Restart Hyprland**

3. **Check monitor configuration:**
   ```bash
   hyprctl monitors
   ```

### Missing Dependencies

If you encounter missing package errors:

1. **Run the diagnostic script:**
   ```bash
   ./bootstrap/doctor.sh
   ```

2. **Install missing packages manually if needed**

## Post-Installation

After installation:

1. **Restart into Hyprland**
2. **Wait for Quickshell to autostart** (3-second delay)
3. **Configure your preferences** using the end4-pC settings panel
4. **Set up wallpapers** and themes as desired

## Uninstallation

To remove kali-land:

```bash
sudo ./bootstrap/uninstall.sh
```

This will:
- Remove configuration symlinks
- Leave backup files for recovery
- Remove installed packages if requested

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
sudo apt install -y hyprland
```

**Note**: `hyprland-guiutils` is included in the desktop-services package list and will be installed automatically by the install script.

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

### Phase 6: Quickshell Configuration (Automated)

The installer creates a modular Quickshell configuration with the following structure:

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

**Key Design Principles:**
- **Modular**: Each UI component is a separate, reusable QML file
- **Configurable**: Central configuration objects control behavior
- **Maintainable**: Clear separation between presentation and logic
- **Scalable**: Easy to add new components without modifying existing ones

For detailed architecture documentation, see [Quickshell Architecture](quickshell-architecture.md).

### Phase 7-10: Configuration and Theming (Automated)

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

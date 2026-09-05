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
- **Quickshell**: Modern desktop shell engine (with `end4-pC` as the default reference shell integration)

## Installation Process

The installer is divided into phases:

1. **Platform Detection**: Validates system requirements
2. **Repository Foundation**: Sets up project structure
3. **Wayland Foundation**: Installs Wayland dependencies
4. **Hyprland Installation**: Installs and configures Hyprland
5. **Fonts Installation**: Installs required fonts
6. **Desktop Services**: Installs audio, network, and desktop services
7. **Quickshell Installation**: Installs Quickshell engine & deploys `end4-pC` reference integration
8. **VMware Optimization**: Optimizes for VMware environment (if detected)

## Quickshell Installation

The installer uses a secure, high-performance installation strategy:

1. **Pre-built Binary & SHA-256 Verification**: Checks for pre-built binaries from GitHub Releases matching `KALI_LAND_VERSION`.
2. **Cryptographic Check**: Downloads and verifies SHA-256 checksums (`.sha256`) before unpacking binaries.
3. **Fast Installation**: Installs verified prebuilt binaries directly to `/usr/local/bin`.
4. **Fallback**: If remote binaries are missing or checksum validation fails, builds Quickshell from source using CMake and Ninja.
5. **Reference Integration**: Deploys `integrations/end4-pC` to `~/.config/quickshell` as the default reference shell integration.

This provides:
- **Maximum security**: Cryptographic verification before execution
- **Fast installation**: Fast binary deployment when release artifacts are present
- **Reliable fallback**: Automated source compilation when prebuilts are unavailable
- **Modular BYOS**: Clear separation between platform runtime and shell integrations

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

1. Install build dependencies:
   ```bash
   sudo apt install -y qt6-base-dev qt6-declarative-dev qt6-wayland-dev cmake ninja-build build-essential pkg-config libpipewire-0.3-dev libpam0g-dev libpolkit-gobject-1-dev
   ```

2. Clone and build Quickshell:
   ```bash
   git clone --recursive https://github.com/outfoxxed/quickshell.git /tmp/quickshell
   cd /tmp/quickshell
   mkdir build && cd build
   cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DDISTRIBUTOR="kali-land" ..
   ninja
   sudo cmake --install .
   ```

#### Option 2: Pre-built Release Binaries with Checksum Verification

Download prebuilt binaries and SHA-256 checksums attached to official `kali-land` GitHub Releases:
```bash
curl -fsSL "https://github.com/FilippoDeSilva/kali-land/releases/download/v1.0.0/quickshell-linux-x86_64.tar.gz" -o /tmp/quickshell.tar.gz
curl -fsSL "https://github.com/FilippoDeSilva/kali-land/releases/download/v1.0.0/quickshell-linux-x86_64.tar.gz.sha256" -o /tmp/quickshell.tar.gz.sha256
sha256sum -c /tmp/quickshell.tar.gz.sha256
tar -xzf /tmp/quickshell.tar.gz -C /tmp/
sudo cp /tmp/quickshell /usr/local/bin/quickshell
```

### Phase 6: Shell Integration Deployment

`kali-land` uses a **Bring Your Own Shell (BYOS)** architecture. By default, the installer deploys the reference integration from `integrations/end4-pC` into `~/.config/quickshell`:

```
integrations/end4-pC/   ──(deployed to)──>   ~/.config/quickshell/
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
- Check logs: `~/.local/state/kali-land/logs/`
- See troubleshooting guide: [docs/troubleshooting.md](troubleshooting.md)

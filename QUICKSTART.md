# Quick Start Guide

## Current Status

✅ **Completed:**
- Phase 0: Platform detection ✓
- Phase 1: Repository foundation ✓
- Phase 2: Wayland foundation ✓ (Wayland packages installed!)

⏳ **Next Steps:**
- Phase 3: Hyprland installation (manual - requires building from source)
- Phase 4: Desktop services (manual - requires sudo)
- Phase 5+: Quickshell and desktop components

## Manual Installation Commands

### Phase 4: Desktop Services (Run with sudo)

```bash
# Update package cache
sudo apt update

# Install desktop services
sudo apt install -y \
  xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
  pipewire pipewire-audio-client-libraries pipewire-pulse wireplumber \
  pavucontrol network-manager blueman bluez bluez-firmware \
  dunst libnotify-bin cliphist swayidle swaylock wlogout
```

### Phase 3: Hyprland Installation (Manual - Build from Source)

```bash
# Install build dependencies
sudo apt install -y cmake g++ libpango-1.0-0 libpangocairo-1.0-0 libxkbcommon0 libxkbcommon-x11-0 libxcb-icccm4 libxcb-keysyms1 libxcb-render-util0 libxcb-xinerama0 libxcb-xkb1 libxcb-cursor0 libxcb-res0

# Clone and build Hyprland
git clone https://github.com/hyprwm/Hyprland.git /tmp/Hyprland
cd /tmp/Hyprland
./install.sh
```

### Phase 5: Quickshell Installation (Manual - Build from Source)

```bash
# Install Qt6 dependencies
sudo apt install -y qt6-base-dev qt6-declarative-dev qt6-wayland-dev cmake

# Clone and build Quickshell
git clone https://github.com/prairielearner/quickshell.git /tmp/quickshell
cd /tmp/quickshell
mkdir build && cd build
cmake ..
make
sudo make install
```

## After Installation

1. Run the doctor to check status:
   ```bash
   ./bootstrap/doctor.sh
   ```

2. Create Hyprland session file (if needed):
   ```bash
   sudo bash -c 'cat > /usr/share/xsessions/hyprland.desktop <<EOF
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland Compositor
Exec=Hyprland
Type=Application
EOF'
   ```

3. Logout and select "Hyprland" from the session menu

## What's Working So Far

✅ Repository structure set up
✅ Bootstrap system functional
✅ Wayland packages installed
✅ Documentation complete
✅ Theme system created
✅ Git repository initialized

## What Still Needs Manual Work

❌ Hyprland (not in Kali repos - needs manual build)
❌ Quickshell (not in Kali repos - needs manual build)
❌ Desktop services (need sudo to install)
❌ Configuration files (need to be linked after install)

## Why Some Components Are Manual

- **Hyprland**: Not available in Kali repositories, requires building from source
- **Quickshell**: Not available in Kali repositories, requires building from source
- **Desktop services**: Need sudo permissions to install system packages

This is intentional per the AGENT.md philosophy: **Architecture first, automation where safe, manual where necessary.**

## Next Steps

1. Run the Phase 4 commands above (desktop services)
2. Build and install Hyprland (Phase 3)
3. Build and install Quickshell (Phase 5)
4. Run the installer script again to complete Phases 6-13
5. Test the desktop environment

## Troubleshooting

If you run into issues:

```bash
# Check system status
./bootstrap/doctor.sh

# Check logs
~/.local/state/kali-omarchy/logs/

# See detailed troubleshooting guide
docs/troubleshooting.md
```

## Summary

You've successfully completed the foundation phases! The remaining work is primarily:
1. Installing system packages (requires sudo)
2. Building Hyprland and Quickshell from source (not in Kali repos)
3. Configuring the desktop environment

The architecture is solid and ready for the remaining components. 🚀

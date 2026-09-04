# Quick Start Guide

## 🚀 Fully Automated Installation

The installation is now **fully automated**! Just run:

```bash
sudo ./bootstrap/install.sh
```

That's it! The installer will:
- ✅ Detect your platform and system
- ✅ Install all required dependencies
- ✅ Build Hyprland from source automatically
- ✅ Build Quickshell from source automatically
- ✅ Install desktop services
- ✅ Set up configuration files
- ✅ Create theme system
- ✅ Configure VMware optimizations

## What You Need

- Kali Linux running in VMware
- Sudo access
- Internet connection
- ~30 minutes (depends on your system)

## Installation Process

The installer runs through 13 phases automatically:

1. **Platform Detection** - Analyzes your Kali system
2. **Repository Foundation** - Sets up project structure
3. **Base Packages** - Installs build tools (cmake, g++, git)
4. **Wayland Foundation** - Installs Wayland and XWayland
5. **Hyprland Installation** - Builds and installs Hyprland from source
6. **Desktop Services** - Installs audio, network, notifications, etc.
7. **Quickshell Skeleton** - Builds and installs Quickshell from source
8. **Quickshell Bar** - Sets up the desktop bar
9. **Launcher** - Configures application launcher
10. **Control Center** - Sets up system controls
11. **Power/Lock/Session** - Configures power management
12. **Visual Theming** - Applies Catppuccin Mocha theme
13. **VMware Optimization** - Optimizes for VMware environment

## After Installation

1. **Check the status:**
   ```bash
   ./bootstrap/doctor.sh
   ```

2. **Create Hyprland session:**
   ```bash
   sudo bash -c 'cat > /usr/share/xsessions/hyprland.desktop <<EOF
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland Compositor
Exec=Hyprland
Type=Application
EOF'
   ```

3. **Logout and select "Hyprland" from the session menu**

4. **Enjoy your new kali-land desktop!** 🎨

## What Gets Installed

**Core Components:**
- Hyprland (Wayland compositor)
- Quickshell (Desktop shell)
- PipeWire (Audio)
- NetworkManager (Networking)
- Dunst (Notifications)
- Swaylock (Lock screen)
- Wlogout (Power menu)

**Applications:**
- Kitty (Terminal)
- Thunar (File manager)
- Firefox (Browser)
- Geany (Editor)

**Theme:**
- Catppuccin Mocha color scheme
- Consistent visual language
- Polished animations

## Troubleshooting

If anything goes wrong:

```bash
# Check system status
./bootstrap/doctor.sh

# Check installation logs
~/.local/state/kali-omarchy/logs/

# See detailed troubleshooting guide
docs/troubleshooting.md
```

## Rollback

If you want to remove the desktop:

```bash
./bootstrap/uninstall.sh
```

This will restore your original XFCE desktop.

## Features

- **Keyboard-first workflow** - Super + Space for launcher
- **Modular architecture** - Easy to customize
- **Git-tracked configs** - Version controlled
- **Automatic backups** - Safe to experiment
- **VMware optimized** - Great performance in VMs
- **Kali native** - Preserves security tools

## Enjoy Your New Desktop!

You now have a professional, modular, and beautiful desktop environment on Kali Linux. The installation handles everything automatically - you just sit back and wait for the magic to happen! ✨

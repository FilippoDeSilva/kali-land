# Installation Guide

This guide explains how to install and configure the `kali-land` Desktop environment.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/FilippoDeSilva/kali-land.git
cd kali-land

# Run the automated installer (requires sudo)
sudo ./bootstrap/install.sh

# Restart into Hyprland
```

**Note**: This project is engineered for bare-metal laptops/desktops as well as VMware virtual machines. VMware optimizations are detected and applied dynamically during installation.

---

## What Gets Installed

The installer sets up:

- **Hyprland**: Modern tiling Wayland compositor configured with modular Lua configuration (`config/hypr/*.lua`).
- **Quickshell**: Extensible desktop shell engine (with `end4-pC` deployed as the default reference shell integration).
- **Declarative Font Delivery System**: Automatic package resolution and font asset syncing (`MaterialSymbolsRounded.ttf`, `Inter`, `Roboto`, `JetBrains Mono`).
- **Desktop Services**: PipeWire audio, NetworkManager, XDG portals, Polkit, Grim/Slurp, Wl-clipboard, and Playerctl.

---

## Installation Phases

The installer executes through the following phases:

1. **Phase 0: Platform & Profile Detection**: Validates system requirements and virtualization environment.
2. **Phase 1: Repository Foundation**: Prepares project structure and capability detection contracts.
3. **Phase 2: Wayland Foundation**: Installs Wayland protocols and core system utilities.
4. **Phase 3: Hyprland Installation**: Installs packaged Hyprland (or builds from source).
5. **Phase 4: Font System Initialization**: Resolves system font packages and syncs font assets (`~/.local/share/fonts/`).
6. **Phase 5: Desktop Services & Hyprland Lua Configuration**: Deploys modular Lua configurations (`hyprland.lua`, `keybinds.lua`, `environment.lua`, etc.).
7. **Phase 6: Quickshell Installation & Shell Deployment**: Installs Quickshell engine & deploys `end4-pC` reference integration to `~/.config/quickshell`.
8. **Phase 7: Color Generation (Matugen)**: Installs Material You color generator.
9. **Phase 11: VMware Optimization**: Installs `open-vm-tools-desktop` and applies VMware cursor/rendering fixes if virtualized.

---

## Quickshell Installation & Security Verification

The installer uses a secure, high-performance installation strategy for Quickshell & Matugen:

1. **Pre-built Binary & SHA-256 Verification**: Checks for pre-built release archives matching `KALI_LAND_VERSION`.
2. **Cryptographic Check**: Downloads and verifies SHA-256 checksums (`.sha256`) before unpacking binaries.
3. **Fast Installation**: Installs verified pre-built binaries directly to `/usr/local/bin`.
4. **Automated Fallback**: If remote binaries are missing or checksum validation fails, builds from source using CMake and Ninja.
5. **Reference Integration**: Deploys `integrations/end4-pC` to `~/.config/quickshell` as the default reference shell integration.

---

## Declarative Font Management

`kali-land` manages font dependencies declaratively inside each shell integration's `manifest.yaml`:

```yaml
requires:
  fonts:
    packages:
      - fonts-inter
      - fonts-roboto
      - fonts-jetbrains-mono
      - fonts-noto-color-emoji
      - fonts-font-awesome
    assets:
      - "assets/fonts/MaterialSymbolsRounded.ttf"
```

During installation, `bootstrap/lib/integrations.sh`:
- Installs all required system font packages via `apt`.
- Copies bundled font assets (`assets/fonts/*.ttf`) to `~/.local/share/fonts/`.
- Executes `fc-cache -fv` to register fonts system-wide, eliminating invisible text in Qt 6 QML components out-of-the-box.

---

## Modular Lua Hyprland Configuration

`kali-land` uses Hyprland's native Lua configuration format:

```text
~/.config/hypr/
├── hyprland.lua        # Main entry point (requires modules)
├── keybinds.lua        # Keyboard shortcuts & Quickshell IPC bindings
├── environment.lua    # Environment variables (QT_QPA_PLATFORM, etc.)
├── windowrules.lua    # Window & workspace rules
├── autostart.lua      # Startup applications & Quickshell launch
└── decorations.lua    # Window gaps, borders, and animations
```

---

## Troubleshooting

### Quickshell Issues & Invisible Text

If typed text in search boxes, app launchers, or lock screens is invisible:
1. Ensure system fonts are indexed:
   ```bash
   fc-cache -fv
   ```
2. Verify font installation via `fc-list`:
   ```bash
   fc-list | grep -i "inter"
   ```

### Check Logs

```bash
cat /run/user/1000/quickshell/by-id/*/log.qslog
```

---

## Rollback

To safely restore previous desktop configurations:

```bash
sudo ./bootstrap/uninstall.sh
```

Backups are stored timestamped in `~/.local/state/kali-land/backups/`.

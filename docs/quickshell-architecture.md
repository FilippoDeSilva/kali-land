# Quickshell Architecture in kali-land

## Overview

Quickshell serves as the graphical desktop shell runtime layer in `kali-land`. It provides user-facing UI components (bars, panels, launchers, control centers, widgets, lock screens, and sidebars) while Hyprland handles window management.

> **"kali-land owns the environment; the user owns the experience."**

`kali-land` strictly distinguishes between:
```text
Quickshell Runtime (Platform)  ≠  Quickshell Shell Integration (Experience)
```

---

## Bring Your Own Shell (BYOS) & Manifest Standard

`kali-land` adopts a **Bring Your Own Shell (BYOS)** model. The platform provides a stable Wayland runtime, capability detection, package resolution, font delivery, and safety/rollback mechanisms, while allowing users to select or bring their preferred Quickshell shell.

Every shell integration in `kali-land` defines its capability contract and package/font requirements in a standardized `manifest.yaml`:

```yaml
name: end4-pC
version: "1.0.0"
type: quickshell
description: "Material 3 Quickshell desktop shell reference integration for kali-land"
provenance: "https://github.com/pctrade/end4-pC"

entry: "shell.qml"

requires:
  capabilities:
    - wayland
    - hyprland
    - quickshell
  packages:
    - qml6-module-qtcore
    - qml6-module-qtquick
    - fontconfig
    - grim
    - slurp
    - wl-clipboard
    - wf-recorder
    - tesseract-ocr
    - jq
    - playerctl
  fonts:
    packages:
      - fonts-inter
      - fonts-roboto
      - fonts-jetbrains-mono
      - fonts-noto-color-emoji
      - fonts-font-awesome
    assets:
      - "assets/fonts/MaterialSymbolsRounded.ttf"

environment:
  QT_QUICK_BACKEND: "software" # Recommended for VMware compatibility
  QS_CONFIG: "end4-pC"
```

---

## Reference Shell Integration (`end4-pC`)

`kali-land` uses `end4-pC` as its primary reference integration proof-of-concept.

### Directory Structure

```text
integrations/end4-pC/
├── manifest.yaml                # Standardized capability & package manifest
├── shell.qml                    # Main entry point
├── panelFamilies/               # Panel configurations
├── modules/                     # UI modules (bar, launcher, sidebars, lock screen)
├── services/                    # Backend Qt/QML service bridges
├── assets/                      # Icons, wallpapers, bundled fonts
│   └── fonts/                   # TTF/OTF font assets (auto-synced to ~/.local/share/fonts/)
├── defaults/                    # Default configurations
├── scripts/                     # Helper scripts
└── translations/                # i18n support
```

---

## Quickshell IPC Interface

Default keybindings in `kali-land` (`config/hypr/keybinds.lua`) interact with Quickshell using native IPC signals:

| Feature / UI Component | Quickshell IPC Command | Description |
|------------------------|------------------------|-------------|
| **Application Launcher** | `quickshell ipc call search toggle` | Toggle search bar & app grid |
| **Clipboard Manager** | `quickshell ipc call search clipboardToggle` | Search & paste clipboard history |
| **Workspace Overview** | `quickshell ipc call search workspacesToggle` | Interactive workspace switcher |
| **Lock Screen** | `quickshell ipc call lock activate` | Lock session with PIN/password |
| **Session / Power Menu** | `quickshell ipc call session toggle` | Shutdown, reboot, sleep, logout |
| **Wallpaper Selector** | `quickshell ipc call wallpaperSelector toggle` | Select & apply wallhaven wallpapers |
| **Random Wallpaper** | `quickshell ipc call wallpaperSelector random` | Switch to random wallpaper |
| **Media Player Controls** | `quickshell ipc call mediaControls toggle` | Music player UI & synchronized lyrics |
| **Left Sidebar** | `quickshell ipc call sidebarLeft toggle` | Quick settings & widgets |
| **Right Sidebar** | `quickshell ipc call sidebarRight toggle` | Notifications & calendar |
| **Status Bar** | `quickshell ipc call bar toggle` | Hide / show desktop status bar |
| **Screen Capture (Region)** | `quickshell ipc call region screenshot` | Interactive area screenshot |
| **Screen Record (Region)** | `quickshell ipc call region record` | Interactive area video recorder |
| **Text OCR Extraction** | `quickshell ipc call region ocr` | Extract text from screen region |

---

## Declarative Font Delivery System

In Qt 6 QML, rendering text with `Text.NativeRendering` when a font is missing causes glyph rasterization to fail, making text invisible. 

`kali-land` solves this cleanly via the **Declarative Font Delivery System**:
1. **Manifest Declarations**: System font packages (`fonts-inter`, `fonts-roboto`, `fonts-jetbrains-mono`) and local TTF font assets are declared in `manifest.yaml`.
2. **Automated Sync**: The installer (`bootstrap/lib/integrations.sh`) installs system package dependencies, copies bundled `.ttf` assets to `~/.local/share/fonts/`, and runs `fc-cache -fv`.
3. **Zero Configuration**: Quickshell UI text renders crisply out-of-the-box on both bare-metal and virtual machines.

---

## References

- [Quickshell Repository](https://github.com/outfoxxed/quickshell)
- [end4-pC Reference Shell](https://github.com/pctrade/end4-pC)
- [Qt 6 QML Documentation](https://doc.qt.io/qt-6/qmlapplications.html)

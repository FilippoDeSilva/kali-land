# Quickshell Architecture & BYOS Guide in kali-land

## Overview

Quickshell serves as the graphical desktop shell runtime layer in `kali-land`. It provides user-facing UI components (status bars, widget panels, launchers, control centers, lock screens, and sidebars) while Hyprland handles window management.

> **"Who says Kali Linux doesn't deserve world-class aesthetics?"**
> **"kali-land owns the environment; the user owns the experience."**

`kali-land` strictly distinguishes between:
```text
Quickshell Runtime (Platform Engine)  ≠  Quickshell Shell Integration (User Experience)
```

---

## Bring Your Own Shell (BYOS)

`kali-land` is built on a **Bring Your Own Shell (BYOS)** architecture. You are never locked into a hardcoded interface or theme! You have complete freedom to:
1. **Adopt a Reference Shell**: Use pre-configured reference integrations like `end4-pC` out-of-the-box.
2. **Port an Existing Shell**: Bring any existing Quickshell configuration from the community.
3. **Build Your Own Custom Shell**: Create a personalized desktop shell from scratch tailored to your workflow.

---

## `kali-land` Standards & Manifest Specification

To make any Quickshell project work seamlessly with `kali-land`'s automated installer (`bootstrap/install.sh`), package resolver, and diagnostic system (`bootstrap/doctor.sh`), every integration must include a standardized `manifest.yaml` in its root folder (`integrations/<shell-name>/manifest.yaml`).

### Standard `manifest.yaml` Schema

```yaml
name: my-custom-shell
version: "1.0.0"
type: quickshell
description: "My custom Material 3 desktop shell integration for kali-land"
provenance: "https://github.com/myuser/my-custom-shell"

# Main QML entry point file (relative to integration root)
entry: "shell.qml"

requires:
  # System display & compositor capabilities required by the shell
  capabilities:
    - wayland
    - hyprland
    - quickshell
    
  # System APT package dependencies required by the shell
  packages:
    - qml6-module-qtcore
    - qml6-module-qtquick
    - qml6-module-qtquick-controls
    - qml6-module-qtquick-layouts
    - qml6-module-qt5compat-graphicaleffects
    - fontconfig
    - grim
    - slurp
    - wl-clipboard
    - playerctl
    
  # Declarative Font System dependencies
  fonts:
    # System font packages installed via apt
    packages:
      - fonts-inter
      - fonts-roboto
      - fonts-jetbrains-mono
      - fonts-noto-color-emoji
      - fonts-font-awesome
    # Local TTF/OTF font assets bundled inside assets/fonts/
    assets:
      - "assets/fonts/MaterialSymbolsRounded.ttf"
      - "assets/fonts/MyCustomFont.ttf"

# Environment variables exported when launching Quickshell
environment:
  QT_QUICK_BACKEND: "software" # Recommended for VMware compatibility
  QS_CONFIG: "my-custom-shell"
```

---

## Best Practices for Custom Shell Developers

### 1. Package Placement Standards (`requires.packages`)
- **Qt6 QML Modules**: Declare all Qt modules your QML code imports (e.g. `qml6-module-qtquick-layouts`, `qml6-module-qt5compat-graphicaleffects`).
- **CLI Helpers**: Declare any command line tools your scripts invoke (e.g. `grim`, `slurp`, `playerctl`, `wl-clipboard`, `jq`, `tesseract-ocr`).
- The installer automatically parses these packages and installs missing dependencies before building/deploying the shell.

### 2. Font Asset Standards (`requires.fonts`)
- **System Fonts**: Place system font packages under `requires.fonts.packages` (e.g. `fonts-inter`, `fonts-roboto`).
- **Custom Font TTF Files**: Place custom `.ttf` or `.otf` font files inside `integrations/<shell-name>/assets/fonts/` and list them under `requires.fonts.assets`.
- The installer copies all files in `assets/fonts/` directly to `~/.local/share/fonts/` and automatically executes `fc-cache -fv`. This guarantees zero invisible text in Qt 6 QML components.

### 3. Keybindings & IPC Integration Standards
- Place your custom keybindings in `config/hypr/keybinds.lua`.
- Trigger Quickshell features cleanly via IPC commands rather than hardcoding complex shell execution lines:

```lua
-- Example in config/hypr/keybinds.lua
local mainMod = "SUPER"

-- Trigger custom search launcher
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("bash -c 'quickshell ipc call search toggle'"))

-- Trigger custom lock screen
hl.bind(mainMod .. " + l", hl.dsp.exec_cmd("bash -c 'quickshell ipc call lock activate'"))
```

---

## Step-by-Step: Creating & Deploying a Custom Shell

1. **Create a Directory**:
   ```bash
   mkdir -p integrations/my-shell/assets/fonts
   ```

2. **Create `manifest.yaml`**:
   Write your `manifest.yaml` following the standard schema above.

3. **Add Entry Point (`shell.qml`)**:
   Create your main `shell.qml` file inside `integrations/my-shell/`.

4. **Deploy via Installer**:
   Deploy your custom integration to `~/.config/quickshell`:
   ```bash
   ./bootstrap/install.sh
   ```
   Or deploy programmatically via the bootstrap library in bash:
   ```bash
   source bootstrap/lib/integrations.sh
   install_integration "my-shell"
   ```

---

## Reference IPC Endpoints (`end4-pC`)

The primary reference integration (`end4-pC`) supports the following native IPC commands out-of-the-box:

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

## References

- [Quickshell Repository](https://github.com/outfoxxed/quickshell)
- [end4-pC Reference Shell](https://github.com/pctrade/end4-pC)
- [Qt 6 QML Documentation](https://doc.qt.io/qt-6/qmlapplications.html)

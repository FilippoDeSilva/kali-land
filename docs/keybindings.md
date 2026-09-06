# Keybindings

This document describes the keybinding scheme for the `kali-land` Desktop.

## Philosophy

The keybinding system follows these principles:

- **Super modifier (`SUPER`)** as the primary modifier key
- **Decoupled BYOS Architecture**: All default keybindings invoke `end4-pC` Quickshell IPC commands out-of-the-box
- **Predictable patterns** for similar actions
- **Minimal conflicts** with terminal (`foot`/`kitty`) and browser (`firefox-esr`) shortcuts
- **Keyboard-first** workflow with instant discoverability

---

## Primary Keybindings

### Window & Application Management

| Keybinding | Action | Command / Dispatcher |
|------------|--------|----------------------|
| `SUPER + Return` | Open Terminal | `$TERMINAL` (`foot` in VM, `kitty` bare metal) |
| `SUPER + Q` | Close Active Window | `close` |
| `SUPER + E` | Open File Manager | `thunar` |
| `SUPER + F` | Toggle Floating | `window.float({ action = "toggle" })` |
| `SUPER + D` | Fullscreen Window | `window.fullscreen()` |
| `SUPER + SHIFT + D` | Toggle Fullscreen | `window.fullscreen({ action = "toggle" })` |
| `SUPER + P` | Toggle Pseudo Tiling | `window.pseudo()` |
| `SUPER + SHIFT + B` | Launch Web Browser | `firefox-esr` |
| `SUPER + SHIFT + G` | Launch Text Editor | `geany` |

### Search & Launcher (Quickshell IPC)

| Keybinding | Action | Quickshell IPC Command |
|------------|--------|------------------------|
| `SUPER + Space` / `ALT + Space` / `SUPER + R` | Toggle Application Launcher | `quickshell ipc call search toggle` |
| `SUPER + V` / `SUPER + SHIFT + V` | Toggle Clipboard Manager | `quickshell ipc call search clipboardToggle` |
| `SUPER + Tab` / `ALT + Tab` | Workspace Overview | `quickshell ipc call search workspacesToggle` |

### Screen Capture & Tools (Quickshell IPC)

| Keybinding | Action | Quickshell IPC Command |
|------------|--------|------------------------|
| `Print` / `SUPER + Print` | Interactive Region Screenshot | `quickshell ipc call region screenshot` |
| `SUPER + SHIFT + Print` | Interactive Region Screen Recording | `quickshell ipc call region record` |
| `SUPER + ALT + Print` | Region Text OCR Extraction | `quickshell ipc call region ocr` |
| `SUPER + T` | Screen Translator | `quickshell ipc call screenTranslator translate` |
| `SUPER + K` | On-Screen Keyboard | `quickshell ipc call osk toggle` |

### Media & Volume Controls

| Keybinding | Action | Command / Quickshell IPC |
|------------|--------|--------------------------|
| `SUPER + M` | Toggle Media Player Controls & Lyrics | `quickshell ipc call mediaControls toggle` |
| `SUPER + SHIFT + Space` / `XF86AudioPlay` | Play / Pause Media | `quickshell ipc call mpris playPause` |
| `SUPER + ]` / `XF86AudioNext` | Skip Next Track | `quickshell ipc call mpris next` |
| `SUPER + [` / `XF86AudioPrev` | Skip Previous Track | `quickshell ipc call mpris previous` |
| `SUPER + =` / `XF86AudioRaiseVolume` | Volume Up (+5%) | `wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+` |
| `SUPER + -` / `XF86AudioLowerVolume` | Volume Down (-5%) | `wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-` |
| `XF86AudioMute` | Toggle Mute | `wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle` |
| `XF86MonBrightnessUp` | Brightness Up (+5%) | `quickshell ipc call brightness increment` |
| `XF86MonBrightnessDown` | Brightness Down (-5%) | `quickshell ipc call brightness decrement` |

### Lock Screen, Session & Sidebars

| Keybinding | Action | Quickshell IPC Command |
|------------|--------|------------------------|
| `SUPER + L` / `SUPER + SHIFT + L` | Lock Screen | `quickshell ipc call lock activate` |
| `SUPER + Escape` / `SUPER + SHIFT + Escape` | Session / Power Menu | `quickshell ipc call session toggle` |
| `SUPER + W` | Open Wallpaper & Theme Selector | `quickshell ipc call wallpaperSelector toggle` |
| `SUPER + SHIFT + W` | Set Random Wallpaper & Theme | `quickshell ipc call wallpaperSelector random` |
| `SUPER + SHIFT + T` | Regenerate / Switch Theme Colors | `switchwall.sh --noswitch` |
| `SUPER + Comma` / `SUPER + I` | Shell Settings & Preferences | `quickshell ipc call settings toggle` |
| `SUPER + /` | Search & Cheatsheet Overview | `quickshell ipc call search toggle` |
| `SUPER + A` | Left Sidebar | `quickshell ipc call sidebarLeft toggle` |

| `SUPER + N` / `SUPER + Period` | Right Sidebar | `quickshell ipc call sidebarRight toggle` |
| `SUPER + B` | Toggle Status Bar | `quickshell ipc call bar toggle` |
| `SUPER + O` | Toggle Widgets Overlay | `quickshell ipc call overlay toggle` |

### Window Focus & Navigation

| Keybinding | Action |
|------------|--------|
| `SUPER + Left / Right / Up / Down` | Move Focus |
| `SUPER + SHIFT + Left / Right / Up / Down` | Move Active Window |
| `SUPER + CTRL + Left / Right / Up / Down` | Resize Active Window |

### Workspaces & Scratchpad

| Keybinding | Action |
|------------|--------|
| `SUPER + 1..9, 0` | Switch to Workspace 1..10 |
| `SUPER + SHIFT + 1..9, 0` | Move Window to Workspace 1..10 |
| `SUPER + S` | Toggle Special Scratchpad Workspace |
| `SUPER + SHIFT + S` | Move Window to Special Scratchpad |
| `SUPER + Mouse Scroll Up/Down` | Switch Workspaces |
| `SUPER + Mouse Drag` | Move Floating Window |
| `SUPER + Right Mouse Drag` | Resize Floating Window |

---

## Configuration File

Keybindings are configured in `config/hypr/keybinds.lua` using Hyprland's Lua binding API:

```lua
-- Sample snippet from config/hypr/keybinds.lua
local mainMod = "SUPER"

-- Quickshell Launcher & Search
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("bash -c 'quickshell ipc call search toggle'"))

-- Screen Capture & OCR
hl.bind("Print", hl.dsp.exec_cmd("bash -c 'quickshell ipc call region screenshot'"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("bash -c 'quickshell ipc call region record'"))
hl.bind(mainMod .. " + ALT + Print", hl.dsp.exec_cmd("bash -c 'quickshell ipc call region ocr'"))
```

## Reloading Keybindings

To apply keybinding changes without restarting Hyprland:

```bash
# Via Keybinding:
SUPER + SHIFT + R

# Via Command:
hyprctl reload
```

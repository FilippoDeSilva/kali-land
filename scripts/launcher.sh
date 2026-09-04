#!/bin/bash
# kali-land Application Launcher
# Triggered by Super+Space

LAUNCHER_CONFIG="$HOME/.config/kali-land/launcher.conf"
HISTORY_FILE="$HOME/.config/kali-land/launcher_history.txt"

# Create config directory
mkdir -p "$(dirname "$LAUNCHER_CONFIG")"
mkdir -p "$(dirname "$HISTORY_FILE")"

# Fuzzy search and launch application
rofi -dmenu \
    -i \
    -p ">_ " \
    -theme-str 'window { background-color: #0a0a0f; opacity: 0.95; border: 2px solid #00ff00; border-radius: 8px; } element { background-color: #0f0f18; border-radius: 4px; } element selected { background-color: #1a1a25; border: 1px solid #00ffff; } element-text { color: #cdd6f4; font-family: "JetBrains Mono, monospace"; } inputbar { children: [prompt, entry]; } prompt { color: #00ff00; } entry { color: #00ffff; }' \
    -matching fuzzy \
    -show run
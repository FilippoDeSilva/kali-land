#!/bin/bash
# kali-land Power Menu
# Triggered by Super+Escape

POWER_MENU_CONFIG="$HOME/.config/kali-land/power_menu.conf"

# Create power menu options
OPTIONS="Lock\nLogout\nSuspend\nReboot\nShutdown"

# Show power menu with rofi
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu \
    -i \
    -p "POWER >_ " \
    -theme-str 'window { background-color: #0a0a0f; opacity: 0.95; border: 2px solid #ff00ff; border-radius: 8px; } element { background-color: #0f0f18; border-radius: 4px; } element selected { background-color: #1a1a25; border: 1px solid #ff00ff; } element-text { color: #cdd6f4; font-family: "JetBrains Mono, monospace"; } inputbar { children: [prompt, entry]; } prompt { color: #ff00ff; } entry { color: #ff00ff; }' \
    -matching fuzzy)

case "$CHOICE" in
    "Lock")
        swaylock -f -c 0a0a0f
        ;;
    "Logout")
        hyprctl dispatch exit
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
esac
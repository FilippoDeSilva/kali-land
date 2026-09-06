#!/bin/bash
# deploy-config.sh - Deploy configurations to user home directory

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Deploying kali-land configurations..."

# Backup existing configurations
BACKUP_DIR="${HOME}/.local/state/kali-land/backups/$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "${BACKUP_DIR}"

echo "Creating backups at: ${BACKUP_DIR}"

# Backup and deploy Hyprland configuration
if [ -d "${HOME}/.config/hypr" ]; then
    echo "Backing up existing Hyprland configuration..."
    cp -r "${HOME}/.config/hypr" "${BACKUP_DIR}/"
fi

echo "Deploying Hyprland configuration..."
mkdir -p "${HOME}/.config/hypr"
cp -r "${REPO_ROOT}/config/hypr/"* "${HOME}/.config/hypr/"

# Backup and deploy Quickshell configuration
if [ -d "${HOME}/.config/quickshell" ]; then
    echo "Backing up existing Quickshell configuration..."
    cp -r "${HOME}/.config/quickshell" "${BACKUP_DIR}/"
fi

echo "Deploying Quickshell configuration..."
mkdir -p "${HOME}/.config/quickshell"
mkdir -p "${HOME}/.config/quickshell/components"
mkdir -p "${HOME}/.config/quickshell/theme"
cp -r "${REPO_ROOT}/config/quickshell/"* "${HOME}/.config/quickshell/"

# Deploy theme files
if [ -d "${REPO_ROOT}/themes" ]; then
    echo "Deploying themes..."
    mkdir -p "${HOME}/.local/share/themes"
    cp -r "${REPO_ROOT}/themes/"* "${HOME}/.local/share/themes/"
fi

# Deploy font assets (e.g. MaterialSymbolsRounded.ttf)
if [ -d "${REPO_ROOT}/integrations/end4-pC/assets/fonts" ]; then
    echo "Deploying font assets to ~/.local/share/fonts..."
    mkdir -p "${HOME}/.local/share/fonts"
    cp -r "${REPO_ROOT}/integrations/end4-pC/assets/fonts/"* "${HOME}/.local/share/fonts/"
    fc-cache -fv &>/dev/null || true
    echo "Font cache updated via fc-cache."
fi

# Deploy default wallpaper and initialize illogical-impulse config
if [ -f "${REPO_ROOT}/integrations/end4-pC/assets/images/default_wallpaper.png" ]; then
    echo "Deploying default wallpaper to ~/Pictures/Wallpapers..."
    mkdir -p "${HOME}/Pictures/Wallpapers"
    cp "${REPO_ROOT}/integrations/end4-pC/assets/images/default_wallpaper.png" "${HOME}/Pictures/Wallpapers/default_wallpaper.png"
    
    python3 -c '
import json, os
cfg = os.path.expanduser("~/.config/illogical-impulse/config.json")
wall = os.path.expanduser("~/Pictures/Wallpapers/default_wallpaper.png")
os.makedirs(os.path.dirname(cfg), exist_ok=True)
data = {}
if os.path.exists(cfg):
    try:
        with open(cfg, "r") as f: data = json.load(f)
    except Exception: data = {}
bg = data.get("background", {})
if not bg.get("wallpaperPath"):
    bg["wallpaperPath"] = wall
    data["background"] = bg
    with open(cfg, "w") as f: json.dump(data, f, indent=4)
' 2>/dev/null || true
    echo "Illogical impulse configuration initialized with valid wallpaper path."
fi

echo "Configuration deployment complete!"
echo "Backups saved at: ${BACKUP_DIR}"
echo ""
echo "To start Hyprland, run:"
echo "  Hyprland"
echo ""
echo "To start Quickshell manually:"
echo "  quickshell"
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

# Backup and deploy Rofi configuration
if [ -d "${REPO_ROOT}/config/rofi" ]; then
    if [ -d "${HOME}/.config/rofi" ]; then
        echo "Backing up existing Rofi configuration..."
        cp -r "${HOME}/.config/rofi" "${BACKUP_DIR}/"
    fi
    echo "Deploying Rofi configuration..."
    mkdir -p "${HOME}/.config/rofi"
    cp -r "${REPO_ROOT}/config/rofi/"* "${HOME}/.config/rofi/"
fi

# Deploy theme files
if [ -d "${REPO_ROOT}/themes" ]; then
    echo "Deploying themes..."
    mkdir -p "${HOME}/.local/share/themes"
    cp -r "${REPO_ROOT}/themes/"* "${HOME}/.local/share/themes/"
fi

echo "Configuration deployment complete!"
echo "Backups saved at: ${BACKUP_DIR}"
echo ""
echo "To start Hyprland, run:"
echo "  Hyprland"
echo ""
echo "To start Quickshell manually:"
echo "  quickshell"
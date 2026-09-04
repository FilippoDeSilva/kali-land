#!/bin/bash
# test-hyprland.sh - Safely test Hyprland configuration

set -Eeuo pipefail

echo "=========================================="
echo "  Hyprland Test Environment"
echo "=========================================="
echo ""
echo "This script will help you test Hyprland safely."
echo "If Hyprland crashes, you can easily return to your current session."
echo ""

# Check if we're already in a Wayland session
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    echo "WARNING: You're already in a Wayland session."
    echo "It's recommended to test Hyprland from a TTY or X11 session."
    echo ""
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
        echo "Test cancelled."
        exit 0
    fi
fi

# Create a safe test environment
echo "Setting up test environment..."

# Backup current Hyprland config if it exists
if [ -d "${HOME}/.config/hypr" ]; then
    echo "Backing up current Hyprland configuration..."
    BACKUP_DIR="${HOME}/.local/state/kali-land/test-backup-$(date +%Y-%m-%d_%H-%M-%S)"
    mkdir -p "${BACKUP_DIR}"
    cp -r "${HOME}/.config/hypr" "${BACKUP_DIR}/"
    echo "Backup saved at: ${BACKUP_DIR}"
fi

# Deploy test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [ -f "${REPO_ROOT}/scripts/deploy-config.sh" ]; then
    echo "Deploying test configuration..."
    "${REPO_ROOT}/scripts/deploy-config.sh"
fi

# Check if we're using Lua configuration
if [ -f "${HOME}/.config/hypr/hyprland.lua" ]; then
    echo "Using Lua configuration format"
elif [ -f "${HOME}/.config/hypr/hyprland.conf" ]; then
    echo "Using traditional .conf configuration format"
else
    echo "WARNING: No Hyprland configuration found!"
fi

echo ""
echo "=========================================="
echo "  Starting Hyprland Test"
echo "=========================================="
echo ""
echo "IMPORTANT TIPS:"
echo "  - Press Super+Shift+Q to close windows"
echo "  - Press Super+M to exit Hyprland"
echo "  - If Hyprland crashes, you'll return to this session"
echo "  - Use Ctrl+Alt+F1-F6 to switch TTYs if needed"
echo ""
echo "Starting Hyprland in 3 seconds..."
sleep 3

# Start Hyprland
if command -v Hyprland &>/dev/null; then
    echo "Starting Hyprland..."
    Hyprland
else
    echo "ERROR: Hyprland not found in PATH"
    echo "Please install Hyprland first"
    exit 1
fi

echo ""
echo "=========================================="
echo "  Hyprland Test Complete"
echo "=========================================="
echo ""
echo "You have returned to your previous session."
echo "If you want to restore your backup configuration:"
echo "  cp -r ${BACKUP_DIR}/hypr ~/.config/hypr"
echo ""
echo "If you want to make the new configuration permanent:"
echo "  It's already deployed in ~/.config/hypr"
echo ""
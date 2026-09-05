#!/bin/bash
# capabilities.sh - Capability detection for kali-land platform

# Prevent re-sourcing
[ -n "${CAPABILITIES_SH_SOURCED:-}" ] && return 0
readonly CAPABILITIES_SH_SOURCED=1

# Source logging
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"

# Capabilities associative array: CAPABILITIES[<name>]="AVAILABLE|UNAVAILABLE"
declare -g -A CAPABILITIES

# detect_capabilities() - Detect all system and desktop capabilities
detect_capabilities() {
    log_step "Detecting system capabilities"

    # Core Display & Compositor
    detect_cap "wayland" "[ \"${XDG_SESSION_TYPE:-}\" = \"wayland\" ] || command -v Wayland &>/dev/null"
    detect_cap "hyprland" "command -v Hyprland &>/dev/null"
    detect_cap "xwayland" "command -v Xwayland &>/dev/null"
    detect_cap "hyprland-ipc" "[ -n \"${HYPRLAND_INSTANCE_SIGNATURE:-}\" ] || command -v hyprctl &>/dev/null"

    # Shell Runtime
    detect_cap "quickshell" "command -v quickshell &>/dev/null"

    # Desktop Services
    detect_cap "pipewire" "command -v pipewire &>/dev/null || systemctl --user is-active pipewire &>/dev/null"
    detect_cap "wireplumber" "command -v wireplumber &>/dev/null || systemctl --user is-active wireplumber &>/dev/null"
    detect_cap "networkmanager" "command -v nmcli &>/dev/null || systemctl is-active NetworkManager &>/dev/null"
    detect_cap "notifications" "command -v notify-send &>/dev/null"
    detect_cap "portals" "dpkg -s xdg-desktop-portal &>/dev/null"
    detect_cap "polkit" "dpkg -s libpolkit-gobject-1-dev &>/dev/null || command -v pkexec &>/dev/null"
    detect_cap "clipboard" "command -v wl-copy &>/dev/null && command -v cliphist &>/dev/null"

    # Utilities & Hardware Controls
    detect_cap "screenshot" "command -v grim &>/dev/null && command -v slurp &>/dev/null"
    detect_cap "lock" "command -v hyprlock &>/dev/null || command -v swaylock &>/dev/null"
    detect_cap "idle" "command -v hypridle &>/dev/null || command -v swayidle &>/dev/null"
    detect_cap "bluetooth" "command -v bluetoothctl &>/dev/null"
    detect_cap "battery" "[ -d /sys/class/power_supply ] && ls /sys/class/power_supply/BAT* &>/dev/null"
    detect_cap "brightness" "command -v brightnessctl &>/dev/null"

    log_success "Capability detection complete"
}

# detect_cap() - Internal helper to evaluate and register a capability
detect_cap() {
    local cap_name=$1
    local check_cmd=$2

    if eval "${check_cmd}"; then
        CAPABILITIES["${cap_name}"]="AVAILABLE"
        log_debug "Capability [${cap_name}]: AVAILABLE"
    else
        CAPABILITIES["${cap_name}"]="UNAVAILABLE"
        log_debug "Capability [${cap_name}]: UNAVAILABLE"
    fi
}

# has_capability() - Check if a capability is available
has_capability() {
    local cap_name=$1
    [ "${CAPABILITIES[${cap_name}]:-UNAVAILABLE}" = "AVAILABLE" ]
}

# print_capability_report() - Print capability detection summary
print_capability_report() {
    echo "=== CAPABILITY REPORT ==="
    
    echo "Required Platform Capabilities:"
    for cap in wayland hyprland quickshell; do
        if has_capability "${cap}"; then
            echo "  ✓ ${cap}: AVAILABLE"
        else
            echo "  ✗ ${cap}: MISSING"
        fi
    done

    echo ""
    echo "Desktop Services & Optional Capabilities:"
    for cap in pipewire wireplumber networkmanager notifications portals polkit clipboard screenshot lock idle bluetooth battery brightness; do
        if has_capability "${cap}"; then
            echo "  ✓ ${cap}: AVAILABLE"
        else
            echo "  - ${cap}: UNAVAILABLE (optional)"
        fi
    done
    echo "========================="
}

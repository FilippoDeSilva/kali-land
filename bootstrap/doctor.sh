#!/bin/bash
# doctor.sh - Diagnostic tool for kali-land

set -Eeuo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source library functions
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/platform.sh"
source "${SCRIPT_DIR}/lib/packages.sh"
source "${SCRIPT_DIR}/lib/capabilities.sh"
source "${SCRIPT_DIR}/lib/profile.sh"
source "${SCRIPT_DIR}/lib/integrations.sh"
source "${SCRIPT_DIR}/lib/backups.sh"
[ -f "${SCRIPT_DIR}/lib/ledger.sh" ] && source "${SCRIPT_DIR}/lib/ledger.sh"

# Test results
declare -A TEST_RESULTS

# test_platform() - Test platform compatibility
test_platform() {
    echo "=== Platform ==="
    
    detect_platform
    
    # OS test
    if is_kali; then
        echo "  OS              PASS (Kali Linux)"
        TEST_RESULTS[OS]=PASS
    else
        echo "  OS              WARN (${PLATFORM_DISTRO})"
        TEST_RESULTS[OS]=WARN
    fi
    
    # Architecture test
    if [ "${PLATFORM_ARCH}" = "x86_64" ] || [ "${PLATFORM_ARCH}" = "amd64" ]; then
        echo "  Architecture    PASS (${PLATFORM_ARCH})"
        TEST_RESULTS[Architecture]=PASS
    else
        echo "  Architecture    WARN (${PLATFORM_ARCH})"
        TEST_RESULTS[Architecture]=WARN
    fi
    
    # VMware test
    if is_vmware; then
        echo "  VMware          PASS (detected)"
        TEST_RESULTS[VMware]=PASS
    else
        echo "  VMware          INFO (${PLATFORM_VM})"
        TEST_RESULTS[VMware]=INFO
    fi
    
    echo ""
}

# test_display() - Test display system
test_display() {
    echo "=== Display ==="
    
    # Wayland test
    if is_wayland; then
        echo "  Wayland         PASS (running)"
        TEST_RESULTS[Wayland]=PASS
    else
        echo "  Wayland         INFO (not running - ${PLATFORM_SESSION_TYPE})"
        TEST_RESULTS[Wayland]=INFO
    fi
    
    # Hyprland test
    if command -v hyprland &>/dev/null; then
        echo "  Hyprland        PASS (installed)"
        TEST_RESULTS[Hyprland]=PASS
    else
        echo "  Hyprland        FAIL (not installed)"
        TEST_RESULTS[Hyprland]=FAIL
    fi
    
    # XWayland test
    if command -v Xwayland &>/dev/null; then
        echo "  XWayland        PASS (installed)"
        TEST_RESULTS[XWayland]=PASS
    else
        echo "  XWayland        INFO (not installed)"
        TEST_RESULTS[XWayland]=INFO
    fi
    
    echo ""
}

# Target home resolution for doctor diagnostics
TARGET_HOME="${HOME}"
if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
    TARGET_HOME="$(eval echo "~${SUDO_USER}")"
fi

# test_ledger() - Test resource ownership ledger health
test_ledger() {
    echo "=== State & Resource Ownership Ledger ==="
    
    local ledger_path="${TARGET_HOME}/.local/state/kali-land/state/installation.json"
    if [ -f "${ledger_path}" ]; then
        echo "  Ledger          PASS (exists at ${ledger_path})"
        TEST_RESULTS[Ledger]=PASS
    else
        echo "  Ledger          INFO (not initialized yet)"
        TEST_RESULTS[Ledger]=INFO
    fi
    echo ""
}

# test_shell() - Test Quickshell runtime & integrations (Optional under BYOS)
test_shell() {
    echo "=== Shell Runtime & Integrations ==="
    
    # Quickshell runtime test
    if command -v quickshell &>/dev/null; then
        echo "  Quickshell      PASS (installed)"
        TEST_RESULTS[Quickshell]=PASS
    else
        echo "  Quickshell      INFO (optional shell runtime not installed)"
        TEST_RESULTS[Quickshell]=INFO
    fi
    
    # Quickshell namespaced integration config test
    if [ -d "${TARGET_HOME}/.config/quickshell/end4-pC" ]; then
        echo "  end4-pC Shell   PASS (namespaced at ~/.config/quickshell/end4-pC)"
        TEST_RESULTS[QuickshellConfig]=PASS
    elif [ -d "${TARGET_HOME}/.config/quickshell" ]; then
        echo "  Quickshell Dir  PASS (custom shell directory exists)"
        TEST_RESULTS[QuickshellConfig]=PASS
    else
        echo "  Shell Config    INFO (no quickshell integration found)"
        TEST_RESULTS[QuickshellConfig]=INFO
    fi
    
    echo ""
}

# test_services() - Test desktop services
test_services() {
    echo "=== Services ==="
    
    # Audio test
    if command -v pipewire &>/dev/null || command -v pulseaudio &>/dev/null; then
        echo "  Audio           PASS (pipewire/pulseaudio available)"
        TEST_RESULTS[Audio]=PASS
    else
        echo "  Audio           WARN (audio service not found)"
        TEST_RESULTS[Audio]=WARN
    fi
    
    # Network test
    if command -v nmcli &>/dev/null; then
        echo "  Network         PASS (NetworkManager available)"
        TEST_RESULTS[Network]=PASS
    else
        echo "  Network         INFO (NetworkManager not found)"
        TEST_RESULTS[Network]=INFO
    fi
    
    # Notifications test
    if command -v dunst &>/dev/null || command -v mako &>/dev/null; then
        echo "  Notifications   PASS (dunst/mako available)"
        TEST_RESULTS[Notifications]=PASS
    else
        echo "  Notifications   INFO (notification daemon not found)"
        TEST_RESULTS[Notifications]=INFO
    fi
    
    # Clipboard test
    if command -v cliphist &>/dev/null; then
        echo "  Clipboard       PASS (cliphist available)"
        TEST_RESULTS[Clipboard]=PASS
    else
        echo "  Clipboard       INFO (clipboard manager not found)"
        TEST_RESULTS[Clipboard]=INFO
    fi
    
    # Portal test
    if dpkg -s xdg-desktop-portal &>/dev/null; then
        echo "  Portal          PASS (xdg-desktop-portal available)"
        TEST_RESULTS[Portal]=PASS
    else
        echo "  Portal          WARN (xdg-desktop-portal not found)"
        TEST_RESULTS[Portal]=WARN
    fi
    
    # hyprland-guiutils test
    if dpkg -s hyprland-guiutils &>/dev/null; then
        echo "  Hyprland GUI Utils PASS (hyprland-guiutils available)"
        TEST_RESULTS[HyprlandGuiUtils]=PASS
    else
        echo "  Hyprland GUI Utils WARN (hyprland-guiutils not installed - run install script)"
        TEST_RESULTS[HyprlandGuiUtils]=WARN
    fi
    
    echo ""
}

# test_configuration() - Test configuration files
test_configuration() {
    echo "=== Configuration ==="
    
    # Hyprland platform config test
    if [ -d "${TARGET_HOME}/.config/hypr/kali-land" ]; then
        echo "  Platform Hypr   PASS (isolated at ~/.config/hypr/kali-land/)"
        TEST_RESULTS[HyprlandPlatform]=PASS
    else
        echo "  Platform Hypr   INFO (~/.config/hypr/kali-land/ not found)"
        TEST_RESULTS[HyprlandPlatform]=INFO
    fi

    # Hyprland entrypoint test
    if [ -f "${TARGET_HOME}/.config/hypr/hyprland.lua" ] || [ -f "${TARGET_HOME}/.config/hypr/hyprland.conf" ]; then
        echo "  Hyprland Config PASS (entry point file exists)"
        TEST_RESULTS[HyprlandConfig]=PASS
    else
        echo "  Hyprland Config INFO (top-level config not found)"
        TEST_RESULTS[HyprlandConfig]=INFO
    fi
    
    # CLI Engine test
    if command -v kali-land &>/dev/null || [ -f "/usr/local/bin/kali-land" ]; then
        echo "  CLI Engine      PASS (/usr/local/bin/kali-land available)"
        TEST_RESULTS[CLIEngine]=PASS
    else
        echo "  CLI Engine      INFO (kali-land executable not symlinked in PATH)"
        TEST_RESULTS[CLIEngine]=INFO
    fi

    # Ownership Ledger test
    if [ -f "${TARGET_HOME}/.local/state/kali-land/state/installation.json" ]; then
        echo "  Ownership Ledger PASS (installation.json present)"
        TEST_RESULTS[LedgerState]=PASS
    else
        echo "  Ownership Ledger INFO (installation.json not initialized)"
        TEST_RESULTS[LedgerState]=INFO
    fi

    # Theme test
    if [ -d "${REPO_ROOT}/themes/default" ]; then
        echo "  Theme           PASS (exists)"
        TEST_RESULTS[Theme]=PASS
    else
        echo "  Theme           INFO (not found)"
        TEST_RESULTS[Theme]=INFO
    fi
    
    echo ""
}

# print_summary() - Print test summary
print_summary() {
    echo "=== SUMMARY ==="
    
    local pass_count=0
    local warn_count=0
    local fail_count=0
    local info_count=0
    
    for result in "${TEST_RESULTS[@]}"; do
        case "${result}" in
            PASS) pass_count=$((pass_count + 1)) ;;
            WARN) warn_count=$((warn_count + 1)) ;;
            FAIL) fail_count=$((fail_count + 1)) ;;
            INFO) info_count=$((info_count + 1)) ;;
        esac
    done
    
    echo "  PASS:  ${pass_count}"
    echo "  WARN:  ${warn_count}"
    echo "  FAIL:  ${fail_count}"
    echo "  INFO:  ${info_count}"
    echo ""
    
    if [ ${fail_count} -gt 0 ]; then
        echo "Status: FAIL - Some critical components are missing"
        echo ""
        echo "Missing components:"
        for key in "${!TEST_RESULTS[@]}"; do
            if [ "${TEST_RESULTS[$key]}" = "FAIL" ]; then
                echo "  - ${key}"
            fi
        done
        return 1
    elif [ ${warn_count} -gt 0 ]; then
        echo "Status: WARN - Some components need attention"
        return 0
    else
        echo "Status: PASS - All critical components are present"
        return 0
    fi
}

# test_capabilities_section() - Run capability model check
test_capabilities_section() {
    detect_capabilities
    echo "=== Capabilities ==="
    for cap in wayland hyprland quickshell pipewire networkmanager notifications portals polkit clipboard; do
        if has_capability "${cap}"; then
            echo "  ${cap}           PASS"
            TEST_RESULTS[Cap_${cap}]=PASS
        else
            echo "  ${cap}           INFO (optional/missing)"
            TEST_RESULTS[Cap_${cap}]=INFO
        fi
    done
    echo ""
}

# test_profile_section() - Test profile detection
test_profile_section() {
    detect_profile
    echo "=== Profile ==="
    echo "  Profile         PASS (${CURRENT_PROFILE})"
    TEST_RESULTS[Profile]=PASS
    echo ""
}

# test_integrations_section() - Test shell integrations
test_integrations_section() {
    echo "=== Shell Integrations ==="
    if [ -d "${REPO_ROOT}/integrations/end4-pC" ]; then
        echo "  end4-pC (ref)   PASS (available)"
        TEST_RESULTS[Integration_end4_pC]=PASS
    else
        echo "  end4-pC (ref)   WARN (missing from integrations/)"
        TEST_RESULTS[Integration_end4_pC]=WARN
    fi
    echo ""
}

# test_package_manager_health() - Test dpkg and package manager health
test_package_manager_health() {
    echo "=== Package Manager ==="
    if ensure_dpkg_healthy; then
        echo "  dpkg/apt status PASS (healthy)"
        TEST_RESULTS[PackageManager]=PASS
    else
        echo "  dpkg/apt status WARN (issues detected)"
        TEST_RESULTS[PackageManager]=WARN
    fi
    echo ""
}

# main() - Main diagnostic function
main() {
    clear
    echo "=========================================="
    echo "  kali-land Desktop Doctor"
    echo "=========================================="
    echo ""
    
    test_platform
    test_ledger
    test_package_manager_health
    test_profile_section
    test_capabilities_section
    test_display
    test_shell
    test_integrations_section
    test_services
    test_configuration
    
    print_summary
    
    echo ""
    echo "For detailed troubleshooting, see docs/troubleshooting.md"
}

# Run main function
main "$@"

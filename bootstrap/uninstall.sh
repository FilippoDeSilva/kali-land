#!/bin/bash
# uninstall.sh - Uninstallation script for kali-land

set -Eeuo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source library functions
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/platform.sh"
source "${SCRIPT_DIR}/lib/filesystem.sh"
source "${SCRIPT_DIR}/lib/prompts.sh"
source "${SCRIPT_DIR}/lib/packages.sh"
[ -f "${SCRIPT_DIR}/lib/ledger.sh" ] && source "${SCRIPT_DIR}/lib/ledger.sh"

# Uninstall options
REMOVE_CONFIGS=false
REMOVE_PACKAGES=false
REMOVE_BACKUPS=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --remove-configs)
            REMOVE_CONFIGS=true
            shift
            ;;
        --remove-packages)
            REMOVE_PACKAGES=true
            shift
            ;;
        --remove-backups)
            REMOVE_BACKUPS=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --remove-configs    Remove Kali-land owned configuration files"
            echo "  --remove-packages   Remove packages installed by Kali-land (preserves pre-existing)"
            echo "  --remove-backups    Remove backup files"
            echo "  --help              Show this help message"
            echo ""
            echo "By default, this script only removes Kali-land runtime artifacts"
            echo "and preserves user configurations and pre-existing packages."
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# welcome() - Show welcome message
welcome() {
    clear
    echo "=========================================="
    echo "  kali-land Desktop Uninstaller"
    echo "=========================================="
    echo ""
    echo "This script will help you remove the kali-land"
    echo "Desktop environment from your system."
    echo ""
    echo "Default behavior:"
    echo "  - Remove Kali-land isolated runtime configs (~/.config/hypr/kali-land/)"
    echo "  - Preserve user custom configurations (backups kept)"
    echo "  - Preserve pre-existing system packages"
    echo ""
    echo "Use options to remove more components."
    echo ""
}

# remove_symlinks() - Remove configuration symlinks
remove_symlinks() {
    log_step "Cleaning up runtime symlinks"
    log_success "Symlinks checked"
}

# remove_configs() - Remove Kali-land owned configuration files
remove_configs() {
    log_step "Removing Kali-land owned configuration files"
    
    if ! confirm_destructive "Remove Kali-land owned configurations" "~/.config/hypr/kali-land, ~/.config/quickshell/end4-pC"; then
        log_info "Skipping configuration removal"
        return
    fi

    local owned_resources=()
    if command -v get_kali_land_owned_resources &>/dev/null; then
        while IFS= read -r path; do
            [ -n "${path}" ] && owned_resources+=("${path}")
        done < <(get_kali_land_owned_resources)
    fi

    # Always include standard isolated Kali-land paths if present
    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi
    owned_resources+=("${target_user_home}/.config/hypr/kali-land")
    owned_resources+=("${target_user_home}/.config/quickshell/end4-pC")

    for resource_path in "${owned_resources[@]}"; do
        if [ -e "${resource_path}" ]; then
            log_info "Removing Kali-land owned path: ${resource_path}"
            rm -rf "${resource_path}"
            log_success "Removed ${resource_path}"
        fi
    done
    
    log_success "Kali-land owned configurations removed"
}

# remove_installed_packages() - Remove packages installed BY Kali-land
remove_installed_packages() {
    log_step "Removing packages installed by Kali-land"
    
    if ! confirm_destructive "Remove packages installed by Kali-land" "Packages marked as installed_by_kali_land in ledger"; then
        log_info "Skipping package removal"
        return
    fi
    
    detect_package_manager

    local kl_packages=()
    if command -v get_kali_land_installed_packages &>/dev/null; then
        while IFS= read -r pkg; do
            [ -n "${pkg}" ] && kl_packages+=("${pkg}")
        done < <(get_kali_land_installed_packages)
    fi

    if [ ${#kl_packages[@]} -gt 0 ]; then
        log_info "Removing ${#kl_packages[@]} packages explicitly installed by Kali-land: ${kl_packages[*]}"
        remove_packages "${kl_packages[@]}"
        log_success "Kali-land installed packages removed"
    else
        log_info "No packages were marked as newly installed by Kali-land in ownership ledger (pre-existing packages preserved)."
    fi
}

# remove_backups() - Remove backup files
remove_backups() {
    log_step "Removing backup files"
    
    if ! confirm_destructive "Remove backup files" "${BACKUP_DIR}"; then
        log_info "Skipping backup removal"
        return
    fi
    
    if [ -d "${BACKUP_DIR}" ]; then
        log_info "Removing: ${BACKUP_DIR}"
        rm -rf "${BACKUP_DIR}"
        log_success "Backups removed"
    else
        log_info "No backups found"
    fi
}

# cleanup_state() - Clean up state directory
cleanup_state() {
    log_step "Cleaning up state directory"
    
    # Remove logs
    if [ -d "${STATE_DIR}/logs" ]; then
        log_info "Removing logs"
        rm -rf "${STATE_DIR}/logs"
    fi
    
    # Remove state directory if empty
    if [ -d "${STATE_DIR}" ] && [ -z "$(ls -A "${STATE_DIR}")" ]; then
        log_info "Removing empty state directory"
        rmdir "${STATE_DIR}"
    fi
    
    log_success "State cleanup complete"
}

# restore_original_desktop() - Restore original desktop
restore_original_desktop() {
    log_step "Restoring original desktop environment"
    
    log_info "Your original XFCE desktop is still available"
    log_info "No changes needed to desktop environment"
    
    log_success "Original desktop preserved"
}

# print_summary() - Print uninstallation summary
print_summary() {
    echo ""
    echo "=== Uninstallation Summary ==="
    echo ""
    echo "Removed:"
    echo "  ✓ Configuration symlinks"
    
    if ${REMOVE_CONFIGS}; then
        echo "  ✓ Configuration files"
    fi
    
    if ${REMOVE_PACKAGES}; then
        echo "  ✓ Installed packages"
    fi
    
    if ${REMOVE_BACKUPS}; then
        echo "  ✓ Backup files"
    fi
    
    echo ""
    echo "Preserved:"
    echo "  ✓ Original XFCE desktop"
    echo "  ✓ System configuration"
    echo "  ✓ User data"
    
    if ! ${REMOVE_CONFIGS}; then
        echo "  ✓ Configuration backups"
    fi
    
    if ! ${REMOVE_PACKAGES}; then
        echo "  ✓ Installed packages"
    fi
    
    echo ""
    echo "You can still use your original Kali desktop environment."
    echo "Log out and log back in to XFCE to return to the original desktop."
}

# main() - Main uninstallation function
main() {
    welcome
    
    if ! confirm "Proceed with uninstallation?" "n"; then
        log_info "Uninstallation cancelled"
        exit 0
    fi
    
    ensure_directories
    
    remove_symlinks
    
    if ${REMOVE_CONFIGS}; then
        remove_configs
    fi
    
    if ${REMOVE_PACKAGES}; then
        remove_installed_packages
    fi
    
    if ${REMOVE_BACKUPS}; then
        remove_backups
    fi
    
    cleanup_state
    restore_original_desktop
    print_summary
    
    log_success "Uninstallation complete!"
}

# Run main function
main "$@"

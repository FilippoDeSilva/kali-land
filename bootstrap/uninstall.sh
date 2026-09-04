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
            echo "  --remove-configs    Remove configuration files"
            echo "  --remove-packages   Remove installed packages"
            echo "  --remove-backups    Remove backup files"
            echo "  --help              Show this help message"
            echo ""
            echo "By default, this script only removes symlinks and"
            echo "preserves configurations and packages."
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
    echo "  - Remove configuration symlinks"
    echo "  - Preserve configurations (backups kept)"
    echo "  - Preserve installed packages"
    echo ""
    echo "Use options to remove more components."
    echo ""
}

# remove_symlinks() - Remove configuration symlinks
remove_symlinks() {
    log_step "Removing configuration symlinks"
    
    local configs=(
        "hypr"
        "quickshell"
        "kitty"
        "foot"
        "mako"
        "wlogout"
        "hyprlock"
        "hypridle"
    )
    
    for config in "${configs[@]}"; do
        local config_path="${HOME}/.config/${config}"
        
        if [ -L "${config_path}" ]; then
            log_info "Removing symlink: ${config_path}"
            rm "${config_path}"
            log_success "Removed ${config}"
        elif [ -e "${config_path}" ]; then
            log_info "Not a symlink, skipping: ${config_path}"
        fi
    done
    
    log_success "Symlinks removed"
}

# remove_configs() - Remove configuration files
remove_configs() {
    log_step "Removing configuration files"
    
    if ! confirm_destructive "Remove configuration files" "~/.config/*"; then
        log_info "Skipping configuration removal"
        return
    fi
    
    local configs=(
        "hypr"
        "quickshell"
        "kitty"
        "foot"
        "mako"
        "wlogout"
        "hyprlock"
        "hypridle"
    )
    
    for config in "${configs[@]}"; do
        remove_config "${config}"
    done
    
    log_success "Configurations removed"
}

# remove_installed_packages() - Remove installed packages
remove_installed_packages() {
    log_step "Removing installed packages"
    
    if ! confirm_destructive "Remove installed packages" "wayland, desktop services, etc."; then
        log_info "Skipping package removal"
        return
    fi
    
    detect_package_manager
    
    # Read package lists and remove packages
    local package_files=(
        "${REPO_ROOT}/packages/wayland.txt"
        "${REPO_ROOT}/packages/desktop-services.txt"
        "${REPO_ROOT}/packages/applications.txt"
    )
    
    for package_file in "${package_files[@]}"; do
        if [ -f "${package_file}" ]; then
            local packages=()
            while IFS= read -r line || [ -n "$line" ]; do
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                [[ -z "${line// }" ]] && continue
                packages+=("$line")
            done < "${package_file}"
            
            if [ ${#packages[@]} -gt 0 ]; then
                log_info "Removing packages from ${package_file}"
                remove_packages "${packages[@]}"
            fi
        fi
    done
    
    log_success "Packages removed"
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

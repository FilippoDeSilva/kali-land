#!/bin/bash
# filesystem.sh - Filesystem operations and backup management

# Prevent re-sourcing
[ -n "${FILESYSTEM_SH_SOURCED:-}" ] && return 0
readonly FILESYSTEM_SH_SOURCED=1

# Source logging
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"

# Directory constants
REPO_ROOT="$(cd "${LIB_DIR}/../.." && pwd)"
CONFIG_DIR="${HOME}/.config"
BACKUP_DIR="${HOME}/.local/state/kali-land/backups"
STATE_DIR="${HOME}/.local/state/kali-land"

# ensure_directories() - Create required directories
ensure_directories() {
    log_step "Creating required directories"
    
    local dirs=(
        "${BACKUP_DIR}"
        "${STATE_DIR}"
        "${STATE_DIR}/logs"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "${dir}" ]; then
            log_info "Creating directory: ${dir}"
            mkdir -p "${dir}"
        fi
    done
    
    log_success "Directories created"
}

# backup_config() - Backup existing configuration
# Usage: backup_config <config_name>
backup_config() {
    local config_name=$1
    local timestamp=$(date +%Y-%m-%dT%H-%M-%S)
    local backup_path="${BACKUP_DIR}/${timestamp}/${config_name}"
    local source_path="${CONFIG_DIR}/${config_name}"
    
    if [ ! -e "${source_path}" ]; then
        log_info "No existing config to backup: ${config_name}"
        return 0
    fi
    
    log_step "Backing up ${config_name}"
    
    mkdir -p "${backup_path}"
    
    if cp -r "${source_path}" "${backup_path}/"; then
        log_success "Backed up ${config_name} to ${backup_path}"
        echo "${backup_path}"  # Return backup path
        return 0
    else
        log_failure "Failed to backup ${config_name}"
        return 1
    fi
}

# restore_config() - Restore configuration from backup
# Usage: restore_config <backup_path> <config_name>
restore_config() {
    local backup_path=$1
    local config_name=$2
    local target_path="${CONFIG_DIR}/${config_name}"
    
    if [ ! -d "${backup_path}" ]; then
        log_error "Backup path not found: ${backup_path}"
        return 1
    fi
    
    log_step "Restoring ${config_name} from ${backup_path}"
    
    # Remove existing config
    if [ -e "${target_path}" ]; then
        log_info "Removing existing config: ${target_path}"
        rm -rf "${target_path}"
    fi
    
    if cp -r "${backup_path}/${config_name}" "${target_path}"; then
        log_success "Restored ${config_name}"
        return 0
    else
        log_failure "Failed to restore ${config_name}"
        return 1
    fi
}

# install_config() - Install configuration from repo
# Usage: install_config <config_name> [use_symlinks]
install_config() {
    local config_name=$1
    local use_symlinks=${2:-false}
    local source_path="${REPO_ROOT}/config/${config_name}"
    local target_path="${CONFIG_DIR}/${config_name}"
    
    if [ ! -e "${source_path}" ]; then
        log_error "Config not found in repo: ${config_name}"
        return 1
    fi
    
    log_step "Installing ${config_name}"
    
    # Backup existing config
    backup_config "${config_name}"
    
    # Remove existing config
    if [ -e "${target_path}" ]; then
        log_info "Removing existing config: ${target_path}"
        rm -rf "${target_path}"
    fi
    
    # Install new config
    if [ "${use_symlinks}" = "true" ]; then
        log_info "Creating symlink: ${target_path} -> ${source_path}"
        ln -s "${source_path}" "${target_path}"
    else
        log_info "Copying config: ${source_path} -> ${target_path}"
        cp -r "${source_path}" "${target_path}"
    fi
    
    if [ $? -eq 0 ]; then
        log_success "Installed ${config_name}"
        return 0
    else
        log_failure "Failed to install ${config_name}"
        return 1
    fi
}

# remove_config() - Remove configuration
# Usage: remove_config <config_name>
remove_config() {
    local config_name=$1
    local target_path="${CONFIG_DIR}/${config_name}"
    
    if [ ! -e "${target_path}" ]; then
        log_info "Config not found: ${config_name}"
        return 0
    fi
    
    log_step "Removing ${config_name}"
    
    # Backup before removing
    backup_config "${config_name}"
    
    if rm -rf "${target_path}"; then
        log_success "Removed ${config_name}"
        return 0
    else
        log_failure "Failed to remove ${config_name}"
        return 1
    fi
}

# list_backups() - List available backups
list_backups() {
    log_info "Available backups:"
    
    if [ ! -d "${BACKUP_DIR}" ]; then
        log_info "No backups found"
        return 0
    fi
    
    for backup in "${BACKUP_DIR}"/*/; do
        if [ -d "${backup}" ]; then
            local timestamp=$(basename "${backup}")
            log_info "  ${timestamp}"
            # List configs in this backup
            for config in "${backup}"/*/; do
                if [ -d "${config}" ]; then
                    log_info "    - $(basename "${config}")"
                fi
            done
        fi
    done
}

# cleanup_old_backups() - Remove old backups (keep last N)
# Usage: cleanup_old_backups <keep_count>
cleanup_old_backups() {
    local keep_count=${1:-5}
    
    log_step "Cleaning up old backups (keeping last ${keep_count})"
    
    if [ ! -d "${BACKUP_DIR}" ]; then
        log_info "No backups to clean"
        return 0
    fi
    
    # List backups sorted by time, remove old ones
    local backup_count=0
    for backup in $(ls -t "${BACKUP_DIR}"/); do
        backup_count=$((backup_count + 1))
        if [ ${backup_count} -gt ${keep_count} ]; then
            log_info "Removing old backup: ${backup}"
            rm -rf "${BACKUP_DIR}/${backup}"
        fi
    done
    
    log_success "Backup cleanup complete"
}

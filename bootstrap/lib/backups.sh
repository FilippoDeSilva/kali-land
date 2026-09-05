#!/bin/bash
# backups.sh - Protected manifest backups & offline rollback system

# Prevent re-sourcing
[ -n "${BACKUPS_SH_SOURCED:-}" ] && return 0
readonly BACKUPS_SH_SOURCED=1

# Source logging and prompts
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"
source "${LIB_DIR}/prompts.sh"

# Target user and home directory resolution (handles sudo execution)
if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
    TARGET_USER="${SUDO_USER}"
    TARGET_HOME="$(eval echo "~${SUDO_USER}")"
else
    TARGET_USER="$(id -un)"
    TARGET_HOME="${HOME}"
fi

STATE_DIR="${TARGET_HOME}/.local/state/kali-land"
BACKUP_BASE="${STATE_DIR}/backups"

# protect_and_install_config() - Protect user configuration: detect -> prompt -> backup -> change -> validate
# Usage: protect_and_install_config <source_dir> <target_dir> <component_name>
protect_and_install_config() {
    local source_path=$1
    local target_path=$2
    local component_name=$3

    log_step "Installing configuration for ${component_name}"

    # Check if target config already exists
    if [ -e "${target_path}" ]; then
        log_info "Existing configuration detected at: ${target_path}"

        # Interactive prompt before touching user settings
        if [ "${INTERACTIVE:-true}" = "true" ]; then
            log_warn "Existing user configuration found for ${component_name}."
            if ! confirm "Would you like to back up your existing ${component_name} configuration and deploy kali-land settings?" "y"; then
                log_info "Skipping installation of ${component_name} per user request"
                return 0
            fi
        fi

        # Perform timestamped backup with manifest
        backup_config_with_manifest "${target_path}" "${component_name}"
        
        log_info "Removing old configuration: ${target_path}"
        rm -rf "${target_path}"
    fi

    # Deploy new config
    log_info "Copying ${source_path} -> ${target_path}"
    mkdir -p "$(dirname "${target_path}")"
    if cp -r "${source_path}" "${target_path}"; then
        if [ -n "${TARGET_USER}" ]; then
            local user_group
            user_group="$(id -gn "${TARGET_USER}" 2>/dev/null || echo "${TARGET_USER}")"
            chown -R "${TARGET_USER}:${user_group}" "${target_path}" 2>/dev/null || true
            chown -R "${TARGET_USER}:${user_group}" "$(dirname "${target_path}")" 2>/dev/null || true
        fi
        log_success "Successfully deployed configuration for ${component_name}"
        return 0
    else
        log_failure "Failed to deploy configuration for ${component_name}"
        return 1
    fi
}

# backup_config_with_manifest() - Create a timestamped backup with manifest.txt
backup_config_with_manifest() {
    local target_path=$1
    local component_name=$2

    local timestamp=$(date +%Y-%m-%dT%H-%M-%S)
    local backup_dir="${BACKUP_BASE}/${timestamp}"
    local backup_target="${backup_dir}/$(basename "${target_path}")"
    local manifest_file="${backup_dir}/manifest.txt"

    log_step "Creating timestamped backup at ${backup_dir}"

    mkdir -p "${backup_dir}"

    if cp -r "${target_path}" "${backup_target}"; then
        # Create structured manifest.txt
        cat <<EOF > "${manifest_file}"
# kali-land Backup Manifest
Timestamp: ${timestamp}
Component: ${component_name}
Original Path: ${target_path}
Backup Path: ${backup_target}
Created By: kali-land installer
EOF
        log_success "Backed up ${component_name} to ${backup_target}"
        log_info "Manifest recorded: ${manifest_file}"
        return 0
    else
        log_failure "Failed to back up ${component_name}"
        return 1
    fi
}

# list_backups_detailed() - List all timestamped backups and manifests
list_backups_detailed() {
    log_info "Scanning backup archive at ${BACKUP_BASE}"

    if [ ! -d "${BACKUP_BASE}" ]; then
        log_info "No backups found."
        return 0
    fi

    echo "=== KALI-LAND BACKUP ARCHIVE ==="
    for bdir in "${BACKUP_BASE}"/*; do
        if [ -d "${bdir}" ]; then
            local ts=$(basename "${bdir}")
            local manifest="${bdir}/manifest.txt"
            echo "  Backup: ${ts}"
            if [ -f "${manifest}" ]; then
                grep -E "Component:|Original Path:" "${manifest}" | sed 's/^/    /'
            fi
        fi
    done
    echo "================================="
}

# restore_from_manifest() - Restore a backup given its timestamp directory
restore_from_manifest() {
    local timestamp=$1
    local backup_dir="${BACKUP_BASE}/${timestamp}"
    local manifest_file="${backup_dir}/manifest.txt"

    if [ ! -d "${backup_dir}" ] || [ ! -f "${manifest_file}" ]; then
        log_error "Backup directory or manifest not found for timestamp: ${timestamp}"
        return 1
    fi

    local original_path=$(grep "Original Path:" "${manifest_file}" | cut -d':' -f2- | xargs)
    local backup_path=$(grep "Backup Path:" "${manifest_file}" | cut -d':' -f2- | xargs)

    log_step "Restoring backup from ${timestamp}"
    log_info "Target: ${original_path}"
    log_info "Source: ${backup_path}"

    if [ -e "${original_path}" ]; then
        rm -rf "${original_path}"
    fi

    if cp -r "${backup_path}" "${original_path}"; then
        log_success "Restored configuration to ${original_path}"
        return 0
    else
        log_failure "Failed to restore backup"
        return 1
    fi
}

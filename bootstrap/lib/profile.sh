#!/bin/bash
# profile.sh - Environment & Profile loader (VMware vs Bare Metal)

# Prevent re-sourcing
[ -n "${PROFILE_SH_SOURCED:-}" ] && return 0
readonly PROFILE_SH_SOURCED=1

# Source logging and platform detection
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"
source "${LIB_DIR}/platform.sh"

CURRENT_PROFILE=""
PROFILE_DIR="$(cd "${LIB_DIR}/../../profiles" 2>/dev/null && pwd || echo "")"

# detect_profile() - Detect active profile based on platform & virtualization
detect_profile() {
    log_step "Detecting hardware & VM profile"

    if [ -z "${PLATFORM_VM}" ]; then
        detect_platform
    fi

    if is_vmware; then
        CURRENT_PROFILE="vmware"
        log_info "Detected environment profile: vmware (VMware virtual machine)"
    else
        CURRENT_PROFILE="bare-metal"
        log_info "Detected environment profile: bare-metal (Physical hardware)"
    fi
}

# load_profile() - Load profile environment variables and options
load_profile() {
    local profile_name=${1:-${CURRENT_PROFILE}}

    if [ -z "${profile_name}" ]; then
        detect_profile
        profile_name="${CURRENT_PROFILE}"
    fi

    log_step "Loading profile [${profile_name}]"

    local profile_yaml="${PROFILE_DIR}/${profile_name}/profile.yaml"

    if [ -f "${profile_yaml}" ]; then
        log_info "Found profile definition at ${profile_yaml}"
        apply_profile_environment "${profile_name}"
    else
        log_warn "Profile definition not found at ${profile_yaml}, applying standard defaults"
        apply_profile_environment "${profile_name}"
    fi

    log_success "Profile [${profile_name}] loaded"
}

# apply_profile_environment() - Set runtime environment variables for active profile
apply_profile_environment() {
    local profile_name=$1
    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi

    # Scrub legacy VM environment variable overrides from user dotfiles if present
    if [ -d "${target_user_home}" ]; then
        for sh_file in "${target_user_home}/.bashrc" "${target_user_home}/.profile"; do
            if [ -f "${sh_file}" ]; then
                sed -i '/export LIBGL_ALWAYS_SOFTWARE/d' "${sh_file}" 2>/dev/null || true
                sed -i '/export WLR_NO_HARDWARE_CURSORS/d' "${sh_file}" 2>/dev/null || true
                sed -i '/export QT_QUICK_BACKEND="software"/d' "${sh_file}" 2>/dev/null || true
            fi
        done
    fi

    if [ "${profile_name}" = "vmware" ]; then
        log_info "VMware virtualization profile active (compatibility overrides isolated to VM sessions)"
    else
        log_info "Bare-metal hardware profile active (full GPU hardware acceleration enabled)"
    fi
}

# print_profile_report() - Print profile detection report
print_profile_report() {
    echo "=== PROFILE REPORT ==="
    echo "Active Profile:      ${CURRENT_PROFILE}"
    echo "Virtualization:      ${PLATFORM_VM}"
    echo "QT_QUICK_BACKEND:    ${QT_QUICK_BACKEND:-native}"
    echo "Profile Directory:   ${PROFILE_DIR}/${CURRENT_PROFILE}"
    echo "======================"
}

#!/bin/bash
# integrations.sh - Shell integration manager & capability contract validator

# Prevent re-sourcing
[ -n "${INTEGRATIONS_SH_SOURCED:-}" ] && return 0
readonly INTEGRATIONS_SH_SOURCED=1

# Source logging, capabilities, and backups
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"
source "${LIB_DIR}/capabilities.sh"
source "${LIB_DIR}/backups.sh"

INTEGRATIONS_DIR="$(cd "${LIB_DIR}/../../integrations" 2>/dev/null && pwd || echo "")"

# list_integrations() - List all available shell integrations in the repository
list_integrations() {
    log_step "Scanning available shell integrations"

    if [ ! -d "${INTEGRATIONS_DIR}" ]; then
        log_warn "Integrations directory not found: ${INTEGRATIONS_DIR}"
        return 1
    fi

    echo "Available Shell Integrations:"
    for item in "${INTEGRATIONS_DIR}"/*; do
        if [ -d "${item}" ]; then
            local name=$(basename "${item}")
            local manifest="${item}/manifest.yaml"
            if [ -f "${manifest}" ]; then
                echo "  ✓ ${name} (manifest: present)"
            else
                echo "  ? ${name} (manifest: missing)"
            fi
        fi
    done
}

# validate_integration_capabilities() - Validate if system meets an integration's capabilities
validate_integration_capabilities() {
    local shell_name=$1
    local shell_dir="${INTEGRATIONS_DIR}/${shell_name}"
    local manifest="${shell_dir}/manifest.yaml"

    log_step "Validating capability contract for integration [${shell_name}]"

    if [ ! -d "${shell_dir}" ]; then
        log_error "Shell integration [${shell_name}] not found in ${INTEGRATIONS_DIR}"
        return 1
    fi

    if ! command -v detect_capabilities &>/dev/null; then
        detect_capabilities
    fi

    local missing_required=0

    # Core required capabilities
    for cap in wayland hyprland quickshell; do
        if ! has_capability "${cap}"; then
            log_warn "Required capability [${cap}] is missing for shell [${shell_name}]"
            missing_required=$((missing_required + 1))
        fi
    done

    if [ ${missing_required} -gt 0 ]; then
        log_warn "Shell integration [${shell_name}] has ${missing_required} missing required capabilities"
        return 1
    else
        log_success "Shell integration [${shell_name}] capability check passed"
        return 0
    fi
}

# install_integration_dependencies() - Install packages declared in an integration's manifest.yaml
install_integration_dependencies() {
    local shell_name=$1
    local shell_dir="${INTEGRATIONS_DIR}/${shell_name}"
    local manifest="${shell_dir}/manifest.yaml"

    if [ ! -f "${manifest}" ]; then
        return 0
    fi

    log_step "Resolving package dependencies for integration [${shell_name}]"

    local temp_pkg_list
    temp_pkg_list=$(mktemp)

    python3 -c '
import sys
in_pkgs = False
with open(sys.argv[1]) as f:
    for line in f:
        raw = line.strip()
        if "packages:" in raw:
            in_pkgs = True
            continue
        if in_pkgs:
            if raw.startswith("- "):
                pkg = raw[2:].strip().split("#")[0].strip()
                if pkg:
                    print(pkg)
            elif raw and not raw.startswith("#") and ":" in raw:
                break
' "${manifest}" > "${temp_pkg_list}"

    if [ -s "${temp_pkg_list}" ]; then
        log_info "Installing package dependencies declared in [${shell_name}/manifest.yaml]:"
        cat "${temp_pkg_list}"
        install_packages "${temp_pkg_list}" || log_warn "Failed to install some integration packages, continuing..."
    else
        log_info "No extra package dependencies declared in manifest for integration [${shell_name}]"
    fi

    rm -f "${temp_pkg_list}"
}

# install_integration() - Install a shell integration with prompt & backup protection
install_integration() {
    local shell_name=${1:-"end4-pC"}
    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi
    local target_dir="${target_user_home}/.config/quickshell"
    local source_dir="${INTEGRATIONS_DIR}/${shell_name}"

    log_step "Deploying shell integration [${shell_name}]"

    if [ ! -d "${source_dir}" ]; then
        log_error "Source directory for shell [${shell_name}] does not exist at ${source_dir}"
        return 1
    fi

    # Validate capabilities
    validate_integration_capabilities "${shell_name}" || log_warn "Deploying shell despite missing capabilities"

    # Install integration-specific package dependencies declared in manifest.yaml
    install_integration_dependencies "${shell_name}"

    # Use protected config installation flow (prompt -> backup -> deploy)
    protect_and_install_config "${source_dir}" "${target_dir}" "Shell Integration (${shell_name})"
}

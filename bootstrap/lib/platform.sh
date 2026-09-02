#!/bin/bash
# platform.sh - Platform detection and validation

# Prevent re-sourcing
[ -n "${PLATFORM_SH_SOURCED:-}" ] && return 0
readonly PLATFORM_SH_SOURCED=1

# Source logging
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"

# Platform detection variables
PLATFORM_OS=""
PLATFORM_DISTRO=""
PLATFORM_VERSION=""
PLATFORM_ARCH=""
PLATFORM_VM=""
PLATFORM_GPU=""
PLATFORM_SESSION_TYPE=""
PLATFORM_CURRENT_DESKTOP=""
PLATFORM_DISPLAY_MANAGER=""

# detect_platform() - Detect all platform information
detect_platform() {
    log_step "Detecting platform information"
    
    # OS and distro
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        PLATFORM_OS="${ID}"
        PLATFORM_DISTRO="${NAME}"
        PLATFORM_VERSION="${VERSION_ID}"
        log_info "OS: ${PLATFORM_DISTRO} ${PLATFORM_VERSION}"
    else
        log_error "Cannot detect OS - /etc/os-release not found"
        return 1
    fi
    
    # Architecture
    PLATFORM_ARCH=$(uname -m)
    log_info "Architecture: ${PLATFORM_ARCH}"
    
    # Virtualization
    PLATFORM_VM=$(systemd-detect-virt 2>/dev/null || echo "none")
    log_info "Virtualization: ${PLATFORM_VM}"
    
    # GPU
    PLATFORM_GPU=$(lspci | grep -Ei 'vga|3d|display' | head -1 || echo "unknown")
    log_info "GPU: ${PLATFORM_GPU}"
    
    # Session information
    PLATFORM_SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"
    PLATFORM_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-unknown}"
    PLATFORM_SESSION_DESKTOP="${XDG_SESSION_DESKTOP:-unknown}"
    
    log_info "Session type: ${PLATFORM_SESSION_TYPE}"
    log_info "Current desktop: ${PLATFORM_CURRENT_DESKTOP}"
    log_info "Session desktop: ${PLATFORM_SESSION_DESKTOP}"
    
    # Display manager
    if command -v lightdm &>/dev/null; then
        PLATFORM_DISPLAY_MANAGER="lightdm"
    elif command -v gdm &>/dev/null; then
        PLATFORM_DISPLAY_MANAGER="gdm"
    elif command -v sddm &>/dev/null; then
        PLATFORM_DISPLAY_MANAGER="sddm"
    else
        PLATFORM_DISPLAY_MANAGER="unknown"
    fi
    log_info "Display manager: ${PLATFORM_DISPLAY_MANAGER}"
    
    log_success "Platform detection complete"
}

# is_kali() - Check if running on Kali
is_kali() {
    [ "${PLATFORM_OS}" = "kali" ]
}

# is_debian() - Check if running on Debian-based system
is_debian() {
    [ "${ID_LIKE}" = "debian" ] || [ "${PLATFORM_OS}" = "debian" ] || is_kali
}

# is_vmware() - Check if running in VMware
is_vmware() {
    [ "${PLATFORM_VM}" = "vmware" ]
}

# is_wayland() - Check if running Wayland session
is_wayland() {
    [ "${PLATFORM_SESSION_TYPE}" = "wayland" ]
}

# is_x11() - Check if running X11 session
is_x11() {
    [ "${PLATFORM_SESSION_TYPE}" = "x11" ]
}

# has_enough_memory() - Check if system has enough memory (in GB)
has_enough_memory() {
    local required_gb=${1:-4}
    local available_gb=$(free -g | awk '/^Mem:/{print $7}')
    [ "${available_gb}" -ge "${required_gb}" ]
}

# has_enough_disk() - Check if system has enough disk space (in GB)
has_enough_disk() {
    local required_gb=${1:-10}
    local available_gb=$(df -BG / | awk 'NR==2 {gsub(/G/,"",$4); print $4}')
    [ "${available_gb}" -ge "${required_gb}" ]
}

# validate_platform() - Validate platform meets requirements
validate_platform() {
    log_step "Validating platform requirements"
    
    local valid=true
    
    if ! is_kali; then
        log_warn "Not running on Kali Linux (detected: ${PLATFORM_DISTRO})"
        log_warn "This project is designed for Kali Linux"
        # Continue anyway, but warn
    fi
    
    if ! is_debian; then
        log_error "Not running on a Debian-based system"
        valid=false
    fi
    
    if [ "${PLATFORM_ARCH}" != "x86_64" ] && [ "${PLATFORM_ARCH}" != "amd64" ]; then
        log_warn "Unsupported architecture: ${PLATFORM_ARCH}"
        log_warn "This project is designed for x86_64/amd64"
    fi
    
    if ! has_enough_memory 4; then
        log_warn "System may not have enough memory (recommend 4GB+)"
    fi
    
    if ! has_enough_disk 10; then
        log_warn "System may not have enough disk space (recommend 10GB+)"
    fi
    
    if $valid; then
        log_success "Platform validation passed"
        return 0
    else
        log_failure "Platform validation failed"
        return 1
    fi
}

# print_platform_report() - Print detailed platform report
print_platform_report() {
    echo "=== PLATFORM REPORT ==="
    echo "OS: ${PLATFORM_DISTRO} ${PLATFORM_VERSION}"
    echo "ID: ${PLATFORM_OS}"
    echo "Architecture: ${PLATFORM_ARCH}"
    echo "Virtualization: ${PLATFORM_VM}"
    echo "GPU: ${PLATFORM_GPU}"
    echo "Session type: ${PLATFORM_SESSION_TYPE}"
    echo "Current desktop: ${PLATFORM_CURRENT_DESKTOP}"
    echo "Session desktop: ${PLATFORM_SESSION_DESKTOP}"
    echo "Display manager: ${PLATFORM_DISPLAY_MANAGER}"
    echo "======================"
}

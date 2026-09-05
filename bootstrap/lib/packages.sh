#!/bin/bash
# packages.sh - Package management utilities

# Prevent re-sourcing
[ -n "${PACKAGES_SH_SOURCED:-}" ] && return 0
readonly PACKAGES_SH_SOURCED=1

# Source logging
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"

# Package manager detection
PACKAGE_MANAGER=""

# detect_package_manager() - Detect the package manager
detect_package_manager() {
    if command -v apt &>/dev/null; then
        PACKAGE_MANAGER="apt"
        log_info "Package manager: apt"
    elif command -v apt-get &>/dev/null; then
        PACKAGE_MANAGER="apt-get"
        log_info "Package manager: apt-get"
    else
        log_error "No supported package manager found"
        return 1
    fi
}

# ensure_dpkg_healthy() - Verify and repair dpkg state & lock recovery
ensure_dpkg_healthy() {
    # Check for active background package manager processes
    local active_pids
    active_pids=$(pgrep -x "apt|apt-get|dpkg|unattended-upgrade|synaptic|aptd" 2>/dev/null || true)

    if [ -n "${active_pids}" ]; then
        log_warn "Active package manager process(es) detected (PIDs: ${active_pids//[$'\n']/ }). Waiting for completion..."
        local wait_count=0
        while [ ${wait_count} -lt 15 ]; do
            sleep 2
            wait_count=$((wait_count + 1))
            active_pids=$(pgrep -x "apt|apt-get|dpkg|unattended-upgrade|synaptic|aptd" 2>/dev/null || true)
            [ -z "${active_pids}" ] && break
        done
    fi

    # Inspect dpkg audit for unconfigured or half-installed packages
    local dpkg_audit
    dpkg_audit=$(dpkg --audit 2>&1 || true)

    if [ -n "${dpkg_audit}" ]; then
        log_warn "Interrupted package state detected (dpkg --audit reported pending packages)."
        log_info "Running automatic repair routine: sudo dpkg --configure -a && sudo apt-get install -f"
        
        if command -v sudo &>/dev/null; then
            sudo dpkg --configure -a || log_warn "dpkg --configure -a finished with warnings"
            sudo apt-get install -f -y || log_warn "apt-get install -f finished with warnings"
        else
            dpkg --configure -a || log_warn "dpkg --configure -a finished with warnings"
            apt-get install -f -y || log_warn "apt-get install -f finished with warnings"
        fi
        log_success "Package manager repair routine completed successfully"
    fi

    return 0
}


# update_package_cache() - Update package cache
update_package_cache() {
    ensure_dpkg_healthy
    log_step "Updating package cache"
    log_command "${PACKAGE_MANAGER} update"
    
    if ${PACKAGE_MANAGER} update; then
        log_success "Package cache updated"
        return 0
    else
        log_failure "Failed to update package cache"
        return 1
    fi
}

# install_packages() - Install packages from list
# Usage: install_packages <package_list_file>
install_packages() {
    local package_file=$1
    
    if [ ! -f "${package_file}" ]; then
        log_error "Package file not found: ${package_file}"
        return 1
    fi

    ensure_dpkg_healthy
    
    log_step "Installing packages from ${package_file}"
    
    # Read packages from file (trimming whitespace, ignoring comments and empty lines)
    local packages=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Trim leading and trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        # Skip comments and empty lines
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        packages+=("$line")
    done < "${package_file}"
    
    if [ ${#packages[@]} -eq 0 ]; then
        log_warn "No packages to install"
        return 0
    fi
    
    log_info "Packages to install: ${packages[*]}"
    
    # Check if packages are available and filter out unavailable ones
    log_info "Checking package availability..."
    local available_packages=()
    local missing_packages=()
    for pkg in "${packages[@]}"; do
        if check_package_available "${pkg}"; then
            available_packages+=("${pkg}")
        else
            log_warn "Package not available in repos, skipping: ${pkg}"
            missing_packages+=("${pkg}")
        fi
    done
    
    if [ ${#available_packages[@]} -eq 0 ]; then
        log_warn "No available packages to install"
        if [ ${#missing_packages[@]} -gt 0 ]; then
            log_info "The following packages were not available:"
            for pkg in "${missing_packages[@]}"; do
                log_info "  - ${pkg}"
            done
        fi
        return 1
    fi
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        log_info "Some packages were not available and will be skipped:"
        for pkg in "${missing_packages[@]}"; do
            log_info "  - ${pkg}"
        done
        log_info "Continuing with available packages..."
    fi
    
    # Install available packages
    log_info "Installing ${#available_packages[@]} available packages..."
    log_command "${PACKAGE_MANAGER} install -y ${available_packages[*]}"
    if ${PACKAGE_MANAGER} install -y "${available_packages[@]}"; then
        log_success "Packages installed successfully"
        if [ ${#missing_packages[@]} -gt 0 ]; then
            log_info "Skipped ${#missing_packages[@]} unavailable packages"
        fi
        return 0
    else
        log_failure "Failed to install packages"
        return 1
    fi
}

# remove_packages() - Remove packages
# Usage: remove_packages <package1> <package2> ...
remove_packages() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        log_warn "No packages to remove"
        return 0
    fi
    
    ensure_dpkg_healthy
    log_step "Removing packages: ${packages[*]}"
    
    log_command "${PACKAGE_MANAGER} remove -y ${packages[*]}"
    if ${PACKAGE_MANAGER} remove -y "${packages[@]}"; then
        log_success "Packages removed successfully"
        return 0
    else
        log_failure "Failed to remove packages"
        return 1
    fi
}

# check_package_installed() - Check if a package is installed
# Usage: check_package_installed <package>
check_package_installed() {
    local package=$1
    dpkg -l "${package}" &>/dev/null
}

# get_package_version() - Get installed package version
# Usage: get_package_version <package>
get_package_version() {
    local package=$1
    dpkg-query -W -f='${Version}' "${package}" 2>/dev/null || echo "not installed"
}

# check_package_available() - Check if a package is available in repos
# Usage: check_package_available <package>
check_package_available() {
    local package=$1
    [ -z "${package}" ] && return 1
    apt-cache show "${package}" &>/dev/null
}

# get_package_info() - Get detailed package information
# Usage: get_package_info <package>
get_package_info() {
    local package=$1
    apt-cache show "${package}" 2>/dev/null || {
        log_error "Package not found: ${package}"
        return 1
    }
}


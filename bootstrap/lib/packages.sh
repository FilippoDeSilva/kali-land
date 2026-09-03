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

# update_package_cache() - Update package cache
update_package_cache() {
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
    
    log_step "Installing packages from ${package_file}"
    
    # Read packages from file (ignoring comments and empty lines)
    local packages=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
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
        if apt-cache policy "${pkg}" &>/dev/null; then
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
    apt-cache policy "${package}" &>/dev/null
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

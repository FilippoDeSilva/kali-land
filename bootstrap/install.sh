#!/bin/bash
# install.sh - Main installation script for kali-land

set -Eeuo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source library functions
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/platform.sh"
source "${SCRIPT_DIR}/lib/packages.sh"
source "${SCRIPT_DIR}/lib/filesystem.sh"
source "${SCRIPT_DIR}/lib/prompts.sh"
source "${SCRIPT_DIR}/lib/capabilities.sh"
source "${SCRIPT_DIR}/lib/profile.sh"
source "${SCRIPT_DIR}/lib/integrations.sh"
source "${SCRIPT_DIR}/lib/backups.sh"

# Load environment variables if .env file exists
if [ -f "${REPO_ROOT}/.env" ]; then
    log_info "Loading environment variables from .env file"
    set -a
    source "${REPO_ROOT}/.env"
    set +a
fi

# Interrupt trap for user aborts or unexpected failures
cleanup_on_exit() {
    local exit_code=$?
    if [ ${exit_code} -ne 0 ]; then
        echo ""
        log_warn "Installation was interrupted or exited unexpectedly (exit code ${exit_code})."
        log_info "If dpkg or package manager was interrupted, run: sudo dpkg --configure -a"
        log_info "You can resume installation anytime by running: ./bootstrap/install.sh"
    fi
}
trap cleanup_on_exit EXIT SIGINT SIGTERM SIGHUP

# Installation phases
PHASE=0
DRY_RUN=false
INTERACTIVE=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --phase)
            PHASE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --non-interactive)
            INTERACTIVE=false
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --phase <number>    Run specific phase (0-13)"
            echo "  --dry-run           Show what would be done without making changes"
            echo "  --non-interactive   Run without user prompts"
            echo "  --help              Show this help message"
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
    echo "  kali-land Desktop Installer"
    echo "=========================================="
    echo ""
    echo "This installer will set up a professional, modular"
    echo "desktop environment on your Kali Linux system."
    echo ""
    echo "Stack: Kali + Wayland + Hyprland + Quickshell"
    echo ""
    echo "The installation is divided into phases:"
    echo "  Phase 0:  Platform detection"
    echo "  Phase 1:  Repository foundation"
    echo "  Phase 2:  Wayland foundation"
    echo "  Phase 3:  Hyprland installation"
    echo "  Phase 4:  Desktop services"
    echo "  Phase 5:  Quickshell skeleton"
    echo "  Phase 6:  Quickshell bar"
    echo "  Phase 7:  Launcher"
    echo "  Phase 8:  Control center"
    echo "  Phase 9:  Power/lock/session"
    echo "  Phase 10: Visual theming"
    echo "  Phase 11: VMware optimization"
    echo "  Phase 12: Reliability testing"
    echo "  Phase 13: Documentation"
    echo ""
}

# get_github_credentials() - Get GitHub credentials from environment or prompt
get_github_credentials() {
    if [ -n "${GITHUB_USERNAME:-}" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
        log_info "Using GitHub credentials from environment"
        return 0
    fi
    
    if ${INTERACTIVE}; then
        log_info "GitHub credentials not found in environment"
        log_info "Enter GitHub credentials if you need to clone private repositories"
        log_info "Leave blank to use public cloning (recommended for most users)"
        
        read -p "GitHub username (optional): " GITHUB_USERNAME
        read -s -p "GitHub token/personal access token (optional): " GITHUB_TOKEN
        echo ""
        
        if [ -n "${GITHUB_USERNAME}" ] && [ -n "${GITHUB_TOKEN}" ]; then
            log_info "GitHub credentials provided"
            export GITHUB_USERNAME
            export GITHUB_TOKEN
        else
            log_info "No GitHub credentials provided, using public cloning"
        fi
    else
        log_info "No GitHub credentials in environment, using public cloning"
    fi
}

# clone_with_credentials() - Clone repository with optional credentials
clone_with_credentials() {
    local repo_url="$1"
    local target_dir="$2"
    
    if [ -n "${GITHUB_USERNAME:-}" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
        # Convert HTTPS URL to authenticated URL
        local auth_url="${repo_url/https:\/\//https:\/\/${GITHUB_USERNAME}:${GITHUB_TOKEN}@}"
        git clone --recursive "${auth_url}" "${target_dir}"
    else
        # Use public cloning
        git clone --recursive "${repo_url}" "${target_dir}"
    fi
}

# phase_0_platform_detection() - Platform detection and validation
phase_0_platform_detection() {
    log_step "Phase 0: Platform & Profile Detection"
    
    detect_platform
    load_profile
    detect_capabilities
    validate_platform
    
    if ! is_kali; then
        log_warn "This project is designed for Kali Linux"
        if ! confirm "Continue anyway?" "n"; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    print_platform_report
    print_profile_report
    
    log_success "Phase 0 complete"
}

# phase_1_repository_foundation() - Create repository foundation
phase_1_repository_foundation() {
    log_step "Phase 1: Repository Foundation"
    
    ensure_directories

    # Copy package manifests from repository
    log_info "Copying package manifests from repository"
    if [ -d "${REPO_ROOT}/packages" ]; then
        log_success "Package manifests already exist in repository"
    else
        log_warn "No package manifests found in repository"
    fi

    log_success "Phase 1 complete"
}

# phase_base_packages() - Install base build packages
phase_base_packages() {
    log_step "Installing Base Build Packages"
    
    detect_package_manager
    update_package_cache
    
    log_info "Installing base build packages"
    if ! install_packages "${REPO_ROOT}/packages/base.txt"; then
        log_error "Failed to install base packages"
        return 1
    fi
    
    log_success "Base packages installed"
}

# phase_2_wayland_foundation() - Install Wayland foundation
phase_2_wayland_foundation() {
    log_step "Phase 2: Wayland Foundation"
    
    detect_package_manager
    update_package_cache
    
    log_info "Installing Wayland packages"
    if ! install_packages "${REPO_ROOT}/packages/wayland.txt"; then
        log_error "Failed to install Wayland packages"
        return 1
    fi
    
    log_success "Phase 2 complete"
}

# phase_3_hyprland_installation() - Install Hyprland
phase_3_hyprland_installation() {
    log_step "Phase 3: Hyprland Installation"
    
    detect_package_manager
    update_package_cache
    
    # Check if Hyprland is available in Kali repositories
    if apt-cache policy hyprland &>/dev/null; then
        log_info "Hyprland is available in Kali repositories"
        log_info "Installing packaged Hyprland..."
        
        if ${PACKAGE_MANAGER} install -y hyprland; then
            log_success "Hyprland installed successfully from package"
        else
            log_error "Failed to install Hyprland package"
            log_info "You may need to install Hyprland manually"
            log_info "See docs/installation.md for manual installation instructions"
            return 1
        fi
    else
        log_info "Hyprland is not available in Kali repositories"
        log_info "Building Hyprland from source..."
        
        # Install build dependencies
        log_info "Installing Hyprland build dependencies..."
        local build_deps="cmake g++ libpango-1.0-0 libpangocairo-1.0-0 libxkbcommon0 libxkbcommon-x11-0 libxcb-icccm4 libxcb-keysyms1 libxcb-render-util0 libxcb-xinerama0 libxcb-xkb1 libxcb-cursor0 libxcb-res0 git libcairo2-dev libpango1.0-dev libxcb-randr0-dev libxcb-util-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-xinerama0-dev libxcb-render0-dev libgl1-mesa-dev libglvnd-dev libegl1-mesa-dev libpixman-1-dev libxkbcommon-dev xorg-dev glslang-dev glslang-tools libaquamarine-dev"
        
        # Install dependencies with graceful failure handling
        local missing_deps=()
        for dep in ${build_deps}; do
            if apt-cache policy "${dep}" &>/dev/null; then
                log_info "Installing ${dep}..."
                ${PACKAGE_MANAGER} install -y "${dep}" || log_warn "Failed to install ${dep}, continuing..."
            else
                log_warn "Build dependency not available: ${dep}"
                missing_deps+=("${dep}")
            fi
        done
        
        if [ ${#missing_deps[@]} -gt 0 ]; then
            log_warn "Some build dependencies were missing, build may fail"
        fi
        
        # Clone and build Hyprland
        local build_dir="/tmp/hyprland-build"
        rm -rf "${build_dir}"
        mkdir -p "${build_dir}"
        
        log_info "Cloning Hyprland repository..."
        if command -v git &>/dev/null; then
            if clone_with_credentials "https://github.com/hyprwm/Hyprland.git" "${build_dir}/hyprland"; then
                log_success "Repository cloned"
            else
                log_error "Failed to clone Hyprland repository"
                log_info "You may need to install Hyprland manually"
                log_info "See docs/installation.md for manual installation instructions"
                return 1
            fi
        else
            log_error "git is not installed, cannot clone repository"
            log_info "You may need to install Hyprland manually"
            log_info "See docs/installation.md for manual installation instructions"
            return 1
        fi
        
        log_info "Building Hyprland..."
        cd "${build_dir}/hyprland"
        
        # Check for install script and use appropriate method
        if [ -f "./install.sh" ]; then
            log_info "Using official install script..."
            if ./install.sh; then
                log_success "Hyprland installed successfully"
            else
                log_error "Failed to build/install Hyprland using install script"
                log_info "You may need to install Hyprland manually"
                log_info "See docs/installation.md for manual installation instructions"
                return 1
            fi
        else
            log_info "No install script found, trying manual cmake build..."
            mkdir -p build && cd build
            if cmake .. && make && sudo make install; then
                log_success "Hyprland installed successfully"
            else
                log_error "Failed to build/install Hyprland using cmake"
                log_info "You may need to install Hyprland manually"
                log_info "See docs/installation.md for manual installation instructions"
                return 1
            fi
        fi
        
        # Cleanup
        cd "${REPO_ROOT}"
        if [ -d "${build_dir}" ]; then
            rm -rf "${build_dir}" || log_warn "Failed to cleanup build directory: ${build_dir}"
        fi
    fi
    
    log_success "Phase 3 complete"
}

# phase_4_fonts() - Install required fonts
phase_4_fonts() {
    log_step "Phase 4: Fonts Installation"
    
    detect_package_manager
    update_package_cache
    
    log_info "Installing required fonts for ekremx25 quickshell"
    if [ -f "${REPO_ROOT}/packages/fonts.txt" ]; then
        if ! install_packages "${REPO_ROOT}/packages/fonts.txt"; then
            log_warn "Failed to install some fonts, continuing..."
        fi
    fi
    
    log_info "Note: JetBrains Mono Nerd Font may need manual installation"
    log_info "Download from: https://github.com/ryanoasis/nerd-fonts/releases"
    
    log_success "Phase 4 complete"
}

# phase_5_desktop_services() - Install desktop services
phase_5_desktop_services() {
    log_step "Phase 5: Desktop Services"
    
    detect_package_manager
    update_package_cache
    
    log_info "Installing desktop services"
    if ! install_packages "${REPO_ROOT}/packages/desktop-services.txt"; then
        log_warn "Failed to install some desktop services, continuing..."
    fi
    
    log_info "Installing terminal applications"
    if ! install_packages "${REPO_ROOT}/packages/applications.txt"; then
        log_warn "Failed to install some terminal applications, continuing..."
    fi
    
    log_success "Phase 4 complete"
}

# phase_6_quickshell_skeleton() - Install Quickshell skeleton
phase_6_quickshell_skeleton() {
    log_step "Phase 5: Quickshell Installation"
    
    detect_package_manager
    update_package_cache
    
    # Check if pre-built Quickshell is available from GitHub releases
    log_info "Checking for pre-built Quickshell from GitHub releases..."
    local repo_nwo
    repo_nwo=$(get_github_repo_nwo)
    
    local download_success=false
    local quickshell_urls=(
        "https://github.com/${repo_nwo}/releases/download/v1.0.0/quickshell-linux-x86_64.tar.gz"
        "https://github.com/${repo_nwo}/releases/latest/download/quickshell-linux-x86_64.tar.gz"
    )
    
    for url in "${quickshell_urls[@]}"; do
        log_info "Attempting download from ${url}..."
        if curl -fsSL "${url}" -o /tmp/quickshell.tar.gz 2>/dev/null; then
            log_info "Found pre-built Quickshell archive, unpacking..."
            if tar -xzf /tmp/quickshell.tar.gz -C /tmp/ && [ -f /tmp/quickshell ]; then
                if sudo cp /tmp/quickshell /usr/local/bin/quickshell && sudo chmod +x /usr/local/bin/quickshell; then
                    log_success "Pre-built Quickshell installed successfully to /usr/local/bin/quickshell"
                    rm -f /tmp/quickshell.tar.gz /tmp/quickshell
                    download_success=true
                    break
                fi
            fi
            rm -f /tmp/quickshell.tar.gz /tmp/quickshell
        fi
    done

    if ${download_success}; then
        log_success "Skipping local source compilation (pre-built binary installed)"
        return 0
    fi
    
    log_info "No remote pre-built Quickshell binary available, building from source..."
    phase_6_quickshell_build_from_source
}

# phase_6_quickshell_build_from_source() - Build Quickshell from source
phase_6_quickshell_build_from_source() {
    # Note: Kali's Quickshell package (0.3.0) is too old for modern configurations
    # We must build from source to get the latest version
    log_info "Kali's Quickshell package (0.3.0) is incompatible with modern configurations"
    log_info "Building Quickshell from source for latest version..."
    
    # Install Quickshell build dependencies from package manifest
    log_info "Installing Quickshell build dependencies"
    if [ -f "${REPO_ROOT}/packages/quickshell.txt" ]; then
        if ! install_packages "${REPO_ROOT}/packages/quickshell.txt"; then
            log_warn "Failed to install some Quickshell dependencies, continuing..."
        fi
    fi

    
    # Clone and build Quickshell
    local build_dir="/tmp/quickshell-build"
    rm -rf "${build_dir}"
    mkdir -p "${build_dir}"
    
    log_info "Cloning Quickshell repository..."
    if command -v git &>/dev/null; then
        if clone_with_credentials "https://github.com/outfoxxed/quickshell.git" "${build_dir}/quickshell"; then
            log_success "Repository cloned"
        else
            log_error "Failed to clone Quickshell repository"
            log_info "You may need to install Quickshell manually"
            log_info "See docs/installation.md for manual installation instructions"
            return 1
        fi
    else
        log_error "git is not installed, cannot clone repository"
        log_info "You may need to install Quickshell manually"
        log_info "See docs/installation.md for manual installation instructions"
        return 1
    fi
    
    log_info "Building Quickshell with cmake and ninja..."
    cd "${build_dir}/quickshell"
    mkdir -p build && cd build
    
    log_info "Configuring with cmake..."
    if cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DDISTRIBUTOR="kali-land" ..; then
        log_success "CMake configuration successful"
    else
        log_error "CMake configuration failed"
        log_info "You may need to install Quickshell manually"
        log_info "See docs/installation.md for manual installation instructions"
        return 1
    fi
    
    log_info "Building with ninja..."
    if ninja; then
        log_success "Build successful"
    else
        log_error "Build failed"
        log_info "You may need to install Quickshell manually"
        log_info "See docs/installation.md for manual installation instructions"
        return 1
    fi
    
    log_info "Installing Quickshell..."
    if sudo cmake --install .; then
        log_success "Quickshell installed successfully"
    else
        log_error "Installation failed"
        log_info "You may need to install Quickshell manually"
        log_info "See docs/installation.md for manual installation instructions"
        return 1
    fi
    
    # Cleanup
    cd "${REPO_ROOT}"
    if [ -d "${build_dir}" ]; then
        rm -rf "${build_dir}" || log_warn "Failed to cleanup build directory: ${build_dir}"
    fi
    
    log_info "Deploying end4-pC reference shell integration"
    install_integration "end4-pC"
    
    # Apply VMware compatibility fixes for Quickshell (only if running in VMware)
    if is_vmware; then
        log_info "Applying VMware compatibility fixes for Quickshell"
        
        # Update Hyprland environment.lua with Quickshell-specific environment variables
        local hypr_env_file="${HOME}/.config/hypr/environment.lua"
        if [ -f "${hypr_env_file}" ]; then
            log_info "Updating Hyprland environment for Quickshell VMware compatibility"
            
            # Check if QT_QUICK_BACKEND is already set
            if ! grep -q "QT_QUICK_BACKEND" "${hypr_env_file}"; then
                # Add Quickshell environment variables
                sed -i '/hl.env("QT_QPA_PLATFORM", "wayland")/a\    -- Qt Quick backend - use software rendering for VMware compatibility\n    hl.env("QT_QUICK_BACKEND", "software")' "${hypr_env_file}"
                log_success "Added QT_QUICK_BACKEND=software for VMware compatibility"
            else
                log_info "QT_QUICK_BACKEND already configured"
            fi
            
            # Ensure other Qt environment variables are present
            if ! grep -q "QT_WAYLAND_DISABLE_WINDOWDECORATION" "${hypr_env_file}"; then
                sed -i '/QT_QUICK_BACKEND/a\    -- Qt Wayland integration\n    hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")' "${hypr_env_file}"
            fi
            
            if ! grep -q "QT_AUTO_SCREEN_SCALE_FACTOR" "${hypr_env_file}"; then
                sed -i '/QT_WAYLAND_DISABLE_WINDOWDECORATION/a\    -- Scale factor for high-DPI displays\n    hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")' "${hypr_env_file}"
            fi
            
            # Add end4-pC specific environment variable
            if ! grep -q "QS_CONFIG" "${hypr_env_file}"; then
                sed -i '/QT_AUTO_SCREEN_SCALE_FACTOR/a\    -- end4-pC Quickshell configuration\n    hl.env("QS_CONFIG", "end4-pC")' "${hypr_env_file}"
                log_success "Added QS_CONFIG environment variable for end4-pC"
            fi
            
            log_success "Quickshell environment variables configured"
        else
            log_warn "Hyprland environment.lua not found, skipping Quickshell environment setup"
        fi
    else
        log_info "Not running in VMware, skipping VMware-specific Quickshell optimizations"
        
        # Still add end4-pC environment variable for non-VMware systems
        local hypr_env_file="${HOME}/.config/hypr/environment.lua"
        if [ -f "${hypr_env_file}" ]; then
            if ! grep -q "QS_CONFIG" "${hypr_env_file}"; then
                sed -i '/hl.env("QT_QPA_PLATFORM", "wayland")/a\    -- end4-pC Quickshell configuration\n    hl.env("QS_CONFIG", "end4-pC")' "${hypr_env_file}"
                log_success "Added QS_CONFIG environment variable for end4-pC"
            fi
        fi
    fi
    
    # end4-pC uses its own configuration management, no need for kali-land-specific overrides
    log_info "end4-pC uses independent configuration management"
    
    # Update Hyprland autostart to use standard quickshell (end4-pC manages its own config)
    local hypr_autostart="${HOME}/.config/hypr/autostart.lua"
    if [ -f "${hypr_autostart}" ]; then
        log_info "Updating Hyprland autostart for end4-pC Quickshell configuration"
        
        # Replace any --path arguments with standard quickshell command
        sed -i 's|quickshell --path.*|quickshell|g' "${hypr_autostart}"
        
        log_success "Hyprland autostart updated for end4-pC Quickshell configuration"
    else
        log_warn "Hyprland autostart.lua not found, skipping autostart update"
    fi
    
    log_success "Quickshell configuration completed"
    
    log_success "Phase 5 complete"
}

# phase_6_desktop_services() - Install desktop services
phase_6_desktop_services() {
    log_step "Phase 6: Desktop Services"
    
    ensure_directories
    
    local hypr_config_dir="${HOME}/.config/hypr"
    mkdir -p "${hypr_config_dir}"
    
    # Copy Lua configuration files
    if [ -d "${REPO_ROOT}/config/hypr" ]; then
        log_info "Copying Lua configuration files to ${hypr_config_dir}"
        cp -r "${REPO_ROOT}/config/hypr/"*.lua "${hypr_config_dir}/"
        
        # Detect if running in VM and set appropriate terminal
        if systemd-detect-virt --vm &>/dev/null; then
            log_info "VM detected - setting terminal to foot (native Wayland)"
            sed -i 's/hl.env("TERMINAL", "kitty")/hl.env("TERMINAL", "foot")/' "${hypr_config_dir}/environment.lua"
        else
            log_info "Bare metal detected - keeping terminal as kitty (GPU accelerated)"
            # kitty is already the default, no change needed
        fi
        
        # Ensure both terminals are available for fallback
        if ! command -v foot &>/dev/null; then
            log_warn "foot not available, installation may have failed"
        fi
        if ! command -v kitty &>/dev/null; then
            log_warn "kitty not available, installation may have failed"
        fi
        
        log_success "Hyprland Lua configuration installed"
    else
        log_warn "Hyprland configuration directory not found"
    fi
    
    log_success "Phase 5 complete"
}

# phase_6_quickshell_bar() - Build Quickshell bar
phase_6_quickshell_bar() {
    log_step "Phase 6: Quickshell Bar"
    
    log_info "This phase will be implemented after Quickshell is installed"
    log_info "Skipping for now"
    
    log_success "Phase 6 skipped (requires Quickshell)"
}

# phase_7_launcher() - Implement launcher
phase_7_launcher() {
    log_step "Phase 7: Launcher"
    
    log_info "This phase will be implemented after Quickshell is installed"
    log_info "Skipping for now"
    
    log_success "Phase 7 skipped (requires Quickshell)"
}

# phase_8_control_center() - Build control center
phase_8_control_center() {
    log_step "Phase 8: Control Center"
    
    log_info "This phase will be implemented after Quickshell is installed"
    log_info "Skipping for now"
    
    log_success "Phase 8 skipped (requires Quickshell)"
}

# phase_9_power_lock_session() - Add power/lock/session UX
phase_9_power_lock_session() {
    log_step "Phase 9: Power/Lock/Session UX"
    
    log_info "This phase will be implemented after Quickshell is installed"
    log_info "Skipping for now"
    
    log_success "Phase 9 skipped (requires Quickshell)"
}

# phase_10_visual_theming() - Implement visual theming
phase_10_visual_theming() {
    log_step "Phase 10: Visual Theming"
    
    log_info "Visual theming is handled in Quickshell configuration"
    log_info "See config/quickshell/shell.qml for styling"
    
    log_success "Phase 10 complete"
}

# phase_11_vmware_optimization() - VMware optimization
phase_11_vmware_optimization() {
    log_step "Phase 11: VMware Optimization"
    
    if ! is_vmware; then
        log_info "Not running in VMware, skipping optimization"
        log_success "Phase 11 skipped (not VMware)"
        return
    fi
    
    log_info "VMware detected, installing VMware tools"
    
    detect_package_manager
    update_package_cache
    
    # Install VMware tools for proper display resolution and guest integration
    log_info "Installing open-vm-tools-desktop for proper VMware integration"
    if ${PACKAGE_MANAGER} install -y open-vm-tools-desktop; then
        log_success "VMware tools installed successfully"
    else
        log_warn "Failed to install VMware tools, continuing..."
        log_info "You may need to install manually: sudo apt install open-vm-tools-desktop"
    fi
    
    # VMware optimization scripts should be in the repository
    if [ -f "${REPO_ROOT}/scripts/vmware/optimize.sh" ]; then
        chmod +x "${REPO_ROOT}/scripts/vmware/optimize.sh" 2>/dev/null || true
        log_success "VMware optimization script found in repository"
    else
        log_warn "No VMware optimization script found in repository"
    fi
    
    log_success "Phase 11 complete"
}

# phase_12_reliability_testing() - Reliability testing
phase_12_reliability_testing() {
    log_step "Phase 12: Reliability Testing"
    
    log_info "This phase requires manual testing"
    log_info "See docs/troubleshooting.md for testing procedures"
    
    log_success "Phase 12 marked for manual completion"
}

# phase_13_documentation() - Complete documentation
phase_13_documentation() {
    log_step "Phase 13: Documentation"
    
    log_info "Documentation should be in the repository docs/ directory"
    
    if [ -d "${REPO_ROOT}/docs" ]; then
        log_success "Documentation found in repository"
    else
        log_warn "No documentation found in repository"
    fi
    
    log_success "Phase 13 complete"
}

# check_privileges() - Check if running with sufficient privileges
check_privileges() {
    if [ "$EUID" -ne 0 ]; then
        log_warn "This script requires root privileges for package installation"
        log_info "Please run with sudo: sudo $0"
        if ${INTERACTIVE}; then
            if ! confirm "Continue anyway (some operations will fail)?" "n"; then
                log_info "Installation cancelled"
                exit 1
            fi
        else
            log_error "Installation halted due to insufficient privileges"
            exit 1
        fi
    fi
}

# main() - Main installation function
main() {
    welcome
    
    # Check for privileges
    check_privileges
    
    # Get GitHub credentials for private repositories if needed
    get_github_credentials
    
    if ${INTERACTIVE} && ! confirm "Begin installation?" "y"; then
        log_info "Installation cancelled"
        exit 0
    fi
    
    if ${DRY_RUN}; then
        log_info "Dry run mode - no changes will be made"
    fi
    
    # Run phases with error handling
    local phase_failed=false
    
    # Critical phases that must succeed
    phase_0_platform_detection || phase_failed=true
    phase_1_repository_foundation || phase_failed=true
    phase_base_packages || phase_failed=true
    phase_2_wayland_foundation || phase_failed=true
    
    # Critical component installations
    if ! phase_3_hyprland_installation; then
        log_error "Critical phase failed: Hyprland installation"
        log_error "Cannot continue without Hyprland"
        if ${INTERACTIVE}; then
            if ! confirm "Continue anyway (desktop will be incomplete)?" "n"; then
                log_info "Installation cancelled due to critical failure"
                exit 1
            fi
        else
            log_error "Installation halted due to critical failure"
            exit 1
        fi
    fi
    
    phase_4_fonts || log_warn "Fonts installation failed, continuing..."
    phase_5_desktop_services || log_warn "Desktop services installation failed, continuing..."
    phase_6_quickshell_skeleton || log_warn "Quickshell installation failed, continuing..."
    phase_7_matugen || log_warn "Matugen installation failed, continuing..."
    
    # Optional phases - can fail gracefully
    # Note: ekremx25 quickshell provides most functionality (bar, launcher, control center, etc.)
    log_info "ekremx25 quickshell provides bar, launcher, control center, and other features"
    log_info "Skipping custom implementation phases"
    
    if ${phase_failed}; then
        log_warn "Some phases failed during installation"
        log_info "Please check the logs at: ${LOG_FILE}"
        log_info "Run ./bootstrap/doctor.sh for system status"
    else
        log_success "Installation complete!"
        log_info "Please check the logs at: ${LOG_FILE}"
        log_info "Run ./bootstrap/doctor.sh for system status"
    fi
}

# Run main function
main "$@"

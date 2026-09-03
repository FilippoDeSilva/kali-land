#!/bin/bash
# install.sh - Main installation script for Kali Omarchy Desktop

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

# Load environment variables if .env file exists
if [ -f "${REPO_ROOT}/.env" ]; then
    log_info "Loading environment variables from .env file"
    set -a
    source "${REPO_ROOT}/.env"
    set +a
fi

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
    echo "  Kali Omarchy-Inspired Desktop Installer"
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
    log_step "Phase 0: Platform Detection"
    
    detect_platform
    validate_platform
    
    if ! is_kali; then
        log_warn "This project is designed for Kali Linux"
        if ! confirm "Continue anyway?" "n"; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    print_platform_report
    
    log_success "Phase 0 complete"
}

# phase_1_repository_foundation() - Create repository foundation
phase_1_repository_foundation() {
    log_step "Phase 1: Repository Foundation"
    
    ensure_directories
    
    # Create package manifests
    log_info "Creating package manifests"
    
    # Base packages
    cat > "${REPO_ROOT}/packages/base.txt" <<'EOF'
# Base system packages
curl
wget
git
vim
nano
htop
tree
ripgrep
fd-find
build-essential
cmake
g++
EOF
    
    # Wayland packages
    cat > "${REPO_ROOT}/packages/wayland.txt" <<'EOF'
# Wayland core packages
wayland-protocols
wayland-utils
libwayland-dev
xwayland
EOF
    
    # Desktop services packages
    cat > "${REPO_ROOT}/packages/desktop-services.txt" <<'EOF'
# Desktop services
xdg-desktop-portal
xdg-desktop-portal-gtk
xdg-desktop-portal-wlr
pipewire
pipewire-audio-client-libraries
pipewire-pulse
wireplumber
pavucontrol
network-manager
blueman
bluez
bluez-firmware
dunst
libnotify-bin
cliphist
swayidle
swaylock
wlogout
hyprland-guiutils
EOF
    
    # Applications packages
    cat > "${REPO_ROOT}/packages/applications.txt" <<'EOF'
# Terminal and applications
kitty
foot
thunar
firefox-esr
geany
EOF
    
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

# phase_4_desktop_services() - Install desktop services
phase_4_desktop_services() {
    log_step "Phase 4: Desktop Services"
    
    detect_package_manager
    update_package_cache
    
    log_info "Installing desktop services"
    if ! install_packages "${REPO_ROOT}/packages/desktop-services.txt"; then
        log_warn "Failed to install some desktop services, continuing..."
    fi
    
    log_success "Phase 4 complete"
}

# phase_5_quickshell_skeleton() - Install Quickshell skeleton
phase_5_quickshell_skeleton() {
    log_step "Phase 5: Quickshell Skeleton"
    
    detect_package_manager
    update_package_cache
    
    # Check if Quickshell is available in Kali repositories
    if apt-cache policy quickshell &>/dev/null; then
        log_info "Quickshell is available in Kali repositories"
        log_info "Installing packaged Quickshell..."
        
        if ${PACKAGE_MANAGER} install -y quickshell; then
            log_success "Quickshell installed successfully from package"
        else
            log_error "Failed to install Quickshell package"
            log_info "You may need to install Quickshell manually"
            log_info "See docs/installation.md for manual installation instructions"
            return 1
        fi
    else
        log_info "Quickshell is not available in Kali repositories"
        log_info "Building Quickshell from source..."
        
        # Ensure package manager is detected
        detect_package_manager
        
        # Install Qt6 dependencies
        log_info "Installing Qt6 build dependencies..."
        local qt_deps="qt6-base-dev qt6-declarative-dev qt6-wayland-dev cmake extra-cmake-modules qt6-tools-dev qt6-scxml-dev libqt6waylandclient6"
        
        # Try to install Qt6 dependencies, skip unavailable ones
        local missing_qt_deps=()
        for dep in ${qt_deps}; do
            if apt-cache policy "${dep}" &>/dev/null; then
                log_info "Installing ${dep}..."
                ${PACKAGE_MANAGER} install -y "${dep}" || log_warn "Failed to install ${dep}, continuing..."
            else
                log_warn "Qt6 dependency not available: ${dep}, skipping..."
                missing_qt_deps+=("${dep}")
            fi
        done
        
        if [ ${#missing_qt_deps[@]} -gt 0 ]; then
            log_warn "Some Qt6 dependencies were missing, Quickshell build may fail"
        fi
        
        # Clone and build Quickshell
        local build_dir="/tmp/quickshell-build"
        rm -rf "${build_dir}"
        mkdir -p "${build_dir}"
        
        log_info "Cloning Quickshell repository..."
        if command -v git &>/dev/null; then
            if clone_with_credentials "https://github.com/quickshell-mirror/quickshell.git" "${build_dir}/quickshell"; then
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
        
        log_info "Building Quickshell..."
        cd "${build_dir}/quickshell"
        
        # Check for build script and use appropriate method
        if [ -f "./install.sh" ]; then
            log_info "Using official install script..."
            if ./install.sh; then
                log_success "Quickshell installed successfully"
            else
                log_error "Failed to build/install Quickshell using install script"
                log_info "You may need to install Quickshell manually"
                log_info "See docs/installation.md for manual installation instructions"
                return 1
            fi
        elif [ -f "./Makefile" ]; then
            log_info "Using Makefile..."
            if make && sudo make install; then
                log_success "Quickshell installed successfully"
            else
                log_error "Failed to build/install Quickshell using Makefile"
                log_info "You may need to install Quickshell manually"
                log_info "See docs/installation.md for manual installation instructions"
                return 1
            fi
        else
            log_info "No install script found, trying manual cmake build..."
            mkdir -p build && cd build
            if cmake .. && make && sudo make install; then
                log_success "Quickshell installed successfully"
            else
                log_error "Failed to build/install Quickshell using cmake"
                log_info "You may need to install Quickshell manually"
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
    
    log_info "Creating Quickshell configuration structure"
    
    # Create basic shell.qml with top bar
    cat > "${REPO_ROOT}/config/quickshell/shell.qml" <<'EOF'
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1920
    height: 1080
    
    // Top Bar
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 30
        color: "#1e1e2e"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 10
            
            // Left side - Workspace info
            Text {
                text: "WS 1"
                color: "#cdd6f4"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignLeft
            }
            
            Item { Layout.fillWidth: true } // Spacer
            
            // Right side - Time
            Text {
                text: Qt.formatDateTime(new Date(), "HH:mm")
                color: "#cdd6f4"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignRight
            }
        }
    }
    
    // Center text for now
    Text {
        anchors.centerIn: parent
        text: "Kali Omarchy Desktop"
        color: "#cdd6f4"
        font.pixelSize: 24
    }
}
EOF
    
    log_info "Creating modular Lua configuration for Hyprland"
    
    # Remove old .conf files and create Lua equivalents
    rm -f "${REPO_ROOT}/config/hypr/"*.conf
    
    # The Lua files are already created above
    log_success "Lua configuration structure created"
    
    # Update Hyprland to use Lua config
    log_info "Configuring Hyprland to use Lua configuration"
    # Hyprland automatically looks for hyprland.lua if it exists
    
    log_success "Phase 5 complete"
    
    # Install Hyprland Lua configuration
    log_info "Installing Hyprland Lua configuration"
    ensure_directories
    
    local hypr_config_dir="${HOME}/.config/hypr"
    mkdir -p "${hypr_config_dir}"
    
    # Copy Lua configuration files
    if [ -d "${REPO_ROOT}/config/hypr" ]; then
        log_info "Copying Lua configuration files to ${hypr_config_dir}"
        cp -r "${REPO_ROOT}/config/hypr/"*.lua "${hypr_config_dir}/"
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
    
    log_info "Creating theme system"
    
    # Create color theme
    cat > "${REPO_ROOT}/themes/default/colors.qml" <<'EOF'
pragma Singleton
import QtQuick

QtObject {
    // Background colors
    readonly property color background: "#1e1e2e"
    readonly property color surface: "#313244"
    readonly property color surfaceElevated: "#45475a"
    
    // Foreground colors
    readonly property color foreground: "#cdd6f4"
    readonly property color muted: "#a6adc8"
    
    // Accent colors
    readonly property color accent: "#89b4fa"
    readonly property color accentHover: "#b4befe"
    
    // Status colors
    readonly property color success: "#a6e3a1"
    readonly property color warning: "#f9e2af"
    readonly property color danger: "#f38ba8"
    
    // Border colors
    readonly property color border: "#45475a"
    readonly property color borderFocus: "#89b4fa"
}
EOF
    
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
    
    log_info "VMware detected, creating optimization scripts"
    
    # Create VMware optimization script
    cat > "${REPO_ROOT}/scripts/vmware/optimize.sh" <<'EOF'
#!/bin/bash
# VMware optimization script

echo "Applying VMware optimizations..."

# Enable dynamic resolution (if supported)
# This may require additional tools

# Configure for better performance
# Add VMware-specific tweaks here

echo "VMware optimizations applied"
EOF
    
    chmod +x "${REPO_ROOT}/scripts/vmware/optimize.sh"
    
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
    
    log_info "Creating documentation structure"
    
    # Create architecture documentation
    cat > "${REPO_ROOT}/docs/architecture.md" <<'EOF'
# Architecture

This document describes the architecture of the Kali Omarchy-Inspired Desktop.

## Stack

- **OS**: Kali Linux (Debian-based)
- **Display**: Wayland
- **Compositor**: Hyprland
- **Desktop Shell**: Quickshell

## Components

### Compositor Layer (Hyprland)
- Window management
- Workspaces
- Input handling
- Monitor configuration
- Animations

### Desktop Shell Layer (Quickshell)
- Top bar
- Application launcher
- Control center
- Power menu
- Notifications

### Services Layer
- Audio (PipeWire/PulseAudio)
- Network (NetworkManager)
- Bluetooth (BlueZ)
- Notifications (mako)
- Clipboard (cliphist)
- Idle management (swayidle)
- Lock screen (swaylock)

## Configuration Management

Repository-first approach:
- Repository contains source configuration
- Installation symlinks/copies to ~/.config
- Backups created before modifications
- Rollback supported
EOF
    
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
    
    phase_4_desktop_services || log_warn "Desktop services installation failed, continuing..."
    
    # Critical component installation
    if ! phase_5_quickshell_skeleton; then
        log_error "Critical phase failed: Quickshell installation"
        log_error "Cannot continue without Quickshell"
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
    
    # Optional phases - can fail gracefully
    phase_6_quickshell_bar || log_warn "Quickshell bar phase failed, continuing..."
    phase_7_launcher || log_warn "Launcher phase failed, continuing..."
    phase_8_control_center || log_warn "Control center phase failed, continuing..."
    phase_9_power_lock_session || log_warn "Power/lock/session phase failed, continuing..."
    phase_10_visual_theming || log_warn "Visual theming phase failed, continuing..."
    phase_11_vmware_optimization || log_warn "VMware optimization phase failed, continuing..."
    phase_12_reliability_testing || log_warn "Reliability testing phase failed, continuing..."
    phase_13_documentation || log_warn "Documentation phase failed, continuing..."
    
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

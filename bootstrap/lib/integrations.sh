#!/bin/bash
# integrations.sh - Shell integration manager & capability contract validator

# Prevent re-sourcing
[ -n "${INTEGRATIONS_SH_SOURCED:-}" ] && return 0
readonly INTEGRATIONS_SH_SOURCED=1

# Source logging, platform, packages, capabilities, and backups
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"
source "${LIB_DIR}/platform.sh"
source "${LIB_DIR}/packages.sh"
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

# get_available_integrations() - Get array of available shell integration names
get_available_integrations() {
    local list=()
    if [ -d "${INTEGRATIONS_DIR}" ]; then
        for item in "${INTEGRATIONS_DIR}"/*; do
            if [ -d "${item}" ]; then
                list+=("$(basename "${item}")")
            fi
        done
    fi
    echo "${list[@]}"
}

# prompt_shell_selection() - Interactive prompt for shell integration selection
prompt_shell_selection() {
    local avail_shells=($(get_available_integrations))
    
    if command -v print_section_header &>/dev/null; then
        print_section_header "Desktop Shell & UI Integration Choice"
    else
        echo "=========================================="
        echo "  Desktop Shell & UI Integration Choice"
        echo "=========================================="
    fi

    echo "Select how you would like to set up your desktop shell:"
    echo ""
    
    local idx=1
    local shell_map=()

    echo "─── Pre-Configured Bundled Integrations ───"
    if [ ${#avail_shells[@]} -gt 0 ]; then
        for s in "${avail_shells[@]}"; do
            echo "  ${idx}) ${s} (Pre-configured supported integration)"
            shell_map+=("${s}")
            idx=$((idx + 1))
        done
    else
        echo "  (No bundled integrations found in repository)"
    fi
    echo ""

    echo "─── Custom Shell / User-Provided Setup ───"
    echo "  ${idx}) Local Folder  - Paste a path to your local shell folder (Auto-configured)"
    shell_map+=("CUSTOM_LOCAL")
    idx=$((idx + 1))

    echo "  ${idx}) Git Repo      - Paste a Git URL to clone your custom shell (Auto-configured)"
    shell_map+=("CUSTOM_GIT")
    idx=$((idx + 1))
    echo ""

    echo "─── Minimalist / DIY Mode ───"
    echo "  ${idx}) none          - Bare Minimal / DIY (Platform foundation only, no shell)"
    shell_map+=("none")
    echo ""

    local choice
    while true; do
        printf "%b" "${COLOR_PROMPT:-}Select choice [1-${#shell_map[@]}]:${COLOR_RESET:-} "
        read choice
        if [[ "${choice}" =~ ^[0-9]+$ ]] && [ "${choice}" -ge 1 ] && [ "${choice}" -le ${#shell_map[@]} ]; then
            break
        fi
        log_error "Invalid selection. Please enter a number between 1 and ${#shell_map[@]}."
    done

    local selected_type="${shell_map[$((choice - 1))]}"

    case "${selected_type}" in
        CUSTOM_LOCAL)
            log_info "Custom Local Folder selected."
            local custom_path
            custom_path=$(prompt_path "Paste full path to your custom shell folder" true)
            echo "path:${custom_path}"
            ;;
        CUSTOM_GIT)
            log_info "Custom Git Repository selected."
            local git_url
            git_url=$(prompt_url "Paste Git repository URL for your shell")
            echo "git:${git_url}"
            ;;
        none)
            echo "none"
            ;;
        *)
            echo "${selected_type}"
            ;;
    esac
}

# auto_detect_shell_manifest() - Auto-generate manifest metadata & detect QML dependencies/fonts if manifest.yaml missing
auto_detect_shell_manifest() {
    local shell_dir=$1
    local manifest="${shell_dir}/manifest.yaml"

    if [ -f "${manifest}" ]; then
        return 0
    fi

    log_step "Auto-detecting shell structure and QML dependencies for [$(basename "${shell_dir}")]"

    # Find primary entry point (shell.qml, main.qml, or first .qml file)
    local entry="shell.qml"
    if [ -f "${shell_dir}/shell.qml" ]; then
        entry="shell.qml"
    elif [ -f "${shell_dir}/main.qml" ]; then
        entry="main.qml"
    else
        local found_qml
        found_qml=$(find "${shell_dir}" -maxdepth 2 -name "*.qml" | head -n 1)
        if [ -n "${found_qml}" ]; then
            entry="$(basename "${found_qml}")"
        fi
    fi

    # Scan QML imports for Qt modules
    local qml_imports
    qml_imports=$(grep -rh "^import " "${shell_dir}" 2>/dev/null | awk '{print $2}' | sort -u || true)

    local detected_pkgs=(
        "qml6-module-qtcore"
        "qml6-module-qtqml"
        "qml6-module-qtquick"
        "qml6-module-qtquick-controls"
        "qml6-module-qtquick-layouts"
        "qml6-module-qtquick-window"
    )

    if echo "${qml_imports}" | grep -qi "Kirigami"; then
        detected_pkgs+=("qml6-module-org-kde-kirigami")
    fi
    if echo "${qml_imports}" | grep -qi "GraphicalEffects"; then
        detected_pkgs+=("qml6-module-qt5compat-graphicaleffects")
    fi
    if echo "${qml_imports}" | grep -qi "SyntaxHighlighting"; then
        detected_pkgs+=("qml6-module-org-kde-syntaxhighlighting")
    fi
    if echo "${qml_imports}" | grep -qi "Positioning"; then
        detected_pkgs+=("qml6-module-qtpositioning")
    fi
    if echo "${qml_imports}" | grep -qi "Labs.Platform"; then
        detected_pkgs+=("qml6-module-qt-labs-platform")
    fi

    # Create dynamic synthetic manifest
    log_info "Synthesizing dynamic manifest.yaml for custom shell..."
    cat <<EOF > "${manifest}"
# Auto-generated by kali-land installer
name: "$(basename "${shell_dir}")"
version: "1.0.0-custom"
type: quickshell
description: "User-provided custom shell integration"
entry: "${entry}"

requires:
  capabilities:
    - wayland
    - hyprland
    - quickshell
  packages:
EOF

    for pkg in "${detected_pkgs[@]}"; do
        echo "    - ${pkg}" >> "${manifest}"
    done

    cat <<EOF >> "${manifest}"
  fonts:
    packages:
      - fonts-font-awesome
      - fonts-jetbrains-mono
      - fonts-inter
EOF

    log_success "Dynamic manifest auto-generated at ${manifest}"
}

# resolve_custom_shell_path() - Resolve custom shell source directory (local path or git url)
resolve_custom_shell_path() {
    local shell_arg=$1
    local resolved_dir=""
    local custom_name=""

    if [[ "${shell_arg}" == "path:"* ]]; then
        local raw_path="${shell_arg#path:}"
        if [ -d "${raw_path}" ]; then
            resolved_dir="${raw_path}"
            custom_name="custom-$(basename "${raw_path}")"
        else
            log_error "Custom directory does not exist: ${raw_path}"
            return 1
        fi
    elif [[ "${shell_arg}" == "git:"* ]] || [[ "${shell_arg}" == "http://"* ]] || [[ "${shell_arg}" == "https://"* ]] || [[ "${shell_arg}" == "git@"* ]]; then
        local raw_url="${shell_arg#git:}"
        local repo_base
        repo_base="$(basename "${raw_url}" .git)"
        
        # If repo name is generic (like "shell" or "quickshell"), prepend org name
        if [ "${repo_base}" = "shell" ] || [ "${repo_base}" = "quickshell" ]; then
            local org_name
            org_name=$(echo "${raw_url}" | sed -E 's|.*[:/]([^/]+)/[^/]+(\.git)?$|\1|')
            if [ -n "${org_name}" ] && [ "${org_name}" != "${raw_url}" ]; then
                custom_name="custom-${org_name}-${repo_base}"
            else
                custom_name="custom-${repo_base}"
            fi
        else
            custom_name="custom-${repo_base}"
        fi

        resolved_dir="${INTEGRATIONS_DIR}/${custom_name}"

        log_step "Cloning custom shell repository from ${raw_url}"
        if [ -d "${resolved_dir}" ]; then
            log_info "Target custom integration directory already exists at ${resolved_dir}, updating..."
            git -C "${resolved_dir}" pull >&2 || log_warn "Failed to pull latest git changes, using existing copy"
        else
            if command -v clone_with_credentials &>/dev/null; then
                clone_with_credentials "${raw_url}" "${resolved_dir}" >&2
            else
                git clone --recursive "${raw_url}" "${resolved_dir}" >&2
            fi
        fi
    elif [ -d "${shell_arg}" ]; then
        resolved_dir="${shell_arg}"
        custom_name="custom-$(basename "${shell_arg}")"
    else
        return 1
    fi

    echo "${custom_name}:${resolved_dir}"
}

# validate_integration_capabilities() - Validate if system meets an integration's capabilities
validate_integration_capabilities() {
    local shell_name=$1
    local explicit_dir=${2:-}
    local shell_dir="${INTEGRATIONS_DIR}/${shell_name}"
    
    if [ -n "${explicit_dir}" ] && [ -d "${explicit_dir}" ]; then
        shell_dir="${explicit_dir}"
    elif [ ! -d "${shell_dir}" ] && [ -d "${shell_name}" ]; then
        shell_dir="${shell_name}"
    fi

    local manifest="${shell_dir}/manifest.yaml"

    log_step "Validating capability contract for integration [${shell_name}]"

    if [ ! -d "${shell_dir}" ]; then
        log_error "Shell integration [${shell_name}] directory not found"
        return 1
    fi

    declare -g -A CAPABILITIES 2>/dev/null || true
    if [ -z "${CAPABILITIES["wayland"]:-}" ] && command -v detect_capabilities &>/dev/null; then
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
        log_success "Shell integration contract check passed for [${shell_name}]"
        return 0
    fi
}

# install_integration_dependencies() - Install packages declared in an integration's manifest.yaml
install_integration_dependencies() {
    local shell_name=$1
    local shell_dir="${INTEGRATIONS_DIR}/${shell_name}"
    if [ ! -d "${shell_dir}" ] && [ -d "${shell_name}" ]; then
        shell_dir="${shell_name}"
    fi

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
        log_info "Installing package dependencies declared in manifest:"
        cat "${temp_pkg_list}"
        install_packages "${temp_pkg_list}" || log_warn "Failed to install some integration packages, continuing..."
    else
        log_info "No extra package dependencies declared in manifest for [${shell_name}]"
    fi

    rm -f "${temp_pkg_list}"
}

# install_integration_fonts() - Parse and install font requirements, assets, and fontconfig fallbacks from manifest.yaml
install_integration_fonts() {
    local shell_name=$1
    local shell_dir="${INTEGRATIONS_DIR}/${shell_name}"
    if [ ! -d "${shell_dir}" ] && [ -d "${shell_name}" ]; then
        shell_dir="${shell_name}"
    fi

    local manifest="${shell_dir}/manifest.yaml"
    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi

    log_step "Resolving font requirements & fallbacks for integration [${shell_name}]"

    if [ -f "${manifest}" ]; then
        # 1. Parse font packages declared in manifest.yaml
        local temp_font_pkgs
        temp_font_pkgs=$(mktemp)

        python3 -c '
import sys
manifest_path = sys.argv[1]
try:
    import yaml
    with open(manifest_path) as f:
        data = yaml.safe_load(f) or {}
    pkgs = data.get("requires", {}).get("fonts", {}).get("packages", [])
    for p in pkgs:
        print(p)
except Exception:
    in_fonts = False
    in_pkgs = False
    with open(manifest_path) as f:
        for line in f:
            raw = line.strip()
            if "fonts:" in raw:
                in_fonts = True
                continue
            if in_fonts and "packages:" in raw:
                in_pkgs = True
                continue
            if in_pkgs:
                if raw.startswith("- "):
                    pkg = raw[2:].strip().split("#")[0].strip()
                    if pkg:
                        print(pkg)
                elif raw and not raw.startswith("#") and ":" in raw:
                    break
' "${manifest}" > "${temp_font_pkgs}"

        if [ -s "${temp_font_pkgs}" ]; then
            log_info "Installing system font packages declared in manifest:"
            cat "${temp_font_pkgs}"
            install_packages "${temp_font_pkgs}" || log_warn "Failed to install some font packages, continuing..."
        fi
        rm -f "${temp_font_pkgs}"
    fi

    # 2. Auto-discover & sync font files (.ttf, .otf) from shell folder to ~/.local/share/fonts/
    local user_font_dir="${target_user_home}/.local/share/fonts"
    mkdir -p "${user_font_dir}"

    if [ -d "${shell_dir}/assets/fonts" ]; then
        log_info "Deploying integration font assets to ${user_font_dir}"
        cp -r "${shell_dir}/assets/fonts/"* "${user_font_dir}/" 2>/dev/null || true
    fi

    # Search for any standalone .ttf or .otf files inside shell_dir
    local found_fonts
    found_fonts=$(find "${shell_dir}" -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null || true)
    if [ -n "${found_fonts}" ]; then
        log_info "Auto-deploying embedded font files to ${user_font_dir}..."
        echo "${found_fonts}" | while read -r f; do
            cp -f "${f}" "${user_font_dir}/" 2>/dev/null || true
        done
    fi

    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        local user_group
        user_group="$(id -gn "${SUDO_USER}" 2>/dev/null || echo "${SUDO_USER}")"
        chown -R "${SUDO_USER}:${user_group}" "${user_font_dir}" 2>/dev/null || true
    fi

    # 3. Refresh font cache
    fc-cache -fv &>/dev/null || true
    log_success "Font requirements and assets successfully processed for [${shell_name}]"
}

# try_download_prebuilt_plugin() - Attempt to download a pre-built native QML plugin from GitHub Releases
# Returns 0 if download+verify+install succeeded, 1 otherwise (caller falls back to local build)
try_download_prebuilt_plugin() {
    local shell_name="$1"   # e.g. "caelestia"
    local artifact_base="$2" # e.g. "caelestia-plugin-linux"
    local kl_release_repo="${3:-FilippoDeSilva/kali-land}"

    # AGENT.md §35: Detect architecture explicitly; never assume x86_64
    local raw_arch
    raw_arch=$(uname -m)
    local norm_arch
    case "${raw_arch}" in
        x86_64|amd64) norm_arch="x86_64" ;;
        aarch64|arm64) norm_arch="aarch64" ;;
        *) log_warn "Unsupported architecture: ${raw_arch} — no prebuilt available"; return 1 ;;
    esac

    # Check if a prebuilt artifact exists for this arch
    local prebuilt_supported=false
    for pa in "${PREBUILT_ARCHS[@]:-x86_64}"; do
        [ "${pa}" = "${norm_arch}" ] && prebuilt_supported=true && break
    done
    if ! "${prebuilt_supported}"; then
        log_info "No prebuilt artifact for arch ${norm_arch} — will build from source"
        return 1
    fi

    if ! command -v curl &>/dev/null; then
        log_warn "curl not found — cannot download prebuilt artifact"
        return 1
    fi

    # Determine which release tag to target from the repo VERSION
    local kl_version="${KALI_LAND_VERSION:-$(cat "${REPO_ROOT:-/dev/null}/VERSION" 2>/dev/null || echo "")}"
    if [ -z "${kl_version}" ]; then
        log_info "No kali-land release version found — cannot download prebuilt; will build from source"
        return 1
    fi

    local artifact_name="${artifact_base}-${norm_arch}.tar.gz"
    local checksum_name="${artifact_name}.sha256"
    local base_url="https://github.com/${kl_release_repo}/releases/download/v${kl_version}"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    log_info "Trying prebuilt ${artifact_name} from release v${kl_version}..."

    # Download artifact + checksum (silent, with timeout)
    if ! curl -fsSL --connect-timeout 10 --max-time 120 \
        -o "${tmp_dir}/${artifact_name}" \
        "${base_url}/${artifact_name}" 2>/dev/null; then
        log_info "Prebuilt artifact not available in release v${kl_version} — falling back to local build"
        rm -rf "${tmp_dir}"
        return 1
    fi

    if ! curl -fsSL --connect-timeout 10 --max-time 10 \
        -o "${tmp_dir}/${checksum_name}" \
        "${base_url}/${checksum_name}" 2>/dev/null; then
        log_warn "Checksum file missing for prebuilt — skipping to ensure integrity; will build from source"
        rm -rf "${tmp_dir}"
        return 1
    fi

    # AGENT.md §36: Verify sha256 checksum before installing anything
    log_info "Verifying sha256 checksum..."
    cd "${tmp_dir}"
    if ! sha256sum -c "${checksum_name}" &>/dev/null; then
        log_error "Checksum verification FAILED for ${artifact_name} — refusing to install"
        log_warn "The downloaded artifact may be corrupt or tampered with"
        rm -rf "${tmp_dir}"
        return 1
    fi
    log_success "Checksum verified: ${artifact_name}"

    # Extract and install the prebuilt QML plugin
    log_info "Installing prebuilt native QML plugin for [${shell_name}]..."
    if ! sudo tar -xzf "${tmp_dir}/${artifact_name}" -C /; then
        log_error "Failed to extract prebuilt artifact — falling back to local build"
        rm -rf "${tmp_dir}"
        return 1
    fi

    rm -rf "${tmp_dir}"
    log_success "Prebuilt [${shell_name}] QML plugin installed from release v${kl_version} (${norm_arch})"
    return 0
}

# build_cmake_shell() - Build a shell that ships with CMakeLists.txt (e.g., Caelestia)
# First tries to download a prebuilt artifact from GitHub Releases for speed.
# Falls back to local cmake build if no prebuilt is available or download fails.
build_cmake_shell() {
    local shell_dir=$1
    local shell_name
    shell_name=$(basename "${shell_dir}")

    log_step "Preparing native QML plugin for shell [${shell_name}]"

    # Fast path: try downloading prebuilt artifact from GitHub Release
    if try_download_prebuilt_plugin "${shell_name}" "${CAELESTIA_ARTIFACT_NAME:-caelestia-plugin-linux}" "FilippoDeSilva/kali-land"; then
        log_success "Using prebuilt artifact — skipping local cmake build"
        return 0
    fi

    log_info "No prebuilt available — building [${shell_name}] from source (this takes a few minutes)"

    # ── Idempotency: check if native QML type is already registered ──────────────
    # Skip rebuild if Caelestia.Config is already available to the QML engine
    if command -v qml6 &>/dev/null; then
        if echo 'import Caelestia 1.0; Item {}' | qml6 --stdin &>/dev/null 2>&1; then
            log_info "Native QML type Caelestia.Config already registered — skipping rebuild"
            return 0
        fi
    fi

    # ── Install cmake build toolchain ────────────────────────────────────────────
    local need_tools=()
    command -v cmake      &>/dev/null || need_tools+=("cmake")
    command -v ninja      &>/dev/null || need_tools+=("ninja-build")
    command -v pkg-config &>/dev/null || need_tools+=("pkg-config")
    if [ ${#need_tools[@]} -gt 0 ]; then
        log_info "Installing build toolchain: ${need_tools[*]}"
        sudo apt-get install -y "${need_tools[@]}" 2>&1 | \
            grep -E "^(Err|E:|dpkg-|Setting up)" || true
    fi

    # ── Mandatory Kali/Debian build dependencies ─────────────────────────────────
    # AGENT.md §13: These are Debian/Kali package names, NOT Arch names.
    local mandatory_deps=(
        "cmake"
        "ninja-build"
        "pkg-config"
        "build-essential"
        "extra-cmake-modules"
        "qt6-base-dev"
        "qt6-base-private-dev"
        "qt6-declarative-dev"
        "qt6-declarative-private-dev"
        "qt6-shadertools-dev"
        "wayland-protocols"
        "libwayland-dev"
        "libpipewire-0.3-dev"
        "libddcutil-dev"
        "libsensors-dev"
        "libqalculate-dev"
        "ddcutil"
        "brightnessctl"
        "fish"
        "swappy"
    )

    # ── Optional Kali/Debian dependencies (shell degrades gracefully if missing) ──
    local optional_deps=(
        "libaubio-dev"        # audio beat detection (optional visualizer feature)
        "power-profiles-daemon"  # battery/power profiles (optional)
        "spirv-tools"         # shader optimization (optional, improves GPU perf)
    )

    log_info "Installing mandatory Caelestia build dependencies..."
    local failed_mandatory=()
    for dep in "${mandatory_deps[@]}"; do
        if ! dpkg -l "${dep}" &>/dev/null 2>&1; then
            if ! sudo apt-get install -y "${dep}" &>/dev/null 2>&1; then
                failed_mandatory+=("${dep}")
                log_warn "  [MISSING] ${dep} — not available in apt"
            fi
        fi
    done
    if [ ${#failed_mandatory[@]} -gt 0 ]; then
        log_error "Failed to install mandatory dependencies: ${failed_mandatory[*]}"
        log_info "See: https://github.com/caelestia-dots/shell#manual-installation"
        return 1
    fi

    log_info "Installing optional Caelestia dependencies (failures are non-fatal)..."
    for dep in "${optional_deps[@]}"; do
        if ! dpkg -l "${dep}" &>/dev/null 2>&1; then
            sudo apt-get install -y "${dep}" &>/dev/null 2>&1 || \
                log_info "  [OPTIONAL SKIP] ${dep} not available — feature may be limited"
        fi
    done

    # AGENT.md §55: Record installed packages for ownership tracking / uninstall safety
    if declare -f ledger_record_packages &>/dev/null; then
        ledger_record_packages "integration:${shell_name}" "${mandatory_deps[@]}"
    fi

    # ── cmake configure → build → install ────────────────────────────────────────
    local build_dir="${shell_dir}/build"
    # Idempotency: reuse existing build dir if source is unchanged
    if [ -f "${build_dir}/CMakeCache.txt" ]; then
        log_info "Existing build dir found — running incremental build"
    else
        rm -rf "${build_dir}"
        mkdir -p "${build_dir}"
    fi

    log_info "Running cmake configure..."
    local cmake_log
    cmake_log=$(mktemp)
    if ! cmake -B "${build_dir}" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/ \
        -S "${shell_dir}" > "${cmake_log}" 2>&1; then
        log_error "cmake configure failed for [${shell_name}]"
        # AGENT.md §48: Show errors, not hide them
        log_error "cmake output:"
        tail -n 30 "${cmake_log}" | while IFS= read -r line; do log_info "  ${line}"; done
        rm -f "${cmake_log}"
        log_info "Full cmake log: ${cmake_log}"
        log_info "Install missing deps and retry: kali-land shell install <url>"
        log_info "Manual install docs: https://github.com/caelestia-dots/shell#manual-installation"
        return 1
    fi
    rm -f "${cmake_log}"

    log_info "Building [${shell_name}] (this may take a few minutes)..."
    local build_log
    build_log=$(mktemp)
    if ! cmake --build "${build_dir}" > "${build_log}" 2>&1; then
        log_error "cmake build failed for [${shell_name}]"
        tail -n 30 "${build_log}" | while IFS= read -r line; do log_info "  ${line}"; done
        rm -f "${build_log}"
        return 1
    fi
    rm -f "${build_log}"

    log_info "Installing native QML plugin to system (requires sudo)..."
    if ! sudo cmake --install "${build_dir}" 2>&1 | grep -E "^(-- Installing|CMake Error)" | \
            while IFS= read -r line; do log_info "  ${line}"; done; then
        log_error "cmake install failed for [${shell_name}]"
        return 1
    fi

    log_success "Native QML plugin for [${shell_name}] built and installed from source"
    return 0
}

# install_integration() - Install a shell integration (bundled, custom path, or git) with prompt & backup protection
install_integration() {
    local raw_shell_name=${1:-"end4-pC"}
    local shell_name="${raw_shell_name}"
    local source_dir="${INTEGRATIONS_DIR}/${shell_name}"

    if [[ "${raw_shell_name}" == "path:"* ]] || [[ "${raw_shell_name}" == "git:"* ]] || [[ "${raw_shell_name}" == "http://"* ]] || [[ "${raw_shell_name}" == "https://"* ]] || [[ "${raw_shell_name}" == "git@"* ]] || [ -d "${raw_shell_name}" ]; then
        local resolved_info
        resolved_info=$(resolve_custom_shell_path "${raw_shell_name}")
        if [ $? -eq 0 ] && [ -n "${resolved_info}" ]; then
            shell_name=$(echo "${resolved_info}" | cut -d':' -f1)
            source_dir=$(echo "${resolved_info}" | cut -d':' -f2-)
        else
            log_error "Failed to resolve custom shell path: ${raw_shell_name}"
            return 1
        fi
    fi

    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi
    local target_dir="${target_user_home}/.config/quickshell/${shell_name}"

    log_step "Deploying shell integration [${shell_name}] to isolated path ${target_dir}"

    if [ ! -d "${source_dir}" ]; then
        log_error "Source directory for shell [${shell_name}] does not exist at ${source_dir}"
        return 1
    fi

    # Auto-detect or synthesize manifest.yaml if missing
    auto_detect_shell_manifest "${source_dir}"

    # If shell ships with CMakeLists.txt, it needs cmake build to register native QML types
    if [ -f "${source_dir}/CMakeLists.txt" ]; then
        log_info "Shell [${shell_name}] has a CMakeLists.txt — building native QML plugin..."
        build_cmake_shell "${source_dir}" || log_warn "CMake build failed; shell may not function correctly without native QML types"
    fi

    # Validate capabilities
    validate_integration_capabilities "${shell_name}" "${source_dir}" || log_warn "Deploying shell despite missing capabilities"

    # Install integration-specific package dependencies declared in manifest.yaml
    install_integration_dependencies "${shell_name}"

    # Install integration font requirements, assets & fontconfig fallbacks
    install_integration_fonts "${shell_name}"

    # Use protected config installation flow (prompt -> backup -> deploy)
    protect_and_install_config "${source_dir}" "${target_dir}" "Shell Integration (${shell_name})"

    # Automatically activate this shell integration in Hyprland autostart
    configure_quickshell_hypr_env "${shell_name}"

    # Export resolved shell name back for calling context
    SELECTED_SHELL="${shell_name}"
}

# configure_quickshell_hypr_env() - Configure Hyprland autostart & environment for Quickshell (Lua & Conf)
configure_quickshell_hypr_env() {
    local raw_name="${1:-end4-pC}"
    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi

    local shell_name="${raw_name}"
    if command -v resolve_installed_shell_name &>/dev/null; then
        shell_name=$(resolve_installed_shell_name "${raw_name}")
    fi

    local hypr_dir="${target_user_home}/.config/hypr"
    mkdir -p "${hypr_dir}/kali-land"

    # Paths for both root ~/.config/hypr/ and ~/.config/hypr/kali-land/
    local env_lua_root="${hypr_dir}/environment.lua"
    local env_lua_kl="${hypr_dir}/kali-land/environment.lua"
    local autostart_lua_root="${hypr_dir}/autostart.lua"
    local autostart_lua_kl="${hypr_dir}/kali-land/autostart.lua"
    local hypr_conf="${hypr_dir}/hyprland.conf"
    local hypr_lua="${hypr_dir}/hyprland.lua"

    local qs_path="${target_user_home}/.config/quickshell/${shell_name}"
    local qs_cmd="exec-once = quickshell --path ${qs_path}"

    log_step "Configuring Hyprland environment & autostart for shell [${shell_name}]"

    # Handle "none" / DIY mode
    if [ "${shell_name}" = "none" ]; then
        log_info "Configuring Hyprland autostart for Bare Minimal / DIY mode"
        for f in "${env_lua_root}" "${env_lua_kl}"; do
            [ -f "${f}" ] && sed -i 's|hl\.env("QS_CONFIG".*|hl.env("QS_CONFIG", "none")|g' "${f}" 2>/dev/null || true
        done
        for f in "${autostart_lua_root}" "${autostart_lua_kl}"; do
            [ -f "${f}" ] && sed -i '/quickshell/d' "${f}" 2>/dev/null || true
        done
        [ -f "${hypr_conf}" ] && sed -i '/quickshell/d' "${hypr_conf}" 2>/dev/null || true
        return 0
    fi

    # Step 0: Deploy kali-land Hyprland config files from repo if not yet deployed
    local repo_hypr_config=""
    for candidate in \
        "${REPO_ROOT:-}/config/hypr" \
        "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null | xargs dirname 2>/dev/null)/../../config/hypr" \
        "${HOME}/Desktop/kali-land/config/hypr" \
        "/home/kali/Desktop/kali-land/config/hypr"; do
        if [ -d "${candidate}" ]; then
            repo_hypr_config="$(cd "${candidate}" && pwd)"
            break
        fi
    done

    if [ -n "${repo_hypr_config}" ]; then
        for src_lua in "${repo_hypr_config}"/*.lua; do
            [ -f "${src_lua}" ] || continue
            local fname
            fname=$(basename "${src_lua}")
            local dest_kl="${hypr_dir}/kali-land/${fname}"
            if [ ! -f "${dest_kl}" ]; then
                cp "${src_lua}" "${dest_kl}"
                log_info "Deployed ${fname} -> ${dest_kl}"
            fi
        done
        # Deploy top-level hyprland.lua entry point if missing
        if [ ! -f "${hypr_lua}" ] && [ -f "${repo_hypr_config}/hyprland.lua" ]; then
            cp "${repo_hypr_config}/hyprland.lua" "${hypr_lua}"
            log_info "Deployed hyprland.lua -> ${hypr_lua}"
        fi
    fi

    # Step 1: Update QS_CONFIG in environment.lua in BOTH locations
    for env_file in "${env_lua_root}" "${env_lua_kl}"; do
        mkdir -p "$(dirname "${env_file}")"
        if [ -f "${env_file}" ]; then
            if grep -q "QS_CONFIG" "${env_file}"; then
                sed -i "s|hl\.env(\"QS_CONFIG\".*|hl.env(\"QS_CONFIG\", \"${shell_name}\")|g" "${env_file}"
            else
                echo "hl.env(\"QS_CONFIG\", \"${shell_name}\")" >> "${env_file}"
            fi
        else
            echo "hl.env(\"QS_CONFIG\", \"${shell_name}\")" > "${env_file}"
        fi
        log_success "Set QS_CONFIG=\"${shell_name}\" in ${env_file}"
    done

    # 2. Update Hyprland Lua Autostart in both locations
    for auto_file in "${autostart_lua_root}" "${autostart_lua_kl}"; do
        mkdir -p "$(dirname "${auto_file}")"
        if [ ! -f "${auto_file}" ] || ! grep -q "quickshell" "${auto_file}"; then
            cat <<EOF >> "${auto_file}"

-- Auto-added by kali-land CLI
local qs_config = os.getenv("QS_CONFIG") or "${shell_name}"
if qs_config and qs_config ~= "" and qs_config ~= "none" then
    local shell_path = os.getenv("HOME") .. "/.config/quickshell/" .. qs_config
    hl.exec_cmd("quickshell --path " .. shell_path)
end
EOF
        fi
        log_success "Updated Lua autostart in ${auto_file}"
    done

    # 3. Update legacy hyprland.conf if present
    if [ -f "${hypr_conf}" ]; then
        if grep -q "quickshell" "${hypr_conf}"; then
            sed -i "s|.*quickshell.*|${qs_cmd}|g" "${hypr_conf}"
        else
            echo "" >> "${hypr_conf}"
            echo "# Auto-configured by kali-land" >> "${hypr_conf}"
            echo "${qs_cmd}" >> "${hypr_conf}"
        fi
        log_success "Updated ${hypr_conf} -> ${qs_cmd}"
    fi

    # 4. Ensure hyprland.lua entrypoint exists if no hyprland.conf exists
    if [ ! -f "${hypr_conf}" ] && [ ! -f "${hypr_lua}" ]; then
        cat <<'EOF' > "${hypr_lua}"
-- Hyprland configuration entry point for Kali-land
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/hypr/kali-land/?.lua"

require("config")
require("environment")
require("monitors")
require("keybinds")
require("rules")
require("autostart")
EOF
        log_success "Created main entry point ${hypr_lua}"
    else
        # Ensure kali-land/ is on the package path in the existing hyprland.lua
        if [ -f "${hypr_lua}" ] && ! grep -q "kali-land" "${hypr_lua}"; then
            sed -i '1s|^|package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/hypr/kali-land/?.lua"\n|' "${hypr_lua}"
            log_success "Added kali-land package.path to ${hypr_lua}"
        fi
    fi

    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        local user_group
        user_group="$(id -gn "${SUDO_USER}" 2>/dev/null || echo "${SUDO_USER}")"
        chown -R "${SUDO_USER}:${user_group}" "${hypr_dir}" 2>/dev/null || true
    fi

    log_success "Hyprland configured: shell [${shell_name}] will launch on next login"
    log_info "Launch NOW without re-login: quickshell --path ${qs_path}"
}

# resolve_runtime_environment() - Detect declared runtime (quickshell, celestia, waybar, none)
resolve_runtime_environment() {
    local target_dir=$1
    local manifest="${target_dir}/manifest.yaml"
    local runtime="quickshell"

    if [ -f "${manifest}" ]; then
        runtime=$(python3 -c '
import sys
try:
    with open(sys.argv[1]) as f:
        for line in f:
            if line.strip().startswith("runtime:"):
                print(line.split(":", 1)[1].strip().strip("\"'\''"))
                sys.exit(0)
            if line.strip().startswith("type:"):
                print(line.split(":", 1)[1].strip().strip("\"'\''"))
                sys.exit(0)
    print("quickshell")
except Exception:
    print("quickshell")
' "${manifest}")
    fi

    echo "${runtime:-quickshell}"
}

# discover_shell() - Non-mutating pre-flight discovery audit & dry-run plan generator
discover_shell() {
    local target_arg=$1
    if [ -z "${target_arg}" ]; then
        log_error "Usage: kali-land shell discover <path|url>"
        return 1
    fi

    local resolved_info
    local temp_clone=false
    local source_dir=""
    local shell_name=""

    if [[ "${target_arg}" == "http://"* ]] || [[ "${target_arg}" == "https://"* ]] || [[ "${target_arg}" == "git@"* ]]; then
        shell_name="custom-$(basename "${target_arg}" .git)"
        source_dir="/tmp/kali-land-discover-${shell_name}"
        if [ -d "${source_dir}" ]; then
            log_info "Using cached temporary audit repository at ${source_dir}"
        else
            log_info "Cloning remote repository for audit: ${target_arg}"
            git clone --depth 1 "${target_arg}" "${source_dir}" &>/dev/null || {
                log_error "Failed to clone repository from ${target_arg}"
                return 1
            }
        fi
        temp_clone=true
    elif [ -d "${target_arg}" ]; then
        source_dir="$(cd "${target_arg}" && pwd)"
        shell_name="custom-$(basename "${source_dir}")"
    else
        log_error "Specified directory or repository does not exist: ${target_arg}"
        return 1
    fi

    echo ""
    echo "=========================================================="
    echo "  KALI-LAND SHELL DISCOVERY AUDIT REPORT"
    echo "=========================================================="
    echo "Target Name:    ${shell_name}"
    echo "Source Path:    ${source_dir}"

    local runtime
    runtime=$(resolve_runtime_environment "${source_dir}")
    echo "Runtime:        ${runtime}"

    local entry="unknown"
    if [ -f "${source_dir}/shell.qml" ]; then
        entry="shell.qml"
    elif [ -f "${source_dir}/main.qml" ]; then
        entry="main.qml"
    else
        local qml
        qml=$(find "${source_dir}" -maxdepth 2 -name "*.qml" 2>/dev/null | head -n 1)
        [ -n "${qml}" ] && entry="$(basename "${qml}")"
    fi
    echo "Entry Point:    ${entry}"

    local manifest_status="missing (will auto-synthesize)"
    [ -f "${source_dir}/manifest.yaml" ] && manifest_status="present"
    echo "Manifest:       ${manifest_status}"

    local font_count
    font_count=$(find "${source_dir}" -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | wc -l)
    echo "Embedded Fonts: ${font_count} font file(s) discovered"

    echo ""
    echo "─── Pre-flight Capability Audit ───"
    if command -v validate_integration_capabilities &>/dev/null; then
        validate_integration_capabilities "${shell_name}" "${source_dir}" || true
    fi
    echo "=========================================================="
    echo ""

    return 0
}

# import_shell() - Import a custom shell into managed integrations directory
import_shell() {
    local target_arg=$1
    if [ -z "${target_arg}" ]; then
        log_error "Usage: kali-land shell import <path|url>"
        return 1
    fi

    log_step "Importing shell [${target_arg}]"
    install_integration "path:${target_arg}"
}

# resolve_installed_shell_name() - Smart resolver mapping identifier, url, or substring to installed shell namespace
resolve_installed_shell_name() {
    local query=$1
    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi
    local qs_dir="${target_user_home}/.config/quickshell"

    [ -z "${query}" ] && echo "" && return 0

    # If query is full URL, resolve repo name
    if [[ "${query}" == "http://"* ]] || [[ "${query}" == "https://"* ]] || [[ "${query}" == "git@"* ]]; then
        local repo_base
        repo_base="$(basename "${query}" .git)"
        if [ "${repo_base}" = "shell" ] || [ "${repo_base}" = "quickshell" ]; then
            local org_name
            org_name=$(echo "${query}" | sed -E 's|.*[:/]([^/]+)/[^/]+(\.git)?$|\1|')
            query="custom-${org_name}-${repo_base}"
        else
            query="custom-${repo_base}"
        fi
    fi

    # 1. Direct exact match in ~/.config/quickshell/
    if [ -d "${qs_dir}/${query}" ]; then
        echo "${query}"
        return 0
    fi
    # 2. Match in INTEGRATIONS_DIR
    if [ -d "${INTEGRATIONS_DIR}/${query}" ]; then
        echo "${query}"
        return 0
    fi
    # 3. Match with custom- prefix
    if [ -d "${qs_dir}/custom-${query}" ]; then
        echo "custom-${query}"
        return 0
    fi
    # 4. Match with custom-<query>-shell
    if [ -d "${qs_dir}/custom-${query}-shell" ]; then
        echo "custom-${query}-shell"
        return 0
    fi
    # 5. Try stripped custom- prefix
    local stripped="${query#custom-}"
    if [ -d "${qs_dir}/${stripped}" ]; then
        echo "${stripped}"
        return 0
    fi
    # 6. Substring match under ~/.config/quickshell/
    if [ -d "${qs_dir}" ]; then
        for match in "${qs_dir}"/*; do
            if [ -d "${match}" ]; then
                local bname
                bname="$(basename "${match}")"
                if [[ "${bname}" == *"${stripped}"* ]]; then
                    echo "${bname}"
                    return 0
                fi
            fi
        done
    fi

    # Fallback to query
    echo "${query}"
}

# switch_shell() - Switch active shell integration and update Hyprland autostart
switch_shell() {
    local raw_target=$1
    if [ -z "${raw_target}" ]; then
        log_error "Usage: kali-land shell switch <integration-id|none>"
        return 1
    fi

    local target_shell
    target_shell=$(resolve_installed_shell_name "${raw_target}")

    log_step "Switching active desktop shell to [${target_shell}]"

    if [ "${target_shell}" != "none" ]; then
        local target_user_home="${HOME}"
        if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
            target_user_home="$(eval echo "~${SUDO_USER}")"
        fi
        local shell_dir="${target_user_home}/.config/quickshell/${target_shell}"
        if [ ! -d "${shell_dir}" ] && [ -d "${INTEGRATIONS_DIR}/${target_shell}" ]; then
            log_info "Installing integration [${target_shell}] first..."
            install_integration "${target_shell}"
        fi
    fi

    if command -v configure_quickshell_hypr_env &>/dev/null; then
        configure_quickshell_hypr_env "${target_shell}"
    fi

    log_success "Active desktop shell switched to [${target_shell}]"
}

# remove_shell() - Safely remove an installed shell integration namespace
remove_shell() {
    local raw_name=$1
    if [ -z "${raw_name}" ]; then
        log_error "Usage: kali-land shell remove <integration-id>"
        return 1
    fi

    local shell_name
    shell_name=$(resolve_installed_shell_name "${raw_name}")

    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi

    local target_dir="${target_user_home}/.config/quickshell/${shell_name}"
    local integration_source="${INTEGRATIONS_DIR}/${shell_name}"
    local removed_anything=false

    log_step "Removing shell integration [${shell_name}]..."

    # 1. Remove deployed config directory in ~/.config/quickshell/
    if [ -d "${target_dir}" ]; then
        if command -v create_backup &>/dev/null; then
            create_backup "${target_dir}" "Pre-removal backup of ${shell_name}"
        fi
        rm -rf "${target_dir}"
        log_info "Removed deployed configuration at ${target_dir}"
        removed_anything=true
    fi

    # 2. Remove cloned custom integration directory in integrations/
    if [ -d "${integration_source}" ]; then
        rm -rf "${integration_source}"
        log_info "Removed integration source at ${integration_source}"
        removed_anything=true
    fi

    if [ "${removed_anything}" = "true" ]; then
        log_success "Shell integration [${shell_name}] removed cleanly."
    else
        log_warn "Shell integration [${raw_name}] (resolved: ${shell_name}) was not found installed."
    fi
}

# list_all_shells() - List bundled integrations, custom installed shells, and active shell
list_all_shells() {
    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi

    local active_shell="none"
    local autostart="${target_user_home}/.config/hypr/kali-land/autostart.lua"
    if [ -f "${autostart}" ]; then
        active_shell=$(grep -o "quickshell --path [^ '\"\\]*" "${autostart}" 2>/dev/null | awk -F'/' '{print $NF}' || echo "none")
    fi

    echo ""
    echo "=========================================================="
    echo "  KALI-LAND SHELL INTEGRATION REGISTRY"
    echo "=========================================================="
    echo "Active Experience: [${active_shell:-none}]"
    echo ""

    echo "Bundled Stock Integrations:"
    if [ -d "${INTEGRATIONS_DIR}" ]; then
        for item in "${INTEGRATIONS_DIR}"/*; do
            if [ -d "${item}" ]; then
                local name
                name=$(basename "${item}")
                if [[ "${name}" != "custom-"* ]]; then
                    local active_mark=" "
                    [ "${name}" = "${active_shell}" ] && active_mark="*"
                    echo "  ${active_mark} ${name}"
                fi
            fi
        done
    fi

    echo ""
    echo "Installed Custom Shells:"
    local seen_shells=()

    # Scan cloned custom integrations in repository integrations/
    if [ -d "${INTEGRATIONS_DIR}" ]; then
        for item in "${INTEGRATIONS_DIR}"/*; do
            if [ -d "${item}" ]; then
                local name
                name=$(basename "${item}")
                if [[ "${name}" == "custom-"* ]]; then
                    seen_shells+=("${name}")
                    local active_mark=" "
                    [ "${name}" = "${active_shell}" ] && active_mark="*"
                    echo "  ${active_mark} ${name} (custom integration)"
                fi
            fi
        done
    fi

    # Scan deployed custom shells in ~/.config/quickshell/
    local qs_dir="${target_user_home}/.config/quickshell"
    if [ -d "${qs_dir}" ]; then
        for item in "${qs_dir}"/*; do
            if [ -d "${item}" ]; then
                local name
                name=$(basename "${item}")

                # Skip backup directories
                if [[ "${name}" == *".backup"* ]] || [[ "${name}" == "backup"* ]]; then
                    continue
                fi

                local already_seen=false
                for s in "${seen_shells[@]:-}"; do
                    if [ "${s}" = "${name}" ]; then
                        already_seen=true
                        break
                    fi
                done
                [ "${already_seen}" = "true" ] && continue

                if [ ! -d "${INTEGRATIONS_DIR}/${name}" ]; then
                    # Must contain a root QML entrypoint (depth 1) or manifest.yaml to be a shell
                    local has_root_qml
                    has_root_qml=$(find "${item}" -maxdepth 1 -name "*.qml" 2>/dev/null | head -n 1)
                    if [ -f "${item}/manifest.yaml" ] || [ -f "${item}/shell.qml" ] || [ -f "${item}/main.qml" ] || [ -n "${has_root_qml}" ]; then
                        local active_mark=" "
                        [ "${name}" = "${active_shell}" ] && active_mark="*"
                        echo "  ${active_mark} ${name} (custom config)"
                    fi
                fi
            fi
        done
    fi
    echo "=========================================================="
    echo ""
}




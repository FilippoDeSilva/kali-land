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
        custom_name="custom-$(basename "${raw_url}" .git)"
        resolved_dir="${INTEGRATIONS_DIR}/${custom_name}"

        log_step "Cloning custom shell repository from ${raw_url}"
        if [ -d "${resolved_dir}" ]; then
            log_info "Target custom integration directory already exists at ${resolved_dir}, updating..."
            git -C "${resolved_dir}" pull || log_warn "Failed to pull latest git changes, using existing copy"
        else
            if command -v clone_with_credentials &>/dev/null; then
                clone_with_credentials "${raw_url}" "${resolved_dir}"
            else
                git clone --recursive "${raw_url}" "${resolved_dir}"
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

    # Validate capabilities
    validate_integration_capabilities "${shell_name}" "${source_dir}" || log_warn "Deploying shell despite missing capabilities"

    # Install integration-specific package dependencies declared in manifest.yaml
    install_integration_dependencies "${shell_name}"

    # Install integration font requirements, assets & fontconfig fallbacks
    install_integration_fonts "${shell_name}"

    # Use protected config installation flow (prompt -> backup -> deploy)
    protect_and_install_config "${source_dir}" "${target_dir}" "Shell Integration (${shell_name})"

    # Export resolved shell name back for calling context
    SELECTED_SHELL="${shell_name}"
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
        rm -rf "${source_dir}"
        log_info "Cloning remote repository for audit: ${target_arg}"
        git clone --depth 1 "${target_arg}" "${source_dir}" &>/dev/null || {
            log_error "Failed to clone repository from ${target_arg}"
            return 1
        }
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

    ${temp_clone} && rm -rf "${source_dir}"
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

# switch_shell() - Switch active shell integration and update Hyprland autostart
switch_shell() {
    local target_shell=$1
    if [ -z "${target_shell}" ]; then
        log_error "Usage: kali-land shell switch <integration-id|none>"
        return 1
    fi

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
    local shell_name=$1
    if [ -z "${shell_name}" ]; then
        log_error "Usage: kali-land shell remove <integration-id>"
        return 1
    fi

    local target_user_home="${HOME}"
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        target_user_home="$(eval echo "~${SUDO_USER}")"
    fi

    local target_dir="${target_user_home}/.config/quickshell/${shell_name}"

    if [ ! -d "${target_dir}" ]; then
        log_warn "Shell integration [${shell_name}] is not installed at ${target_dir}"
        return 0
    fi

    log_step "Removing installed shell integration [${shell_name}] at ${target_dir}"
    
    if command -v create_backup &>/dev/null; then
        create_backup "${target_dir}" "Pre-removal backup of ${shell_name}"
    fi

    rm -rf "${target_dir}"
    log_success "Shell integration [${shell_name}] removed cleanly."
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

    echo "Bundled Integrations:"
    if [ -d "${INTEGRATIONS_DIR}" ]; then
        for item in "${INTEGRATIONS_DIR}"/*; do
            if [ -d "${item}" ]; then
                local name
                name=$(basename "${item}")
                local active_mark=" "
                [ "${name}" = "${active_shell}" ] && active_mark="*"
                echo "  ${active_mark} ${name}"
            fi
        done
    fi

    echo ""
    echo "Installed Custom Shells (~/.config/quickshell/):"
    local qs_dir="${target_user_home}/.config/quickshell"
    if [ -d "${qs_dir}" ]; then
        for item in "${qs_dir}"/*; do
            if [ -d "${item}" ]; then
                local name
                name=$(basename "${item}")
                if [ ! -d "${INTEGRATIONS_DIR}/${name}" ]; then
                    local active_mark=" "
                    [ "${name}" = "${active_shell}" ] && active_mark="*"
                    echo "  ${active_mark} ${name} (custom)"
                fi
            fi
        done
    fi
    echo "=========================================================="
    echo ""
}




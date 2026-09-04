#!/bin/bash
# validate-lua-config.sh - Validate Hyprland Lua configuration without starting Hyprland

set -Eeuo pipefail

echo "=========================================="
echo "  Hyprland Lua Configuration Validator"
echo "=========================================="
echo ""

CONFIG_DIR="${HOME}/.config/hypr"
REPO_CONFIG_DIR="/home/kali/Desktop/kali-land/config/hypr"

# Check if config directory exists
if [ ! -d "${CONFIG_DIR}" ]; then
    echo "ERROR: Hyprland config directory not found: ${CONFIG_DIR}"
    exit 1
fi

echo "Checking configuration files in: ${CONFIG_DIR}"
echo ""

# Check for main entry point
if [ -f "${CONFIG_DIR}/hyprland.lua" ]; then
    echo "✓ Main entry point found: hyprland.lua"
else
    echo "✗ Main entry point missing: hyprland.lua"
    exit 1
fi

# Check for required modules
required_modules=("config" "environment" "monitors" "keybinds" "rules" "autostart" "vmware")
missing_modules=()

for module in "${required_modules[@]}"; do
    if [ -f "${CONFIG_DIR}/${module}.lua" ]; then
        echo "✓ Module found: ${module}.lua"
    else
        echo "✗ Module missing: ${module}.lua"
        missing_modules+=("${module}")
    fi
done

echo ""

# Check for old .conf files
conf_files=$(find "${CONFIG_DIR}" -name "*.conf" 2>/dev/null | wc -l)
if [ "${conf_files}" -gt 0 ]; then
    echo "⚠ WARNING: Found ${conf_files} old .conf files in config directory"
    echo "  These may conflict with Lua configuration"
    find "${CONFIG_DIR}" -name "*.conf" -exec basename {} \;
else
    echo "✓ No old .conf files found (clean state)"
fi

echo ""

# Check module syntax (basic validation)
echo "Validating Lua module structure..."

for module in "${required_modules[@]}"; do
    module_file="${CONFIG_DIR}/${module}.lua"
    if [ -f "${module_file}" ]; then
        # Check for basic Lua syntax errors
        # Since we don't have luac, we do basic checks
        if grep -q "hl\\.config\\|hl\\.env\\|hl\\.window_rule\\|hl\\.bind\\|hl\\.exec_cmd\\|hl\\.on\\|hl\\.curve\\|hl\\.animation\\|hl\\.monitor" "${module_file}"; then
            echo "✓ ${module}.lua: Contains expected Hyprland API calls"
        else
            echo "⚠ ${module}.lua: May not contain Hyprland API calls"
        fi
        
        # Check for balanced quotes (simple check) - make this non-fatal
        single_quotes=$(grep -o "'" "${module_file}" | wc -l || true)
        if [ $((single_quotes % 2)) -ne 0 ]; then
            echo "⚠ ${module}.lua: Possible unbalanced single quotes (non-fatal)"
        fi
    fi
done

echo ""

# Check main entry point structure
echo "Validating main entry point structure..."
if grep -q "require" "${CONFIG_DIR}/hyprland.lua"; then
    echo "✓ hyprland.lua: Uses require() statements"
else
    echo "✗ hyprland.lua: Missing require() statements"
fi

# Check that all required modules are required
for module in "${required_modules[@]}"; do
    if grep -q "require(\"${module}\")" "${CONFIG_DIR}/hyprland.lua"; then
        echo "✓ hyprland.lua: Requires ${module}"
    else
        echo "✗ hyprland.lua: Missing require(\"${module}\")"
    fi
done

echo ""
echo "=========================================="
echo "  Validation Summary"
echo "=========================================="

if [ ${#missing_modules[@]} -eq 0 ]; then
    echo "✓ All required modules present"
    echo ""
    echo "Configuration structure appears valid."
    echo "Note: This is a basic syntax check."
    echo "Full validation requires running Hyprland and checking for runtime errors."
    echo ""
    echo "To test the configuration in a live session:"
    echo "  1. Run: bash /home/kali/Desktop/kali-land/scripts/test-hyprland.sh"
    echo "  2. If Hyprland starts successfully, the configuration is valid"
    echo "  3. Check the Hyprland log for any Lua errors:"
    echo "     journalctl --user -u hyprland"
    exit 0
else
    echo "✗ Missing modules: ${missing_modules[*]}"
    echo ""
    echo "Please ensure all required Lua modules are present in:"
    echo "  ${CONFIG_DIR}"
    exit 1
fi

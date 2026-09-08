-- Main Hyprland Lua configuration
-- kali-land - Modern Desktop Environment
-- This is the main entry point that requires all other modules

-- Core configuration modules
require("config")
require("environment")
require("monitors")
require("keybinds")
require("rules")
require("autostart")

-- VMware-specific configuration (only loaded if genuinely running under VMware virtualization)
local function check_is_vmware()
    if os.getenv("VIRTUALIZATION") == "vmware" then
        return true
    end
    local handle = io.popen("systemd-detect-virt 2>/dev/null")
    if handle then
        local result = handle:read("*a") or ""
        handle:close()
        result = result:gsub("%s+", "")
        if result == "vmware" then
            return true
        fi
    end
    return false
end

if check_is_vmware() then
    require("vmware")
end

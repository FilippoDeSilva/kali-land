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

-- VMware-specific configuration (only load if running in VMware)
local vm_detected = os.getenv("VIRTUALIZATION") == "vmware" or 
                   os.getenv("DESKTOP_SESSION") == "vmware" or
                   (os.execute("systemd-detect-virt") == 0 and os.execute("systemd-detect-virt | grep -q vmware") == 0)

if vm_detected then
    require("vmware")
end

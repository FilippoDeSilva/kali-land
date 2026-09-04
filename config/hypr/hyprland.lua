-- Main Hyprland Lua configuration
-- kali-land - Modern Desktop Environment
-- This is the main entry point that requires all other modules

-- Force monitor resolution (backup method)
monitor = "Virtual-1,1920x1080@60,auto,1"

-- Core configuration modules
require("config")
require("environment")
require("monitors")
require("keybinds")
require("rules")
require("autostart")

-- VMware-specific configuration
require("vmware")

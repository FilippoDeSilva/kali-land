-- Main Hyprland Lua configuration
-- Kali Omarchy-Inspired Desktop
-- This is the main entry point that requires all other modules

-- Core configuration modules
require("config")
require("environment")
require("monitors")
require("keybinds")
require("rules")
require("autostart")

-- VMware-specific configuration
require("vmware")

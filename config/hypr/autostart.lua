-- Autostart configuration
-- Applications and services to start automatically

-- Start on Hyprland launch
hl.on("hyprland.start", function()
    -- Start notification daemon
    hl.exec_cmd("dunst")
    
    -- Start clipboard manager
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    
    -- Start network applet if available
    hl.exec_cmd("nm-applet")
    
    -- Start Desktop Shell if configured (e.g. QS_CONFIG="end4-pC")
    local qs_config = os.getenv("QS_CONFIG")
    if qs_config and qs_config ~= "" and qs_config ~= "none" then
        local shell_path = os.getenv("HOME") .. "/.config/quickshell/" .. qs_config
        hl.exec_cmd("sleep 2 && quickshell --path " .. shell_path)
    end
end)

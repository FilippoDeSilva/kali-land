-- Autostart configuration
-- Applications and services to start automatically

-- Start on Hyprland launch
hl.on("hyprland.start", function()
    -- Start terminal (critical for usability)
    hl.exec_cmd("kitty")
    
    -- Start notification daemon
    hl.exec_cmd("dunst")
    
    -- Start clipboard manager
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    
    -- Start network applet if available
    hl.exec_cmd("nm-applet")
    
    -- Start wallpaper manager (will be configured later)
    -- hl.exec_cmd("hyprpaper &")
    
    -- Start desktop components (Quickshell will be added later)
    -- hl.exec_cmd("quickshell &")
end)

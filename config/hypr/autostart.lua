-- Autostart configuration
-- Applications and services to start automatically

-- Start on Hyprland launch
hl.on("hyprland.start", function()
    -- Start terminal
    hl.exec("kitty")
    
    -- Start notification daemon
    hl.exec("dunst")
    
    -- Start clipboard manager
    hl.exec("wl-paste --type text --watch cliphist store")
    
    -- Start network applet if available
    hl.exec("nm-applet")
    
    -- Start wallpaper manager (will be configured later)
    -- hl.exec("hyprpaper &")
    
    -- Start desktop components (Quickshell will be added later)
    -- hl.exec("quickshell &")
end)

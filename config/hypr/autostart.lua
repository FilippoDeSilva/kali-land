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
    
    -- Start Quickshell desktop shell with proper config path
    hl.exec_cmd("quickshell --config ~/.config/quickshell")
    
    -- Set a simple background (we'll add proper wallpaper support later)
    -- For now, the dark background is fine
end)

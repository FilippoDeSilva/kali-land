-- Window rules configuration
-- Modular window rules using the latest Hyprland v0.56.2 syntax

-- Make floating windows float
hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "pavucontrol" },
    float = true
})
hl.window_rule({
    name = "float-nm-connection-editor",
    match = { class = "nm-connection-editor" },
    float = true
})
hl.window_rule({
    name = "float-blueman-manager",
    match = { class = "blueman-manager" },
    float = true
})
hl.window_rule({
    name = "float-gnome-calculator",
    match = { class = "org.gnome.Calculator" },
    float = true
})
hl.window_rule({
    name = "float-gnome-calendar",
    match = { class = "org.gnome.Calendar" },
    float = true
})
hl.window_rule({
    name = "float-gnome-settings",
    match = { class = "org.gnome.Settings" },
    float = true
})

-- Make dialog windows float
hl.window_rule({
    name = "float-dialog",
    match = { class = "dialog" },
    float = true
})
hl.window_rule({
    name = "float-file-progress",
    match = { class = "file_progress" },
    float = true
})
hl.window_rule({
    name = "float-notification",
    match = { class = "notification" },
    float = true
})
hl.window_rule({
    name = "float-splash",
    match = { class = "splash" },
    float = true
})
hl.window_rule({
    name = "float-confirm",
    match = { class = "confirm" },
    float = true
})

-- Center floating windows
hl.window_rule({
    name = "center-pavucontrol",
    match = { class = "pavucontrol" },
    center = true
})
hl.window_rule({
    name = "center-nm-connection-editor",
    match = { class = "nm-connection-editor" },
    center = true
})
hl.window_rule({
    name = "center-blueman-manager",
    match = { class = "blueman-manager" },
    center = true
})

-- Set window sizes for specific applications
-- Note: size syntax may vary by Hyprland version, using default for now
-- hl.window_rule({
--     name = "size-pavucontrol",
--     match = { class = "pavucontrol" },
--     size = { width = 800, height = 600 }
-- })
-- hl.window_rule({
--     name = "size-nm-connection-editor",
--     match = { class = "nm-connection-editor" },
--     size = { width = 600, height = 400 }
-- })

-- Make windows ignore workspace rules
hl.window_rule({
    name = "workspace-steam",
    match = { class = "steam" },
    workspace = "special"
})

-- Pin windows to all workspaces
hl.window_rule({
    name = "pin-discord",
    match = { class = "discord" },
    pin = true
})
hl.window_rule({
    name = "pin-spotify",
    match = { class = "Spotify" },
    pin = true
})

-- Prevent window tiling for specific applications
hl.window_rule({
    name = "float-pip",
    match = { title = "Picture-in-Picture" },
    float = true
})
hl.window_rule({
    name = "noborder-pip",
    match = { title = "Picture-in-Picture" },
    border_size = 0
})

-- Set opacity for inactive windows
hl.window_rule({
    name = "opacity-inactive",
    match = { class = ".*" },
    opacity = 0.8
})

-- Focus rules (commented out as focusonactivate is not available in v0.56.2)
-- hl.window_rule({
--     name = "focusonactivate-all",
--     match = { class = ".*" },
--     focusonactivate = true
-- })
-- stayfocused may not be available in v0.56.2
-- hl.window_rule({
--     name = "stayfocused-firefox",
--     match = { class = "firefox" },
--     stay_focused = true
-- })

-- Minimal Hyprland configuration
-- Fallback configuration if main configuration fails

-- Basic settings
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
    },
})

-- Basic keybindings
hl.bind("SUPER", "return", function() hl.exec("kitty") end)
hl.bind("SUPER", "q", function() hl.exec("killactive") end)
hl.bind("SUPER", "m", function() hl.exec("exit") end)

-- Keybindings configuration
-- Modular keybinding setup for keyboard-first workflow

-- Modifier variable
local mainMod = "SUPER"
-- Use the TERMINAL environment variable (set in environment.lua)
-- For VMs: foot (native Wayland), for bare metal: kitty/alacritty (GPU accelerated)
local terminal = os.getenv("TERMINAL") or "kitty"
local fileManager = "thunar"

-- Window management
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + q", hl.dsp.window.close())
hl.bind(mainMod .. " + e", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + f", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + d", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + d", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + p", hl.dsp.window.pseudo())

-- Focus windows
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Resize windows
hl.bind(mainMod .. " + CTRL + left", hl.dsp.exec_cmd("resizeactive -20 0"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("resizeactive 20 0"))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.exec_cmd("resizeactive 0 -20"))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.exec_cmd("resizeactive 0 20"))

-- Workspace management
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move windows to workspaces
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + s", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + s", hl.dsp.window.move({ workspace = "special:magic" }))

-- Media and volume controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Brightness controls
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Screenshot
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("grimblast copy area"))
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("grimblast copy screen"))
hl.bind(mainMod .. " + CTRL + PRINT", hl.dsp.exec_cmd("grimblast copy window"))

-- Launcher (will be Quickshell)
hl.bind(mainMod .. " + r", hl.dsp.exec_cmd("quickshell"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("quickshell"))

-- Application launcher shortcuts
hl.bind(mainMod .. " + b", hl.dsp.exec_cmd("firefox-esr"))
hl.bind(mainMod .. " + g", hl.dsp.exec_cmd("geany"))

-- Configuration management
hl.bind(mainMod .. " + SHIFT + r", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + q", hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- System controls
hl.bind(mainMod .. " + SHIFT + e", hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. " + l", hl.dsp.exec_cmd("swaylock"))

-- Resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

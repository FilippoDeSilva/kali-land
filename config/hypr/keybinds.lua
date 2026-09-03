-- Keybindings configuration
-- Modular keybinding setup for keyboard-first workflow

-- Modifier variable
local mainMod = "SUPER"

-- Window management
hl.bind(mainMod, "return", function() hl.exec("kitty") end)
hl.bind(mainMod, "q", function() hl.exec("killactive") end)
hl.bind(mainMod, "m", function() hl.exec("exit") end)
hl.bind(mainMod, "e", function() hl.exec("thunar") end)
hl.bind(mainMod, "f", function() hl.exec("togglefloating") end)
hl.bind(mainMod, "space", function() hl.exec("togglefloating") end)
hl.bind(mainMod, "d", function() hl.exec("fullscreen") end)
hl.bind(mainMod, "SHIFT", "d", function() hl.exec("fullscreen 1") end)
hl.bind(mainMod, "p", function() hl.exec("pseudo") end)

-- Focus windows
hl.bind(mainMod, "left", function() hl.exec("movefocus l") end)
hl.bind(mainMod, "right", function() hl.exec("movefocus r") end)
hl.bind(mainMod, "up", function() hl.exec("movefocus u") end)
hl.bind(mainMod, "down", function() hl.exec("movefocus d") end)

-- Move windows
hl.bind(mainMod, "SHIFT", "left", function() hl.exec("movewindow l") end)
hl.bind(mainMod, "SHIFT", "right", function() hl.exec("movewindow r") end)
hl.bind(mainMod, "SHIFT", "up", function() hl.exec("movewindow u") end)
hl.bind(mainMod, "SHIFT", "down", function() hl.exec("movewindow d") end)

-- Resize windows
hl.bind(mainMod, "CTRL", "left", function() hl.exec("resizeactive -20 0") end)
hl.bind(mainMod, "CTRL", "right", function() hl.exec("resizeactive 20 0") end)
hl.bind(mainMod, "CTRL", "up", function() hl.exec("resizeactive 0 -20") end)
hl.bind(mainMod, "CTRL", "down", function() hl.exec("resizeactive 0 20") end)

-- Workspace management
hl.bind(mainMod, "1", function() hl.exec("workspace 1") end)
hl.bind(mainMod, "2", function() hl.exec("workspace 2") end)
hl.bind(mainMod, "3", function() hl.exec("workspace 3") end)
hl.bind(mainMod, "4", function() hl.exec("workspace 4") end)
hl.bind(mainMod, "5", function() hl.exec("workspace 5") end)
hl.bind(mainMod, "6", function() hl.exec("workspace 6") end)
hl.bind(mainMod, "7", function() hl.exec("workspace 7") end)
hl.bind(mainMod, "8", function() hl.exec("workspace 8") end)
hl.bind(mainMod, "9", function() hl.exec("workspace 9") end)
hl.bind(mainMod, "0", function() hl.exec("workspace 10") end)

-- Move windows to workspaces
hl.bind(mainMod, "SHIFT", "1", function() hl.exec("movetoworkspace 1") end)
hl.bind(mainMod, "SHIFT", "2", function() hl.exec("movetoworkspace 2") end)
hl.bind(mainMod, "SHIFT", "3", function() hl.exec("movetoworkspace 3") end)
hl.bind(mainMod, "SHIFT", "4", function() hl.exec("movetoworkspace 4") end)
hl.bind(mainMod, "SHIFT", "5", function() hl.exec("movetoworkspace 5") end)
hl.bind(mainMod, "SHIFT", "6", function() hl.exec("movetoworkspace 6") end)
hl.bind(mainMod, "SHIFT", "7", function() hl.exec("movetoworkspace 7") end)
hl.bind(mainMod, "SHIFT", "8", function() hl.exec("movetoworkspace 8") end)
hl.bind(mainMod, "SHIFT", "9", function() hl.exec("movetoworkspace 9") end)
hl.bind(mainMod, "SHIFT", "0", function() hl.exec("movetoworkspace 10") end)

-- Scroll through workspaces
hl.bind(mainMod, "mouse_down", function() hl.exec("workspace e+1") end)
hl.bind(mainMod, "mouse_up", function() hl.exec("workspace e-1") end)

-- Special workspace (scratchpad)
hl.bind(mainMod, "s", function() hl.exec("togglespecialworkspace magic") end)
hl.bind(mainMod, "SHIFT", "s", function() hl.exec("movetoworkspacesilent special:magic") end)

-- Media and volume controls
hl.bind({}, "XF86AudioRaiseVolume", function() hl.exec("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+") end)
hl.bind({}, "XF86AudioLowerVolume", function() hl.exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") end)
hl.bind({}, "XF86AudioMute", function() hl.exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") end)
hl.bind({}, "XF86AudioPlay", function() hl.exec("playerctl play-pause") end)
hl.bind({}, "XF86AudioNext", function() hl.exec("playerctl next") end)
hl.bind({}, "XF86AudioPrev", function() hl.exec("playerctl previous") end)

-- Brightness controls
hl.bind({}, "XF86MonBrightnessUp", function() hl.exec("brightnessctl set +5%") end)
hl.bind({}, "XF86MonBrightnessDown", function() hl.exec("brightnessctl set 5%-") end)

-- Screenshot
hl.bind(mainMod, "PRINT", function() hl.exec("grimblast copy area") end)
hl.bind(mainMod, "SHIFT", "PRINT", function() hl.exec("grimblast copy screen") end)
hl.bind(mainMod, "CTRL", "PRINT", function() hl.exec("grimblast copy window") end)

-- Launcher (will be Quickshell)
hl.bind(mainMod, "r", function() hl.exec("quickshell") end)
hl.bind(mainMod, "period", function() hl.exec("quickshell") end)

-- Application launcher shortcuts
hl.bind(mainMod, "b", function() hl.exec("firefox-esr") end)
hl.bind(mainMod, "g", function() hl.exec("geany") end)
hl.bind(mainMod, "t", function() hl.exec("kitty") end)

-- System controls
hl.bind(mainMod, "SHIFT", "e", function() hl.exec("wlogout") end)
hl.bind(mainMod, "l", function() hl.exec("swaylock") end)

-- Resize with mouse
hl.bindm(mainMod, "mouse:272", function() hl.exec("movewindow") end)
hl.bindm(mainMod, "mouse:273", function() hl.exec("resizewindow") end)

-- Keybindings configuration for Kali-Land
-- Decoupled BYOS Architecture: All default keybindings are mapped
-- directly to end4-pC Quickshell IPC features out-of-the-box.
-- Theming is handled 100% by end4-pC (no hardcoded themes).

local mainMod = "SUPER"
local terminal = os.getenv("TERMINAL") or "foot"
local fileManager = "thunar"

-- Helper function to wrap commands safely in bash -c
local function exec_ipc(cmd)
    return hl.dsp.exec_cmd("bash -c '" .. cmd .. "'")
end

-- ===================================================================
-- 1. Window & Application Management
-- ===================================================================
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + q", hl.dsp.window.close())
hl.bind(mainMod .. " + e", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + f", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + d", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + d", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + p", hl.dsp.window.pseudo())

-- Dedicated Application Shortcuts (No collision with SUPER+B bar toggle)
hl.bind(mainMod .. " + SHIFT + b", hl.dsp.exec_cmd("firefox-esr"))
hl.bind(mainMod .. " + SHIFT + g", hl.dsp.exec_cmd("geany"))

-- ===================================================================
-- 2. end4-pC Search & Application Launcher
-- ===================================================================
hl.bind(mainMod .. " + space", exec_ipc("quickshell ipc call search toggle"))
hl.bind("ALT + space", exec_ipc("quickshell ipc call search toggle"))
hl.bind(mainMod .. " + r", exec_ipc("quickshell ipc call search toggle"))

-- Clipboard Search & Manager (Native end4-pC Clipboard)
hl.bind(mainMod .. " + v", exec_ipc("quickshell ipc call search clipboardToggle"))
hl.bind(mainMod .. " + SHIFT + v", exec_ipc("quickshell ipc call search clipboardToggle"))

-- ===================================================================
-- 3. end4-pC Workspace Overview & Workspaces Switcher
-- ===================================================================
hl.bind(mainMod .. " + tab", exec_ipc("quickshell ipc call search workspacesToggle"))
hl.bind("ALT + tab", exec_ipc("quickshell ipc call search workspacesToggle"))

-- ===================================================================
-- 4. end4-pC Lock Screen & Session / Power Menu
-- ===================================================================
hl.bind(mainMod .. " + SHIFT + e", exec_ipc("quickshell ipc call lock activate"))
hl.bind(mainMod .. " + l", exec_ipc("quickshell ipc call lock activate"))
hl.bind(mainMod .. " + SHIFT + l", exec_ipc("quickshell ipc call lock activate"))
hl.bind(mainMod .. " + Escape", exec_ipc("quickshell ipc call session toggle"))
hl.bind(mainMod .. " + SHIFT + Escape", exec_ipc("quickshell ipc call session toggle"))

-- ===================================================================
-- 5. end4-pC Wallpapers, Themes & Customization Settings
-- ===================================================================
hl.bind(mainMod .. " + w", exec_ipc("quickshell ipc call wallpaperSelector toggle"))
hl.bind(mainMod .. " + SHIFT + w", exec_ipc("quickshell ipc call wallpaperSelector random"))
hl.bind(mainMod .. " + ALT + w", exec_ipc("quickshell ipc call background toggleCenteredWallpaper"))
hl.bind(mainMod .. " + comma", exec_ipc("quickshell ipc call settings toggle"))
hl.bind(mainMod .. " + i", exec_ipc("quickshell ipc call settings toggle"))
hl.bind(mainMod .. " + SHIFT + t", exec_ipc("~/.config/quickshell/scripts/colors/switchwall.sh --noswitch"))
hl.bind(mainMod .. " + slash", exec_ipc("quickshell ipc call search toggle"))


-- ===================================================================
-- 6. end4-pC Sidebars & Status Bar
-- ===================================================================
hl.bind(mainMod .. " + a", exec_ipc("quickshell ipc call sidebarLeft toggle"))
hl.bind(mainMod .. " + n", exec_ipc("quickshell ipc call sidebarRight toggle"))
hl.bind(mainMod .. " + period", exec_ipc("quickshell ipc call sidebarRight toggle"))
hl.bind(mainMod .. " + b", exec_ipc("quickshell ipc call bar toggle"))
hl.bind(mainMod .. " + o", exec_ipc("quickshell ipc call overlay toggle"))

-- ===================================================================
-- 7. end4-pC Tools & Screen Capture
-- ===================================================================
hl.bind(mainMod .. " + t", exec_ipc("quickshell ipc call screenTranslator translate"))
hl.bind(mainMod .. " + k", exec_ipc("quickshell ipc call osk toggle"))
hl.bind("Print", exec_ipc("quickshell ipc call region screenshot"))
hl.bind(mainMod .. " + Print", exec_ipc("quickshell ipc call region screenshot"))
hl.bind(mainMod .. " + SHIFT + Print", exec_ipc("quickshell ipc call region record"))
hl.bind(mainMod .. " + ALT + Print", exec_ipc("quickshell ipc call region ocr"))

-- ===================================================================
-- 8. Media & Volume Controls (Hardware Keys + Standard Key Combinations)
-- ===================================================================
hl.bind(mainMod .. " + m", exec_ipc("quickshell ipc call mediaControls toggle"))
hl.bind(mainMod .. " + SHIFT + space", exec_ipc("quickshell ipc call mpris playPause || playerctl play-pause"))
hl.bind(mainMod .. " + bracketright", exec_ipc("quickshell ipc call mpris next || playerctl next"))
hl.bind(mainMod .. " + bracketleft", exec_ipc("quickshell ipc call mpris previous || playerctl previous"))

hl.bind("XF86AudioPlay", exec_ipc("quickshell ipc call mpris playPause || playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", exec_ipc("quickshell ipc call mpris next || playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", exec_ipc("quickshell ipc call mpris previous || playerctl previous"), { locked = true })

hl.bind(mainMod .. " + equal", exec_ipc("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind(mainMod .. " + minus", exec_ipc("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioRaiseVolume", exec_ipc("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", exec_ipc("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", exec_ipc("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessUp", exec_ipc("quickshell ipc call brightness increment || brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", exec_ipc("quickshell ipc call brightness decrement || brightnessctl set 5%-"), { locked = true, repeating = true })

-- ===================================================================
-- 9. Window Focus & Movement
-- ===================================================================
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + CTRL + left", hl.dsp.exec_cmd("resizeactive -20 0"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("resizeactive 20 0"))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.exec_cmd("resizeactive 0 -20"))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.exec_cmd("resizeactive 0 20"))

-- ===================================================================
-- 10. Workspace Management
-- ===================================================================
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

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + s", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + s", hl.dsp.window.move({ workspace = "special:magic" }))

-- Configuration management
hl.bind(mainMod .. " + SHIFT + r", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + q", hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Mouse actions
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

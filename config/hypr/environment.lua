-- Environment variables configuration
-- Set up environment variables for Hyprland

-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt & Wayland environment
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_ACCESSIBILITY", "1")

-- Default applications
hl.env("TERMINAL", "kitty")
hl.env("BROWSER", "firefox-esr")
hl.env("EDITOR", "geany")

-- Desktop Shell Integration (managed by kali-land CLI)
-- Set to the shell namespace name, e.g. "end4-pC", "custom-caelestia-dots-shell"
hl.env("QS_CONFIG", "none")

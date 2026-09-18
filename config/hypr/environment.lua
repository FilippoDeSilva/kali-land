-- Environment variables configuration
-- Set up environment variables for Hyprland

-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- VMware / Software rendering compatibility (Mesa LLVMpipe GLSL OpenGL)
hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")

-- Qt & Wayland environment for Quickshell
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_ACCESSIBILITY", "1")

-- Default applications
-- Foot terminal with Herdr terminal multiplexer support
hl.env("TERMINAL", "foot -e herdr")
hl.env("BROWSER", "firefox-esr")
hl.env("EDITOR", "geany")

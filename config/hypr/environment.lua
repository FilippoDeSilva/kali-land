-- Environment variables configuration
-- Set up environment variables for Hyprland

-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- VMware / Software rendering compatibility
hl.env("QT_QUICK_BACKEND", "software")
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
-- Use foot for VMs (native Wayland), kitty for bare metal (GPU accelerated)
-- The install script will auto-detect VM vs bare metal and set the appropriate terminal
-- Default to kitty (GPU accelerated), installer will change to foot for VMs
hl.env("TERMINAL", "kitty")
hl.env("BROWSER", "firefox-esr")
hl.env("EDITOR", "geany")

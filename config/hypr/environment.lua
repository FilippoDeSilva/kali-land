-- Environment variables configuration
-- Set up environment variables for Hyprland

-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Enable hardware cursors for better performance in VMware
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- Video acceleration for VMware
hl.env("VDPAU_DRIVER", "va_gl")

-- Default applications
-- Use foot for VMs (native Wayland), kitty for bare metal (GPU accelerated)
-- The install script will auto-detect VM vs bare metal and set the appropriate terminal
-- Default to kitty (GPU accelerated), installer will change to foot for VMs
hl.env("TERMINAL", "kitty")
hl.env("BROWSER", "firefox-esr")
hl.env("EDITOR", "geany")

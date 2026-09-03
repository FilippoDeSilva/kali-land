-- VMware-specific configuration
-- Optimizations for running Hyprland in VMware

-- VMware-specific optimizations
hl.config({
    general = {
        -- Direct scanout can be better for VMs
        direct_scanout = false,
        
        -- Performance optimizations for VMs
        allow_tearing = false,
    },
    
    decoration = {
        -- Reduce blur for better VM performance
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
    
    -- Disable some expensive features for VM performance
    animations = {
        enabled = true,
    },
})

-- Disable hardware cursors in VMware (better compatibility)
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

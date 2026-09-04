-- Monitor configuration
-- Configure display settings for monitors

-- Auto-detect and configure all monitors with optimal settings
-- This will work for VMs, laptops, and external monitors
hl.monitor({
    output = "auto",
    mode = "preferred",  -- Use monitor's preferred resolution
    position = "auto",
    scale = 1,  -- Use integer scaling by default
    -- Monitor-specific scaling for high-DPI displays
    -- Uncomment and adjust if you have high-DPI monitors:
    -- transform = 0,  -- 0 = normal, 1 = 90°, 2 = 180°, 3 = 270°
    -- vrr = 0,  -- Variable refresh rate (0 = disabled, 1 = enabled)
})

-- Secondary monitor support (uncomment if you have multiple monitors)
-- hl.monitor({
--     output = "DP-1",  -- Change to your secondary monitor's output name
--     mode = "preferred",
--     position = "auto",  -- Will auto-position relative to primary
--     scale = 1,
-- })

-- Manual monitor configuration (if auto-detection fails)
-- Uncomment and adjust to your specific monitor setup:
-- hl.monitor({
--     output = "HDMI-A-1",
--     mode = "preferred",
--     position = "0x0",
--     scale = 1,
-- })
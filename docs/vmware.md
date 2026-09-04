# VMware-Specific Configuration

This document covers VMware-specific optimizations and considerations for the kali-land Desktop.

## Purpose

VMware is used during development. The desktop environment is designed to work on bare metal hardware as well. VMware-specific optimizations are only applied when running in a VMware virtual machine.

**Important**: This project is in active development. While designed for VMware during development, it can be used on bare metal. Use on daily drivers at your own risk until stable release.

## VMware Detection

The system automatically detects VMware using:
```bash
systemd-detect-virt
```

Expected output: `vmware`

VMware-specific configurations are only applied when VMware is detected. On bare metal, these optimizations are skipped.

## VMware Tools

Ensure VMware Tools is installed and running:

```bash
# Check if installed
dpkg -l | grep open-vm-tools

# Check if running
systemctl status open-vm-tools
```

If not installed:
```bash
sudo apt install open-vm-tools-desktop
sudo systemctl start open-vm-tools
sudo systemctl enable open-vm-tools
```

## Display Configuration

### 3D Acceleration

Enable 3D acceleration in VMware settings:

1. Right-click VM → Settings
2. Display → Accelerate 3D graphics
3. Set adequate graphics memory (512MB+)

### Dynamic Resolution

Enable dynamic resolution for automatic resizing:

1. VM Settings → Display
2. Enable "Use host setting for monitors"
3. Install VMware Tools for auto-resize support

### Monitor Configuration

For Hyprland monitor configuration in VMware:

```conf
# config/hypr/monitors.conf
monitor=eDP-1,1920x1080@60,0x0,1
```

The system will auto-detect VMware virtual monitors.

## Performance Optimization

### CPU Allocation

- **Minimum**: 2 vCPUs
- **Recommended**: 4+ vCPUs for smooth performance

### Memory Allocation

- **Minimum**: 4GB RAM
- **Recommended**: 8GB+ RAM for comfortable usage

### Disk I/O

- Use SSD storage if available
- Enable paravirtual SCSI controller for better performance
- Allocate adequate disk space (20GB+)

## VMware-Specific Scripts

VMware-specific scripts are located in `scripts/vmware/`:

### Optimization Script

Run the VMware optimization script:
```bash
./scripts/vmware/optimize.sh
```

This script:
- Configures display settings
- Optimizes input handling
- Tweaks performance settings
- Enables VMware-specific features

## Clipboard Integration

### Host-VM Clipboard

Enable clipboard sharing:

1. VM Settings → Options → Shared Clipboard
2. Set to "Bidirectional"
3. Restart VM

### Clipboard Manager

For clipboard history within the VM:
- `cliphist` is installed by default
- Works with Wayland clipboard protocols

## Drag and Drop

Enable drag and drop:

1. VM Settings → Options → Drag and Drop
2. Set to "Bidirectional"
3. Restart VM

## Shared Folders

If using shared folders:

1. VM Settings → Options → Shared Folders
2. Add folders you want to share
3. Mount points appear in `/mnt/hgfs/`

## Network Configuration

### Network Adapter

Recommended network adapter types:
- **NAT**: For internet access (default)
- **Bridged**: For network visibility
- **Host-only**: For isolated development

### Network Issues

If network doesn't work:

1. Check network adapter type in VMware settings
2. Restart NetworkManager: `sudo systemctl restart NetworkManager`
3. Check interface: `nmcli device`
4. Try different adapter type

## Audio Configuration

### Audio Device

VMware audio device should be auto-detected by PipeWire.

### Audio Issues

If audio doesn't work:

1. Check VMware audio settings
2. Restart audio services:
   ```bash
   systemctl --user restart pipewire wireplumber
   ```
3. Check audio devices: `pactl list sinks`

## Input Configuration

### Mouse Integration

VMware mouse integration should work automatically with Wayland.

### Keyboard Issues

If keyboard has issues:

1. Disable VM keyboard shortcuts when conflicting
2. Check keybinding conflicts in Hyprland config
3. Try different keyboard type in VMware settings

## Snapshot Strategy

### Recommended Snapshots

Create VMware snapshots at these points:

1. **Pre-installation**: Clean Kali installation
2. **Post-Wayland**: After Wayland foundation
3. **Post-Hyprland**: After Hyprland working
4. **Post-Quickshell**: After Quickshell working
5. **Complete**: After full installation

### Snapshot Management

- Keep snapshots for rollback capability
- Name snapshots descriptively
- Clean up old snapshots periodically
- Document what each snapshot contains

## Troubleshooting

### Poor Performance

**Symptoms**: Laggy desktop, slow animations

**Solutions**:
1. Enable 3D acceleration
2. Increase RAM/CPU allocation
3. Reduce animations in Hyprland
4. Check CPU usage: `htop`
5. Run VMware optimization script

### Resolution Issues

**Symptoms**: Wrong resolution, can't change resolution

**Solutions**:
1. Enable VMware Tools
2. Check display settings in VMware
3. Configure monitor in Hyprland
4. Try different resolution in VMware settings

### Clipboard Not Working

**Symptoms**: Can't copy/paste between host and VM

**Solutions**:
1. Enable clipboard sharing in VMware settings
2. Restart VMware Tools service
3. Check if clipboard manager is running
4. Restart the VM

### Network Not Working

**Symptoms**: No internet connectivity

**Solutions**:
1. Check network adapter type in VMware
2. Restart NetworkManager
3. Try different network adapter type
4. Check host network connectivity

## VMware-Specific Hyprland Configuration

Add to `config/hypr/hyprland.conf`:

```conf
# VMware-specific optimizations
env = WLR_NO_HARDWARE_CURSORS,1         # Software cursors if needed
env = VDPAU_DRIVER,va_gl                # Video acceleration

# Performance tweaks
render:direct_scanout = false          # Better for VM
no_direct_scanout = true
```

## Migration to Bare Metal

When migrating to bare metal:

1. **Remove VMware-specific configs**:
   - Remove VMware tools
   - Disable VMware-specific optimizations
   - Revert to generic display configuration

2. **Install hardware-specific drivers**:
   - GPU drivers (NVIDIA/AMD/Intel)
   - Audio drivers
   - Network drivers

3. **Update monitor configuration**:
   - Detect physical monitors
   - Update monitor config
   - Configure multi-monitor if needed

4. **Test thoroughly**:
   - Run doctor script
   - Test all components
   - Verify performance

## VMware Workstation vs VMware Player

### VMware Workstation

- More configuration options
- Snapshot management
- Better for development
- Commercial license

### VMware Player

- Free for personal use
- Limited configuration
- Basic snapshot support
- Good for testing

Both work with this desktop environment, but Workstation provides more control for development.

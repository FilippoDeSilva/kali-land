# Troubleshooting Guide

This guide helps diagnose and fix common issues with the kali-land Desktop.

## Diagnostic Tools

### Run the Doctor

Always start with the diagnostic tool:
```bash
./bootstrap/doctor.sh
```

This will show:
- Platform compatibility
- Installed components
- Missing components
- Configuration status

### Check Logs

Installation logs:
```bash
~/.local/state/kali-land/logs/
```

Service logs:
```bash
journalctl --user -u hyprland
journalctl --user -u quickshell
journalctl --user -u pipewire
journalctl --user -u wireplumber
```

## Common Issues

### Installation Issues

#### Permission Denied

**Problem**: `apt update` fails with permission errors

**Solution**: Run with sudo:
```bash
sudo ./bootstrap/install.sh
```

#### Package Not Found

**Problem**: `apt-cache policy <package>` returns nothing

**Solution**: 
1. Update package cache: `sudo apt update`
2. Check Kali repositories: `cat /etc/apt/sources.list.d/kali.sources`
3. Package may not be available in Kali - see installation guide for alternatives

### Wayland Issues

#### Wayland Session Not Available

**Problem**: Can't select Wayland session in display manager

**Solution**:
1. Verify Wayland is installed:
   ```bash
   dpkg -l | grep wayland
   ```

2. Check session files:
   ```bash
   ls /usr/share/xsessions/
   ls /usr/share/wayland-sessions/
   ```

3. Ensure GPU drivers support Wayland

#### XWayland Not Working

**Problem**: X11 applications don't work in Wayland session

**Solution**:
1. Verify XWayland is installed:
   ```bash
   command -v Xwayland
   ```

2. Check Hyprland config for XWayland settings

### Hyprland Issues

#### Hyprland Won't Start with Lua Configuration

**Problem**: Hyprland fails to start after deploying Lua configuration

**Solution**:
1. Check the Hyprland log:
   ```bash
   cat ~/.local/share/hyprland/hyprland.log
   ```

2. Validate the Lua configuration structure:
   ```bash
   bash scripts/validate-lua-config.sh
   ```

3. Check for syntax errors:
   - Ensure all `.lua` files are syntactically correct
   - Verify all `require()` statements match actual module files
   - Check that API calls match the installed Hyprland version

4. Test with minimal configuration:
   ```bash
   cp ~/.config/hypr/minimal.lua ~/.config/hypr/hyprland.lua
   # Try starting Hyprland with minimal config
   ```

5. Restore from backup:
   ```bash
   # Find your backup directory
   ls ~/.local/state/kali-land/backups/
   # Restore the previous configuration
   cp -r ~/.local/state/kali-land/backups/<timestamp>/hypr ~/.config/hypr
   ```

#### Mixed .conf and .lua Files

**Problem**: You have both `.conf` and `.lua` files in `~/.config/hypr/`

**Solution**:
- Hyprland 0.56.2+ prefers `.lua` configuration
- Remove old `.conf` files to avoid conflicts:
  ```bash
  rm ~/.config/hypr/*.conf
  ```

#### Module Not Found Errors

**Problem**: You see errors like "module not found"

**Solution**:
1. Check that the module file exists:
   ```bash
   ls ~/.config/hypr/
   ```

2. Verify the `require()` statement in `hyprland.lua` matches the filename:
   ```bash
   grep require ~/.config/hypr/hyprland.lua
   ```

3. Ensure the module is in the correct directory (`~/.config/hypr/`)

#### Hyprland Won't Start (General)

**Problem**: Hyprland crashes or won't start

**Solution**:
1. Check Hyprland log:
   ```bash
   cat ~/.local/share/hyprland/hyprland.log
   ```

2. Verify dependencies:
   ```bash
   ldd $(which Hyprland)
   ```

3. Test with minimal config:
   ```bash
   cp ~/.config/hypr/minimal.lua ~/.config/hypr/hyprland.lua
   Hyprland
   ```

#### Keybindings Not Working

**Problem**: Keybindings don't respond

**Solution**:
1. Check keybinding syntax in config
2. Verify no conflicts with other applications
3. Check for syntax errors in keybinds.conf

#### Monitor Configuration Wrong

**Problem**: Wrong resolution or monitor arrangement

**Solution**:
1. Check monitors.conf
2. Use `hyprctl monitors` to see detected monitors
3. Adjust monitor configuration in config

### Quickshell Issues

#### Quickshell Won't Start

**Problem**: Quickshell doesn't appear

**Solution**:
1. Check if Quickshell is running:
   ```bash
   ps aux | grep quickshell
   ```

2. Check logs:
   ```bash
   journalctl --user -u quickshell
   ```

3. Verify Qt6 dependencies:
   ```bash
   dpkg -l | grep qt6
   ```

#### Shell Components Not Visible

**Problem**: Bar, launcher, or other components don't show

**Solution**:
1. Check shell.qml for errors
2. Verify component paths are correct
3. Check Quickshell logs for QML errors

#### System Data Not Updating

**Problem**: Clock, network, or other system indicators don't update

**Solution**:
1. Check if services are running
2. Verify service connections in QML
3. Check for errors in service files

### Desktop Services Issues

#### Audio Not Working

**Problem**: No sound output

**Solution**:
1. Check PipeWire status:
   ```bash
   systemctl --user status pipewire
   systemctl --user status wireplumber
   ```

2. Check audio devices:
   ```bash
   pactl list sinks
   ```

3. Restart audio services:
   ```bash
   systemctl --user restart pipewire wireplumber
   ```

#### Network Not Working

**Problem**: No network connectivity

**Solution**:
1. Check NetworkManager status:
   ```bash
   systemctl status NetworkManager
   ```

2. Check network devices:
   ```bash
   nmcli device
   ```

3. Restart NetworkManager:
   ```bash
   sudo systemctl restart NetworkManager
   ```

#### Notifications Not Appearing

**Problem**: No notification popups

**Solution**:
1. Check dunst status:
   ```bash
   systemctl --user status dunst
   ```

2. Test notification:
   ```bash
   notify-send "Test" "This is a test notification"
   ```

3. Check dunst config:
   ```bash
   cat ~/.config/dunst/dunstrc
   ```

#### Clipboard Not Working

**Problem**: Clipboard history not available

**Solution**:
1. Check if cliphist is installed:
   ```bash
   command -v cliphist
   ```

2. Test clipboard:
   ```bash
   echo "test" | wl-copy
   wl-paste
   ```

### VMware-Specific Issues

#### Poor Performance

**Problem**: Desktop feels slow or laggy

**Solution**:
1. Enable 3D acceleration in VMware settings
2. Increase allocated RAM
3. Check CPU usage: `htop`
4. Run VMware optimization script

#### Resolution Issues

**Problem**: Wrong resolution or can't change resolution

**Solution**:
1. Enable VMware tools: `sudo systemctl start open-vm-tools`
2. Check display settings in VMware
3. Configure monitor resolution in Hyprland

#### Clipboard Integration Not Working

**Problem**: Can't copy/paste between host and VM

**Solution**:
1. Ensure VMware tools is installed and running
2. Enable clipboard sharing in VMware settings
3. Restart VMware tools service

## Getting Help

If you can't resolve your issue:

1. Run the doctor and save the output
2. Collect relevant logs
3. Check the documentation
4. Search for similar issues in the project repository
5. Open an issue with detailed information:

   - Platform information (from doctor)
   - What you were trying to do
   - What happened instead
   - Relevant log files
   - Steps to reproduce

## Recovery

### Restore from Backup

If something breaks and you need to restore:

1. List available backups:
   ```bash
   ./bootstrap/uninstall.sh --help
   # or manually check
   ls ~/.local/state/kali-land/backups/
   ```

2. Restore specific config:
   ```bash
   # Manually restore from backup
   cp -r ~/.local/state/kali-land/backups/<timestamp>/hypr ~/.config/hypr
   ```

### Complete Uninstall

If you need to completely remove the desktop:

```bash
./bootstrap/uninstall.sh --remove-configs --remove-packages --remove-backups
```

This will:
- Remove all configurations
- Remove installed packages
- Remove backups
- Restore your original desktop environment

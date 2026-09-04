# Repository Structure

This document describes the current repository structure and explains the purpose of each directory and file.

## Root Directory

```
kali-land/
├── AGENT.md                    # Agent instructions and architecture rules
├── README.md                   # Project overview and quick start
├── LICENSE                     # License information
├── .gitignore                  # Git ignore patterns
├── QUICKSTART.md               # Quick start guide
├── .env.example                # Environment variables example
├── .github/                    # GitHub Actions CI/CD workflows
│   └── workflows/
│       ├── build-quickshell.yml  # Quickshell build workflow
│       └── installer.yml         # Installer package workflow
├── end4-pC/                    # Cloned end4-pC Quickshell configuration
├── packages/                   # Package manifests
├── scripts/                    # Utility scripts
├── system/                     # System-level configurations
├── tests/                      # Test files
├── themes/                     # Theme configurations
└── docs/                       # Documentation
```

## Bootstrap System

```
bootstrap/
├── install.sh                  # Main installation script
├── uninstall.sh                # Uninstallation script
├── doctor.sh                   # Diagnostic and validation script
└── lib/
    ├── logging.sh              # Logging utilities
    ├── platform.sh             # Platform detection
    ├── packages.sh             # Package management
    ├── filesystem.sh           # Filesystem operations
    └── prompts.sh              # User prompts
```

**Purpose:** Provides automated installation, uninstallation, and diagnostic capabilities. The library files contain reusable functions for the main scripts. The installer now supports pre-built Quickshell from GitHub releases with fallback to source building.

## Package Manifests

```
packages/
├── base.txt                    # Base system packages
├── wayland.txt                 # Wayland foundation packages
├── hyprland.txt                # Hyprland compositor packages
├── quickshell.txt              # Quickshell dependencies
├── desktop-services.txt        # Desktop services (audio, network, etc.)
├── applications.txt            # Desktop applications
└── optional.txt                # Optional packages
```

**Purpose:** Package lists organized by concern. Each file contains a list of packages to install for a specific phase or component.

## Configuration

```
config/
├── hypr/                       # Hyprland compositor configuration
│   ├── hyprland.lua            # Main entry point (imports other modules)
│   ├── config.lua              # General settings and environment
│   ├── environment.lua         # Environment variables
│   ├── monitors.lua            # Monitor configuration
│   ├── keybinds.lua            # Keyboard shortcuts
│   ├── rules.lua               # Window rules
│   ├── autostart.lua            # Startup applications
│   └── vmware.lua              # VMware-specific configuration (only loaded in VM)
│
├── foot/                       # Foot terminal configuration
├── gtk/                        # GTK theme configuration
├── hypridle/                   # Hypridle (idle management) configuration
├── hyprlock/                   # Hyprlock (screen lock) configuration
├── kitty/                      # Kitty terminal configuration
├── mako/                       # Mako notification daemon configuration
└── wlogout/                    # Wlogout (logout menu) configuration
```

**Purpose:** Source of truth for all user configuration. The installation system copies these files to `~/.config/` during installation.

**Note**: Quickshell configuration is provided by end4-pC in the `end4-pC/` directory, not in `config/quickshell/`.

### Hyprland Configuration Structure

Hyprland uses a modular Lua configuration format:

- **hyprland.lua**: Main entry point that imports all other modules
- **config.lua**: General settings (animations, decorations, layout, etc.)
- **environment.lua**: Environment variables for Wayland applications
- **monitors.lua**: Monitor configuration and outputs
- **keybinds.lua**: Keyboard shortcuts and key bindings
- **rules.lua**: Window rules and behavior
- **autostart.lua**: Applications to start on Hyprland launch
- **vmware.lua**: VMware-specific optimizations
- **minimal.lua**: Minimal configuration for testing

### Quickshell Configuration Structure

kali-land uses the end4-pC Quickshell configuration for a professional Material 3 design:

- **end4-pC/**: Cloned end4-pC Quickshell configuration
  - **shell.qml**: Main entry point for end4-pC
  - **modules/**: Various UI modules (bar, launcher, etc.)
  - **services/**: Backend services (network, audio, etc.)
  - **panelFamilies/**: Different panel configurations
  - **defaults/**: Default configurations and presets
  - **assets/**: Icons, fonts, images

The installation script clones end4-pC to `~/.config/quickshell/` and sets up the necessary environment variables. The basic `config/quickshell/` directory serves as a backup/alternative configuration.

For detailed Quickshell architecture, see [Quickshell Architecture](quickshell-architecture.md).

## Scripts

```
scripts/
├── audio/                      # Audio control scripts
├── deploy-config.sh            # Deploy configuration files
├── launch/                     # Application launch scripts
├── launcher.sh                 # Application launcher
├── network/                    # Network control scripts
├── power-menu.sh              # Power menu script
├── screenshot/                 # Screenshot scripts
├── system/                     # System control scripts
├── test-hyprland.sh            # Test Hyprland configuration
├── validate-lua-config.sh     # Validate Hyprland Lua configuration
├── vmware/                     # VMware-specific scripts
└── wallpaper/                  # Wallpaper management scripts
```

**Purpose:** Utility scripts for various desktop functions including audio control, application launching, system management, and configuration validation.

## Documentation

```
docs/
├── architecture.md             # System architecture overview
├── ci-cd.md                    # CI/CD setup and workflow documentation
├── installation.md             # Installation guide
├── keybindings.md              # Keybindings reference
├── lua-configuration.md       # Hyprland Lua configuration guide
├── quickshell-architecture.md  # Quickshell component architecture
├── repository-structure.md     # This file
├── theming.md                  # Theming guide
├── troubleshooting.md          # Troubleshooting guide
└── vmware.md                   # VMware-specific notes
```

**Purpose:** Comprehensive documentation for installation, configuration, CI/CD, and troubleshooting.

## Configuration Flow

```
Repository (Source of Truth)
    ↓
bootstrap/install.sh
    ↓
~/.config/hypr/ (Runtime)
~/.config/quickshell/ (Runtime - end4-pC)
~/.config/foot/ (Runtime)
~/.config/kitty/ (Runtime)
~/.config/gtk/ (Runtime)
~/.config/mako/ (Runtime)
~/.config/wlogout/ (Runtime)
```

The installation system:
1. Reads configuration from `config/` in the repository
2. Copies files to appropriate locations in `~/.config/`
3. Clones end4-pC to `~/.config/quickshell/`
4. Sets up necessary environment variables
5. Applies VMware optimizations only if VMware is detected
6. Preserves existing files by backing them up
7. Reports all changes made

## Adding New Components

### Adding a New Hyprland Module

1. Create a new `.lua` file in `config/hypr/`
2. Add it to the import list in `config/hypr/hyprland.lua`
3. Update documentation as needed
4. Add to installation script if it requires special handling

### Adding a New Quickshell Component

Quickshell configuration is managed by end4-pC. To customize:
1. Modify files in `end4-pC/` before installation
2. The installer will clone the modified version to `~/.config/quickshell/`
3. Alternatively, customize after installation in `~/.config/quickshell/`

### Adding a New Package Group

1. Create a new `.txt` file in `packages/`
2. Add package names (one per line)
3. Update installation script to install the package group
4. Update documentation

## File Naming Conventions

- **Lua files**: Use lowercase with underscores (e.g., `keybinds.lua`)
- **QML files**: Use PascalCase (e.g., `WorkspaceIndicator.qml`)
- **Shell scripts**: Use lowercase with hyphens (e.g., `validate-lua-config.sh`)
- **Documentation**: Use lowercase with hyphens (e.g., `installation.md`)
- **Package lists**: Use lowercase with hyphens (e.g., `desktop-services.txt`)

## Version Control

The repository tracks:
- All configuration files (source of truth)
- Installation and maintenance scripts
- Documentation
- Utility scripts
- CI/CD workflows
- Theme configurations
- Test files

The repository does NOT track:
- Runtime files in `~/.config/` (these are generated by the installer)
- System-wide files in `/etc/` (unless project-specific)
- Binary packages or build artifacts
- User-specific data

## Additional Directories

### System Configuration
```
system/
├── etc/                        # System-level configuration files
└── systemd/                    # Systemd service files
```

### Tests
```
tests/
├── hyprland/                   # Hyprland configuration tests
├── quickshell/                 # Quickshell configuration tests
└── shell/                      # Shell script tests
```

### Themes
```
themes/
├── default/                    # Default theme configuration
└── wallpapers/                 # Wallpaper collection
```

## CI/CD Integration

The project uses GitHub Actions for continuous integration and deployment:

### Workflows
- **build-quickshell.yml**: Builds Quickshell from source on GitHub Actions
- **installer.yml**: Creates installer packages automatically

### Build Process
1. Triggered on push to main/master branches and releases
2. Builds Quickshell with proper dependencies
3. Creates pre-built binaries for Linux x86_64
4. Attaches artifacts to GitHub releases
5. Installer downloads pre-built binaries for faster installation

For detailed CI/CD information, see [CI/CD Documentation](ci-cd.md).

## Backup Strategy

Before overwriting configuration files, the installer:
1. Creates a backup directory: `~/.local/state/kali-land/backups/<timestamp>/`
2. Copies existing files to the backup directory
3. Reports what was backed up
4. Never silently overwrites user data

This ensures safe rollback if needed.

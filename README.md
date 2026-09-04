# kali-land - Modern Desktop Environment

A professional, modular, reproducible desktop environment for Kali Linux running inside VMware.

## Mission

Build a Kali-native desktop environment using Hyprland + Quickshell that provides a modern workflow and aesthetic while preserving Kali's security tooling and Debian/Kali package ecosystem.

## Stack

- **OS**: Kali Linux (Debian-based)
- **Display**: Wayland
- **Compositor**: Hyprland
- **Desktop Shell**: Quickshell (end4-pC with Material 3 design)
- **Target**: VMware virtual machine (with bare-metal migration path)

## Features

- **Modern Desktop**: Professional Material 3 design with end4-pC Quickshell
- **Modular Configuration**: Clean separation of concerns with Lua and QML
- **Automated Installation**: Single-command setup with dependency management
- **CI/CD Integration**: Pre-built Quickshell binaries from GitHub Actions
- **VMware Optimized**: Pre-configured for VMware virtual machines
- **Kali Native**: Preserves all Kali security tools and package ecosystem

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/kali-land.git
cd kali-land

# Run the installer
sudo ./bootstrap/install.sh

# Restart into Hyprland
```

## Installation

The installer handles everything automatically:

1. **Platform Detection**: Validates Kali Linux environment
2. **Dependencies**: Installs all required packages
3. **Hyprland**: Configures modern Wayland compositor
4. **Quickshell**: Installs with end4-pC Material 3 design
5. **Configuration**: Sets up modular configuration system
6. **VMware**: Optimizes for VMware environment

## Quickshell

kali-land uses the end4-pC Quickshell configuration for a professional Material 3 desktop experience:

- **Top Bar**: System information, workspaces, launchers
- **Launcher**: Application launcher with fuzzy search
- **Settings Panel**: Comprehensive configuration GUI
- **Material 3 Design**: Modern, polished aesthetic
- **Hyprland Integration**: Designed specifically for Hyprland

## CI/CD

kali-land uses GitHub Actions for automated builds:

- **Quickshell Build**: Automatically builds Quickshell from source
- **Pre-built Binaries**: Downloads pre-built binaries for fast installation
- **Installer Packages**: Creates ready-to-use installer packages
- **Release Management**: Automatically attaches builds to releases

## Project Structure

```
kali-land/
├── bootstrap/          # Installation and maintenance scripts
├── config/            # Configuration files (source of truth)
├── packages/          # Package manifests
├── scripts/           # Utility scripts
├── docs/              # Documentation
├── end4-pC/           # Cloned end4-pC Quickshell configuration
├── .github/           # CI/CD workflows
└── system/            # System-level configurations
```

## Documentation

- [Installation Guide](docs/installation.md) - Detailed installation instructions
- [Architecture](docs/architecture.md) - System architecture overview
- [Repository Structure](docs/repository-structure.md) - Project organization
- [CI/CD Setup](docs/ci-cd.md) - CI/CD configuration and workflows
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please follow the coding standards and architectural guidelines in [AGENT.md](AGENT.md).

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     Kali Linux                            │
│                                                          │
│  Debian/Kali packages + security tooling + systemd       │
│                                                          │
├──────────────────────────────────────────────────────────┤
│                     Wayland                              │
├──────────────────────────────────────────────────────────┤
│                     Hyprland                             │
│                                                          │
│  compositor / windows / workspaces / keybinds            │
├──────────────────────────────────────────────────────────┤
│                    Desktop Services                       │
│                                                          │
│  portals / notifications / audio / network / clipboard   │
│  idle / lock / wallpaper / screenshots / authentication  │
├──────────────────────────────────────────────────────────┤
│                     Quickshell                            │
│                                                          │
│  bar / launcher / control center / widgets / menus       │
├──────────────────────────────────────────────────────────┤
│                   Applications                            │
│                                                          │
│  terminal / browser / editor / file manager / tools      │
└──────────────────────────────────────────────────────────┘
```

## Installation

See [docs/installation.md](docs/installation.md) for detailed installation instructions.

## Quick Start

```bash
# Run the diagnostic first
./bootstrap/doctor.sh

# Install the desktop environment
./bootstrap/install.sh
```

## Project Structure

```
kali-omarchy/
├── AGENT.md              # Agent instructions and architecture
├── README.md             # This file
├── bootstrap/            # Installation and maintenance scripts
├── packages/             # Package manifests by concern
├── config/               # Configuration files (source of truth)
├── scripts/              # Utility scripts
├── themes/               # Theme system
├── system/               # System-level configuration
├── docs/                 # Documentation
└── tests/                # Validation tests
```

## Key Features

- Keyboard-first workflow
- Modular, reproducible configuration
- Source-controlled desktop environment
- VMware-optimized with bare-metal migration path
- Preserves Kali security tooling
- Coexists with existing XFCE desktop during development

## Documentation

- [Repository Structure](docs/repository-structure.md)
- [Architecture](docs/architecture.md)
- [Installation](docs/installation.md)
- [Lua Configuration](docs/lua-configuration.md)
- [Quickshell Architecture](docs/quickshell-architecture.md)
- [Keybindings](docs/keybindings.md)
- [Theming](docs/theming.md)
- [Troubleshooting](docs/troubleshooting.md)
- [VMware](docs/vmware.md)

## Status

🚧 **In Development** - This is an active project following a phased approach.

See [AGENT.md](AGENT.md) for the complete implementation plan and engineering rules.

## License

[Specify your license here]

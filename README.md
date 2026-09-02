# Kali Omarchy-Inspired Desktop

A professional, modular, reproducible Omarchy-inspired desktop environment for Kali Linux running inside VMware.

## Mission

Build a Kali-native desktop environment using Hyprland + Quickshell that provides an Omarchy-like workflow and aesthetic while preserving Kali's security tooling and Debian/Kali package ecosystem.

## Stack

- **OS**: Kali Linux (Debian-based)
- **Display**: Wayland
- **Compositor**: Hyprland
- **Desktop Shell**: Quickshell
- **Target**: VMware virtual machine (with bare-metal migration path)

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

- [Architecture](docs/architecture.md)
- [Installation](docs/installation.md)
- [Keybindings](docs/keybindings.md)
- [Theming](docs/theming.md)
- [Troubleshooting](docs/troubleshooting.md)
- [VMware](docs/vmware.md)

## Status

🚧 **In Development** - This is an active project following a phased approach.

See [AGENT.md](AGENT.md) for the complete implementation plan and engineering rules.

## License

[Specify your license here]

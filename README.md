# kali-land

A modular, reproducible desktop environment for Kali Linux built on Hyprland and Quickshell.

## Overview

kali-land provides a modern Wayland desktop environment that preserves Kali's security tooling while offering a polished user experience.

**Note**: This project is currently in active development. While designed for VMware during development, it can be used on bare metal hardware. Use on daily drivers at your own risk until stable release.

## Components

- **Hyprland**: Wayland compositor for window management
- **Quickshell**: Desktop shell using the end4-pC Material 3 configuration
- **Kali Linux**: Debian-based security distribution

## Requirements

- Kali Linux (Rolling)
- Sudo access
- Internet connection
- 4GB RAM minimum (8GB recommended)

## Installation

```bash
git clone https://github.com/yourusername/kali-land.git
cd kali-land
sudo ./bootstrap/install.sh
```

See [Installation Guide](docs/installation.md) for detailed instructions.

## Architecture

```
Kali Linux
    ↓
Wayland
    ↓
Hyprland (compositor)
    ↓
Desktop Services (audio, network, notifications)
    ↓
Quickshell (desktop shell)
    ↓
Applications
```

## Key Features

- Modular, source-controlled configuration
- Automated installation with rollback support
- VMware-optimized with bare-metal compatibility
- Keyboard-first workflow
- Preserves all Kali security tools

## Credits

This project builds upon excellent open-source work:

- **Hyprland**: Dynamic tiling Wayland compositor by [vaxerski](https://github.com/vaxerski/Hyprland)
- **Quickshell**: Extensible desktop shell framework by [outfoxxed](https://github.com/outfoxxed/quickshell)
- **end4-pC**: Material 3 Quickshell configuration by [pctrade](https://github.com/pctrade/end4-pC)
- **Kali Linux**: Penetration testing distribution by [Offensive Security](https://www.kali.org/)
- **Wayland**: Display server protocol
- **Qt**: Cross-platform application framework

## Documentation

- [Installation](docs/installation.md)
- [Architecture](docs/architecture.md)
- [Repository Structure](docs/repository-structure.md)
- [CI/CD](docs/ci-cd.md)
- [Troubleshooting](docs/troubleshooting.md)
- [VMware Guide](docs/vmware.md)

## Development

See [AGENT.md](AGENT.md) for architectural guidelines and implementation rules.

## License

MIT License - see [LICENSE](LICENSE) for details.

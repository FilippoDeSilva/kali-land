# kali-land

A modular, reproducible desktop environment for Kali Linux built on Hyprland and Quickshell.

## Overview

kali-land provides a modern Wayland desktop environment that preserves Kali's security tooling while offering a polished user experience. It targets VMware virtual machines with a clear migration path to bare metal.

## Components

- **Hyprland**: Wayland compositor for window management
- **Quickshell**: Desktop shell using the end4-pC Material 3 configuration
- **Kali Linux**: Debian-based security distribution

## Requirements

- Kali Linux (Rolling)
- VMware virtual machine
- Sudo access
- Internet connection

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

## Documentation

- [Installation](docs/installation.md)
- [Architecture](docs/architecture.md)
- [Repository Structure](docs/repository-structure.md)
- [CI/CD](docs/ci-cd.md)
- [Troubleshooting](docs/troubleshooting.md)

## Development

See [AGENT.md](AGENT.md) for architectural guidelines and implementation rules.

## License

MIT License - see [LICENSE](LICENSE) for details.

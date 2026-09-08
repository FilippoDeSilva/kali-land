# kali-land

> **Who says Kali doesn't deserve Aesthetics?**

A modular, reproducible desktop platform for Kali Linux built on Wayland, Hyprland, and Quickshell.

## Core Philosophy

> **Kali-land owns the plumbing, not the personality.**  
> **Kali-land provides the floor, not the furniture.**  
> **Kali-land owns the environment; the user owns the experience.**

`kali-land` is not a Kali Linux fork, theme pack, or opinionated distribution. It is a minimal, robust desktop runtime foundation around Kali Linux that provides a solid Wayland + Hyprland runtime, desktop services, capability detection, resource ownership tracking, and safety tooling — with support for any desktop setup under a **Bring Your Own Setup (BYOS)** model.

## Overview

`kali-land` provides a modern Wayland desktop environment that preserves 100% of Kali's security tooling while allowing complete user customization without taking ownership of unrelated dotfiles or application settings.

**Note**: Engineered for both bare-metal hardware and virtualized environments (e.g. VMware), with dynamic hardware detection and profile optimization.

## Core Architecture

```text
                         USER LAND
┌─────────────────────────────────────────────────────┐
│  User Shell / Dotfiles / Themes / Workflows        │
└─────────────────────────────────────────────────────┘
                         ▲
                         │ optional integration
                         │
┌─────────────────────────────────────────────────────┐
│                   KALI-LAND                         │
│  Integration Contract / Capability Engine           │
│  Resource Ownership Ledger (~/.local/state/...)     │
│  Backup / Rollback / Diagnostics / Lifecycle       │
│  Platform Configuration (~/.config/hypr/kali-land/) │
└─────────────────────────────────────────────────────┘
                         ▲
                         │
┌─────────────────────────────────────────────────────┐
│                 PLATFORM LAYER                      │
│  Wayland / Hyprland / Desktop Services             │
└─────────────────────────────────────────────────────┘
                         ▲
                         │
┌─────────────────────────────────────────────────────┐
│                  KALI LINUX                         │
└─────────────────────────────────────────────────────┘
```

### Platform Foundation (Kali-land Owned)
- **Kali Linux Base**: Debian security distribution (`apt`, `dpkg`, `systemd`).
- **Wayland & Hyprland**: Wayland session protocol, tiling window compositor, window rules, and workspace IPC.
- **Desktop Services**: PipeWire audio, NetworkManager, XDG desktop portals, Polkit authentication, cliphist, desktop notifications.
- **State & Resource Ownership Ledger**: Track package provenance and file ownership at `~/.local/state/kali-land/state/installation.json`.
- **Diagnostics & Safety**: Non-destructive installer, manifest backups, offline rollback, and `./bootstrap/doctor.sh`.

### Experience Layer (User Owned)
- **Namespace-Isolated Integrations**: Desktop shell integrations live strictly in namespaced locations (e.g. `~/.config/quickshell/end4-pC/`), leaving the parent folder and user configurations untouched.
- **User Customizations**: Custom dotfiles, terminal setups, wallpapers, keybindings, and application workflows.

## Requirements

- Kali Linux (Rolling)
- Sudo access
- Internet connection
- 4GB RAM minimum (8GB recommended)

## Installation

```bash
git clone https://github.com/FilippoDeSilva/kali-land.git
cd kali-land
sudo ./bootstrap/install.sh
```

See [Installation Guide](docs/installation.md) for detailed instructions.

## Key Features

- **Bring Your Own Shell (BYOS)**: Support for modular Quickshell desktop shells with `end4-pC` as the primary reference integration.
- **Declarative Manifest Font Delivery**: Integration `manifest.yaml` files declaratively state system font packages and local TTF assets, automatically installed and cached during setup.
- **Modular Lua Hyprland Configuration**: Clean, maintainable Hyprland setup using native Lua configuration modules (`hyprland.lua`, `keybinds.lua`, `environment.lua`, etc.).
- **Platform/Experience Separation**: Core platform runtime is completely decoupled from user interface themes.
- **Automated Installation & Rollback**: Safe, idempotent setup with timestamped backups (`~/.local/state/kali-land/backups/`).
- **VMware & Bare-metal Profiles**: Automatic environment detection and dynamic virtualization optimization.
- **Preserves Security Tooling**: 100% compatibility with official Kali Linux penetration testing tools.


## Documentation

- [Architecture](docs/architecture.md)
- [Quickshell Architecture](docs/quickshell-architecture.md)
- [Installation Guide](docs/installation.md)
- [Repository Structure](docs/repository-structure.md)
- [CI/CD Pipeline](docs/ci-cd.md)
- [Troubleshooting](docs/troubleshooting.md)
- [VMware Guide](docs/vmware.md)
- [Architectural Guidelines (AGENT.md)](AGENT.md)

## Credits

This project builds upon excellent open-source work:

- **Hyprland**: Dynamic tiling Wayland compositor by [vaxerski](https://github.com/vaxerski/Hyprland)
- **Quickshell**: Extensible desktop shell framework by [outfoxxed](https://github.com/outfoxxed/quickshell)
- **end4-pC**: Material 3 Quickshell configuration by [pctrade](https://github.com/pctrade/end4-pC)
- **Kali Linux**: Penetration testing distribution by [Offensive Security](https://www.kali.org/)
- **Wayland**: Display server protocol
- **Qt**: Cross-platform application framework

## License

MIT License - see [LICENSE](LICENSE) for details.

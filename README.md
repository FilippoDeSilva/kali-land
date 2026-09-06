# kali-land

> **Who says Kali doesn't deserve Aesthetics?**

A modular, reproducible desktop platform for Kali Linux built on Wayland, Hyprland, and Quickshell.

## Core Principle

> **kali-land owns the environment; the user owns the experience.**

`kali-land` is not a Kali Linux fork, theme pack, or locked-in shell clone. It is a robust desktop/runtime layer around Kali Linux that provides a solid Wayland + Hyprland runtime foundation, desktop services, capability detection, and safety/rollback tooling, with first-class support for Quickshell-based desktop shells under a **Bring Your Own Shell (BYOS)** model.

## Overview

`kali-land` provides a modern Wayland desktop environment that preserves Kali's security tooling while offering a polished user experience.

**Note**: This project is currently in active development. While designed for VMware during development, it is engineered for bare-metal laptops and desktops as well. VMware-specific optimizations are applied dynamically when running inside a VM.

## Core Architecture

```text
                         KALI LINUX
                 security + Debian ecosystem
                            │
                         WAYLAND
                            │
                        HYPRLAND
                  compositor + window IPC
                            │
                  ┌─────────┴─────────┐
                  │                   │
             Desktop Services     Shell Runtime
                  │                   │
          PipeWire / Network      Quickshell
          Portals / Polkit            │
          Notifications / IPC         │
                  │            ┌──────┼──────┐
                  │            │      │      │
                  │         end4-pC  User   Future
                  │            (ref) Shells Shells
                  │
                  └───────────┬───────┘
                              │
                         Applications
```

### Platform Layer (kali-land-owned)
- **Kali Linux**: Debian-based security distribution & package manager (`apt`).
- **Wayland & Hyprland**: Wayland session protocol, tiling compositor, workspaces, and window IPC.
- **Desktop Services**: PipeWire, NetworkManager, XDG desktop portals, Polkit, cliphist, notifications.
- **Platform Infrastructure**: Capability detection, profile management (VMware / Bare metal), idempotent installer, diagnostics (`doctor`), and backups (`~/.local/state/kali-land/`).

### Experience Layer (User-owned)
- **Quickshell Integrations**: First-class support for Quickshell desktop shells (`end4-pC` is the primary reference integration proof-of-concept).
- **User Customizations**: Custom shell configurations, visual themes, keyboard workflows, and application choices.

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

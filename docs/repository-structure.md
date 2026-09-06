# Repository Structure

This document describes the current repository structure of `kali-land` and explains the purpose of each directory and file.

---

## Root Directory

```text
kali-land/
├── AGENT.md                    # Agent instructions and architectural boundaries
├── README.md                   # Project overview and quick start
├── LICENSE                     # MIT License
├── VERSION                     # Version indicator (1.0.0)
├── .gitignore                  # Git ignore rules
├── QUICKSTART.md               # Quick start guide
├── .env.example                # Environment variables template
├── .github/                    # GitHub Actions CI/CD workflows
│   └── workflows/
│       ├── build-quickshell.yml  # Quickshell build workflow
│       └── installer.yml         # Installer packaging workflow
├── bootstrap/                  # Idempotent installer & system libraries
├── config/                     # User space configuration source of truth
├── integrations/              # Decoupled shell integrations (BYOS model)
│   └── end4-pC/              # Reference Quickshell shell integration
├── packages/                  # Base package manifests
├── profiles/                  # Hardware & virtual machine profiles (vmware, bare-metal)
├── scripts/                   # Utility scripts & deployment tools
├── system/                    # System-level configurations
├── tests/                     # Test suites
├── themes/                    # Visual theme definitions
└── docs/                      # Technical documentation
```

---

## Bootstrap & Integration Subsystem

```text
bootstrap/
├── install.sh                  # Main entry-point installer script
├── uninstall.sh                # System uninstallation script
├── doctor.sh                   # System diagnostic & validation tool
└── lib/
    ├── backups.sh              # Protected backup management (~/.local/state/kali-land/backups/)
    ├── capabilities.sh         # System & display capability detector
    ├── filesystem.sh           # Safe directory creation & copy utilities
    ├── integrations.sh         # Shell integration manager, manifest parser & font installer
    ├── logging.sh              # Structured CLI logging (log_info, log_step, log_success)
    ├── packages.sh             # APT package manager wrapper
    ├── platform.sh             # OS distribution & virtualization detector
    ├── profile.sh              # Hardware profile loader
    └── prompts.sh              # Interactive prompt utilities
```

---

## Package Manifests & Integrations

```text
packages/
├── base.txt                    # Base system tools (git, curl, jq, cmake, gcc)
├── wayland.txt                 # Wayland protocol libraries & XWayland
├── hyprland.txt                # Hyprland compositor dependencies
├── desktop-services.txt        # Audio (PipeWire), network, portal services
├── applications.txt            # Terminal apps (foot, kitty, thunar, geany)
└── optional.txt                # Extended tools (matugen, optional fonts)

integrations/end4-pC/
├── manifest.yaml                # Declarative capability, package & font manifest
├── shell.qml                    # Quickshell entry point
├── modules/                     # UI components (bar, launcher, sidebars, lock screen)
├── services/                    # Backend Qt/QML service bridges
├── assets/
│   └── fonts/                   # Bundled font assets (MaterialSymbolsRounded.ttf)
└── scripts/                     # Helper scripts (wallpaper generator, color switcher)
```

---

## Configuration Layer (`config/`)

```text
config/
├── hypr/                       # Hyprland compositor configuration (Lua)
│   ├── hyprland.lua            # Main entry point (requires modules)
│   ├── keybinds.lua            # Keyboard shortcuts & Quickshell IPC bindings
│   ├── environment.lua         # Environment variables (QT_QPA_PLATFORM, etc.)
│   ├── monitors.lua            # Monitor resolution & scale
│   ├── rules.lua               # Window & workspace layout rules
│   ├── autostart.lua           # Startup applications & Quickshell daemon
│   ├── decorations.lua         # Gaps, borders, shadows & animations
│   ├── vmware.lua              # VMware software backend & cursor overrides
│   └── minimal.lua             # Minimal fallback configuration
```

---

## Key Maintenance Scripts

```text
scripts/
├── deploy-config.sh            # Deploys config/ to ~/.config/ and syncs font assets
├── validate-lua-config.sh      # Validates Hyprland Lua syntax and structure
├── test-hyprland.sh            # Safe sandbox test runner for Hyprland session
└── vmware/                     # VMware display optimization scripts
```

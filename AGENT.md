# AGENT.md --- kali-land - Modern Desktop Environment

## 0. Mission

Build a **professional, modular, reproducible, maintainable
desktop environment for Kali Linux running inside
VMware**.

The target is:

> **Kali Linux + Hyprland + Quickshell + a deliberately engineered
> desktop stack that provides a modern workflow and aesthetic
> while preserving Kali's security tooling and Debian/Kali package
> ecosystem.**

The project must be designed like a real Linux configuration project
maintained by an experienced Linux user:

-   modular
-   reproducible
-   source-controlled
-   idempotent
-   debuggable
-   reversible
-   documented
-   platform-aware
-   safe to iterate on
-   easy to migrate to bare metal later
-   easy to extend without turning into one giant shell script

Do not optimize for "make it look cool as quickly as possible." Optimize
for **architecture first, polish second**.

------------------------------------------------------------------------

# 1. Non-Negotiable Rules

## 1.1 Platform

This project targets:

-   OS: **Kali Linux**
-   Base family: Debian
-   Development environment: **VMware virtual machine**
-   Production target: **VMware or bare metal**
-   Display stack target: **Wayland**
-   Compositor: **Hyprland**
-   Desktop shell: **Quickshell**

VMware is used during development. The desktop environment is designed to work on bare metal hardware as well. VMware-specific optimizations are only applied when running in a VMware virtual machine.

Never assume Arch Linux commands, package managers, filesystem layouts,
or AUR availability.

Use Kali/Debian conventions unless a component explicitly requires
otherwise.

Examples:

-   package manager: `apt`
-   package database: `dpkg`
-   services: `systemd`
-   user configuration: `$HOME/.config`
-   system configuration: `/etc`
-   local system-wide additions: `/usr/local`
-   user-local binaries: `$HOME/.local/bin`

Do not introduce Arch-specific tooling.

------------------------------------------------------------------------

## 1.2 Do Not Destroy the Existing Desktop

The existing Kali desktop must remain usable as a recovery path until
the new environment is proven stable.

Do NOT:

-   remove XFCE/GNOME/KDE immediately
-   replace the display manager unnecessarily
-   overwrite unrelated system configuration
-   modify `/usr/share` application files
-   replace Kali's package sources
-   install random third-party repositories without justification
-   run arbitrary installation scripts from the internet
-   use `curl ... | bash`
-   blindly install somebody else's entire dotfiles repository

The new environment must initially coexist with the existing desktop.

------------------------------------------------------------------------

## 1.3 Configuration Ownership

Prefer:

``` text
user configuration
    ↓
~/.config/...
```

over modifying vendor/system files.

System files should only be modified when genuinely necessary.

Every system-level modification must be:

1.  documented
2.  isolated
3.  reversible
4.  represented by an installation/configuration script where practical

------------------------------------------------------------------------

# 2. Project Goals

## Primary Goals

1.  Install and validate Hyprland on Kali.
2.  Establish a reliable Wayland session.
3.  Install and validate Quickshell.
4.  Build a modular Quickshell desktop shell.
5.  Reproduce important UX concepts:
    -   keyboard-first workflow
    -   application launcher
    -   workspace navigation
    -   top bar
    -   notifications
    -   system controls
    -   power menu
    -   wallpaper management
    -   consistent theme
    -   polished animations
6.  Preserve Kali's security tooling.
7.  Maintain a clean separation between:
    -   compositor
    -   shell
    -   services
    -   applications
    -   themes
    -   keybindings
    -   installation logic
8.  Make the entire setup reproducible.
9.  Make rollback possible.
10. Make future migration to physical hardware straightforward.

## Secondary Goals

Eventually support:

-   multiple monitors
-   laptop power management
-   suspend/resume
-   brightness
-   audio
-   Bluetooth
-   screenshots
-   screen recording
-   clipboard history
-   lock screen
-   idle management
-   wallpaper transitions
-   media controls
-   notifications
-   network controls
-   VM-specific optimizations
-   NVIDIA/AMD/Intel hardware-specific configuration
-   optional modules

------------------------------------------------------------------------

# 3. Architecture

The conceptual architecture is:

``` text
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

Hyprland owns window-management behavior.

Quickshell owns desktop UI.

External utilities should own specialized system functions rather than
forcing Quickshell to reinvent them.

------------------------------------------------------------------------

# 4. Repository Philosophy

The repository is the **source of truth for user-owned configuration and
project automation**.

Recommended location:

``` text
~/Projects/kali-land/
```

If the user's preferred development directory differs, detect it first
and use the existing convention.

Recommended repository structure:

``` text
kali-land/
├── AGENT.md
├── README.md
├── LICENSE
├── .gitignore
│
├── bootstrap/
│   ├── install.sh
│   ├── uninstall.sh
│   ├── doctor.sh
│   └── lib/
│       ├── logging.sh
│       ├── platform.sh
│       ├── packages.sh
│       ├── filesystem.sh
│       └── prompts.sh
│
├── packages/
│   ├── base.txt
│   ├── wayland.txt
│   ├── hyprland.txt
│   ├── quickshell.txt
│   ├── desktop-services.txt
│   ├── applications.txt
│   └── optional.txt
│
├── config/
│   ├── hypr/
│   │   ├── hyprland.conf
│   │   ├── keybinds.conf
│   │   ├── monitors.conf
│   │   ├── rules.conf
│   │   ├── environment.conf
│   │   └── autostart.conf
│   │
│   ├── quickshell/
│   │   ├── shell.qml
│   │   ├── qmldir
│   │   └── Colors.qml
│   │
│   ├── kitty/
│   ├── foot/
│   ├── mako/
│   ├── wlogout/
│   ├── hyprlock/
│   ├── hypridle/
│   └── gtk/
│
├── scripts/
│   ├── launch/
│   ├── wallpaper/
│   ├── screenshot/
│   ├── system/
│   ├── audio/
│   ├── network/
│   └── vmware/
│
├── themes/
│   ├── default/
│   │   ├── colors.qml
│   │   ├── spacing.qml
│   │   ├── typography.qml
│   │   └── effects.qml
│   └── wallpapers/
│
├── system/
│   ├── etc/
│   └── systemd/
│
├── docs/
│   ├── architecture.md
│   ├── installation.md
│   ├── keybindings.md
│   ├── quickshell-architecture.md
│   ├── theming.md
│   ├── troubleshooting.md
│   ├── vmware.md
│   └── hardware.md
│
└── tests/
    ├── shell/
    ├── hyprland/
    └── quickshell/
```

The exact structure may evolve, but preserve the architectural
boundaries.

------------------------------------------------------------------------

# 5. Configuration Management Strategy

Use a **repo-first configuration model**.

Do not manually maintain unrelated copies of files.

Recommended mapping:

``` text
repo/config/hypr/hyprland.conf
        ↓
~/.config/hypr/hyprland.conf

repo/config/quickshell/
        ↓
~/.config/quickshell/
```

The installation system should create directories and symlinks or
managed copies consistently.

Preferred behavior:

``` text
repository = source of truth
$HOME/.config = runtime location
```

If symlinks are used, the installer must:

-   detect existing files
-   back them up
-   never silently overwrite user data
-   clearly report what it changed

Example backup location:

``` text
~/.local/state/kali-land/backups/<timestamp>/
```

------------------------------------------------------------------------

# 6. Bootstrap System

`bootstrap/install.sh` must be safe to execute repeatedly.

Requirements:

-   `set -Eeuo pipefail`
-   meaningful error messages
-   command existence checks
-   OS detection
-   package manager detection
-   privilege handling
-   dry-run support if practical
-   idempotent operations
-   logging
-   explicit confirmation for destructive operations

The installer must first collect facts.

Examples:

``` bash
cat /etc/os-release
uname -a
echo "$XDG_SESSION_TYPE"
echo "$XDG_CURRENT_DESKTOP"
echo "$XDG_SESSION_DESKTOP"
systemctl --user is-system-running
```

Also detect:

-   VM vs physical hardware
-   GPU vendor
-   CPU architecture
-   available memory
-   Wayland support
-   existing desktop environment
-   display manager
-   package versions
-   existing Hyprland installation
-   existing Quickshell installation

Never guess these values.

------------------------------------------------------------------------

# 7. Package Management

Create package manifests by concern.

Example:

``` text
packages/base.txt
packages/wayland.txt
packages/hyprland.txt
packages/quickshell.txt
packages/desktop-services.txt
packages/applications.txt
```

The installer should install only the required group for the current
phase.

Do not install a huge package list at once.

Before installation:

``` bash
apt update
apt-cache policy <package>
apt-cache show <package>
```

Verify package availability and version compatibility.

If a package is unavailable in Kali's repositories:

1.  stop
2.  investigate the official upstream installation method
3.  document the source
4.  evaluate dependency impact
5.  prefer a packaged release over a random binary
6.  avoid mixing incompatible Debian repositories
7.  never add Ubuntu repositories to Kali as a shortcut

------------------------------------------------------------------------

# 8. Hyprland Strategy

Hyprland is the compositor.

Do not treat Hyprland as the complete desktop environment.

Its responsibility:

-   windows
-   workspaces
-   layouts
-   monitor configuration
-   input
-   animations
-   keybindings
-   window rules
-   startup commands

Keep configuration modular.

Recommended:

``` text
hyprland.conf
├── environment.conf
├── monitors.conf
├── keybinds.conf
├── rules.conf
└── autostart.conf
```

The main file should mostly compose modules.

Avoid a 1000-line monolithic configuration.

------------------------------------------------------------------------

# 9. Quickshell Strategy

Quickshell is the **desktop shell**, not the compositor.

kali-land uses the end4-pC Quickshell configuration as the foundation, which provides:

- Material 3 design system
- Comprehensive desktop shell features
- Hyprland integration
- Modular architecture

The end4-pC configuration is cloned from:
``` text
https://github.com/pctrade/end4-pC
```

## end4-pC Architecture

The configuration is organized as:

``` text
end4-pC/
├── shell.qml                    # Main entry point
├── panelFamilies/               # Panel configurations
├── modules/                     # UI modules
│   ├── common/                  # Shared utilities and models
│   ├── ii/                      # Illogical Impulse (main desktop)
│   │   ├── verticalBar/         # Vertical bar components
│   │   ├── sidebarLeft/        # Left sidebar (launcher, AI, etc.)
│   │   └── sidebarRight/       # Right sidebar (controls, notifications)
│   └── other panels...
├── services/                    # Backend services
│   ├── HyprlandBackend.qml
│   ├── Audio.qml
│   ├── Network.qml
│   └── ...
├── assets/                      # Icons, fonts, images
├── defaults/                    # Default configurations
├── scripts/                     # Helper scripts
└── translations/                # i18n support
```

## Customization Strategy

When customizing end4-pC:

1. **Modify modules in place** - Edit QML files in `end4-pC/`
2. **Preserve architecture** - Keep the modular structure
3. **Test changes incrementally** - Quickshell supports hot reload
4. **Backup before major changes** - Use version control

## Installation

The installer copies end4-pC from the repository to:
``` text
~/.config/quickshell/
```

This ensures the configuration is source-controlled and reproducible.

------------------------------------------------------------------------

# 10. Quickshell UI Architecture

The end4-pC configuration provides a comprehensive UI:

## Vertical Bar

The main vertical bar contains:
- Workspace indicators
- System information
- Quick toggles
- Application launcher trigger

## Sidebars

### Left Sidebar
- Application launcher with fuzzy search
- AI chat integration (optional)
- Translator
- Wallpaper selector

### Right Sidebar
- Quick toggles (Wi-Fi, Bluetooth, volume, etc.)
- Notification center
- Calendar widget
- Volume mixer
- Power controls
- Todo list

## Control Center

The control center provides:
- Unified system controls
- Audio device management
- Network configuration
- Bluetooth device management
- Brightness controls
- Night light settings
- Power profile selection

## Power Menu

Available actions:
- Lock screen
- Logout
- Suspend
- Reboot
- Shutdown

All destructive actions require confirmation.

## Features

- Material 3 design language
- Smooth animations
- Keyboard-first navigation
- Configurable widgets
- Multi-language support
- Hyprland-specific integrations

------------------------------------------------------------------------

# 11. Desktop Services

Do not reinvent every Linux service in QML.

Use appropriate existing tools/services for:

-   notifications
-   audio
-   networking
-   Bluetooth
-   clipboard
-   authentication
-   portals
-   idle
-   locking
-   wallpapers
-   screenshots

Quickshell should provide the UI and orchestration layer.

------------------------------------------------------------------------

# 12. Wayland Integration

The project must validate:

``` bash
echo "$XDG_SESSION_TYPE"
```

Expected target:

``` text
wayland
```

Also inspect:

``` bash
loginctl
loginctl show-session "$XDG_SESSION_ID"
```

Validate:

-   XWayland availability
-   XDG desktop portals
-   clipboard
-   screenshots
-   file picker behavior
-   browser compatibility
-   terminal compatibility

Kali's existing desktop must remain available as fallback while this is
being developed.

------------------------------------------------------------------------

# 13. VMware-Specific Requirements

This is a VM-first project.

Do not assume physical hardware behavior.

First determine:

``` bash
systemd-detect-virt
```

and inspect VMware-related hardware.

The environment must be evaluated for:

-   VMware SVGA graphics
-   3D acceleration
-   dynamic resolution
-   clipboard integration
-   drag-and-drop
-   mouse integration
-   multi-monitor behavior
-   suspend/resume behavior
-   shared folders if used
-   performance

Do not install physical-GPU-specific configuration unless the VM
actually exposes that hardware.

VMware-specific configuration must live separately:

``` text
scripts/vmware/
docs/vmware.md
```

Do not contaminate generic Hyprland configuration with VMware-only
hacks.

------------------------------------------------------------------------

# 14. Theming System

Treat the visual design as a system.

Do not scatter colors throughout QML files.

Centralize:

``` text
theme/
├── colors
├── typography
├── spacing
├── radius
├── shadows/effects
└── animations
```

Example conceptual tokens:

``` text
background
surface
surfaceElevated
foreground
muted
accent
warning
danger
success

radiusSmall
radiusMedium
radiusLarge

spacingXS
spacingSM
spacingMD
spacingLG
spacingXL
```

All UI components should consume theme tokens.

This makes future themes possible without rewriting the shell.

------------------------------------------------------------------------

# 15. Modern UX Principles

The project should capture the *principles*, not necessarily duplicate
modern desktop implementation.

Target:

-   keyboard-first operation
-   minimal mouse dependency
-   fast application launch
-   predictable workspaces
-   coherent visual language
-   sensible defaults
-   polished transitions
-   low visual noise
-   terminal-friendly workflow
-   discoverable shortcuts
-   consistent menus
-   strong information hierarchy

Do not copy proprietary artwork or blindly duplicate third-party
configuration.

------------------------------------------------------------------------

# 16. Keybinding Philosophy

Use a small, predictable vocabulary.

Primary modifier:

``` text
Super
```

Suggested concepts:

``` text
Super + Enter       terminal
Super + Space       launcher
Super + Q           close window
Super + 1..9        workspace
Super + Shift + 1..9 move window
Super + H/J/K/L     focus direction
Super + Shift + H/J/K/L move window
Super + F           fullscreen
Super + V           toggle floating
Super + L           lock
Super + Escape      control center / system UI
```

Exact bindings may change after testing.

Avoid collisions with:

-   terminal applications
-   browser shortcuts
-   accessibility shortcuts
-   Kali tooling

Every final binding must be documented in:

``` text
docs/keybindings.md
```

------------------------------------------------------------------------

# 17. Application Philosophy

Do not install applications merely because they are popular.

Choose tools based on:

1.  Kali compatibility
2.  Wayland compatibility
3.  maintenance quality
4.  keyboard workflow
5.  resource usage
6.  interoperability
7.  licensing
8.  reversibility

Candidate categories:

-   terminal
-   shell
-   editor
-   browser
-   file manager
-   notification daemon
-   launcher
-   screenshot utility
-   clipboard manager
-   lock screen
-   idle daemon
-   wallpaper tool

Every application should have a reason to exist.

------------------------------------------------------------------------

# 18. Shell and CLI Layer

The graphical environment should be backed by a strong terminal
workflow.

Possible tools should be evaluated individually rather than blindly
installed.

Categories:

``` text
shell
prompt
directory navigation
search
file discovery
process inspection
system inspection
git
terminal multiplexer
```

The CLI stack must remain compatible with Kali's security workflow.

Do not change the user's default shell without explicit intent.

------------------------------------------------------------------------

# 19. Security Requirements

This is Kali.

Security matters more than aesthetics.

Never:

-   disable security controls just to make a UI work
-   blindly run scripts as root
-   store credentials in the repository
-   commit tokens
-   commit SSH keys
-   commit browser profiles
-   commit machine-specific secrets
-   disable AppArmor/security mechanisms without documentation
-   add untrusted repositories casually

Repository must include a strong `.gitignore`.

Potential exclusions:

``` text
.env
*.pem
*.key
id_*
credentials*
secrets*
machine-specific files
runtime state
cache
logs
```

Before every commit, inspect:

``` bash
git status
git diff --cached
```

------------------------------------------------------------------------

# 20. Git Strategy

Use small, logical commits.

Suggested phases:

``` text
chore: initialize project
feat: add platform detection
feat: add package manifests
feat: install wayland stack
feat: add hyprland base configuration
feat: add quickshell skeleton
feat: add desktop bar
feat: add launcher
feat: add notifications
feat: add control center
feat: add theme system
feat: add vmware integration
docs: add troubleshooting guide
```

Do not create one giant "setup everything" commit.

------------------------------------------------------------------------

# 21. Testing Strategy

Every major layer needs a validation command or test.

## Platform

``` bash
cat /etc/os-release
systemd-detect-virt
uname -m
```

## Session

``` bash
echo "$XDG_SESSION_TYPE"
echo "$XDG_CURRENT_DESKTOP"
```

## Hyprland

Validate:

-   compositor starts
-   terminal opens
-   workspaces work
-   keybindings work
-   configuration reload works
-   application rules work
-   animations work

## Quickshell

Validate:

-   shell starts
-   shell survives reload
-   bar renders
-   launcher opens
-   popups open
-   system data updates
-   shell errors are visible
-   one broken module does not destroy the entire desktop where
    practical

## Services

Validate:

-   notifications
-   audio
-   network
-   clipboard
-   screenshots
-   locking
-   portals

------------------------------------------------------------------------

# 22. Doctor Command

`bootstrap/doctor.sh` should eventually provide a diagnostic report.

Example output:

``` text
KALI-LAND DOCTOR

Platform
  OS              PASS
  Architecture    PASS
  VMware          PASS

Display
  Wayland         PASS
  Hyprland        PASS
  XWayland        PASS

Shell
  Quickshell      PASS
  Bar             PASS
  Launcher        PASS

Services
  Audio           PASS
  Network         PASS
  Notifications   PASS
  Clipboard       PASS
  Portal          PASS

Configuration
  Hyprland config PASS
  Quickshell      PASS
  Theme           PASS
```

Failures should explain how to investigate them.

------------------------------------------------------------------------

# 23. Logging

Installation scripts should log to:

``` text
~/.local/state/kali-land/logs/
```

Example:

``` text
install-2026-09-02T15-30-00.log
doctor-2026-09-02T16-10-00.log
```

Do not dump enormous unreadable output by default.

Use clear levels:

``` text
INFO
WARN
ERROR
DEBUG
```

------------------------------------------------------------------------

# 24. Backup and Rollback

Before modifying an existing config:

``` text
~/.local/state/kali-land/backups/
```

Backups must be timestamped.

Example:

``` text
backups/
└── 2026-09-02T15-30-00/
    ├── hypr/
    ├── quickshell/
    └── manifest.txt
```

Rollback should restore the previous configuration without requiring
internet access.

For major milestones, take a VMware snapshot.

Recommended snapshot points:

``` text
01-kali-clean
02-packages-installed
03-hyprland-working
04-quickshell-working
05-desktop-complete
```

------------------------------------------------------------------------

# 25. Development Workflow

The agent must work incrementally.

For every task:

``` text
1. Inspect current state
2. Explain intended change internally
3. Make smallest safe change
4. Validate
5. Inspect resulting state
6. Fix regressions
7. Update documentation
8. Commit logically
```

Never assume the previous step worked.

------------------------------------------------------------------------

# 26. First-Run Discovery

Before changing anything, gather:

``` bash
cat /etc/os-release
uname -a
uname -m

systemd-detect-virt

echo "$XDG_SESSION_TYPE"
echo "$XDG_CURRENT_DESKTOP"
echo "$XDG_SESSION_DESKTOP"

loginctl
systemctl --user is-system-running

dpkg --print-architecture

lspci | grep -Ei 'vga|3d|display'

free -h
df -h /
```

Also inspect:

``` bash
command -v hyprland || true
command -v quickshell || true
command -v waybar || true
command -v dunst || true
```

And package availability:

``` bash
apt-cache policy hyprland
apt-cache policy quickshell
```

Do not proceed based on assumed versions.

------------------------------------------------------------------------

# 27. Implementation Phases

## Phase 0 --- Baseline

Goal:

Understand the clean Kali VM.

Deliverables:

-   platform report
-   hardware/VM report
-   current desktop report
-   package state
-   backup strategy
-   repository initialized

Do not install the complete environment yet.

------------------------------------------------------------------------

## Phase 1 --- Repository Foundation

Create:

``` text
AGENT.md
README.md
.gitignore
bootstrap/
packages/
config/
docs/
scripts/
themes/
tests/
```

Implement:

-   platform detection
-   logging
-   backup system
-   basic doctor command

Acceptance criteria:

-   repository initializes cleanly
-   scripts run without modifying the desktop
-   platform is correctly detected

------------------------------------------------------------------------

## Phase 2 --- Wayland Foundation

Determine the correct Kali-supported path for the current installation.

Install only the required Wayland/Hyprland dependencies.

Validate:

``` bash
echo "$XDG_SESSION_TYPE"
```

Acceptance:

-   Wayland session works
-   original desktop still works
-   no broken login path
-   fallback session remains accessible

------------------------------------------------------------------------

## Phase 3 --- Hyprland

Implement the smallest usable compositor configuration.

Start with:

-   terminal
-   workspaces
-   keybindings
-   basic monitor configuration
-   sane gaps
-   minimal animations
-   XWayland
-   startup behavior

Do not implement the fancy shell yet.

Acceptance:

> Hyprland is usable as a minimal desktop with keyboard control.

------------------------------------------------------------------------

## Phase 4 --- Core Desktop Services

Add and validate:

-   XDG desktop portal
-   notifications
-   audio
-   network
-   clipboard
-   lock
-   idle
-   screenshot
-   wallpaper

Each service should be validated independently.

------------------------------------------------------------------------

## Phase 5 --- Quickshell Skeleton

Install/validate Quickshell using the appropriate method for the exact
Kali release.

Create:

``` text
shell.qml
modules/
components/
services/
models/
utils/
theme/
```

Initially render only:

``` text
hello / debug shell
```

Then add one module at a time.

Acceptance:

-   Quickshell launches reliably
-   errors are diagnosable
-   configuration is modular

------------------------------------------------------------------------

## Phase 6 --- Bar

Implement:

``` text
launcher
workspaces
window title
system indicators
clock
```

First optimize functionality.

Then optimize visuals.

------------------------------------------------------------------------

## Phase 7 --- Launcher

Implement keyboard-first application launcher.

Requirements:

-   Super + Space
-   fuzzy search
-   desktop entry support
-   keyboard navigation
-   fast startup
-   escape handling

------------------------------------------------------------------------

## Phase 8 --- Control Center

Implement system popup.

Build reusable UI primitives first.

Example:

``` text
Panel
 ├── Network
 ├── Audio
 ├── Bluetooth
 ├── Brightness
 ├── Battery
 └── Notifications
```

------------------------------------------------------------------------

## Phase 9 --- Power / Lock / Session UX

Implement:

-   lock
-   logout
-   reboot
-   shutdown
-   suspend

Use explicit confirmation for destructive actions.

------------------------------------------------------------------------

## Phase 10 --- Visual System

Only after functionality is stable:

-   typography
-   spacing
-   colors
-   borders
-   radius
-   shadows
-   animations
-   wallpaper
-   cursor
-   icons
-   terminal theme

Create centralized theme tokens.

------------------------------------------------------------------------

## Phase 11 --- VMware Optimization

Tune:

-   resolution
-   scaling
-   input
-   3D acceleration
-   clipboard
-   multi-monitor
-   resource usage

Keep all VMware-specific code isolated.

------------------------------------------------------------------------

## Phase 12 --- Reliability

Run the full environment for several sessions.

Test:

-   login
-   logout
-   reboot
-   suspend
-   shell restart
-   compositor reload
-   network loss/reconnect
-   audio device changes
-   application crashes
-   display resize
-   VMware suspend/resume

------------------------------------------------------------------------

## Phase 13 --- Documentation

README should answer:

-   What is this?
-   Why Kali?
-   Why Hyprland?
-   Why Quickshell?
-   How do I install it?
-   How do I update it?
-   How do I roll back?
-   How do I troubleshoot it?
-   How do I customize it?
-   What is VM-specific?
-   What is hardware-specific?

------------------------------------------------------------------------

# 28. Dependency Rules

Every dependency should belong to a category:

``` text
required
recommended
optional
VM-only
hardware-specific
development-only
```

Do not make optional features hard dependencies.

Example:

If Bluetooth is unavailable:

``` text
Bluetooth module = disabled/unavailable
Desktop = still works
```

Not:

``` text
Bluetooth missing
    ↓
Quickshell crashes
    ↓
desktop broken
```

------------------------------------------------------------------------

# 29. Failure Isolation

A broken optional component must not take down the entire desktop.

Examples:

``` text
weather API unavailable
    ↓
weather widget unavailable
    ↓
bar still works
```

``` text
Bluetooth unavailable
    ↓
Bluetooth controls disabled
    ↓
control center still works
```

``` text
Quickshell module error
    ↓
module fails
    ↓
shell remains diagnosable
```

Favor graceful degradation.

------------------------------------------------------------------------

# 30. Performance

This is a VM.

Do not build a beautiful desktop that consumes excessive CPU/RAM.

Measure before optimizing.

Monitor:

``` bash
free -h
top
htop
```

For graphical processes, inspect process CPU/RAM usage.

Avoid:

-   aggressive polling
-   unnecessary timers
-   constant shell command spawning
-   huge image assets
-   excessive animations
-   redundant background daemons

Prefer event-driven updates where the framework/service supports them.

------------------------------------------------------------------------

# 31. QML/Quickshell Engineering Rules

Treat QML as production code.

Rules:

-   reusable components
-   clear naming
-   small files
-   no giant root component
-   avoid duplicated UI
-   avoid hard-coded colors
-   avoid hard-coded screen dimensions
-   avoid hard-coded application paths
-   centralize theme values
-   separate data from presentation
-   avoid unnecessary shell process spawning
-   document non-obvious system integrations

Use consistent naming:

``` text
PascalCase.qml
```

for reusable components.

Use meaningful service names:

``` text
AudioService
NetworkService
BatteryService
HyprlandService
```

------------------------------------------------------------------------

# 32. Hyprland Engineering Rules

Avoid putting everything in one config.

Prefer:

``` text
hyprland.conf
    ↓
includes
    ↓
feature-specific files
```

Separate:

-   monitor configuration
-   keybindings
-   window rules
-   environment
-   startup
-   appearance

Do not hard-code VM-specific monitor IDs into the generic configuration.

------------------------------------------------------------------------

# 33. Hardware Profiles

Eventually support:

``` text
profiles/
├── vmware.conf
├── laptop.conf
├── desktop-intel.conf
├── desktop-amd.conf
└── desktop-nvidia.conf
```

The exact implementation can differ.

The architectural rule is:

> Hardware-specific configuration must not leak into the generic desktop
> configuration.

------------------------------------------------------------------------

# 34. Environment Profiles

Support at least:

``` text
development
vmware
bare-metal
```

Potential future profiles:

``` text
laptop
desktop
minimal
```

Avoid duplicating entire configurations.

Use shared defaults plus overrides.

------------------------------------------------------------------------

# 35. Documentation Standards

Every non-obvious decision should be documented.

Use Architecture Decision Records if decisions become significant:

``` text
docs/adr/
├── 0001-wayland.md
├── 0002-quickshell-architecture.md
├── 0003-config-management.md
└── 0004-vmware-profile.md
```

ADR format:

``` text
# Decision

## Context

## Decision

## Alternatives Considered

## Consequences
```

------------------------------------------------------------------------

# 36. What the Agent Must Never Do Without Approval

Do not perform these silently:

-   remove the existing desktop environment
-   replace the display manager
-   modify package repositories
-   add third-party repositories
-   install unsigned binaries
-   overwrite existing dotfiles
-   delete user configuration
-   change default shell
-   modify firewall/network security policy
-   disable security mechanisms
-   change kernel parameters unnecessarily
-   reboot the machine without telling the user
-   shut down the machine without telling the user
-   destroy a VMware snapshot
-   delete backups

When such a change becomes necessary, explain:

``` text
why
what changes
risk
rollback
```

before proceeding.

------------------------------------------------------------------------

# 37. Definition of Done

The project is not "done" because it looks like a screenshot.

Done means:

### Platform

-   [ ] Kali remains healthy
-   [ ] original desktop remains available
-   [ ] package state is documented
-   [ ] VM detection works

### Wayland

-   [ ] Wayland session works
-   [ ] XWayland works
-   [ ] portals work

### Hyprland

-   [ ] starts reliably
-   [ ] workspaces work
-   [ ] keybindings work
-   [ ] monitor configuration works
-   [ ] applications launch correctly

### Quickshell

-   [ ] starts reliably
-   [ ] bar works
-   [ ] launcher works
-   [ ] workspaces integrate
-   [ ] system controls work
-   [ ] notifications work
-   [ ] power menu works

### UX

-   [ ] keyboard-first workflow
-   [ ] consistent theme
-   [ ] responsive UI
-   [ ] sensible animations
-   [ ] no major visual glitches

### Reliability

-   [ ] login tested
-   [ ] logout tested
-   [ ] reboot tested
-   [ ] resize tested
-   [ ] network reconnect tested
-   [ ] audio tested
-   [ ] shell restart tested
-   [ ] Hyprland reload tested

### Engineering

-   [ ] configuration is source controlled
-   [ ] installer is idempotent
-   [ ] backups exist
-   [ ] rollback documented
-   [ ] doctor command works
-   [ ] README is complete
-   [ ] no secrets committed
-   [ ] VM-specific code is isolated

------------------------------------------------------------------------

# 38. Agent Operating Principle

The agent should think like a Linux systems engineer, not a theme
installer.

Before every change ask:

``` text
Is this Kali-compatible?
Is this Wayland-native?
Is this reversible?
Is this reproducible?
Is this modular?
Is this VM-safe?
Does this belong in the compositor, shell, service layer, or application layer?
Can this fail without taking down the desktop?
Can another machine reproduce this setup?
```

Prefer boring, reliable engineering over clever hacks.

Prefer upstream documentation over random tutorials.

Prefer distro packages when appropriate.

Prefer small changes over massive scripts.

Prefer explicit configuration over hidden magic.

Prefer diagnostics over guessing.

Prefer a clean architecture that can grow for years over a beautiful
configuration that becomes impossible to maintain in three weeks.

------------------------------------------------------------------------

# 39. Immediate Task for the Agent

Do **not** start by installing everything.

Start with:

### Step 1

Inspect the current Kali installation.

Collect:

``` bash
cat /etc/os-release
uname -a
uname -m
systemd-detect-virt

echo "$XDG_SESSION_TYPE"
echo "$XDG_CURRENT_DESKTOP"
echo "$XDG_SESSION_DESKTOP"

loginctl
systemctl --user is-system-running

dpkg --print-architecture

lspci | grep -Ei 'vga|3d|display'

free -h
df -h /

apt-cache policy hyprland
apt-cache policy quickshell

command -v hyprland || true
command -v quickshell || true
```

### Step 2

Determine the exact Kali release and whether the currently configured
repositories provide compatible versions of the required components.

### Step 3

Inspect the current desktop/session/display manager.

### Step 4

Determine VMware graphics capabilities and whether 3D acceleration is
available.

### Step 5

Create the repository skeleton.

### Step 6

Create the diagnostic/doctor foundation.

### Step 7

Report findings before making risky system changes.

Only then begin the installation phases.

------------------------------------------------------------------------

# 40. Final Principle

The end result should feel like:

``` text
             ┌─────────────────────────────┐
             │         KALI LINUX          │
             │                             │
             │  security tools + Debian    │
             │  package ecosystem          │
             └──────────────┬──────────────┘
                            │
                         Wayland
                            │
                       ┌────▼────┐
                       │Hyprland │
                       └────┬────┘
                            │
                    Desktop services
                            │
                       ┌────▼────┐
                       │Quickshell│
                       └────┬────┘
                            │
                ┌───────────┼───────────┐
                │           │           │
              Bar        Launcher    Controls
                │           │           │
                └───────────┼───────────┘
                            │
                    Modern UX
```

The goal is **not a Kali theme**.

The goal is a **Kali-native, engineer-maintained desktop environment
built from composable Linux components**, with enough structure that
future-you can still understand and modify it months or years from now.

# AGENT.md — kali-land

> **Who says Kali doesn't deserve Aesthetics?**

## 0. Mission

Build **kali-land**, a professional, modular, reproducible, maintainable desktop
platform for Kali Linux.

kali-land is **not a Kali Linux fork, replacement distribution, theme pack, or
end4-pC clone**. It is a desktop/runtime layer around Kali Linux, with a strong
Wayland + Hyprland foundation and first-class support for Quickshell-based
desktop shells.

Core principle:

> **kali-land owns the environment; the user owns the experience.**

The project should provide sensible defaults without forcing every user to
adopt one particular Quickshell configuration.

The current development environment is a Kali Linux VM running under VMware.
The project must remain capable of evolving toward bare-metal laptops and
desktops.

---

# 1. Project Identity

## 1.1 Name

Project name:

```text
kali-land
```

Repository:

```text
FilippoDeSilva/kali-land
```

Use `kali-land` consistently in paths, state directories, documentation,
commands, and generated output.

## 1.2 Positioning

Think of the stack as:

```text
Kali Linux
    +
desktop/runtime infrastructure
    +
Wayland
    +
Hyprland
    +
desktop services
    +
Quickshell compatibility
    +
user-selected shell
```

kali-land may be opinionated about defaults, but those defaults must not become
architectural requirements.

---

# 2. Core Architecture

The most important distinction is between the **platform** and the **shell**.

```text
                         KALI-LAND
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
     Runtime             Services            Shell Layer
        │                   │                   │
   Wayland              PipeWire             Quickshell
   Hyprland             NetworkManager           │
   XWayland             Portals                   ├── end4-pC
   IPC                  Notifications              ├── user shell
                        Polkit                    └── future shells
                        Clipboard
```

### kali-land owns

- Kali/Debian-aware installation
- package and dependency handling
- Wayland runtime
- Hyprland integration
- desktop service integration
- capability detection
- environment detection
- hardware/VM profiles
- configuration safety
- backups and rollback
- diagnostics
- shell discovery/integration
- sensible defaults
- documentation
- testing and reproducibility

### kali-land does not inherently own

- a specific Quickshell UI
- a specific bar or launcher
- a specific Material 3 implementation
- a specific visual theme
- a user's entire `~/.config/quickshell`
- a user's shell/prompt
- a user's preferred terminal
- every application installed on Kali

A reference shell may exist, but it remains a shell integration.

---

# 3. Non-Negotiable Rules

## 3.1 Kali-first

Target:

```text
OS: Kali Linux
Base: Debian
Package manager: apt
Package database: dpkg
Init/service manager: systemd
```

Never assume:

- `pacman`
- AUR
- Arch package names
- Arch repositories
- Arch-specific filesystem conventions

Translate upstream Arch instructions into a Kali/Debian-compatible approach.

Never add Ubuntu repositories to Kali.

Do not replace Kali's package ecosystem.

## 3.2 Existing desktop is a recovery path

During development, the existing Kali desktop must remain usable.

Do not silently:

- remove XFCE/GNOME/KDE
- replace the display manager
- destroy an existing session
- overwrite unrelated configuration
- modify `/usr/share`
- replace Kali package sources
- disable security controls

A new environment must initially coexist with the existing desktop.

## 3.3 No destructive automation

Never use:

```bash
curl ... | bash
```

Never execute arbitrary internet-hosted scripts without inspecting them.

Never blindly install a third-party dotfiles repository.

Before modifying existing configuration:

```text
detect → backup → change → validate
```

For destructive changes, explain:

```text
why
what changes
risk
rollback
```

before proceeding.

## 3.4 Idempotency

Installation/configuration must be safe to repeat.

Scripts should:

- detect existing state
- skip satisfied operations
- avoid duplicates
- preserve user data
- report changes
- fail clearly

---

# 4. Current Proof of Concept

The project has successfully run **end4-pC inside the Kali VMware environment**.

Treat this as an important integration proof:

```text
Kali + Wayland + Hyprland + Quickshell + end4-pC
                         ↓
                      proven
```

Do **not** interpret this as:

```text
kali-land = end4-pC
```

or:

```text
end4-pC = mandatory
```

end4-pC is the first concrete Quickshell integration/reference target.

Build abstractions from real requirements discovered through this integration.
Do not design a giant framework before a second integration requires one.

---

# 5. Bring Your Own Shell

kali-land should support a **Bring Your Own Shell (BYOS)** model.

Users may bring:

- a custom Quickshell configuration
- a third-party Quickshell configuration
- a kali-land reference shell
- a fork of an existing shell
- future supported shells

Do not promise that literally every Quickshell configuration works automatically.

Instead provide:

> a standardized runtime, documented capabilities, dependency detection, and
> integration contracts for compatible shells.

---

# 6. Shell Integrations

Treat shells as integrations/adapters.

Conceptual structure:

```text
integrations/
├── end4-pC/
├── generic/
└── future/
```

The exact repository structure may evolve.

A shell integration may declare:

```yaml
name: example-shell
type: quickshell

requires:
  - wayland
  - hyprland
  - quickshell

optional:
  - pipewire
  - networkmanager
  - bluetooth

launch:
  command: ...
```

Keep the contract small. Do not build a complicated plugin system until real
integrations require it.

---

# 7. Capability Model

Reason about **capabilities**, not just packages.

Examples:

```text
wayland
hyprland
xwayland
hyprland-ipc
quickshell
pipewire
wireplumber
networkmanager
notifications
portals
polkit
clipboard
screenshot
lock
idle
bluetooth
battery
brightness
```

A shell can require or optionally consume capabilities.

Example:

```text
Required:
  ✓ Wayland
  ✓ Hyprland
  ✓ Quickshell

Optional:
  ✓ PipeWire
  ✓ NetworkManager
  ✗ Bluetooth
```

Missing optional capabilities must not unnecessarily break the desktop.

This model should eventually power:

```bash
kali-land doctor
kali-land shell list
kali-land shell detect
kali-land shell doctor
```

---

# 8. Platform Layers

Keep responsibilities explicit.

## Kali

Owns the OS, security tooling, Debian/Kali packages, systemd, and system
security. kali-land works with this layer.

## Wayland

Provides the graphical session protocol.

## Hyprland

Owns:

- windows
- workspaces
- layouts
- monitors
- input
- keybindings
- window rules
- compositor behavior
- animations
- startup

Hyprland is not the complete desktop environment.

## Desktop services

Examples:

- XDG desktop portals
- PipeWire/WirePlumber
- NetworkManager
- notifications
- polkit
- clipboard
- screenshots
- lock/idle services
- wallpaper tooling

Use existing Linux services instead of reinventing them in QML.

## Shell

Quickshell provides the graphical shell layer.

A shell may provide:

- bars
- panels
- launchers
- widgets
- notifications UI
- controls
- power UI
- system information

## Applications

Examples:

- terminal
- browser
- editor
- file manager
- security tools
- development tools
- optional utilities

Do not make arbitrary applications core dependencies.

---

# 9. Repository Philosophy

The repository is the source of truth for **kali-land-owned code/configuration**.

It is not automatically the source of truth for every user's personal setup.

```text
kali-land-owned config
    ↓
repository is source of truth

user-owned shell/config
    ↓
user remains source of truth
```

Never take ownership of a user's configuration merely because kali-land can
modify it.

---

# 10. Configuration Ownership

Prefer:

```text
$HOME/.config/
$HOME/.local/bin/
$HOME/.local/state/kali-land/
```

over modifying vendor/system files.

Every system-level change must be:

1. documented
2. isolated
3. reversible
4. reproducible
5. attributable to a project component

Do not modify `/usr/share` unless genuinely required and explicitly documented.

---

# 11. Configuration Installation

For kali-land-owned configuration:

```text
repository
    ↓
runtime configuration
    ↓
~/.config/...
```

For user-provided shells, do not automatically replace their configuration.

If symlinks or managed copies are used:

- detect existing files
- back them up
- never silently overwrite
- report changes
- make rollback possible

Prefer namespaced shell locations when possible:

```text
~/.config/quickshell/<shell>/
```

rather than assuming kali-land owns all of:

```text
~/.config/quickshell/
```

---

# 12. Backup and Rollback

Use:

```text
~/.local/state/kali-land/
```

Recommended:

```text
~/.local/state/kali-land/
├── backups/
├── logs/
├── state/
└── reports/
```

Example:

```text
backups/
└── 2026-09-05T10-30-00/
    ├── manifest.txt
    ├── hypr/
    ├── quickshell/
    └── other/
```

Rollback must restore configuration without requiring internet access.

VMware snapshots complement, but do not replace, project backups.

---

# 13. Bootstrap System

Keep bootstrap logic modular.

Conceptually:

```text
bootstrap/
├── install.sh
├── uninstall.sh
├── doctor.sh
└── lib/
    ├── logging.sh
    ├── platform.sh
    ├── packages.sh
    ├── filesystem.sh
    ├── capabilities.sh
    ├── backups.sh
    └── prompts.sh
```

Do not turn `install.sh` into a giant monolith.

Use:

```bash
set -Eeuo pipefail
```

where appropriate.

Support where practical:

- dry-run
- non-interactive mode
- explicit confirmation
- logging
- clear errors
- idempotency

---

# 14. Discovery Before Mutation

Before changing the machine, inspect it.

Useful commands:

```bash
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

Check components:

```bash
command -v hyprland || true
command -v quickshell || true
command -v kitty || true
command -v foot || true
```

Check packages:

```bash
apt-cache policy <package>
apt-cache show <package>
```

Never assume versions or package availability.

---

# 15. Package Management

Organize dependencies by purpose:

```text
packages/
├── base.txt
├── wayland.txt
├── hyprland.txt
├── quickshell.txt
├── desktop-services.txt
└── optional.txt
```

Every dependency should be classified:

```text
required
recommended
optional
VM-only
hardware-specific
development-only
shell-specific
```

Do not make optional features hard dependencies.

If a package is unavailable:

1. stop
2. inspect official upstream installation guidance
3. verify Kali compatibility
4. document the source
5. evaluate security/maintenance implications
6. prefer packaged software where appropriate
7. avoid repository mixing

Never add Ubuntu repositories to Kali.

---

# 16. Hyprland Strategy

Hyprland is the compositor.

Keep its configuration independent from shell implementation.

Conceptual structure:

```text
config/hypr/
├── hyprland.conf
├── environment.conf
├── monitors.conf
├── keybinds.conf
├── rules.conf
├── appearance.conf
└── autostart.conf
```

The main file should compose smaller files.

Avoid giant monolithic configuration.

Do not put Quickshell UI logic into Hyprland configuration.

---

# 17. Quickshell Strategy

Distinguish:

```text
Quickshell runtime
        ≠
specific Quickshell configuration
```

The project may provide a reference shell, but the platform should remain
usable with other compatible shells.

When working on a third-party/reference shell:

- respect its existing architecture
- avoid unnecessary rewrites
- isolate kali-land integration changes
- document local modifications
- preserve upstream provenance
- avoid silently replacing upstream files

---

# 18. end4-pC Integration

end4-pC is currently the primary reference integration.

It proves that a sophisticated Quickshell desktop shell can operate within the
Kali-land runtime.

Do not make kali-land architecture depend on end4-pC-specific internals.

Do not hard-code assumptions about:

- panel layout
- Material 3
- launcher implementation
- sidebar implementation
- service implementation
- directory layout

unless scoped specifically to the end4-pC integration.

When modifying end4-pC:

- keep upstream attribution clear
- isolate local changes
- document why a change is needed
- preserve the ability to update/replace the integration

---

# 19. Desktop Services

Use existing Linux mechanisms for:

```text
audio
networking
Bluetooth
notifications
authentication
portals
clipboard
locking
idle
screenshots
wallpapers
```

Quickshell should consume and present capabilities, not become a replacement
for the underlying service ecosystem.

---

# 20. Wayland Validation

Validate:

```bash
echo "$XDG_SESSION_TYPE"
```

Expected target:

```text
wayland
```

Also inspect:

```bash
loginctl
loginctl show-session "$XDG_SESSION_ID"
```

Validate:

- Wayland
- XWayland
- portals
- clipboard
- screenshots
- file pickers
- browsers
- terminals
- common graphical applications

---

# 21. VMware

VMware is the current development and validation environment.

Detect with:

```bash
systemd-detect-virt
```

Evaluate:

- VMware virtual GPU
- 3D acceleration
- resolution/scaling
- clipboard integration
- drag-and-drop
- mouse integration
- multi-monitor behavior
- suspend/resume
- shared folders if used
- CPU/RAM overhead

Do not add physical GPU configuration to a VM.

Keep VMware-specific logic isolated:

```text
scripts/vmware/
docs/vmware.md
```

The same project should eventually work without VMware-specific logic on bare
metal.

---

# 22. Environment and Hardware Profiles

Conceptually support:

```text
profiles/
├── vmware/
├── bare-metal/
├── laptop/
└── desktop/
```

Potential hardware capabilities:

```text
Intel
AMD
NVIDIA
battery
brightness
multiple monitors
```

Do not duplicate entire configurations.

Prefer:

```text
shared defaults
    +
environment/hardware overrides
```

Hardware-specific configuration must not leak into generic configuration.

---

# 23. Terminal and CLI

kali-land may provide terminal/CLI defaults, but they are **defaults**.

Do not silently change:

- default shell
- `.bashrc`
- `.zshrc`
- terminal emulator
- editor
- prompt
- aliases

If aliases or CLI enhancements are offered:

```text
detect → offer → backup → apply
```

The CLI must remain compatible with Kali security workflows.

---

# 24. Applications

Do not install applications simply because another desktop project uses them.

Evaluate:

1. Kali compatibility
2. Wayland compatibility
3. security
4. maintenance quality
5. resource usage
6. keyboard workflow
7. interoperability
8. licensing
9. reversibility
10. actual project value

Optional applications remain optional.

---

# 25. Keybindings

Use a predictable vocabulary.

Default modifier may be:

```text
Super
```

Possible concepts:

```text
Super + Enter           terminal
Super + Space           launcher
Super + Q               close window
Super + 1..9            workspace
Super + Shift + 1..9    move window
Super + H/J/K/L         directional focus
Super + Shift + H/J/K/L move window
Super + F               fullscreen
Super + V               floating
Super + L               lock
```

These are defaults, not immutable requirements.

Document final bindings.

---

# 26. Theming

For kali-land-owned UI, centralize:

```text
colors
typography
spacing
radius
effects
animations
```

Do not scatter colors and dimensions throughout QML.

Do not impose kali-land's theme on a user-provided shell.

---

# 27. QML / Quickshell Engineering

Treat QML as production code.

Prefer:

- small components
- reusable components
- clear naming
- separation of data and presentation
- event-driven updates
- minimal process spawning
- capability-aware services
- graceful error handling

Avoid:

- giant root components
- duplicated UI
- hard-coded screen dimensions
- hard-coded application paths
- hard-coded colors
- unnecessary polling
- constant shell command spawning
- hidden global state
- assumptions that hardware exists

Reusable components should normally use:

```text
PascalCase.qml
```

Services should have meaningful names such as:

```text
AudioService
NetworkService
BatteryService
HyprlandService
```

When modifying third-party shells, follow their existing conventions unless
there is a compelling reason not to.

---

# 28. Security Requirements

This is Kali.

Security matters more than aesthetics.

Never:

- disable security controls merely to make a UI work
- blindly run commands as root
- store credentials in the repository
- commit tokens
- commit SSH private keys
- commit browser profiles
- commit machine-specific secrets
- casually disable AppArmor/security mechanisms
- casually modify firewall/network security policy
- add untrusted repositories

If root is required, isolate the privileged operation.

---

# 29. Git Hygiene

Use a strong `.gitignore`.

Potential exclusions:

```text
.env
*.pem
*.key
id_*
credentials*
secrets*
machine-specific state
runtime state
cache
logs
```

Before commits:

```bash
git status
git diff
git diff --cached
```

Never commit passwords, tokens, API keys, SSH private keys, VM credentials, or
personal browser state.

---

# 30. Testing Strategy

Test each layer independently.

## Platform

```text
Kali detection
architecture
virtualization
package availability
```

## Session

```text
Wayland
XWayland
login
logout
```

## Hyprland

```text
startup
workspaces
keybindings
window rules
monitor configuration
reload
application launching
```

## Services

```text
audio
network
notifications
portals
clipboard
lock
idle
screenshots
```

## Shell

```text
Quickshell startup
shell reload
shell failure behavior
capability detection
```

## Integration

For each shell:

```text
dependencies
runtime requirements
startup
basic interaction
reload
shutdown
diagnostics
```

---

# 31. VMware Testing

Use snapshots for major milestones.

Suggested points:

```text
01-kali-clean
02-platform-detected
03-packages-installed
04-hyprland-working
05-services-working
06-quickshell-working
07-end4-pC-working
08-kali-land-stable
```

Snapshots complement reproducible installation; they do not replace it.

---

# 32. Performance

Measure before optimizing.

Useful tools:

```bash
free -h
top
htop
```

Avoid:

- aggressive polling
- unnecessary timers
- excessive process spawning
- huge assets
- excessive animations
- redundant daemons

Prefer event-driven updates where supported.

Do not sacrifice reliability for visual effects.

---

# 33. Failure Isolation

A failure in an optional component must not unnecessarily destroy unrelated
layers.

Examples:

```text
Bluetooth unavailable
    ↓
Bluetooth capability disabled
    ↓
desktop continues
```

```text
optional widget fails
    ↓
widget unavailable
    ↓
shell continues
```

Diagnostics should identify the failing boundary.

---

# 34. Logging

Use:

```text
~/.local/state/kali-land/logs/
```

Example:

```text
install-2026-09-05T10-30-00.log
doctor-2026-09-05T11-00-00.log
```

Levels:

```text
INFO
WARN
ERROR
DEBUG
```

Normal output should be useful and readable. Debug mode may expose verbose
details.

---

# 35. Development Workflow

For every task:

```text
1. Inspect current repository state
2. Inspect machine state when relevant
3. Understand existing architecture
4. Identify ownership boundary
5. Make the smallest appropriate change
6. Validate
7. Inspect resulting state
8. Fix regressions
9. Update documentation
10. Commit logically
```

Never assume a previous command succeeded.

Never rebuild an existing component without first determining why the current
implementation is insufficient.

Prefer incremental improvements over rewrites.

---

# 36. Agent Decision Checklist

Before changing anything:

```text
Is this Kali-compatible?

Is this Wayland-compatible?

Does this belong to kali-land or a shell integration?

Does this belong to Hyprland, a service, or Quickshell?

Am I accidentally making an optional dependency mandatory?

Am I taking ownership of user configuration?

Is this reversible?

Is this reproducible?

Is this VM-safe?

Will this work on bare metal later?

Can this fail without taking down the desktop?

Am I hard-coding something that should be detected?

Does this need a capability check?

Does this need a backup?

Does this need documentation?

Am I solving a real requirement or prematurely abstracting?
```

The final question is critical.

Do not build abstractions merely because they sound elegant. Build them when
real requirements justify them.

---

# 37. Repository Structure

A reasonable target architecture is:

```text
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
│
├── packages/
│   ├── base.txt
│   ├── wayland.txt
│   ├── hyprland.txt
│   ├── quickshell.txt
│   ├── desktop-services.txt
│   └── optional.txt
│
├── config/
│   └── hypr/
│
├── integrations/
│   ├── end4-pC/
│   └── ...
│
├── profiles/
│   ├── vmware/
│   └── ...
│
├── scripts/
│   ├── system/
│   ├── wallpaper/
│   ├── screenshot/
│   └── vmware/
│
├── themes/
├── system/
│
├── docs/
│   ├── architecture.md
│   ├── installation.md
│   ├── configuration.md
│   ├── shells.md
│   ├── capabilities.md
│   ├── troubleshooting.md
│   ├── vmware.md
│   └── hardware.md
│
└── tests/
    ├── platform/
    ├── hyprland/
    ├── services/
    └── integrations/
```

This is a target architecture, not a demand to create every directory
immediately.

The actual repository structure takes precedence.

Do not create empty architecture for its own sake.

---

# 38. Documentation

Documentation must clearly distinguish:

```text
Kali provides
kali-land provides
Hyprland provides
Quickshell provides
shell integration provides
end4-pC provides
user provides
```

README should answer:

- What is kali-land?
- Why Kali?
- Why Wayland?
- Why Hyprland?
- Why Quickshell?
- Is Quickshell mandatory?
- What is end4-pC?
- Can I use my own shell?
- How do I install?
- How do I update?
- How do I roll back?
- How do I diagnose problems?
- What is VM-specific?
- What is hardware-specific?
- What is optional?

Do not claim support that has not been tested.

---

# 39. Architecture Decision Records

Use:

```text
docs/adr/
```

for significant decisions.

Examples:

```text
0001-wayland-runtime.md
0002-hyprland.md
0003-quickshell-integration-model.md
0004-config-ownership.md
0005-vmware-profile.md
```

Format:

```text
# Decision

## Context

## Decision

## Alternatives Considered

## Consequences
```

---

# 40. What the Agent Must Never Do Without Approval

Do not silently:

- remove an existing desktop
- replace the display manager
- modify package repositories
- add third-party repositories
- install unsigned binaries
- overwrite existing dotfiles
- delete user configuration
- change the default shell
- modify firewall/network security policy
- disable security mechanisms
- change kernel parameters unnecessarily
- reboot
- shut down
- destroy VMware snapshots
- delete backups

When necessary, explain:

```text
why
what changes
risk
rollback
```

before proceeding.

---

# 41. Definition of Done

A feature is not complete because it looks good.

## Platform

- [ ] Kali remains healthy
- [ ] existing desktop remains available
- [ ] package changes are understood
- [ ] VM/hardware is detected
- [ ] changes are reproducible

## Wayland

- [ ] Wayland session works
- [ ] XWayland works
- [ ] portals work
- [ ] graphical applications work

## Hyprland

- [ ] starts reliably
- [ ] workspaces work
- [ ] keybindings work
- [ ] monitors work
- [ ] applications launch
- [ ] configuration reload works

## Services

- [ ] audio works
- [ ] network works
- [ ] notifications work
- [ ] clipboard works
- [ ] portals work
- [ ] lock/idle work where enabled
- [ ] screenshots work where enabled

## Shell

- [ ] Quickshell runtime works
- [ ] selected shell launches
- [ ] requirements are validated
- [ ] failures are diagnosable
- [ ] optional capabilities degrade gracefully

## Integration

- [ ] requirements documented
- [ ] upstream provenance documented
- [ ] user configuration protected
- [ ] integration can be updated/replaced independently

## Reliability

- [ ] login tested
- [ ] logout tested
- [ ] reboot tested
- [ ] shell restart tested
- [ ] Hyprland reload tested
- [ ] network reconnect tested
- [ ] display resize tested
- [ ] VM suspend/resume tested where applicable

## Engineering

- [ ] source controlled
- [ ] installer idempotent
- [ ] backups exist
- [ ] rollback documented
- [ ] diagnostics work
- [ ] no secrets committed
- [ ] VM-specific code isolated
- [ ] documentation updated

---

# 42. Agent Operating Principle

Think like a **Linux systems engineer**, not a theme installer.

Prefer:

```text
composition over reinvention
detection over assumptions
capabilities over hard-coded dependencies
integration over ownership
reversibility over convenience
simplicity over premature abstraction
upstream software over unnecessary forks
documented behavior over hidden magic
```

The goal is not:

> Make Kali look like another distribution.

The goal is:

> **Give Kali a modern, beautiful, keyboard-first desktop experience while
> respecting the Linux ecosystem underneath it.**

---

# 43. Current Development Priority

The project is **not a clean-slate project**.

The current state already includes a successful end4-pC proof of concept in the
Kali VMware environment.

Therefore, do not restart from an imaginary Phase 0.

Prioritize:

```text
1. Stabilize the proven runtime
2. Separate platform-owned config from shell-owned config
3. Make end4-pC an explicit integration
4. Protect existing user configuration
5. Improve detection and diagnostics
6. Introduce capability detection
7. Add a lightweight shell contract when needed
8. Improve backup/rollback
9. Validate VMware behavior
10. Validate bare-metal assumptions
```

---

# 44. Do Not Prematurely Build

Do not build without a concrete requirement:

- a custom display manager
- a custom Linux distribution
- a custom compositor
- a custom audio daemon
- a custom network manager
- a Quickshell replacement
- a package manager
- a plugin marketplace
- an elaborate shell SDK
- a universal compatibility layer for every shell
- a giant installer abstraction
- unnecessary daemon infrastructure

kali-land should compose existing Linux technologies well.

---

# 45. Final Principle

The intended architecture is:

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
                  │                   Shells
                  │
                  └───────────┬───────┘
                              │
                         Applications
```

The key boundary is:

```text
                    KALI-LAND
                        │
          ┌─────────────┴─────────────┐
          │                           │
       PLATFORM                    EXPERIENCE
          │                           │
   runtime/services             user-selected shell
   detection/profiles           configuration/theme
   safety/rollback              workflow/UI
   integrations
```

**kali-land owns the platform.  
Users own their desktop experience.**

Keep the architecture flexible enough that end4-pC can be the first successful
shell integration without becoming the last one.

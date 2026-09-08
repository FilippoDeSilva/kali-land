# kali-land — Agent Engineering Guide

> **kali-land owns the environment; the user owns the experience.**

This document defines the engineering principles, architectural boundaries, safety requirements, and development expectations for **kali-land**.

Agents and contributors MUST treat this document as the architectural contract for the project.

When the existing implementation and this document disagree, inspect the implementation first, identify the mismatch, and fix the architecture deliberately. Do not blindly introduce abstractions simply because this document describes them.

---

# 1. Project Identity

**kali-land** is a Kali Linux desktop platform built around:

* Kali Linux / Debian
* Wayland
* Hyprland
* desktop services
* capability detection
* hardware/environment profiles
* shell integrations
* installation lifecycle management
* backups and rollback
* diagnostics
* reproducible installation

kali-land is **not**:

* a Kali Linux fork
* a theme pack
* an Omarchy clone
* an end4-pC clone
* a Quickshell distribution
* a mandatory Quickshell desktop
* a single locked desktop experience

The project provides the platform.

The user chooses the experience.

---

# 2. Core Principle

The most important architectural rule is:

> **Maximum capability with minimum ownership.**

kali-land should provide as much useful desktop infrastructure as possible while taking ownership of as little user data and configuration as possible.

Prefer:

```text
detect
→ understand
→ isolate
→ integrate
→ record
→ validate
```

over:

```text
replace
→ overwrite
→ assume
→ hope
```

---

# 3. Platform vs Experience

kali-land has two conceptual layers.

## Platform

The platform provides the environment required to run a modern Kali desktop.

Examples:

* Wayland
* Hyprland
* PipeWire / WirePlumber
* portals
* notifications
* polkit
* NetworkManager integration
* clipboard infrastructure
* hardware/environment detection
* package management
* profiles
* installation
* backup
* rollback
* update
* uninstall
* diagnostics

## Experience

The experience is what the user actually interacts with.

Examples:

* Quickshell shell
* end4-pC
* Celestia
* another supported shell
* a third-party shell
* a user's own shell
* a custom shell
* no shell at all

The platform MUST NOT depend on a particular experience unless that dependency is explicitly declared by the selected integration.

---

# 4. User Ownership

kali-land MUST distinguish between:

### kali-land-owned resources

Resources created and managed by kali-land.

Examples:

```text
/var/lib/kali-land/
/usr/local/bin/kali-land
~/.local/state/kali-land/
~/.config/kali-land/
```

### integration-owned resources

Resources belonging to a specific shell integration installed through kali-land.

Examples:

```text
~/.config/quickshell/kali-land/end4-pC/
~/.config/kali-land/integrations/<id>/
```

### user-owned resources

Existing user configuration that kali-land did not create.

Examples:

```text
~/.config/quickshell/
~/.config/hypr/
~/.config/waybar/
~/.config/kitty/
~/.bashrc
```

The existence of a resource inside a directory does NOT mean kali-land owns that resource.

---

# 5. No Destructive Automation

Never assume that backing something up gives permission to destroy it.

Bad:

```bash
backup ~/.config/quickshell
rm -rf ~/.config/quickshell
cp -r integration ~/.config/quickshell
```

Correct:

```text
inspect
→ determine exact resource required
→ determine ownership
→ backup exact resource if necessary
→ modify only that resource
→ record ownership
→ validate
```

Never blindly overwrite:

* user configuration
* existing shells
* existing Hyprland configuration
* dotfiles
* scripts
* themes
* wallpapers
* user services
* environment configuration

---

# 6. Bring Your Own Shell

BYOS is a first-class kali-land capability.

Users should be able to choose:

```text
No shell
Built-in integration
Supported third-party integration
Quickshell shell
Celestia shell
Other supported runtime
User-provided shell
Custom shell
```

A user-provided shell should be installable through the same lifecycle system as built-in integrations.

The objective is:

> **Give kali-land the shell; kali-land handles the plumbing.**

However, kali-land MUST NOT claim that literally every arbitrary shell will work automatically.

Automatic support depends on whether kali-land can safely discover:

* runtime
* entrypoint
* dependencies
* capabilities
* installation resources
* launch behavior
* configuration boundaries

If those cannot be determined safely, the installer must explain what is missing instead of guessing.

---

# 7. Shell Selection Is an Installation Decision

The installer MUST NOT implicitly install a shell merely because kali-land is installed.

The user should explicitly choose an experience.

Conceptually:

```text
Kali-land Platform
        │
        ├── No shell
        │
        ├── Built-in integration
        │
        ├── Supported integration
        │
        ├── User shell
        │
        └── Custom shell
```

A minimal installation must remain valid without any shell integration.

---

# 8. Shell Discovery

When the user provides a shell directory, kali-land should inspect it before modifying the system.

Example:

```bash
kali-land shell import ~/Downloads/my-shell
```

The discovery process should conceptually be:

```text
INPUT
  ↓
Directory validation
  ↓
Runtime detection
  ↓
Entrypoint detection
  ↓
Manifest detection
  ↓
Dependency discovery
  ↓
Capability discovery
  ↓
Conflict detection
  ↓
Installation plan
  ↓
User confirmation
  ↓
Installation
  ↓
Validation
  ↓
Registration
```

Do not copy arbitrary files simply because they exist in the supplied directory.

---

# 9. Shell Runtime Abstraction

A shell integration declares its runtime.

Example:

```yaml
runtime: quickshell
```

Another integration may declare:

```yaml
runtime: celestia
```

Or another future runtime:

```yaml
runtime: <runtime>
```

The core MUST NOT hardcode:

```text
Quickshell = kali-land
```

Quickshell is one supported runtime, not the definition of kali-land.

Do not implement fake universal runtime support.

Build the smallest abstraction required by real integrations.

---

# 10. Integration Model

Shells are integrations layered on top of the platform.

Conceptually:

```text
kali-land
│
├── platform
│
└── integrations
    ├── end4-pC
    ├── Celestia
    ├── other supported shells
    └── user-provided shells
```

Every integration should define, where applicable:

```text
identity
runtime
version
entrypoint
dependencies
required capabilities
optional capabilities
environment
owned resources
launch behavior
source/provenance
```

The core should consume this information rather than hardcoding integration-specific behavior.

---

# 11. Integration Manifest

Use a declarative manifest where practical.

A conceptual example:

```yaml
id: example-shell
name: Example Shell
version: "1.0.0"

runtime: quickshell

entry:
  command: quickshell
  config: shell.qml

requires:
  capabilities:
    - wayland
    - hyprland
    - quickshell

  packages:
    - some-package

optional:
  capabilities:
    - pipewire
    - networkmanager

ownership:
  config:
    - "~/.config/quickshell/kali-land/example-shell"

environment:
  QS_CONFIG: "example-shell"
```

This is an example of the model, not a requirement to copy the schema exactly.

Keep manifests small and useful.

---

# 12. Capability Model

Capabilities describe what the platform can provide.

Examples:

```text
wayland
hyprland
pipewire
wireplumber
networkmanager
bluetooth
portals
polkit
quickshell
```

An integration declares what it requires.

Example:

```text
Integration requires:
    wayland
    hyprland
    quickshell
```

The installer must validate required capabilities before installation.

Missing required capabilities should normally be a blocking condition.

Optional capabilities should degrade gracefully.

---

# 13. Shell Compatibility

Compatibility is determined by contracts, not assumptions.

A shell is compatible when kali-land can establish:

```text
runtime available
entrypoint valid
required dependencies available
required capabilities available
installation path safe
launch mechanism valid
```

If compatibility cannot be established:

```text
DO NOT GUESS
DO NOT FORCE INSTALL
DO NOT CLAIM SUCCESS
```

Instead provide an actionable diagnostic.

---

# 14. Quickshell

Quickshell is an optional runtime.

The core platform MUST remain usable without Quickshell.

Do not hardcode:

```text
install Quickshell
install end4-pC
install Matugen
```

as the definition of a kali-land installation.

Instead:

```text
platform
+
selected integration
+
integration dependencies
```

determines what gets installed.

---

# 15. end4-pC

end4-pC is the first concrete reference integration.

It proves that:

```text
Kali
+
Wayland
+
Hyprland
+
Quickshell
+
end4-pC
```

can work together.

It does NOT define kali-land.

Do not move end4-pC-specific assumptions into the core merely because it is currently the primary integration.

---

# 16. Integration Installation Isolation

An integration MUST NOT take ownership of the parent configuration directory.

Bad:

```text
~/.config/quickshell/
```

as the integration's entire installation target.

Prefer an isolated namespace:

```text
~/.config/quickshell/kali-land/<integration-id>/
```

or another equivalent ownership-safe structure.

Installing:

```text
end4-pC
```

must not destroy:

```text
~/.config/quickshell/my-existing-shell/
```

Installing a custom shell must not destroy another shell.

---

# 17. User Shell Imports

When importing a user shell:

```text
~/my-shell/
```

kali-land should preserve the original source.

Prefer:

```text
source
    ↓
validated copy / managed installation
    ↓
kali-land-owned integration
```

Do not silently modify the user's source directory.

If the user explicitly requests an in-place installation model, explain the ownership implications first.

---

# 18. Installation Plans

Before significant mutation, the installer should construct an installation plan.

The plan should answer:

```text
What will be installed?
What packages will be installed?
What runtime will be installed?
What files will be created?
What files will be changed?
What capabilities are required?
What existing resources are affected?
What backups are required?
What resources will kali-land own?
How will the installation be launched?
How can it be rolled back?
```

For interactive installation, present a concise summary before committing destructive or significant changes.

---

# 19. Installation Lifecycle

Installation should follow a consistent lifecycle:

```text
Detect
→ Validate
→ Discover
→ Plan
→ Confirm
→ Backup
→ Install dependencies
→ Install resources
→ Configure
→ Register
→ Validate
→ Commit state
```

Never report success before validation completes.

---

# 20. Idempotency

Running installation repeatedly must be safe.

```bash
kali-land install
kali-land install
kali-land install
```

must not:

* duplicate configuration
* repeatedly overwrite files
* create unnecessary backups
* reinstall unchanged packages
* duplicate startup commands
* corrupt user configuration

The installer should detect:

```text
already installed
already configured
already owned
already correct
```

and avoid unnecessary mutation.

---

# 21. Installation State

kali-land should maintain authoritative installation state.

State should allow the system to answer:

```text
What is installed?
Which version?
Which integration?
Which runtime?
Which resources are owned?
Which packages were installed?
Where did they come from?
Which configuration was modified?
Which backups exist?
Which profile is active?
```

Do not rely solely on filesystem inspection.

---

# 22. Ownership Ledger

Resource ownership should be explicit.

Conceptually:

```text
resource
owner
component
source
created_at
modified_by
backup
provenance
```

For example:

```text
~/.config/quickshell/kali-land/end4-pC/
    owner: kali-land
    component: integration:end4-pC
    source: bundled
```

This ownership information must be consumed by:

* update
* rollback
* uninstall
* doctor
* backup
* restore

---

# 23. Package Provenance

Never assume:

```text
package is in our list
→ therefore we may remove it
```

Instead track whether a package was:

```text
pre-existing
installed by kali-land
installed by an integration
installed by another system
```

Uninstallation must respect provenance.

---

# 24. Backup and Rollback

Backups are a safety mechanism, not permission to overwrite user data.

A backup should answer:

```text
What was protected?
Why?
Who changed it?
Which installation changed it?
Where was the original?
Can it be restored?
```

Rollback should restore the exact resources affected by the operation.

Avoid broad:

```bash
rm -rf
```

operations whenever a narrower operation is possible.

---

# 25. Uninstallation

Uninstall must be ownership-aware.

Never use a static list such as:

```text
hyprland
quickshell
kitty
foot
mako
...
```

and assume kali-land owns all of them.

Instead:

```text
read installation state
→ determine ownership
→ determine provenance
→ remove owned resources
→ preserve user resources
→ preserve pre-existing packages
→ restore configuration where appropriate
→ validate
```

Uninstalling an integration should remove that integration, not unrelated shells.

---

# 26. Hyprland Ownership

Hyprland is part of the platform, but user Hyprland configuration may be user-owned.

Do not blindly replace:

```text
~/.config/hypr/
```

Prefer an isolated kali-land configuration layer.

For example:

```text
~/.config/hypr/
├── kali-land/
│   ├── platform.lua
│   ├── environment.lua
│   └── ...
├── user configuration
└── existing configuration
```

The exact mechanism may change after inspecting the implementation.

The invariant must not change:

> kali-land must not silently become the owner of the user's entire Hyprland configuration.

---

# 27. Shell Startup

Shell startup must be integration-driven.

Do not hardcode:

```text
quickshell
```

into the platform simply because Quickshell is currently used.

The selected integration determines:

```text
runtime
entrypoint
startup command
environment
```

The platform provides the mechanism to launch it.

---

# 28. Desktop Services

Desktop services should be capability-driven.

Examples:

```text
PipeWire
WirePlumber
NetworkManager
Bluetooth
notifications
clipboard
portals
polkit
```

If a service is optional, the absence of that service should not break unrelated components.

Avoid unconditional startup of optional components.

---

# 29. Profiles

Profiles describe environmental conditions.

Examples:

```text
VMware
bare-metal
future virtual machines
future hardware profiles
```

Profiles should expose facts and capabilities.

Avoid making assumptions such as:

```text
VMware = software rendering always
```

unless that is explicitly required and documented.

Prefer:

```text
detect environment
→ determine capabilities
→ apply profile-specific behavior
```

---

# 30. VMware

VMware support must not violate BYOS.

Do not modify:

```text
~/.bashrc
~/.profile
```

just because the user is running VMware unless the user explicitly requests it and the resource is properly protected.

VMware-specific environment variables should be profile-scoped.

Do not apply software rendering globally to bare-metal systems.

---

# 31. User Configuration

Treat unknown user configuration as opaque.

The system does not need to understand every configuration.

It needs to avoid destroying it.

Potential existing resources include:

```text
Hyprland
Waybar
Quickshell
Celestia
Alacritty
Kitty
foot
Neovim
tmux
custom scripts
systemd user services
custom environment variables
custom themes
custom wallpapers
custom keybindings
```

Genericity means coexistence, not universal knowledge.

---

# 32. Defaults

kali-land may provide sensible defaults.

Defaults MUST NOT silently become permanent ownership.

Examples:

```text
terminal
browser
editor
keybindings
theme
wallpaper
```

should be treated as defaults unless explicitly owned by kali-land.

Never overwrite an existing user preference simply because kali-land has a preferred default.

---

# 33. Security

Security is a first-class requirement.

Never:

```bash
curl ... | bash
```

Never execute arbitrary internet-hosted scripts without inspection.

External artifacts should be:

* versioned
* architecture-aware
* checksum verified
* preferably cryptographically signed where practical

Avoid:

```text
latest
master
main
unversioned downloads
unpinned git clones
```

when reproducibility matters.

---

# 34. Reproducibility

A release should be reproducible from explicit versions.

Pin:

```text
runtime versions
source revisions
build dependencies
artifact versions
architecture
```

Do not silently fall back from:

```text
requested version
```

to:

```text
latest
```

A version-specific installation should either:

```text
install the requested version
```

or:

```text
fail clearly / use an equally pinned source fallback
```

Never silently install an unrelated newer version.

---

# 35. Architecture

Never assume x86_64.

Detect architecture explicitly.

Normalize architectures such as:

```text
x86_64 / amd64
aarch64 / arm64
```

Artifacts must match the detected architecture.

If a prebuilt artifact is unavailable:

```text
source-build using a pinned revision
```

or:

```text
fail clearly
```

Do not download an x86_64 binary onto another architecture.

---

# 36. Release Integrity

The canonical release source should be explicit.

A release should contain:

```text
version
architecture
artifact
checksum
source revision
build metadata
```

Where practical, add:

```text
signature
attestation
provenance
```

Checksum verification protects against corruption and mismatched downloads.

It does not by itself prove publisher authenticity.

---

# 37. Installer Architecture

The installer should be organized around explicit phases.

Conceptually:

```text
1. Welcome
2. Detect platform
3. Detect existing environment
4. Select profile
5. Select experience
6. Discover integration
7. Resolve dependencies
8. Generate installation plan
9. Confirm
10. Backup
11. Install platform
12. Install integration
13. Configure
14. Validate
15. Register state
16. Report result
```

The exact implementation may differ.

The principle is:

> **Discovery happens before mutation.**

---

# 38. Installer UX

The installer should feel professional and predictable.

Users should understand:

```text
where they are
what was detected
what is being installed
why it is needed
what will change
what will remain untouched
what failed
how to recover
```

Avoid noisy implementation details unless debug mode is enabled.

Use clear stages and meaningful failure messages.

---

# 39. Dry Run

Dry-run mode must actually prevent mutations.

For example:

```bash
kali-land install --dry-run
```

must not:

* install packages
* modify configuration
* delete resources
* write ownership state
* modify shell startup
* change system services

It should instead show the planned operations.

---

# 40. Failure Handling

If an important phase fails:

```text
do not claim success
preserve backups
record failure
explain affected components
provide recovery
```

The system should be able to distinguish:

```text
success
partial success
failed
rolled back
```

Do not swallow errors merely to make the installer continue.

---

# 41. Diagnostics

`kali-land doctor` should eventually answer:

```text
Is kali-land healthy?
What platform capabilities exist?
What profile is active?
Which integrations are installed?
Which shell is active?
What resources are owned?
What packages were installed by kali-land?
Are required capabilities available?
Are there conflicts?
Are owned resources intact?
```

Doctor must remain generic.

It must not assume:

```text
Quickshell = kali-land
end4-pC = kali-land
```

---

# 42. CLI Design

Prefer predictable commands.

Conceptually:

```bash
kali-land install
kali-land install --platform-only

kali-land shell list
kali-land shell discover <path>
kali-land shell import <path>
kali-land shell install <id>
kali-land shell remove <id>
kali-land shell switch <id>

kali-land doctor

kali-land update

kali-land rollback

kali-land uninstall
```

Do not implement every command immediately.

Build commands as the underlying lifecycle capabilities become real.

---

# 43. Do Not Build a Giant Plugin Framework

Do not prematurely build:

```text
universal plugin marketplace
dynamic plugin API
plugin SDK
remote plugin registry
```

unless real integrations demonstrate the need.

First prove the architecture with:

1. end4-pC
2. another materially different integration
3. a user-imported shell

If those can share the same lifecycle without special-case hacks, the abstraction is probably healthy.

---

# 44. Repository Structure

The actual repository structure is authoritative.

Do not create architectural directories merely because an example structure looks clean.

Before introducing a new subsystem:

```text
inspect existing structure
→ determine whether an existing subsystem owns the responsibility
→ extend it if appropriate
→ introduce a new abstraction only when justified
```

Avoid duplicate implementations of the same lifecycle responsibility.

---

# 45. Configuration Ownership

Every configuration mutation should answer:

```text
Who owns this?
Why are we changing it?
Can we isolate the change?
Was it backed up?
Can it be reverted?
Will uninstall know about it?
```

If these questions cannot be answered:

> Do not mutate the resource.

---

# 46. Testing Strategy

Tests should cover lifecycle behavior, not merely shell syntax.

Minimum scenarios should eventually include:

### Clean system

```text
Kali
→ kali-land
→ selected shell
```

### Existing desktop

```text
Kali
→ existing XFCE/GNOME/KDE configuration
→ kali-land
```

### Existing shell

```text
existing Quickshell configuration
→ kali-land
```

### Multiple shells

```text
shell A
shell B
→ both coexist
```

### User import

```text
custom shell directory
→ discover
→ install
→ launch
→ uninstall
```

### Reinstallation

```text
install
→ install again
```

### Failure

```text
dependency failure
→ recovery
```

### Rollback

```text
install
→ change
→ rollback
```

### Uninstall

```text
kali-land install
→ uninstall
→ user configuration remains intact
```

---

# 47. VMware Testing

VMware is a required development environment.

Test:

```text
clean VMware VM
existing desktop
Wayland
Hyprland
selected shell
software-rendering constraints
open-vm-tools
reinstall
rollback
uninstall
```

VMware-specific behavior must not leak into bare-metal configuration.

---

# 48. Logging

Logs should distinguish:

```text
INFO
WARN
ERROR
DEBUG
```

Errors should identify:

```text
operation
resource
reason
recommended action
```

Do not hide failures behind:

```bash
|| true
```

unless the failure is explicitly optional and the reason is documented.

---

# 49. Source and Artifact Provenance

Every external component should have traceable provenance.

Record where applicable:

```text
source repository
version
commit/tag
artifact URL
checksum
architecture
installation source
```

This is especially important for:

* Quickshell
* Matugen
* Hyprland source builds
* third-party integrations
* imported shell sources

---

# 50. User-Provided Code

A user-provided shell is untrusted input from kali-land's perspective.

Do not execute arbitrary installation scripts merely because they exist in the supplied directory.

Inspect:

```text
manifest
entrypoint
scripts
dependencies
services
permissions
filesystem targets
```

The user explicitly choosing to install their own shell does not justify kali-land blindly executing everything in it.

---

# 51. Updates

Updating an integration should update only that integration.

Updating the platform should not implicitly update unrelated integrations.

Conceptually:

```text
platform update
    ≠
all shell updates
```

and:

```text
shell update
    ≠
platform replacement
```

Respect component boundaries.

---

# 52. Active Shell

The system should maintain an explicit concept of the active experience.

For example:

```text
active integration:
    end4-pC

runtime:
    quickshell
```

Switching shells should not require reinstalling the entire platform.

The platform should remain stable while the experience changes.

---

# 53. Coexistence

Multiple integrations may exist simultaneously.

Example:

```text
kali-land
│
├── end4-pC
├── custom-shell
└── another-shell
```

Only the selected integration should normally be launched.

Installing or removing one integration must not damage another.

---

# 54. No Hidden Global Mutation

Avoid modifying global state merely because it is convenient.

Be especially careful with:

```text
/etc/*
/usr/share/*
~/.bashrc
~/.profile
~/.config/*
systemd user services
environment variables
desktop session files
display manager configuration
```

Global changes must have a clear platform-level justification.

---

# 55. Package Installation

Package installation should be:

```text
detected
→ resolved
→ installed
→ recorded
→ validated
```

Do not reinstall packages unnecessarily.

Do not remove packages simply because an integration no longer needs them unless provenance confirms kali-land owns them and removal is safe.

---

# 56. Documentation

Documentation must describe actual behavior.

Never document:

```text
supports every shell
```

unless that is genuinely true.

Documentation should distinguish:

```text
implemented
planned
experimental
reference integration
```

If implementation changes, update:

```text
README
QUICKSTART
installation documentation
CI/release documentation
AGENT.md
```

as appropriate.

---

# 57. Current Development Priorities

Work in this order unless a concrete issue requires otherwise.

## Priority 0 — Ownership and Safety

Fix:

```text
integration isolation
Hyprland ownership
profile mutations
global rendering assumptions
ownership tracking
uninstall safety
```

## Priority 1 — Installer Architecture

Implement:

```text
platform detection
experience selection
integration discovery
installation plans
dependency resolution
validation
registration
```

## Priority 2 — BYOS

Implement:

```text
shell discovery
runtime detection
custom shell import
isolated installation
ownership tracking
launch registration
rollback
uninstall
```

## Priority 3 — Reproducibility

Fix:

```text
unpinned source builds
latest fallbacks
architecture assumptions
release versioning
artifact verification
```

## Priority 4 — Lifecycle

Unify:

```text
install
update
rollback
uninstall
doctor
backup
restore
```

around the same installation state.

## Priority 5 — More Integrations

Add:

```text
second materially different shell
Celestia or another runtime
additional reference integrations
```

Only after the core lifecycle works correctly.

---

# 58. Architectural Decision Checklist

Before implementing a feature, ask:

### Ownership

```text
Who owns this resource?
```

### Scope

```text
Is this platform behavior or integration behavior?
```

### Compatibility

```text
Does this assume Quickshell?
```

### User safety

```text
Could this overwrite existing user configuration?
```

### Lifecycle

```text
Can install, update, rollback, doctor, and uninstall understand it?
```

### Reproducibility

```text
Is the dependency/version pinned?
```

### Failure

```text
What happens if this operation fails halfway through?
```

### Testing

```text
Can this be tested with an existing user configuration?
```

If the answer is unclear, stop and investigate before coding.

---

# 59. The `rm -rf` Rule

Whenever code approaches:

```bash
rm -rf ~/.config/<something>
```

stop and ask:

```text
1. Who owns this?
2. Did kali-land create it?
3. Did kali-land modify it?
4. Does the entire directory belong to kali-land?
5. Could unrelated user configuration exist inside it?
6. Can the operation be narrowed?
7. Is ownership recorded?
8. Is there a rollback path?
```

If the answer is unclear:

> **Do not perform the destructive operation.**

Prefer isolation.

---

# 60. Definition of Done

A feature is not complete merely because:

```bash
install
```

works once.

The architecture is considered successful when:

### Platform

kali-land can provide its desktop platform without requiring a particular shell.

### Shell selection

The user explicitly chooses their experience.

### Built-in integration

A bundled integration can be installed through the standard lifecycle.

### BYOS

A compatible user-provided shell can be discovered and imported through the same lifecycle.

### Runtime abstraction

The core does not assume Quickshell is the only possible runtime.

### Isolation

Installing one shell does not destroy another.

### Ownership

Every managed resource has clear ownership.

### Lifecycle

Install, update, rollback, doctor, and uninstall understand the same state.

### Reproducibility

External dependencies are versioned and architecture-aware.

### Safety

Existing user configuration remains intact unless the user explicitly chooses otherwise.

### Failure recovery

Failed installations do not falsely report success and leave a recoverable state.

### Coexistence

The system works alongside existing Kali desktop configuration.

---

# 61. Final Engineering Principle

When in doubt, choose the architecture that gives the user more freedom while giving kali-land less unnecessary ownership.

The desired relationship is:

```text
                    USER
                     │
                     ▼
             Choose experience
                     │
        ┌────────────┴────────────┐
        │                         │
   Existing shell           Custom shell
        │                         │
        └────────────┬────────────┘
                     ▼
             SHELL DISCOVERY
                     │
                     ▼
           CAPABILITY + DEPENDENCY
                  RESOLUTION
                     │
                     ▼
              INSTALLATION PLAN
                     │
                     ▼
              KALI-LAND CORE
                     │
       ┌─────────────┼─────────────┐
       │             │             │
    Wayland       Hyprland     Services
       │             │             │
       └─────────────┼─────────────┘
                     ▼
               USER EXPERIENCE
```

The platform should be stable.

The experience should be replaceable.

The user's configuration should remain theirs.

The installer should handle the complexity.

And the lifecycle should always know what it owns.

> **kali-land owns the environment.**
>
> **The user owns the experience.**
>
> **The installer handles the plumbing.**

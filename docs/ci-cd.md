# CI/CD Setup for kali-land

## Overview

kali-land uses GitHub Actions for CI/CD to build and distribute Quickshell and the installer package automatically.

## Workflows

### 1. Quickshell Build Workflow

**File:** `.github/workflows/build-quickshell.yml`

**Triggers:**
- Push to `main` or `master` branches
- Pull requests to `main` or `master` branches
- Release creation

**Process:**
1. Uses GitHub Actions with official Kali Linux container (`kalilinux/kali-rolling:latest`)
2. Installs all Quickshell build dependencies
3. Clones pinned versions of upstream dependencies: `cpptrace` (`v0.7.3`) and `quickshell` (`v0.4.0`)
4. Builds Quickshell with CMake and Ninja (`-DDISTRIBUTOR="kali-land"`)
5. Compiles Matugen (`0.16.0`) with Cargo
6. Generates SHA-256 checksum files (`.sha256`) for both `quickshell` and `matugen` archives
7. Uploads temporary CI artifacts for development pushes (retained 30 days)
8. On git tag/release publication, attaches immutable release binaries and `.sha256` checksum files to the release assets

**Outputs:**
- `quickshell-linux-x86_64.tar.gz`
- `quickshell-linux-x86_64.tar.gz.sha256`
- `matugen-linux-x86_64.tar.gz`
- `matugen-linux-x86_64.tar.gz.sha256`

### 2. Installer Build Workflow

**File:** `.github/workflows/installer.yml`

**Triggers:**
- Push to `main` or `master` branches
- Pull requests to `main` or `master` branches
- Release creation

**Process:**
1. Checks out the repository
2. Creates a compressed archive of the installer files
3. Uploads the artifact (retained for 30 days)
4. On release creation, uploads the artifact to the release

**Output:** `kali-land-installer.tar.gz`

## Installation & Verification Process

The installer script (`bootstrap/install.sh`) uses a 3-tier distribution strategy:

1. **GitHub Release Binary Check**: Checks for pre-built binaries matching `KALI_LAND_VERSION` from GitHub releases
2. **Cryptographic SHA-256 Checksum Verification**: Downloads `.sha256` hash files and verifies integrity using `sha256sum`/`shasum`. If checksum validation fails, rejects the binary.
3. **Automated Source Compilation Fallback**: If remote prebuilt binaries are missing or fail integrity checks, builds Quickshell and dependencies locally from source using CMake and Ninja.

This provides the best of both worlds:
- **Fast installation** when pre-built binaries are available
- **Fallback to source** when needed (custom builds, no release, etc.)

## Release Process

To create a new release:

1. **Tag the commit:**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. **Create GitHub Release:**
   - Go to GitHub → Releases → Create new release
   - Choose the tag you just created
   - Add release notes
   - Publish the release

3. **Automatic builds:**
   - Both workflows will automatically trigger
   - Quickshell will be built and attached to the release
   - Installer package will be attached to the release

## User Installation

Users can install kali-land using the standard installer:

```bash
# Clone the repository
git clone https://github.com/yourusername/kali-land.git
cd kali-land

# Run the installer
sudo ./bootstrap/install.sh
```

The installer will automatically:
- Check for pre-built Quickshell from releases
- Use pre-built binary if available (fast)
- Fall back to building from source if needed

## Benefits

1. **Faster Installation:** Pre-built binaries save users from long compilation times
2. **Consistent Builds:** All users get the same pre-compiled Quickshell
3. **Reduced Requirements:** Users don't need full build toolchain
4. **Faster Development:** CI/CD builds Quickshell automatically on changes
5. **Easy Distribution:** Pre-built packages are attached to releases

## Maintenance & Dependency Management

### Versioning Model

`kali-land` uses a single source of truth for versioning:
- **`VERSION` File**: Located at the repository root (`/VERSION`). `bootstrap/install.sh` dynamically reads this file to determine `KALI_LAND_VERSION` unless overridden via environment variable (`KALI_LAND_VERSION=1.1.0 ./bootstrap/install.sh`).

### Upstream Dependency Pinned Versions

Built-from-source dependencies are pinned inside `.github/workflows/build-quickshell.yml` under `env`:

```yaml
env:
  CPPTRACE_REF: v1.0.4      # Pinned cpptrace version tag (e.g. v1.0.4)
  QUICKSHELL_REF: master    # Pinned version tag (e.g. v0.3.1) or branch (e.g. master)
  MATUGEN_VERSION: 0.16.0   # Pinned matugen version on crates.io
```

### Upstream Dependency & Version Upgrade Guide

When an upstream dependency releases an update, a patch, or a new version:

#### Step 1: Verify Upstream Release
Check the upstream repositories for new stable tags or commit SHAs:
- **Quickshell**: [outfoxxed/quickshell releases](https://github.com/outfoxxed/quickshell/releases)
- **cpptrace**: [jeremy-rifkin/cpptrace releases](https://github.com/jeremy-rifkin/cpptrace/releases)
- **Matugen**: [matugen on crates.io](https://crates.io/crates/matugen)

#### Step 2: Update Pinned Variables in CI
Edit `.github/workflows/build-quickshell.yml` and update the relevant environment variable:
```yaml
env:
  QUICKSHELL_REF: v0.5.0   # Updated tag or commit SHA
```

#### Step 3: Bump Project Version (If Applicable)
If the dependency bump constitutes a new `kali-land` release:
1. Update the root `VERSION` file:
   ```bash
   echo "1.1.0" > VERSION
   ```
2. Commit the changes:
   ```bash
   git add VERSION .github/workflows/build-quickshell.yml
   git commit -m "chore(deps): update Quickshell to v0.5.0 and bump version to 1.1.0"
   git push origin main
   ```

#### Step 4: Re-Trigger Release CI Build & Asset Distribution
Tag and push the new release version (or force-push to update existing release assets):
```bash
# For new version:
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0

# To re-build and overwrite assets for current version (e.g. v1.0.0):
git tag -f -a v1.0.0 -m "Release v1.0.0 (updated binaries)"
git push origin -f v1.0.0
```

GitHub Actions will automatically run the container build, compile updated binaries, compute SHA-256 checksums, and attach the updated assets to the release.

---

## Troubleshooting

### Build Failures

If the Quickshell build fails in CI/CD:
1. Check the Actions tab in GitHub
2. Review the build logs
3. Update build dependencies in `.github/workflows/build-quickshell.yml` if new Qt/system libs are required
4. Verify upstream commit/tag compatibility

### Checksum Verification Failures

If `install.sh` rejects a prebuilt binary with a SHA-256 mismatch:
1. Ensure both `.tar.gz` and `.tar.gz.sha256` were uploaded cleanly by CI.
2. Run `sha256sum /tmp/quickshell.tar.gz` manually to inspect hash output.
3. Re-trigger CI tag build if release assets were partially uploaded or corrupted.
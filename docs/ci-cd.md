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

## Maintenance

### Dependencies

The CI/CD workflows require no additional dependencies beyond standard GitHub Actions.

### Secrets

No secrets are required for the basic workflows. The GitHub token is automatically provided by GitHub Actions.

### Updates

To update the workflows:
1. Edit the workflow files in `.github/workflows/`
2. Commit and push changes
3. Workflows will automatically update on next push

## Troubleshooting

### Build Failures

If the Quickshell build fails in CI/CD:
1. Check the Actions tab in GitHub
2. Review the build logs
3. Update build dependencies if needed
4. Check for Quickshell repository changes

### Artifact Issues

If artifacts aren't uploaded:
1. Check workflow permissions in repository settings
2. Ensure GitHub Actions has write permissions
3. Verify token has proper scopes

### Installation Issues

If users can't download pre-built binaries:
1. Check that releases are published
2. Verify artifact names match expected patterns
3. Check download URLs in install script
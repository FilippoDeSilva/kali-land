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
3. Clones the official Quickshell repository (with recursive submodules for `cpptrace`)
4. Builds Quickshell with cmake and ninja
5. Creates a tar.gz package with the Quickshell binary
6. Uploads the artifact (retained for 30 days)
7. On release creation, uploads the artifact to the release

**Output:** `quickshell-linux-x86_64.tar.gz`

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

## Installation Process

The installer script (`bootstrap/install.sh`) has been updated to:

1. **First**, check for pre-built Quickshell from GitHub releases
2. **If found**, download and install the pre-built binary (much faster)
3. **If not found**, fall back to building from source (original behavior)

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
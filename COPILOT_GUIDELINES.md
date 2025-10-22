# Copilot AI Guidelines for GitHub Actions Runner Add-on

## Overview

This document provides comprehensive guidelines for contributors and users working with the GitHub Actions Runner Home Assistant Add-on. It covers setup, configuration, troubleshooting, and best practices for working with Home Assistant, Docker, GitHub Runner integration, and versioning.

---

## Table of Contents

1. [Home Assistant Integration](#home-assistant-integration)
2. [Docker Container Management](#docker-container-management)
3. [GitHub Runner Configuration](#github-runner-configuration)
4. [Versioning and Release Management](#versioning-and-release-management)
5. [Using Copilot AI with This Repository](#using-copilot-ai-with-this-repository)
6. [Troubleshooting Guide](#troubleshooting-guide)

---

## Home Assistant Integration

### Understanding Home Assistant Add-ons

Home Assistant add-ons are Docker containers that extend Home Assistant functionality. This add-on specifically provides a self-hosted GitHub Actions runner.

### Setup Steps

#### 1. Add the Repository

Add this repository to your Home Assistant add-on store:
1. Navigate to **Supervisor** → **Add-on Store** → **⋮** (three dots) → **Repositories**
2. Add the repository URL: `https://github.com/skille/home-assistant-github-runner-add-on`
3. Refresh the add-on store

#### 2. Install the Add-on

1. Find "GitHub Actions Runner" in the add-on store
2. Click **Install**
3. Wait for installation to complete

#### 3. Configure the Add-on

The add-on requires two essential configuration parameters:

```yaml
repo_url: "https://github.com/yourusername/yourrepo"
runner_token: "YOUR_RUNNER_TOKEN_HERE"
debug_logging: false
```

**Configuration Parameters:**

- `repo_url` (required): Full GitHub repository or organization URL
  - Repository: `https://github.com/username/repo`
  - Organization: `https://github.com/organization`
- `runner_token` (required): Registration token from GitHub (valid for 1 hour)
- `debug_logging` (optional): Enable verbose logging for troubleshooting

#### 4. Start the Add-on

1. Navigate to the **Info** tab
2. Enable "Start on boot" if desired
3. Click **Start**
4. Monitor the logs for successful registration

### Home Assistant Configuration Files

- **config.yaml**: Defines add-on metadata, schema, and default options
- **build.yaml**: Specifies base Docker images for each architecture
- **repository.yaml**: Repository-level metadata for the add-on store

### Configuration Best Practices

1. **Token Security**: Never commit runner tokens to version control
2. **URL Format**: Always use full HTTPS URLs (e.g., `https://github.com/user/repo`)
3. **Startup Mode**: Set `boot: auto` for production, `manual` for testing
4. **Resource Allocation**: Monitor Home Assistant resource usage when running workflows
5. **Network Access**: The runner has access to your local network by default

### Reading Configuration in Add-ons

The add-on reads configuration from `/data/options.json`:

```bash
CONFIG_FILE="/data/options.json"
REPO_URL=$(jq -r '.repo_url // empty' "$CONFIG_FILE")
RUNNER_TOKEN=$(jq -r '.runner_token // empty' "$CONFIG_FILE")
```

This approach avoids API permission issues and provides direct access to user-configured values.

---

## Docker Container Management

### Architecture Support

This add-on supports multiple architectures:
- `amd64` (x86-64)
- `aarch64` (ARM 64-bit)
- `armv7` (ARM 32-bit v7)
- `armhf` (ARM hard-float)
- `i386` (x86 32-bit)

### Dockerfile Structure

The Dockerfile follows Home Assistant best practices:

```dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM

# Debian-based container with minimal dependencies
# Uses non-root user for security
# Includes .NET Core dependencies via GitHub Actions runner's installdependencies.sh
```

### Key Dependencies

The add-on installs these base packages via apt-get:

- **Runtime**: bash, curl, git, jq, tar, sudo, ca-certificates
- **.NET Core Dependencies**: Automatically installed by GitHub Actions runner's `./bin/installdependencies.sh` script
- **Purpose**: GitHub Actions runner requires .NET Core runtime and supporting libraries

The runner's `installdependencies.sh` script automatically installs all required .NET Core dependencies for Debian-based systems, including:
- libkrb5-3, zlib1g (Kerberos and compression libraries)
- liblttng-ust1 or liblttng-ust0 (Linux Trace Toolkit)
- libicu (International Components for Unicode)
- Other platform-specific dependencies

### Security: Non-Root Execution

The runner executes as a dedicated non-root user:

```bash
# Create runner user with UID 1000
RUN adduser -D -u 1000 runner

# Set ownership
RUN chown -R runner:runner /runner

# Execute commands as runner user
su runner -c "./config.sh ..."
su runner -c "./run.sh"
```

**Why Non-Root?**
- GitHub Actions runner displays warnings when run as root
- Reduces security risk by limiting container privileges
- Follows least-privilege principle

### Container Lifecycle

1. **Initialization**: Container starts, dependencies are verified
2. **Configuration**: Runner registers with GitHub using token
3. **Execution**: Runner processes workflow jobs
4. **Cleanup**: On shutdown, runner automatically unregisters (trap EXIT)

### Volume Management

Home Assistant automatically mounts:
- `/data`: Persistent storage for add-on data
- Configuration is read from `/data/options.json`

### Building Multi-Architecture Images

The add-on uses Home Assistant's build system:

```yaml
# build.yaml
build_from:
  aarch64: "ghcr.io/home-assistant/aarch64-base-debian:bookworm"
  amd64: "ghcr.io/home-assistant/amd64-base-debian:bookworm"
  # ... other architectures
```

Architecture mapping for GitHub Actions runner:
- amd64 → x64
- aarch64 → arm64
- armv7/armhf → arm

### Docker Best Practices for This Add-on

1. **Use Official Base Images**: Always use `ghcr.io/home-assistant/*-base-debian` images
2. **Pin Versions**: Specify exact versions (e.g., `bookworm`) for reproducibility
3. **Layer Optimization**: Combine RUN commands to reduce image layers
4. **Dependency Installation**: Run `./bin/installdependencies.sh` to ensure all .NET dependencies are installed (requires sudo/root)
5. **Cleanup**: Remove temporary files and caches to minimize image size

### Debugging Container Issues

Enable debug logging to inspect:
- Debian/Ubuntu OS version
- Installed dependency packages
- Runner directory contents and permissions
- Runner version and configuration

```yaml
debug_logging: true
```

This enables `set -x` in the run script and outputs detailed diagnostic information.

---

## GitHub Runner Configuration

### Obtaining Runner Tokens

#### Repository Runners

1. Navigate to: `https://github.com/username/repo/settings/actions/runners`
2. Click **New self-hosted runner**
3. Copy the token from the configuration command
4. Token format: `A...` (starts with 'A', approximately 29 characters)
5. **Expires**: 1 hour from generation

#### Organization Runners

1. Navigate to: `https://github.com/organizations/org-name/settings/actions/runners`
2. Click **New runner**
3. Copy the token from the configuration command
4. Same expiration: 1 hour

### Runner Configuration Process

The runner configuration happens automatically:

```bash
./config.sh --url "${REPO_URL}" --token "${RUNNER_TOKEN}" --unattended --replace
```

**Flags Explained:**
- `--url`: GitHub repository or organization URL
- `--token`: Registration token
- `--unattended`: Non-interactive mode (no user prompts)
- `--replace`: Replace existing runner with same name

### Runner Labels and Tags

The runner automatically receives these labels:
- `self-hosted`: Indicates it's a self-hosted runner
- Architecture label: `Linux`, `ARM64`, `X64`, etc.
- OS label: Based on Debian Linux

To use this runner in workflows:

```yaml
jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running on self-hosted runner"
```

### Security Best Practices

#### Token Management

1. **Never Commit Tokens**: Tokens are secrets and must not be in version control
2. **Regenerate Regularly**: Generate new tokens when reconfiguring
3. **Single Use**: Each token should only be used once
4. **Secure Storage**: Store tokens in Home Assistant configuration securely

#### Runner Security

1. **Network Isolation**: Consider network segmentation if running untrusted workflows
2. **Resource Limits**: Monitor CPU/memory usage to prevent DoS
3. **Code Review**: Review workflow YAML files before running
4. **Secrets Management**: Use GitHub encrypted secrets, not hardcoded values
5. **Update Regularly**: Keep the add-on updated for security patches

#### Workflow Security

```yaml
# Good: Use specific versions
- uses: actions/checkout@v4

# Bad: Using @master can introduce breaking changes or vulnerabilities
- uses: actions/checkout@master
```

### Maintenance and Monitoring

#### Health Checks

Monitor runner status:
1. Check GitHub UI: Repository → Settings → Actions → Runners
2. Review Home Assistant add-on logs
3. Enable debug logging for detailed diagnostics

#### Log Analysis

Key log entries to watch:
- "Starting GitHub Actions Runner..." - Initialization
- "Configuring GitHub Actions Runner..." - Registration phase
- "Starting runner..." - Execution phase
- Any error messages related to token, URL, or connectivity

#### Automatic Cleanup

The add-on includes automatic cleanup:

```bash
cleanup() {
    bashio::log.info "Removing runner..."
    su runner -c "./config.sh remove --token \"${RUNNER_TOKEN}\""
}
trap cleanup EXIT
```

This ensures the runner unregisters from GitHub when the add-on stops, preventing "offline" runners from cluttering your GitHub interface.

### Runner Limitations

1. **Token Expiry**: Registration tokens expire after 1 hour
2. **Single Instance**: Each add-on instance runs one runner
3. **Resource Sharing**: Shares resources with Home Assistant host
4. **Network Access**: Has access to host network (within container boundaries)

### Advanced Configuration

#### Running Multiple Runners

To run multiple runners:
1. Install the add-on multiple times (not natively supported)
2. Use different repository URLs or tokens
3. Consider resource implications

**Note**: Home Assistant may not support multiple instances of the same add-on. Consider using separate machines or VMs for multiple runners.

#### Organization vs. Repository Runners

**Repository Runners:**
- Scoped to a single repository
- Simpler to configure
- Better for single-project automation

**Organization Runners:**
- Available to all repositories in the organization
- Centralized management
- Better for multi-project automation

#### Workflow Job Assignment

Workflows can target specific runners using labels:

```yaml
jobs:
  build:
    runs-on: [self-hosted, linux, x64]
```

The runner automatically gets appropriate labels based on its environment.

---

## Versioning and Release Management

### Semantic Versioning

This project follows [Semantic Versioning](https://semver.org/):

**Version Format**: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (incompatible API changes)
- **MINOR**: New features (backward-compatible functionality)
- **PATCH**: Bug fixes (backward-compatible fixes)

### Current Version

Version is defined in `config.yaml`:

```yaml
name: GitHub Actions Runner
version: "1.0.3"
```

### Release Process

#### 1. Update Version Number

Edit `config.yaml`:

```yaml
version: "1.0.4"  # Increment appropriately
```

#### 2. Update CHANGELOG.md

Follow Keep a Changelog format:

```markdown
## [1.0.4] - YYYY-MM-DD

### Added
- New feature description

### Fixed
- Bug fix description

### Changed
- Change description
```

#### 3. Create Git Tag

```bash
git tag -a v1.0.4 -m "Release version 1.0.4"
git push origin v1.0.4
```

#### 4. Create GitHub Release

1. Navigate to GitHub → Releases → Draft a new release
2. Select the tag created above
3. Add release notes (can copy from CHANGELOG.md)
4. Publish release

### Version Number Guidelines

**When to Increment MAJOR (X.0.0):**
- Breaking configuration changes
- Incompatible add-on API changes
- Major architectural changes

**When to Increment MINOR (1.X.0):**
- New configuration options
- New features (e.g., debug logging was added in 1.0.3)
- Backward-compatible enhancements

**When to Increment PATCH (1.0.X):**
- Bug fixes
- Security patches
- Documentation updates
- Dependency updates (without feature changes)

### CHANGELOG Best Practices

Structure entries by type:
- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerabilities

Example:

```markdown
## [1.0.3] - 2025-10-22

### Fixed
- Fixed Dotnet Core 6.0 Libicu dependency errors by installing icu-data-full package
- Fixed symbol not found errors in libcoreclr.so by running installdependencies.sh

### Added
- New configuration option `debug_logging` for troubleshooting
- Enhanced logging with OS version and package information
```

### Git Workflow

#### Feature Development

```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes, commit
git add .
git commit -m "Add new feature"

# Push to remote
git push origin feature/new-feature

# Create pull request on GitHub
```

#### Bug Fixes

```bash
# Create bugfix branch
git checkout -b fix/bug-description

# Make changes, commit
git add .
git commit -m "Fix bug description"

# Push and create PR
git push origin fix/bug-description
```

#### Hotfix Process

For urgent production fixes:

```bash
# Create hotfix from main
git checkout main
git checkout -b hotfix/critical-fix

# Make fix, increment PATCH version
# Update CHANGELOG.md

# Commit and tag
git commit -am "Hotfix: critical fix description"
git tag -a v1.0.4 -m "Hotfix release 1.0.4"

# Merge back to main
git checkout main
git merge hotfix/critical-fix
git push origin main --tags
```

### Testing Before Release

1. **Build Test**: Verify Docker image builds for all architectures
2. **Installation Test**: Install add-on in Home Assistant test instance
3. **Functionality Test**: Register runner and execute test workflow
4. **Upgrade Test**: Test upgrade from previous version
5. **Documentation Review**: Ensure README and DOCS are current

### Release Checklist

- [ ] Version incremented in `config.yaml`
- [ ] CHANGELOG.md updated with changes
- [ ] README.md reflects new features (if applicable)
- [ ] DOCS.md updated (if configuration changed)
- [ ] All tests passing
- [ ] Git tag created
- [ ] GitHub release published
- [ ] Add-on tested in Home Assistant

---

## Using Copilot AI with This Repository

### Repository Structure Understanding

When using Copilot AI to work on this repository, it should understand:

**Core Files:**
- `config.yaml`: Add-on configuration and schema
- `Dockerfile`: Container build instructions
- `run.sh`: Main execution script (uses bashio for logging)
- `README.md`: User-facing documentation
- `DOCS.md`: Detailed configuration guide
- `CHANGELOG.md`: Version history

**Key Technologies:**
- Home Assistant Add-on framework
- Docker/Debian Linux
- GitHub Actions Runner (requires .NET Core)
- Bash scripting with bashio library

### Common Development Tasks

#### Adding a New Configuration Option

1. **Update config.yaml schema:**
   ```yaml
   options:
     new_option: "default_value"
   schema:
     new_option: str
   ```

2. **Read in run.sh:**
   ```bash
   NEW_OPTION=$(jq -r '.new_option // "default"' "$CONFIG_FILE")
   ```

3. **Update DOCS.md** with option description and usage

4. **Update README.md** if user-facing

#### Fixing Dependency Issues

When fixing .NET Core or Debian package issues:

1. Identify missing library from error messages
2. Find Debian package: `apt-cache search <package>` or `apt-file search <library>`
3. Add to Dockerfile RUN command using `apt-get install`
4. Test build for all architectures
5. Document in CHANGELOG.md

Note: The GitHub Actions runner's `installdependencies.sh` script automatically handles .NET Core dependencies on Debian-based systems.

#### Improving Logging

Use bashio logging functions:
```bash
bashio::log.info "Information message"
bashio::log.warning "Warning message"
bashio::log.error "Error message"
bashio::log.fatal "Fatal error, exiting"
```

### Copilot Prompts and Examples

#### Prompt: "Add timeout configuration"

Expected workflow:
1. Add `timeout` field to config.yaml
2. Read value in run.sh
3. Apply timeout to runner execution
4. Document in DOCS.md
5. Update version and CHANGELOG.md

#### Prompt: "Improve error handling"

Expected approach:
1. Identify critical failure points
2. Add validation and error messages
3. Use bashio::log.error or bashio::log.fatal
4. Ensure proper cleanup on failure
5. Test edge cases

#### Prompt: "Add support for runner labels"

Expected implementation:
1. Add `runner_labels` array to config.yaml
2. Parse labels in run.sh
3. Pass to config.sh with `--labels` flag
4. Document usage in DOCS.md
5. Add example to README.md

### Code Style Guidelines

#### Bash Scripts

- Use `#!/usr/bin/env bashio` shebang for Home Assistant scripts
- Enable error checking: `set -e`
- Use double quotes for variables: `"${VARIABLE}"`
- Use bashio logging functions
- Add comments for complex logic

#### Docker

- Use ARG for build-time variables
- Combine RUN commands to reduce layers
- Clean up in the same layer (rm tarballs)
- Always specify package versions when possible
- Use `SHELL ["/bin/bash", "-o", "pipefail", "-c"]` for safety

#### Documentation

- Use markdown formatting
- Include code examples
- Provide both repository and organization examples
- Keep README.md concise, details in DOCS.md
- Update CHANGELOG.md with every release

### AI-Assisted Testing Recommendations

When using Copilot AI for testing:

1. **Build Validation**: Test Docker build for each architecture
2. **Configuration Validation**: Test with various config combinations
3. **Error Cases**: Test token expiry, network issues, invalid URLs
4. **Security**: Review for hardcoded secrets or credentials
5. **Documentation**: Verify examples work as documented

### Common Pitfalls to Avoid

1. **Don't use Supervisor API**: Read `/data/options.json` directly
2. **Don't run as root**: Always use the `runner` user
3. **Don't forget installdependencies.sh**: Required for .NET Core
4. **Don't hardcode architectures**: Use BUILD_ARCH variable
5. **Don't skip cleanup**: Always include trap EXIT for cleanup
6. **Don't forget token expiry**: Tokens are valid for only 1 hour

### AI Code Review Checklist

When reviewing AI-generated code:

- [ ] Configuration read from `/data/options.json` correctly
- [ ] Non-root user execution maintained
- [ ] Proper error handling with bashio logging
- [ ] Cleanup trap in place
- [ ] Documentation updated (README, DOCS, CHANGELOG)
- [ ] Version incremented appropriately
- [ ] No hardcoded secrets or tokens
- [ ] Multi-architecture support maintained
- [ ] Backward compatibility considered

---

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue: Runner Token Expired

**Symptoms:**
- Error message: "Token expired" or "Invalid token"
- Runner fails to register

**Solution:**
1. Generate a new token from GitHub (Settings → Actions → Runners)
2. Update add-on configuration with new token
3. Restart the add-on
4. Token is valid for 1 hour, so configure and start promptly

#### Issue: Runner Shows as Offline

**Symptoms:**
- Runner appears offline in GitHub
- Add-on is running but not processing jobs

**Solution:**
1. Check add-on logs for errors
2. Verify network connectivity
3. Restart the add-on
4. Regenerate runner token and reconfigure

#### Issue: .NET Core Dependency Errors

**Symptoms:**
- Error: "Libicu not found"
- Error: "Symbol not found: __isnan, __isnanf"
- Error: "Can't detect current OS type based on /etc/os-release"
- Error: "Can't install dotnet core dependencies"
- Runner fails to start

**Solution:**
1. Ensure the add-on is using Debian-based images (version 1.0.4+)
2. Verify `./bin/installdependencies.sh` runs successfully in Dockerfile
3. Enable debug logging to see installed packages
4. Check that the runner downloads and extracts correctly

**Prevention:**
Version 1.0.4+ uses Debian-based images which are officially supported by GitHub Actions runner. The `installdependencies.sh` script automatically installs all required .NET Core dependencies.

#### Issue: Permission Denied Errors

**Symptoms:**
- Error: "Permission denied" when accessing /runner
- Runner fails to configure or start

**Solution:**
1. Verify runner user owns /runner directory
2. Check `chown -R runner:runner /runner` in Dockerfile and run.sh
3. Ensure commands run as `su runner -c "command"`

#### Issue: API Forbidden Errors

**Symptoms:**
- Error: "403 Forbidden" when reading configuration
- Add-on fails to start

**Solution:**
Configuration should be read from `/data/options.json`, not via Supervisor API:

```bash
CONFIG_FILE="/data/options.json"
REPO_URL=$(jq -r '.repo_url // empty' "$CONFIG_FILE")
```

This approach avoids API permission issues (fixed in version 1.0.1+).

#### Issue: Must Not Run with Sudo Warning

**Symptoms:**
- Warning: "Must not run with sudo"
- Runner starts but displays warning

**Solution:**
Execute runner as non-root user (fixed in version 1.0.2+):

```bash
su runner -c "./run.sh"
```

#### Issue: Workflow Not Running on Self-Hosted Runner

**Symptoms:**
- Workflow runs on GitHub-hosted runners instead
- Self-hosted runner is online but idle

**Solution:**
1. Verify workflow uses `runs-on: self-hosted`:
   ```yaml
   jobs:
     build:
       runs-on: self-hosted
   ```
2. Check runner labels match workflow requirements
3. Ensure runner is online in GitHub UI
4. Check for runner busy with other jobs

### Debug Mode

Enable comprehensive debugging:

```yaml
debug_logging: true
```

This provides:
- Operating system version (Debian)
- Installed dependency packages
- Runner directory contents and permissions
- Runner version and configuration details
- Detailed command execution traces (`set -x`)

### Log Analysis

Key log sections to examine:

**Startup:**
```
Starting GitHub Actions Runner...
Repository URL: https://github.com/user/repo
Configuring GitHub Actions Runner...
```

**Registration:**
```
Connected to GitHub
Runner registration successful
Starting runner...
```

**Error Indicators:**
```
fatal: repo_url is required!
error: Token expired
warning: Must not run with sudo
```

### Getting Help

1. **Enable Debug Logging**: Set `debug_logging: true` and restart
2. **Check Logs**: Review full add-on logs
3. **Verify Configuration**: Ensure repo_url and token are correct
4. **GitHub Status**: Check runner status in GitHub UI
5. **Open Issue**: If problem persists, open an issue on GitHub with:
   - Add-on version
   - Home Assistant version
   - Architecture (amd64, aarch64, etc.)
   - Debug logs (sanitize tokens!)
   - Steps to reproduce

### Performance Optimization

#### Reducing Resource Usage

1. **Limit Concurrent Jobs**: Configure repository settings to limit parallel workflows
2. **Use Lightweight Workflows**: Minimize dependencies and build steps
3. **Monitor Resources**: Watch Home Assistant system metrics
4. **Schedule Jobs**: Run resource-intensive workflows during off-peak hours

#### Improving Runner Performance

1. **Keep Updated**: Use latest add-on version for performance improvements
2. **Clean Workflows**: Remove unnecessary steps and dependencies
3. **Cache Dependencies**: Use actions/cache for faster builds
4. **Local Network**: Leverage local network resources when possible

### Security Hardening

1. **Network Segmentation**: Consider isolating runner network if running untrusted workflows
2. **Minimal Permissions**: Only grant necessary GitHub repository permissions
3. **Regular Updates**: Keep add-on and Home Assistant updated
4. **Token Rotation**: Regenerate runner tokens regularly
5. **Audit Workflows**: Review and approve workflow changes before running

---

## Conclusion

This guide provides comprehensive instructions for working with the GitHub Actions Runner Home Assistant Add-on. By following these guidelines, contributors and users can effectively:

- Set up and configure the add-on in Home Assistant
- Understand Docker container architecture and management
- Configure and secure GitHub Actions runners
- Follow proper versioning and release practices
- Leverage Copilot AI for development tasks
- Troubleshoot common issues efficiently

For additional support, refer to:
- [README.md](README.md) - Quick start guide
- [DOCS.md](DOCS.md) - Detailed configuration reference
- [CHANGELOG.md](CHANGELOG.md) - Version history and changes
- [GitHub Issues](https://github.com/skille/home-assistant-github-runner-add-on/issues) - Report bugs or request features

Keep this document updated as the project evolves to ensure it remains a valuable resource for all contributors and users.

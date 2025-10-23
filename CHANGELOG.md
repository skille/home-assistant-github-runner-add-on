# Changelog

## [1.0.9] - 2025-10-23

### Fixed
- Fixed Docker build failure caused by PEP 668 restriction on pip installs in Debian Bookworm
- Replaced `pip3 install flask==3.0.0` with `python3-flask` from Debian repository to comply with externally-managed environment policy

### Changed
- Flask installation now uses `apt-get install python3-flask` (version 2.2.2) instead of pip
- Consolidated Flask installation into main dependencies RUN command, reducing Docker layers

### Notes
- PEP 668 in Debian Bookworm prevents global pip installs to protect system Python installations
- Flask 2.2.2 from Debian repositories is fully compatible with the web UI features
- Follows Docker and Python packaging best practices for system-wide packages

## [1.0.8] - 2025-10-22

### Added
- Web UI interface with Ingress support for managing the runner
- "Unregister GitHub Runner" button in the web interface
- Visual runner status indicator showing if the runner is configured
- API endpoints for runner status check and unregistration
- Flask-based web server for the UI backend

### Changed
- Added Python 3 and Flask dependencies to the Docker image
- Updated run.sh to start the web UI server alongside the runner
- Enhanced documentation with Web UI usage instructions

### Notes
- Web UI is accessible via "OPEN WEB UI" button in Home Assistant add-on page
- Manual unregistration requires restarting the add-on with a new token to re-register

## [1.0.7] - 2025-10-22

### Added
- Added URL format validation in run.sh to detect incorrect repository URLs
- Added token length validation to catch obviously invalid tokens
- Added proactive informational messages about token expiration (1-hour validity)
- Added comprehensive error handling for runner registration failures with actionable troubleshooting steps
- Added detailed troubleshooting section in README.md for 404 errors during registration
- Added expanded troubleshooting documentation in DOCS.md with specific 404 error guidance

### Improved
- Enhanced error messages to clearly explain common causes of registration failures
- Improved documentation to distinguish between registration tokens and Personal Access Tokens (PATs)
- Added token length to debug logging output for better diagnostics
- Enhanced configuration documentation with explicit notes about token expiration and format

## [1.0.6] - 2025-10-22

### Added
- Mandatory version bump enforcement for all commits to main branch
- GitHub Actions workflow (`version-bump-check.yml`) to automatically verify version bumps on PRs
- CONTRIBUTING.md with comprehensive contribution guidelines and version bump requirements
- Enhanced documentation in COPILOT_GUIDELINES.md with critical version bump policy
- Automated CI check that fails PRs without proper version bumps

### Changed
- Updated README.md to include contribution guidelines and version bump requirements
- Updated COPILOT_GUIDELINES.md with mandatory version bump enforcement details
- Enhanced release checklist to emphasize version bump requirement

### Documentation
- All PRs to main must now bump version in config.yaml to be greater than current main version
- Version bumps follow semantic versioning (MAJOR.MINOR.PATCH)
- Automated enforcement prevents merges without proper version updates

## [1.0.5] - 2025-10-22

### Fixed
- Fixed Docker build failure caused by Alpine Linux incompatibility with GitHub Actions runner
- Switched from Alpine Linux base images to Debian (bookworm) base images for better .NET Core support
- Resolved "Can't detect current OS type based on /etc/os-release" error
- Resolved "Can't install dotnet core dependencies" error

### Changed
- Updated base images from `ghcr.io/home-assistant/*-base:3.19` (Alpine) to `ghcr.io/home-assistant/*-base-debian:bookworm`
- Changed package manager from `apk` to `apt-get` for Debian compatibility
- Updated debug logging to show Debian OS information instead of Alpine version
- Removed Alpine-specific packages (gcompat, icu-libs, icu-data-full, etc.) as they are no longer needed
- The `./bin/installdependencies.sh` script now successfully installs all required .NET Core dependencies

### Notes
- GitHub Actions runner officially supports Debian/Ubuntu-based systems but not Alpine Linux
- Image size will be slightly larger (~100MB vs ~5MB base) but with improved compatibility
- All architectures (amd64, aarch64, armhf, armv7, i386) are still supported

## [1.0.3] - 2025-10-22

### Fixed
- Fixed Dotnet Core 6.0 Libicu dependency errors by installing icu-data-full package
- Fixed symbol not found errors (__isnan, __isnanf) in libcoreclr.so by running installdependencies.sh during Docker build
- Added lttng-ust package for .NET Core runtime tracing support

### Added
- New configuration option `debug_logging` to enable verbose/debug output for troubleshooting
- Debug mode displays Alpine version, installed packages, runner directory contents, and runner version
- Enhanced logging to help diagnose dependency and startup issues

## [1.0.2] - 2025-10-22

### Fixed
- Fixed "Must not run with sudo" warning by creating and using a non-root user for running the GitHub Actions runner
- Runner now executes as a dedicated 'runner' user instead of root for improved security
- Set proper file ownership for runner directory to ensure non-root user can access files

## [1.0.1] - 2025-10-22

### Fixed
- Fixed API forbidden errors by reading configuration directly from /data/options.json instead of using Supervisor API
- Resolved issue where repo_url and runner_token variables were not accessible
- Add-on now starts successfully without requiring auth_api permissions

## [1.0.0] - 2024-10-22

### Added
- Initial release of GitHub Actions Runner add-on
- Support for repository and organization-level runners
- Configuration options for repo_url and runner_token
- Automatic runner registration and cleanup
- Multi-architecture support (amd64, aarch64, armhf, armv7, i386)

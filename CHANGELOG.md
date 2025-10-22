# Changelog

## [1.0.4] - 2025-10-22

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

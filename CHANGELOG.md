# Changelog

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

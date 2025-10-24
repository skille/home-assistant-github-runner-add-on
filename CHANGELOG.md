# Changelog

## [1.5.2] - 2025-10-24
- Added Node.js and npm to support GitHub Actions composite actions (fixes setup-terraform and similar actions)

## [1.5.1] - 2025-10-24
- Added unzip utility to support Terraform setup and other workflows requiring archive extraction

## [1.5.0] - 2025-10-23
- Added Python3, pip, and python3-venv to runner environment to support Python-based workflows

## [1.4.0] - 2025-10-23
- Added configurable runner labels via `runner_labels` option
- Custom labels replace default labels when specified

## [1.3.0] - 2025-10-23
- Added graceful shutdown handling to prevent job dispatch to unavailable runners

## [1.2.1] - 2025-10-23
- Fixed logging timestamp offset to match host system time
- Added runner name display in logs

## [1.2.0] - 2025-10-23
- Added automatic runner configuration persistence across restarts
- Added auto-recovery if runner is deleted from GitHub portal
- Fixed issue with expired tokens on restart

## [1.1.0] - 2025-10-23
- Removed Web UI feature and Flask dependencies

## [1.0.9] - 2025-10-23
- Fixed Docker build failure with PEP 668 restriction

## [1.0.8] - 2025-10-22
- Added Web UI with runner management interface

## [1.0.7] - 2025-10-22
- Added URL and token validation with improved error messages

## [1.0.6] - 2025-10-22
- Added mandatory version bump enforcement for PRs

## [1.0.5] - 2025-10-22
- Fixed Docker build by switching from Alpine to Debian base images

## [1.0.3] - 2025-10-22
- Fixed Dotnet Core 6.0 Libicu dependency errors
- Added `debug_logging` configuration option

## [1.0.2] - 2025-10-22
- Fixed "Must not run with sudo" warning by using non-root user

## [1.0.1] - 2025-10-22
- Fixed API forbidden errors

## [1.0.0] - 2024-10-22
- Initial release

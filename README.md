# GitHub Actions Runner Add-on for Home Assistant

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]

Run a self-hosted GitHub Actions runner directly within your Home Assistant installation.

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "GitHub Actions Runner" add-on
3. Configure the add-on (see below)
4. Start the add-on

**Note:** This add-on uses [GitHub Releases][releases] for versioning. Each version corresponds to a release tag (e.g., `v1.4.0`). Home Assistant will automatically detect and offer updates when new releases are published.

## Configuration

### Required Options

**`repo_url`** - The URL of your GitHub repository or organization
- Repository: `https://github.com/username/repo`
- Organization: `https://github.com/organization`

**`runner_token`** - Registration token from GitHub
- Get it from: Repository/Organization → Settings → Actions → Runners → New self-hosted runner
- Valid for 1 hour after generation
- Only needed for initial setup (configuration persists across restarts)

### Optional Options

**`runner_name`** - Custom name for your runner (default: auto-generated)

**`runner_labels`** - Comma-separated custom labels (default: `self-hosted,Linux,X64`)
- Example: `"production,fast"`
- Note: Custom labels replace defaults; include defaults explicitly if needed

**`debug_logging`** - Enable verbose logging (default: `false`)

### Example Configuration

```yaml
repo_url: "https://github.com/username/repo"
runner_token: "YOUR_RUNNER_TOKEN_HERE"
runner_name: "my-home-assistant-runner"
runner_labels: "self-hosted,Linux,X64,production"
debug_logging: false
```

## Features

- ✅ Persistent configuration across restarts (no token re-entry needed)
- ✅ Auto-recovery if runner is deleted from GitHub
- ✅ Graceful shutdown handling
- ✅ Multi-architecture support (amd64, aarch64, armhf, armv7, i386)
- ✅ Configurable runner labels

## Troubleshooting

**404 Error During Registration**
- Most common: Token expired (valid for 1 hour) → Generate a new token
- Check URL format: `https://github.com/owner/repo` (no trailing slash)
- Verify you have admin permissions on the repository/organization
- Don't use Personal Access Tokens (PATs); use the registration token from "New self-hosted runner" page

## Support

Got questions or issues? Please open an issue on the [GitHub repository][github].

## Contributing

This is an active open-source project. We welcome contributions!

**Important**: All pull requests to the main branch must include a version bump in `config.yaml`. This is enforced by automated checks. When merged to main, a GitHub release is automatically created with the new version. See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Quick Contribution Guidelines

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. **Bump the version in `config.yaml`** (must be greater than current main version)
5. Update `CHANGELOG.md` with your changes
6. Submit a pull request
7. Upon merge, a release is automatically created

For detailed contribution guidelines, versioning rules, and release workflow, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License

Copyright (c) 2024

[releases-shield]: https://img.shields.io/github/release/skille/home-assistant-github-runner-add-on.svg
[releases]: https://github.com/skille/home-assistant-github-runner-add-on/releases
[project-stage-shield]: https://img.shields.io/badge/project%20stage-production%20ready-brightgreen.svg
[github]: https://github.com/skille/home-assistant-github-runner-add-on

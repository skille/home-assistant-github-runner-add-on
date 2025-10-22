# GitHub Actions Runner Add-on for Home Assistant

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]

A Home Assistant add-on that runs a self-hosted GitHub Actions runner in a Docker container.

## About

This add-on allows you to run a self-hosted GitHub Actions runner directly within your Home Assistant installation. This is useful when you want to run GitHub Actions workflows on your own infrastructure, with access to your local network and resources.

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "GitHub Actions Runner" add-on
3. Configure the add-on with your repository URL and runner token
4. Start the add-on

## Configuration

The add-on requires the following configuration options:

### Option: `repo_url` (required)

The URL of the GitHub repository where you want to register the runner.

Example: `https://github.com/yourusername/yourrepo`

For organization-level runners, use: `https://github.com/yourorganization`

### Option: `runner_token` (required)

The registration token for the GitHub Actions runner. You can generate this token from:

- **Repository runners**: Go to your repository → Settings → Actions → Runners → New self-hosted runner
- **Organization runners**: Go to your organization → Settings → Actions → Runners → New runner

**Note**: The token is valid for 1 hour after generation, so you need to configure and start the add-on within that time frame.

### Example Configuration

```yaml
repo_url: "https://github.com/yourusername/yourrepo"
runner_token: "YOUR_RUNNER_TOKEN_HERE"
```

## How to Use

1. Navigate to your GitHub repository or organization settings
2. Go to Settings → Actions → Runners → New self-hosted runner
3. Copy the registration token provided
4. Configure this add-on with:
   - Your repository URL (e.g., `https://github.com/username/repo`)
   - The registration token you just copied
5. Start the add-on
6. The runner will appear as online in your GitHub repository/organization

## Features

- ✅ Self-hosted GitHub Actions runner
- ✅ Runs within Home Assistant as an add-on
- ✅ Supports multiple architectures (amd64, aarch64, armhf, armv7, i386)
- ✅ Automatic cleanup on shutdown
- ✅ Easy configuration through Home Assistant UI

## Support

Got questions or issues? Please open an issue on the [GitHub repository][github].

## Contributing

This is an active open-source project. Feel free to submit pull requests or open issues.

## License

MIT License

Copyright (c) 2024

[releases-shield]: https://img.shields.io/github/release/skille/home-assistant-github-runner-add-on.svg
[releases]: https://github.com/skille/home-assistant-github-runner-add-on/releases
[project-stage-shield]: https://img.shields.io/badge/project%20stage-production%20ready-brightgreen.svg
[github]: https://github.com/skille/home-assistant-github-runner-add-on

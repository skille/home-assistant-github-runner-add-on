# Documentation

## GitHub Actions Runner Add-on

This add-on runs a self-hosted GitHub Actions runner within your Home Assistant environment.

### Prerequisites

Before using this add-on, you need:

1. A GitHub account
2. Access to a GitHub repository or organization where you want to register the runner
3. Permissions to create self-hosted runners in that repository/organization

### Getting a Runner Token

#### For Repository Runners:

1. Go to your GitHub repository
2. Click on **Settings**
3. Navigate to **Actions** → **Runners**
4. Click **New self-hosted runner**
5. Copy the token shown in the configuration command

#### For Organization Runners:

1. Go to your GitHub organization page
2. Click on **Settings**
3. Navigate to **Actions** → **Runners**
4. Click **New runner**
5. Copy the token shown in the configuration command

**Important**: The registration token expires after 1 hour, so configure and start the add-on promptly.

### Configuration Options

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `repo_url` | string | Yes | The URL of the GitHub repository or organization (e.g., `https://github.com/username/repo`) |
| `runner_token` | string | Yes | The registration token from GitHub for registering the runner |
| `debug_logging` | boolean | No | Enable debug/verbose logging for troubleshooting (default: `false`) |

### Runner Behavior

- The runner will automatically register with GitHub when the add-on starts
- It will appear as "online" in your GitHub repository/organization runners list
- The runner will process workflow jobs assigned to it
- When the add-on stops, the runner will automatically unregister from GitHub

### Troubleshooting

#### Runner doesn't appear in GitHub

- Verify that the `repo_url` is correct and includes the full URL
- Ensure the `runner_token` hasn't expired (tokens are valid for 1 hour)
- Check the add-on logs for error messages
- Enable `debug_logging: true` for more detailed diagnostic information

#### Runner shows as offline

- Check if the add-on is running in Home Assistant
- Verify your network connectivity
- Check the add-on logs for connection issues

#### Token expired error

- Generate a new runner token from GitHub
- Update the add-on configuration with the new token
- Restart the add-on

#### Dependency or startup errors

If you encounter errors related to missing dependencies or .NET Core issues:

1. Enable debug logging by setting `debug_logging: true` in the configuration
2. Restart the add-on
3. Check the logs for detailed dependency information
4. The add-on includes all necessary .NET Core 6.0 dependencies (including Libicu)

The debug logs will show:
- Alpine Linux version
- Installed dependency packages (icu, gcompat, lttng, libssl, krb5)
- Runner directory contents and permissions
- Runner version and configuration status

### Security Considerations

- The runner token is sensitive and should be kept secure
- Runners have access to your repository code and secrets configured in GitHub
- Consider the security implications of running workflows on your Home Assistant host
- The runner runs in a containerized environment for isolation

### Advanced Usage

#### Organization-Level Runners

To register a runner at the organization level instead of repository level:

```yaml
repo_url: "https://github.com/your-organization"
runner_token: "YOUR_ORG_RUNNER_TOKEN"
```

#### Multiple Runners

You can install multiple instances of this add-on by using different repositories or organizations. Each instance will run as a separate runner.

### Limitations

- The runner token must be regenerated each time you want to reconfigure the runner
- Workflows running on this runner have access to the host network and filesystem (within container boundaries)
- Resource-intensive workflows may impact Home Assistant performance

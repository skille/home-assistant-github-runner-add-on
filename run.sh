#!/usr/bin/env bashio
set -e

bashio::log.info "Starting GitHub Actions Runner..."

# Get configuration from Home Assistant options file
CONFIG_FILE="/data/options.json"
REPO_URL=$(jq -r '.repo_url // empty' "$CONFIG_FILE")
RUNNER_TOKEN=$(jq -r '.runner_token // empty' "$CONFIG_FILE")
DEBUG_LOGGING=$(jq -r '.debug_logging // false' "$CONFIG_FILE")

# Enable debug logging if requested
if [ "$DEBUG_LOGGING" = "true" ]; then
    bashio::log.info "Debug logging enabled"
    set -x
fi

# Validate required parameters
if [ -z "$REPO_URL" ]; then
    bashio::log.fatal "repo_url is required!"
    exit 1
fi

if [ -z "$RUNNER_TOKEN" ]; then
    bashio::log.fatal "runner_token is required!"
    exit 1
fi

bashio::log.info "Repository URL: ${REPO_URL}"

# Validate repository URL format
if [[ ! "$REPO_URL" =~ ^https://github\.com/[a-zA-Z0-9_-]+(/[a-zA-Z0-9_-]+)?$ ]]; then
    bashio::log.warning "Repository URL format may be incorrect. Expected format:"
    bashio::log.warning "  - For repository: https://github.com/owner/repo"
    bashio::log.warning "  - For organization: https://github.com/organization"
    bashio::log.warning "Provided URL: ${REPO_URL}"
fi

# Validate token is not empty and has reasonable length
TOKEN_LENGTH=${#RUNNER_TOKEN}
if [ "$TOKEN_LENGTH" -lt 20 ]; then
    bashio::log.warning "Runner token appears to be too short (length: ${TOKEN_LENGTH})"
    bashio::log.warning "Please ensure you're using a valid registration token from GitHub"
fi

bashio::log.info "Note: Registration tokens expire after 1 hour. If you see 404 errors,"
bashio::log.info "generate a new token from: GitHub → Settings → Actions → Runners → New runner"

# Debug information
if [ "$DEBUG_LOGGING" = "true" ]; then
    bashio::log.info "=== Debug Information ==="
    bashio::log.info "OS Version: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')"
    bashio::log.info "Installed packages:"
    dpkg -l | grep -E "(libicu|libkrb5|liblttng|libssl|zlib)" || true
    bashio::log.info "Runner directory contents:"
    ls -la /runner
    bashio::log.info "Runner version:"
    cat /runner/.runner 2>/dev/null || echo "Runner not yet configured"
    bashio::log.info "Token length: ${TOKEN_LENGTH} characters"
    bashio::log.info "========================="
fi

# Change to runner directory
cd /runner

# Ensure runner user owns the directory
chown -R runner:runner /runner

# Configure the runner as the runner user
bashio::log.info "Configuring GitHub Actions Runner..."
if ! su runner -c "./config.sh --url \"${REPO_URL}\" --token \"${RUNNER_TOKEN}\" --unattended --replace"; then
    bashio::log.error "Failed to configure runner. Common causes:"
    bashio::log.error "  1. Registration token expired (valid for 1 hour only)"
    bashio::log.error "  2. Invalid repository URL format"
    bashio::log.error "  3. Insufficient permissions for the repository/organization"
    bashio::log.error "  4. Network connectivity issues"
    bashio::log.error ""
    bashio::log.error "To fix:"
    bashio::log.error "  1. Go to GitHub → Your Repo → Settings → Actions → Runners"
    bashio::log.error "  2. Click 'New self-hosted runner'"
    bashio::log.error "  3. Copy the NEW registration token shown"
    bashio::log.error "  4. Update the add-on configuration with the new token"
    bashio::log.error "  5. Restart the add-on"
    exit 1
fi

# Cleanup function
cleanup() {
    bashio::log.info "Removing runner..."
    su runner -c "./config.sh remove --token \"${RUNNER_TOKEN}\""
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Start the runner as the runner user
bashio::log.info "Starting runner..."
su runner -c "./run.sh"

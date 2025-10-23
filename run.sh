#!/usr/bin/env bashio
set -e

bashio::log.info "Starting GitHub Actions Runner..."

# Get configuration from Home Assistant options file
CONFIG_FILE="/data/options.json"
REPO_URL=$(jq -r '.repo_url // empty' "$CONFIG_FILE")
RUNNER_TOKEN=$(jq -r '.runner_token // empty' "$CONFIG_FILE")
RUNNER_NAME=$(jq -r '.runner_name // empty' "$CONFIG_FILE")
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
    bashio::log.info "Persistent config directory contents:"
    ls -la /data/runner-config/ 2>/dev/null || echo "No persistent config yet"
    bashio::log.info "========================="
fi

# Change to runner directory
cd /runner

# Ensure runner user owns the directory
chown -R runner:runner /runner

# Persistent storage for runner configuration
RUNNER_CONFIG_DIR="/data/runner-config"
mkdir -p "$RUNNER_CONFIG_DIR"
chown runner:runner "$RUNNER_CONFIG_DIR"

# Function to configure the runner
configure_runner() {
    bashio::log.info "Configuring GitHub Actions Runner..."
    if [ -n "$RUNNER_NAME" ]; then
        bashio::log.info "Using custom runner name: ${RUNNER_NAME}"
        if ! su runner -c "./config.sh --url \"${REPO_URL}\" --token \"${RUNNER_TOKEN}\" --name \"${RUNNER_NAME}\" --unattended --replace"; then
            return 1
        fi
    else
        if ! su runner -c "./config.sh --url \"${REPO_URL}\" --token \"${RUNNER_TOKEN}\" --unattended --replace"; then
            return 1
        fi
    fi
    
    # Backup configuration files to persistent storage
    bashio::log.info "Backing up runner configuration to persistent storage..."
    cp -f .runner "$RUNNER_CONFIG_DIR/" 2>/dev/null || true
    cp -f .credentials "$RUNNER_CONFIG_DIR/" 2>/dev/null || true
    cp -f .credentials_rsaparams "$RUNNER_CONFIG_DIR/" 2>/dev/null || true
    chown runner:runner "$RUNNER_CONFIG_DIR"/.* 2>/dev/null || true
    
    return 0
}

# Function to restore runner configuration
restore_runner_config() {
    if [ -f "$RUNNER_CONFIG_DIR/.runner" ] && [ -f "$RUNNER_CONFIG_DIR/.credentials" ]; then
        bashio::log.info "Found existing runner configuration, attempting to restore..."
        cp -f "$RUNNER_CONFIG_DIR/.runner" . 2>/dev/null || return 1
        cp -f "$RUNNER_CONFIG_DIR/.credentials" . 2>/dev/null || return 1
        cp -f "$RUNNER_CONFIG_DIR/.credentials_rsaparams" . 2>/dev/null || true
        chown runner:runner .runner .credentials .credentials_rsaparams 2>/dev/null || true
        return 0
    fi
    return 1
}

# Try to restore existing configuration
RUNNER_CONFIGURED=false
if restore_runner_config; then
    bashio::log.info "Runner configuration restored. Validating..."
    
    # Test if the restored configuration is valid by checking the .runner file
    if su runner -c "cat .runner" > /dev/null 2>&1; then
        bashio::log.info "Existing runner configuration is valid. Runner will resume without re-registration."
        RUNNER_CONFIGURED=true
    else
        bashio::log.warning "Restored configuration appears invalid. Will reconfigure..."
        rm -f .runner .credentials .credentials_rsaparams 2>/dev/null || true
    fi
fi

# If no valid configuration exists, configure the runner
if [ "$RUNNER_CONFIGURED" = false ]; then
    if ! configure_runner; then
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
    bashio::log.info "Runner configured successfully!"
fi

# Cleanup function
cleanup() {
    bashio::log.info "Cleaning up..."
    
    # Remove the runner
    bashio::log.info "Removing runner..."
    su runner -c "./config.sh remove --token \"${RUNNER_TOKEN}\""
    
    # Clear backed-up configuration since runner is being unregistered
    bashio::log.info "Clearing backed-up runner configuration..."
    rm -rf "$RUNNER_CONFIG_DIR"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Start the runner as the runner user
bashio::log.info "Starting runner..."
su runner -c "./run.sh"

#!/usr/bin/env bashio
set -e

bashio::log.info "Starting GitHub Actions Runner..."

# Start the web UI server in the background
bashio::log.info "Starting web UI server..."
python3 /webui/server.py &
WEB_UI_PID=$!

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
    bashio::log.info "========================="
fi

# Change to runner directory
cd /runner

# Ensure runner user owns the directory
chown -R runner:runner /runner

# Configure the runner as the runner user
bashio::log.info "Configuring GitHub Actions Runner..."
su runner -c "./config.sh --url \"${REPO_URL}\" --token \"${RUNNER_TOKEN}\" --unattended --replace"

# Cleanup function
cleanup() {
    bashio::log.info "Cleaning up..."
    
    # Stop the web UI server
    if [ ! -z "$WEB_UI_PID" ]; then
        bashio::log.info "Stopping web UI server..."
        kill $WEB_UI_PID 2>/dev/null || true
    fi
    
    # Remove the runner
    bashio::log.info "Removing runner..."
    su runner -c "./config.sh remove --token \"${RUNNER_TOKEN}\""
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Start the runner as the runner user
bashio::log.info "Starting runner..."
su runner -c "./run.sh"

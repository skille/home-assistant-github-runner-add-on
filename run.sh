#!/usr/bin/env bashio
set -e

bashio::log.info "Starting GitHub Actions Runner..."

# Get configuration from Home Assistant options file
CONFIG_FILE="/data/options.json"
REPO_URL=$(jq -r '.repo_url // empty' "$CONFIG_FILE")
RUNNER_TOKEN=$(jq -r '.runner_token // empty' "$CONFIG_FILE")

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

# Change to runner directory
cd /runner

# Ensure runner user owns the directory
chown -R runner:runner /runner

# Configure the runner as the runner user
bashio::log.info "Configuring GitHub Actions Runner..."
su runner -c "./config.sh --url \"${REPO_URL}\" --token \"${RUNNER_TOKEN}\" --unattended --replace"

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

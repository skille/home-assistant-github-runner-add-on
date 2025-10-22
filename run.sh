#!/usr/bin/env bashio
set -e

bashio::log.info "Starting GitHub Actions Runner..."

# Get configuration from Home Assistant
REPO_URL=$(bashio::config 'repo_url')
RUNNER_TOKEN=$(bashio::config 'runner_token')

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

# Configure the runner
bashio::log.info "Configuring GitHub Actions Runner..."
./config.sh --url "${REPO_URL}" --token "${RUNNER_TOKEN}" --unattended --replace

# Cleanup function
cleanup() {
    bashio::log.info "Removing runner..."
    ./config.sh remove --token "${RUNNER_TOKEN}"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Start the runner
bashio::log.info "Starting runner..."
./run.sh

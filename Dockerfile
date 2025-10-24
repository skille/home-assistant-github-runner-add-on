ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    jq \
    tar \
    unzip \
    sudo \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for running the GitHub Actions runner
RUN useradd -m -u 1000 runner

# Set up runner directory
RUN mkdir -p /runner && chmod 755 /runner
WORKDIR /runner

# Download and install GitHub Actions Runner
ARG BUILD_ARCH
RUN RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | sed 's/v//') && \
    if [ "$BUILD_ARCH" = "amd64" ]; then \
        RUNNER_ARCH="x64"; \
    elif [ "$BUILD_ARCH" = "aarch64" ]; then \
        RUNNER_ARCH="arm64"; \
    elif [ "$BUILD_ARCH" = "armv7" ] || [ "$BUILD_ARCH" = "armhf" ]; then \
        RUNNER_ARCH="arm"; \
    else \
        RUNNER_ARCH="x64"; \
    fi && \
    echo "Downloading runner for architecture: ${RUNNER_ARCH}" && \
    curl -o actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" && \
    tar xzf actions-runner.tar.gz && \
    rm actions-runner.tar.gz && \
    ./bin/installdependencies.sh && \
    chown -R runner:runner /runner

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

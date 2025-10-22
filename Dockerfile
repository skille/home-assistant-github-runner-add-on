ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    tar \
    sudo \
    gcompat \
    icu-libs \
    krb5-libs \
    libgcc \
    libintl \
    libssl3 \
    libstdc++ \
    zlib

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
    rm actions-runner.tar.gz

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

# Multi-Stage Optimized Dockerfile Template
# Supports multi-project environments with layer optimization

ARG BASE_IMAGE=node:20-bullseye
ARG TZ=UTC
ARG USER_UID=1000
ARG USER_GID=1000
ARG NODE_VERSION=20
ARG PYTHON_VERSION=3.11

# =============================================================================
# Stage 1: Base System
# =============================================================================
FROM ${BASE_IMAGE} AS base-system

ARG TZ
ARG USER_UID
ARG USER_GID

ENV TZ=$TZ
ENV DEBIAN_FRONTEND=noninteractive

# Create user with matching host UID/GID
RUN groupmod -g $USER_GID node && \
    usermod -u $USER_UID -g $USER_GID node && \
    mkdir -p /home/node && \
    chown -R node:node /home/node

# Install base system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg2 \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Stage 2: Development Tools
# =============================================================================
FROM base-system AS dev-tools

# Install development essentials
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    vim \
    nano \
    less \
    htop \
    tree \
    jq \
    unzip \
    zip \
    procps \
    sudo \
    man-db \
    build-essential \
    && apt-get clean

# Install zsh and make it default shell
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y --no-install-recommends zsh \
    && chsh -s /bin/zsh node \
    && apt-get clean

# Configure sudo for node user
RUN echo 'node ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/node \
    && chmod 0440 /etc/sudoers.d/node

# =============================================================================
# Stage 3: Networking and Security Tools
# =============================================================================
FROM dev-tools AS network-tools

# Install networking tools (required for init-firewall.sh)
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    iptables \
    ipset \
    iproute2 \
    dnsutils \
    netcat-openbsd \
    && apt-get clean

# =============================================================================
# Stage 4: Language Runtimes
# =============================================================================
FROM network-tools AS language-runtimes

ARG PYTHON_VERSION

# Install Python with development headers
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    && apt-get clean

# Create python3 symlink
RUN ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 \
    && ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python

# Install Rust (for faster tools)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && echo 'source $HOME/.cargo/env' >> /home/node/.bashrc \
    && echo 'source $HOME/.cargo/env' >> /home/node/.zshrc

# =============================================================================
# Stage 5: Development Utilities
# =============================================================================
FROM language-runtimes AS dev-utilities

# Install git-delta for better git diffs
ARG GIT_DELTA_VERSION=0.18.2
RUN curl -L "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/delta-${GIT_DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /tmp \
    && mv "/tmp/delta-${GIT_DELTA_VERSION}-x86_64-unknown-linux-musl/delta" /usr/local/bin/ \
    && chmod +x /usr/local/bin/delta \
    && rm -rf /tmp/delta-*

# Install modern CLI tools
RUN --mount=type=cache,target=/root/.cargo/registry \
    /home/node/.cargo/bin/cargo install \
    ripgrep \
    fd-find \
    bat \
    exa

# =============================================================================
# Stage 6: Shell Configuration
# =============================================================================
FROM dev-utilities AS shell-config

# Install Powerlevel10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /opt/powerlevel10k \
    && chown -R node:node /opt/powerlevel10k

# Copy Powerlevel10k configuration
COPY --chown=node:node .p10k.zsh /home/node/.p10k.zsh

# Set up zsh configuration
RUN echo 'source /opt/powerlevel10k/powerlevel10k.zsh-theme' >> /home/node/.zshrc \
    && echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /home/node/.zshrc \
    && echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> /home/node/.zshrc

# =============================================================================
# Stage 7: Claude Code Integration
# =============================================================================
FROM shell-config AS claude-integration

# Install Claude Code (latest version)
RUN npm install -g @anthropic/claude-code@latest

# Install MCP servers for enhanced capabilities
RUN --mount=type=cache,target=/home/node/.npm \
    npm install -g \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-git \
    && chown -R node:node /home/node/.npm

# Create Claude context directory
RUN mkdir -p /home/node/.claude/context \
    && chown -R node:node /home/node/.claude

# =============================================================================
# Stage 8: Firewall Script
# =============================================================================
FROM claude-integration AS final

# Copy and configure firewall initialization script
COPY --chown=root:root init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh

# Set default user
USER node
WORKDIR /workspace

# Set up shell environment
SHELL ["/bin/zsh", "-c"]
ENV SHELL=/bin/zsh

# Create workspace structure
RUN mkdir -p /workspace/.devcontainer/cache \
    && mkdir -p /workspace/.devcontainer/logs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command
CMD ["/bin/zsh"]

# =============================================================================
# Build Metadata
# =============================================================================
LABEL org.opencontainers.image.title="Optimized Multi-Project DevContainer"
LABEL org.opencontainers.image.description="DevContainer optimized for multi-project development with Claude Code integration"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.vendor="DevContainer Optimization Project"
LABEL org.opencontainers.image.source="https://github.com/your-org/devcontainer-optimization"
# syntax=docker/dockerfile:1
FROM node:20-bullseye

ARG TZ
ENV TZ="$TZ"
ARG CLAUDE_CODE_VERSION=latest
ARG GIT_DELTA_VERSION=0.18.2
ARG ZSH_IN_DOCKER_VERSION=1.2.0

# Consolidated system packages installation (combines 2 apt-get operations)
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  procps \
  sudo \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  jq \
  nano \
  vim \
  curl \
  wget \
  ca-certificates \
  aggregate \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install fzf from source (more reliable than package)
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /usr/local/share/fzf \
  && /usr/local/share/fzf/install --bin \
  && ln -s /usr/local/share/fzf/bin/fzf /usr/local/bin/fzf

# Setup GitHub CLI repository and install with Python environment (combines 2 apt-get operations)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
  && apt-get update && apt-get install -y --no-install-recommends \
    gh \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-setuptools \
    python3-wheel \
    build-essential \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create symbolic link for python command
RUN ln -s /usr/bin/python3 /usr/local/bin/python

# Upgrade pip and install basic Python packages
RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install --upgrade pip setuptools wheel

# Install commonly used Python packages
RUN --mount=type=cache,target=/root/.cache/pip \
    pip3 install \
    requests \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    jupyter \
    jupyterlab \
    notebook \
    ipython \
    pytest \
    pytest-cov \
    black \
    flake8 \
    pylint \
    autopep8 \
    isort \
    mypy \
    fastapi \
    flask \
    django \
    sqlalchemy \
    psycopg2-binary \
    pymongo \
    redis \
    celery \
    pydantic \
    httpx \
    aiohttp \
    rich \
    typer \
    click \
    python-dotenv

# Install git-delta
RUN DELTA_VERSION=${GIT_DELTA_VERSION} && \
    curl -L "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb" -o /tmp/git-delta.deb && \
    dpkg -i /tmp/git-delta.deb && \
    rm /tmp/git-delta.deb

# Configure sudo for node user (passwordless)
RUN usermod -aG sudo node && \
    echo 'node ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/node && \
    chmod 0440 /etc/sudoers.d/node

# Switch to node user before installing Oh My Zsh
USER node
WORKDIR /home/node

# Install Oh My Zsh with plugins and Powerlevel10k theme
RUN rm -rf ~/.oh-my-zsh && \
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh && \
    chmod 755 ~/.oh-my-zsh && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Switch back to root for remaining installation steps
USER root

# Install Claude Code CLI
RUN --mount=type=cache,target=/root/.npm \
    npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Install uv package manager for SpecKit to node user's .local/bin
RUN mkdir -p /home/node/.local/bin && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /home/node/.local/bin/uv && \
    mv /root/.local/bin/uvx /home/node/.local/bin/uvx && \
    chown -R node:node /home/node/.local && \
    chmod 755 /home/node/.local/bin/uv /home/node/.local/bin/uvx

# Setup firewall script and copy p10k config
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
COPY .p10k.zsh /home/node/.p10k.zsh
# Setup permissions and directories for node user
RUN chmod +x /usr/local/bin/init-firewall.sh && \
    chown node:node /home/node/.p10k.zsh && \
    mkdir -p /usr/local/share/npm-global && \
    chown -R node:node /usr/local/share && \
    mkdir -p /home/node/.npm-global && \
    chown -R node:node /home/node/.npm-global && \
    mkdir -p /home/node/.virtualenvs && \
    chown -R node:node /home/node/.virtualenvs

# Configure shell configuration files for node user
RUN echo 'export PATH=/home/node/.npm-global/bin:/home/node/.local/bin:/home/node/bin:$PATH' >> /home/node/.bashrc && \
    echo 'export NPM_CONFIG_PREFIX=/home/node/.npm-global' >> /home/node/.bashrc && \
    echo 'export PYTHONPATH=/workspace:$PYTHONPATH' >> /home/node/.bashrc && \
    echo 'export PIP_USER=0' >> /home/node/.bashrc && \
    chown node:node /home/node/.bashrc && \
    echo 'export ZSH="$HOME/.oh-my-zsh"' > /home/node/.zshrc && \
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> /home/node/.zshrc && \
    echo 'plugins=(git ssh-agent zsh-autosuggestions zsh-syntax-highlighting)' >> /home/node/.zshrc && \
    echo 'source $ZSH/oh-my-zsh.sh' >> /home/node/.zshrc && \
    echo 'export PATH=/home/node/.npm-global/bin:/home/node/.local/bin:/home/node/bin:$PATH' >> /home/node/.zshrc && \
    echo 'export NPM_CONFIG_PREFIX=/home/node/.npm-global' >> /home/node/.zshrc && \
    echo 'export PYTHONPATH=/workspace:$PYTHONPATH' >> /home/node/.zshrc && \
    echo 'export PIP_USER=0' >> /home/node/.zshrc && \
    echo '# Powerlevel10k instant prompt' >> /home/node/.zshrc && \
    echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then' >> /home/node/.zshrc && \
    echo '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"' >> /home/node/.zshrc && \
    echo 'fi' >> /home/node/.zshrc && \
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /home/node/.zshrc && \
    chown node:node /home/node/.zshrc && \
    chmod 644 /home/node/.zshrc

# Set default shell to zsh for node user
RUN chsh -s /usr/bin/zsh node

# Switch to node user
USER node
WORKDIR /home/node

# Create SSH directory for Oh My Zsh ssh-agent plugin
RUN mkdir -p /home/node/.ssh && chmod 700 /home/node/.ssh

# Install some user-level Python packages
RUN --mount=type=cache,target=/home/node/.cache/pip,uid=1000,gid=1000 \
    pip3 install --user \
    poetry \
    pipenv \
    virtualenvwrapper

# GitHub SpecKit integration
RUN mkdir -p /home/node/.local/bin
COPY --chown=node:node --chmod=755 init-speckit.sh /home/node/.local/bin/init-speckit

# Set default working directory
WORKDIR /workspace
FROM node:20-bullseye

ARG TZ
ENV TZ="$TZ"
ARG CLAUDE_CODE_VERSION=latest
ARG GIT_DELTA_VERSION=0.18.2
ARG ZSH_IN_DOCKER_VERSION=1.2.0

# Install basic development tools and utilities
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
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install fzf from source (more reliable than package)
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /usr/local/share/fzf \
  && /usr/local/share/fzf/install --bin \
  && ln -s /usr/local/share/fzf/bin/fzf /usr/local/bin/fzf

# Install aggregate tool separately if needed
RUN apt-get update && apt-get install -y --no-install-recommends \
  aggregate \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
  && apt-get update && apt-get install -y gh \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python environment
RUN apt-get update && apt-get install -y --no-install-recommends \
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
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install commonly used Python packages
RUN pip3 install --no-cache-dir \
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

# Install Oh My Zsh manually (more reliable method)
RUN rm -rf ~/.oh-my-zsh && \
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh && \
    chmod 755 ~/.oh-my-zsh

# Install zsh plugins and Powerlevel10k theme as node user
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Switch back to root for remaining installation steps
USER root

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Setup firewall script and copy p10k config
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
COPY .p10k.zsh /home/node/.p10k.zsh
RUN chmod +x /usr/local/bin/init-firewall.sh && \
    chown node:node /home/node/.p10k.zsh

# Ensure node user has proper permissions
RUN mkdir -p /usr/local/share/npm-global && \
    chown -R node:node /usr/local/share && \
    mkdir -p /home/node/.npm-global && \
    chown -R node:node /home/node/.npm-global && \
    mkdir -p /home/node/.virtualenvs && \
    chown -R node:node /home/node/.virtualenvs

# Configure .bashrc for node user (done as root to avoid permission issues)
RUN echo 'export PATH=/home/node/.npm-global/bin:$PATH' >> /home/node/.bashrc && \
    echo 'export NPM_CONFIG_PREFIX=/home/node/.npm-global' >> /home/node/.bashrc && \
    echo 'export PYTHONPATH=/workspace:$PYTHONPATH' >> /home/node/.bashrc && \
    echo 'export PIP_USER=0' >> /home/node/.bashrc && \
    chown node:node /home/node/.bashrc

# Configure .zshrc for node user with Powerlevel10k theme
RUN echo 'export ZSH="$HOME/.oh-my-zsh"' > /home/node/.zshrc \
  && echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> /home/node/.zshrc \
  && echo 'plugins=(git ssh-agent zsh-autosuggestions zsh-syntax-highlighting)' >> /home/node/.zshrc \
  && echo 'source $ZSH/oh-my-zsh.sh' >> /home/node/.zshrc \
  && echo 'export PATH=/home/node/.npm-global/bin:$PATH' >> /home/node/.zshrc \
  && echo 'export NPM_CONFIG_PREFIX=/home/node/.npm-global' >> /home/node/.zshrc \
  && echo 'export PYTHONPATH=/workspace:$PYTHONPATH' >> /home/node/.zshrc \
  && echo 'export PIP_USER=0' >> /home/node/.zshrc \
  && echo '# Powerlevel10k instant prompt' >> /home/node/.zshrc \
  && echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then' >> /home/node/.zshrc \
  && echo '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"' >> /home/node/.zshrc \
  && echo 'fi' >> /home/node/.zshrc \
  && echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /home/node/.zshrc \
  && chown node:node /home/node/.zshrc \
  && chmod 644 /home/node/.zshrc

# Set default shell to zsh for node user
RUN chsh -s /usr/bin/zsh node

# Switch to node user
USER node
WORKDIR /home/node

# Install some user-level Python packages
RUN pip3 install --user \
    poetry \
    pipenv \
    virtualenvwrapper

# Set default working directory
WORKDIR /workspace
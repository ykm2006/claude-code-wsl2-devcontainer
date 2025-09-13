# Baseline DevContainer Dockerfile for Performance Measurement
# This is the initial, unoptimized version

FROM node:20-bullseye

# Install basic development tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    build-essential \
    python3 \
    python3-pip \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install modern CLI tools
RUN apt-get update && apt-get install -y \
    ripgrep \
    fd-find \
    bat \
    && rm -rf /var/lib/apt/lists/*

# Install git-delta
RUN wget -q https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb \
    && dpkg -i git-delta_0.16.5_amd64.deb \
    && rm git-delta_0.16.5_amd64.deb

# Install Python packages
RUN pip3 install --no-cache-dir \
    black \
    pylint \
    pytest

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install global npm packages
RUN npm install -g \
    typescript \
    @types/node \
    eslint \
    prettier \
    nodemon

# Set Zsh as default shell
SHELL ["/bin/zsh", "-c"]

# Create workspace directory
WORKDIR /workspace

# Set environment variables
ENV SHELL=/bin/zsh
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

CMD ["/bin/zsh"]
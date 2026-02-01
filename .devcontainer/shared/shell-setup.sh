#!/bin/bash
# Shell setup script for DevContainer environments
# Sourced by .zshrc or .bashrc during shell initialization

# Environment identifier (set by Dockerfile)
export DEVCONTAINER_ENV="${DEVCONTAINER_ENV:-unknown}"

# Common aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline -10'

# Claude Code alias
alias cc='claude'

# FZF configuration
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Display environment info (only in interactive shells)
if [[ $- == *i* ]]; then
  echo "DevContainer Environment: $DEVCONTAINER_ENV"
fi

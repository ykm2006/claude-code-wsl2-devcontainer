#!/bin/bash

# WSL2 DevContainer Setup Script
# Optimized DevContainer environment for Claude Code development
# Created for Phase 6: GitHub Distribution Preparation

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WORK_DIR="$HOME/WORK"
DEVCONTAINER_SOURCE=".devcontainer"
CLAUDE_CONFIG_DIR="$HOME/.claude"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Environment checks
check_environment() {
    log_info "Checking required tools..."

    # Check Git
    if command_exists git; then
        log_success "Git is available ($(git --version | head -n1))"
    else
        log_error "Git is not installed. Please install git first."
        exit 1
    fi

    # Check Docker
    if command_exists docker; then
        # Test Docker daemon connectivity
        if docker info >/dev/null 2>&1; then
            log_success "Docker is available and running ($(docker --version))"
        else
            log_error "Docker is installed but not running or not accessible."
            log_info "Make sure Docker Desktop is running and WSL2 integration is enabled."
            exit 1
        fi
    else
        log_error "Docker is not available. Please install Docker Desktop with WSL2 integration."
        exit 1
    fi

    # Check VS Code
    if command_exists code; then
        log_success "VS Code is available ($(code --version | head -n1))"
    else
        log_error "VS Code is not available in PATH."
        log_info "Make sure VS Code is installed with 'code' command available in WSL."
        exit 1
    fi

    log_success "All required tools are available!"
}

# Create WORK directory structure
create_work_directory() {
    log_info "Setting up development workspace..."

    if [ -d "$WORK_DIR" ]; then
        log_warning "Directory $WORK_DIR already exists."
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled by user."
            exit 0
        fi
    else
        mkdir -p "$WORK_DIR"
        log_success "Created workspace directory: $WORK_DIR"
    fi
}

# Copy DevContainer configuration
setup_devcontainer() {
    log_info "Setting up optimized DevContainer configuration..."

    local target_devcontainer="$WORK_DIR/.devcontainer"

    if [ -d "$target_devcontainer" ]; then
        log_warning "DevContainer configuration already exists at $target_devcontainer"
        read -p "Do you want to overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping DevContainer setup."
            return
        fi
        rm -rf "$target_devcontainer"
    fi

    if [ ! -d "$DEVCONTAINER_SOURCE" ]; then
        log_error "Source .devcontainer directory not found!"
        exit 1
    fi

    cp -r "$DEVCONTAINER_SOURCE" "$target_devcontainer"
    log_success "Copied optimized DevContainer configuration"
    log_info "Features: 60% faster build, SpecKit integration, Serena MCP support"
}

# Setup Claude authentication
setup_claude_auth() {
    log_info "Setting up Claude Code authentication..."

    if [ -f "$HOME/.claude.json" ]; then
        log_success "Claude configuration already exists at ~/.claude.json"
        return
    fi

    log_warning "Claude authentication not found."
    log_info "You'll need to set up Claude Code authentication manually."
    log_info "Run 'claude auth' after the setup completes."

    # Create basic directories for Claude if they don't exist
    mkdir -p "$CLAUDE_CONFIG_DIR"
    log_info "Created Claude configuration directory: $CLAUDE_CONFIG_DIR"
}

# Launch VS Code
launch_vscode() {
    log_info "Launching VS Code with DevContainer..."

    cd "$WORK_DIR"

    # Open VS Code in the WORK directory
    log_info "Opening $WORK_DIR in VS Code..."
    code .

    log_success "VS Code launched!"
    log_info "In VS Code, you should see a notification to 'Reopen in Container'"
    log_info "Click that notification to start the optimized DevContainer"
}

# Print final instructions
print_final_instructions() {
    echo
    log_success "=== Setup Complete! ==="
    echo
    log_info "Next steps:"
    echo "1. In VS Code, click 'Reopen in Container' when prompted"
    echo "2. Wait for DevContainer to build (optimized - 60% faster!)"
    echo "3. Run 'claude auth' to set up Claude Code authentication"
    echo "4. Start coding with AI assistance!"
    echo
    log_info "Available tools in DevContainer:"
    echo "• Claude Code - AI coding assistant"
    echo "• SpecKit - AI-powered spec-driven development"
    echo "• Serena MCP - Advanced code analysis"
    echo "• Python data science stack (40+ packages)"
    echo "• Node.js development environment"
    echo "• Rust toolchain"
    echo
    log_info "Workspace location: $WORK_DIR"
    log_info "Happy coding! 🚀"
}

# Main execution
main() {
    echo
    log_info "=== WSL2 DevContainer Setup ==="
    log_info "Optimized development environment for Claude Code"
    echo

    check_environment
    create_work_directory
    setup_devcontainer
    setup_claude_auth
    launch_vscode
    print_final_instructions
}

# Run main function
main "$@"
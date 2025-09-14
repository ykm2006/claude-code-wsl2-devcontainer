#!/bin/bash
set -e

# Display help message
show_help() {
    cat << EOF
init-serena-mcp - Serena MCP Server Initialization for Claude Code

USAGE:
    init-serena-mcp [PROJECT_NAME] [OPTIONS]

ARGUMENTS:
    PROJECT_NAME    Optional. Create new project with Serena MCP.
                   If omitted, adds Serena MCP to current directory project.

OPTIONS:
    --help, -h     Show this help message

EXAMPLES:
    # Add Serena MCP to existing project (current directory)
    init-serena-mcp

    # Create new project and add Serena MCP
    init-serena-mcp my-awesome-project

DESCRIPTION:
    This script adds Serena MCP server to Claude Code for enhanced coding
    capabilities. Serena MCP provides:

    - Semantic code analysis and understanding
    - Symbol-level code editing capabilities
    - Multi-language support (Python, TypeScript, JavaScript, Rust, etc.)
    - IDE-like features through Model Context Protocol (MCP)
    - Free and open-source (no API key required)

    The script will:
    1. Check for git repository (existing projects) or create one (new projects)
    2. Ensure uv package manager is available
    3. Add Serena MCP server to Claude Code using 'claude mcp add'
    4. Configure project-specific MCP settings

REQUIREMENTS:
    - Git must be available
    - Claude Code must be installed and accessible
    - Internet connection for downloading Serena MCP
EOF
}

# Parse command line arguments
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

PROJECT_NAME="$1"

echo "=== Serena MCP Server Initialization ==="

# Case 1: New project creation
if [[ -n "$PROJECT_NAME" ]]; then
    echo "Creating new project: $PROJECT_NAME"

    if [[ -d "$PROJECT_NAME" ]]; then
        echo "Error: Directory '$PROJECT_NAME' already exists"
        exit 1
    fi

    # Create and initialize new project
    mkdir "$PROJECT_NAME"
    cd "$PROJECT_NAME"
    git init
    echo "✓ New git repository created"

# Case 2: Existing project setup
else
    echo "Adding Serena MCP to current directory: $(pwd)"

    # Validate we're in a project directory
    if [[ ! -d ".git" ]]; then
        echo "Error: Current directory is not a git repository"
        echo "Please run 'git init' first or specify a project name to create a new one"
        echo "Use 'init-serena-mcp --help' for more information"
        exit 1
    fi

    PROJECT_NAME=$(basename "$(pwd)")
    echo "✓ Detected existing git repository: $PROJECT_NAME"
fi

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "uv package manager not found. Installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$PATH:$HOME/.local/bin"
    echo "✓ uv package manager installed"

    # Also ensure it's available for future sessions
    if [[ -n "$BASH_VERSION" ]]; then
        echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
    elif [[ -n "$ZSH_VERSION" ]]; then
        echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc
    fi
else
    echo "✓ uv package manager found"
fi

# Check if Claude Code is available
if ! command -v claude &> /dev/null; then
    echo "❌ Claude Code not found in PATH"
    echo "Please ensure Claude Code is installed and accessible"
    echo "You can install it from: https://claude.ai/code"
    exit 1
fi

echo "✓ Claude Code found"

# Get current project path
CURRENT_DIR=$(pwd)
echo "Project path: $CURRENT_DIR"

# Add Serena MCP server to Claude Code
echo "Adding Serena MCP server to Claude Code..."
if claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project "$CURRENT_DIR"; then
    echo ""
    echo "✅ Serena MCP server added to Claude Code successfully!"
    echo ""
    echo "📋 Configuration applied:"
    echo "  Server name: serena"
    echo "  Context: ide-assistant"
    echo "  Project: $CURRENT_DIR"
    echo "  Command: uvx --from git+https://github.com/oraios/serena serena start-mcp-server"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Restart Claude Code to activate the MCP server"
    echo "2. Open your project in Claude Code"
    if [[ "$1" ]]; then
        echo "   cd $PROJECT_NAME"
    fi
    echo "3. Ask Claude to 'read Serena's initial instructions' if needed"
    echo "4. Start coding with enhanced AI assistance!"
    echo ""
    echo "💡 Serena MCP features:"
    echo "  - Semantic code understanding and analysis"
    echo "  - Symbol-level editing and refactoring"
    echo "  - Multi-language support and IDE-like capabilities"
    echo "  - Free and open-source (no API costs)"
    echo ""
    echo "🌐 Dashboard: Serena will start a web dashboard on localhost for logs"
    echo ""
else
    echo ""
    echo "❌ Failed to add Serena MCP to Claude Code"
    echo "Please check that:"
    echo "  - Claude Code is properly installed"
    echo "  - You have internet connection"
    echo "  - uv package manager is working"
    echo ""
    echo "For manual setup, run:"
    echo "  claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $CURRENT_DIR"
    exit 1
fi
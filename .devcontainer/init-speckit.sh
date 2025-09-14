#!/bin/bash
set -e

# Display help message
show_help() {
    cat << EOF
init-speckit - GitHub SpecKit Project Initialization

USAGE:
    init-speckit [PROJECT_NAME] [OPTIONS]

ARGUMENTS:
    PROJECT_NAME    Optional. Create new project with specified name.
                   If omitted, initializes SpecKit in current directory.

OPTIONS:
    --help, -h     Show this help message

EXAMPLES:
    # Initialize SpecKit in existing project (current directory)
    init-speckit

    # Create new project with SpecKit
    init-speckit my-awesome-project

DESCRIPTION:
    This script helps you initialize GitHub SpecKit for spec-driven development
    with Claude Code integration. SpecKit creates a structured workflow for:

    - /specify: Create project specifications
    - /plan:    Define technical implementation details
    - /tasks:   Generate actionable task lists

    The script will:
    1. Check for git repository (existing projects) or create one (new projects)
    2. Install uv package manager if not present
    3. Initialize SpecKit with Claude AI integration
    4. Display available commands and directory structure

REQUIREMENTS:
    - Git must be available
    - Internet connection for downloading uv and SpecKit
EOF
}

# Parse command line arguments
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

PROJECT_NAME="$1"

echo "=== GitHub SpecKit Project Initialization ==="

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

# Case 2: Existing project initialization
else
    echo "Initializing SpecKit in current directory: $(pwd)"

    # Validate we're in a project directory
    if [[ ! -d ".git" ]]; then
        echo "Error: Current directory is not a git repository"
        echo "Please run 'git init' first or specify a project name to create a new one"
        echo "Use 'init-speckit --help' for more information"
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

# Initialize SpecKit with appropriate command
echo "Running GitHub SpecKit initialization..."
if [[ "$1" ]]; then
    # New project: use project name
    uvx --from git+https://github.com/github/spec-kit.git specify init "$PROJECT_NAME" --ai claude
else
    # Existing project: use --here flag
    uvx --from git+https://github.com/github/spec-kit.git specify init --here --ai claude
fi

echo ""
echo "✅ SpecKit initialized successfully!"
echo ""
echo "📁 Directory structure created:"
echo "  .specify/"
echo "    ├── memory/     # Project constitution and update checklists"
echo "    ├── scripts/    # Utility scripts for project management"
echo "    ├── specs/      # Feature specifications"
echo "    └── templates/  # Markdown templates for specs, plans, and tasks"
echo ""
echo "🚀 Available commands:"
echo "  /specify - Create initial project specification"
echo "  /plan    - Define technical implementation details"
echo "  /tasks   - Create actionable task list"
echo ""
echo "💡 Next steps:"
if [[ "$1" ]]; then
    echo "  cd $PROJECT_NAME"
fi
echo "  Use Claude Code with SpecKit commands to start spec-driven development!"
echo ""
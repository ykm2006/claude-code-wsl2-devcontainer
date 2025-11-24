#!/bin/bash
#
# setup-devcontainer-symlink.sh
# Automatically detects the environment (WSL2 or native Linux) and creates
# the appropriate symlink for devcontainer.json.
#
# Usage: bash scripts/setup-devcontainer-symlink.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DEVCONTAINER_DIR="$PROJECT_DIR/.devcontainer"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
  echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Check if required files exist
check_required_files() {
  if [ ! -f "$DEVCONTAINER_DIR/devcontainer.json.wsl2" ]; then
    log_error "Missing: $DEVCONTAINER_DIR/devcontainer.json.wsl2"
    return 1
  fi

  if [ ! -f "$DEVCONTAINER_DIR/devcontainer.json.linux" ]; then
    log_error "Missing: $DEVCONTAINER_DIR/devcontainer.json.linux"
    return 1
  fi

  return 0
}

# Detect environment: WSL2 or native Linux
detect_environment() {
  if grep -qi microsoft /proc/version; then
    echo "wsl2"
  else
    echo "linux"
  fi
}

# Get available drives in WSL2
get_wsl2_drives() {
  if [ -d "/mnt" ]; then
    # List available drives: /mnt/c, /mnt/d, etc.
    ls -d /mnt/[a-z] 2>/dev/null | sed 's|/mnt/||' | tr '\n' ',' | sed 's/,$//'
  else
    echo ""
  fi
}

# Create symlink
create_symlink() {
  local target="$1"
  local symlink_path="$DEVCONTAINER_DIR/devcontainer.json"

  # Remove existing symlink or file
  if [ -L "$symlink_path" ] || [ -f "$symlink_path" ]; then
    log_debug "Removing existing devcontainer.json"
    rm -f "$symlink_path"
  fi

  # Create new symlink
  ln -s "$(basename "$target")" "$symlink_path"

  if [ ! -L "$symlink_path" ]; then
    log_error "Failed to create symlink to $target"
    return 1
  fi

  return 0
}

# Main logic
main() {
  log_info "Detecting environment..."

  # Check required files
  if ! check_required_files; then
    log_error "Required configuration files not found"
    return 1
  fi

  # Detect environment
  ENV=$(detect_environment)
  log_info "Environment detected: $ENV"

  case "$ENV" in
    wsl2)
      log_info "WSL2 environment detected"

      # Check available drives
      DRIVES=$(get_wsl2_drives)
      if [ -n "$DRIVES" ]; then
        log_debug "Available drives: $DRIVES"
      fi

      # Create symlink to WSL2 version
      if create_symlink "$DEVCONTAINER_DIR/devcontainer.json.wsl2"; then
        log_info "Created symlink to devcontainer.json.wsl2"
        log_info "✅ Setup complete for WSL2 environment"
        return 0
      else
        log_error "Failed to create symlink for WSL2"
        return 1
      fi
      ;;

    linux)
      log_info "Native Linux environment detected"

      # Create symlink to Linux version
      if create_symlink "$DEVCONTAINER_DIR/devcontainer.json.linux"; then
        log_info "Created symlink to devcontainer.json.linux"
        log_info "✅ Setup complete for Linux environment"
        return 0
      else
        log_error "Failed to create symlink for Linux"
        return 1
      fi
      ;;

    *)
      log_error "Unknown environment: $ENV"
      return 1
      ;;
  esac
}

# Run main function
main "$@"

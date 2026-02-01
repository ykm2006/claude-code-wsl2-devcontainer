#!/bin/bash
#
# setup-devcontainer.sh
# Automatically detects the environment (WSL2 or native Linux) and copies
# the appropriate devcontainer.json configuration.
#
# Note: Using copy instead of symlink due to VS Code Dev Containers
#       not reliably following symlinks in WSL2 environments.
#
# Usage:
#   bash scripts/setup-devcontainer.sh          # Setup for .devcontainer/
#   bash scripts/setup-devcontainer.sh minimal  # Setup for .devcontainer/minimal/
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Subdirectory argument (optional)
SUBDIR="${1:-}"

if [ -n "$SUBDIR" ]; then
  DEVCONTAINER_DIR="$PROJECT_DIR/.devcontainer/$SUBDIR"
else
  DEVCONTAINER_DIR="$PROJECT_DIR/.devcontainer"
fi

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
    ls -d /mnt/[a-z] 2>/dev/null | sed 's|/mnt/||' | tr '\n' ',' | sed 's/,$//'
  else
    echo ""
  fi
}

# Copy config file (using copy instead of symlink due to VS Code Dev Containers issue)
copy_config() {
  local source="$1"
  local dest_path="$DEVCONTAINER_DIR/devcontainer.json"

  # Remove existing symlink or file
  if [ -L "$dest_path" ] || [ -f "$dest_path" ]; then
    log_debug "Removing existing devcontainer.json"
    rm -f "$dest_path"
  fi

  # Copy instead of symlink
  cp "$source" "$dest_path"

  if [ ! -f "$dest_path" ]; then
    log_error "Failed to copy $source"
    return 1
  fi

  return 0
}

# Main logic
main() {
  log_info "Detecting environment..."

  if [ -n "$SUBDIR" ]; then
    log_info "Target directory: .devcontainer/$SUBDIR/"
  else
    log_info "Target directory: .devcontainer/"
  fi

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

      # Copy WSL2 config
      if copy_config "$DEVCONTAINER_DIR/devcontainer.json.wsl2"; then
        log_info "Copied devcontainer.json.wsl2 → devcontainer.json"
        log_info "✅ Setup complete for WSL2 environment"
        return 0
      else
        log_error "Failed to copy config for WSL2"
        return 1
      fi
      ;;

    linux)
      log_info "Native Linux environment detected"

      # Copy Linux config
      if copy_config "$DEVCONTAINER_DIR/devcontainer.json.linux"; then
        log_info "Copied devcontainer.json.linux → devcontainer.json"
        log_info "✅ Setup complete for Linux environment"
        return 0
      else
        log_error "Failed to copy config for Linux"
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

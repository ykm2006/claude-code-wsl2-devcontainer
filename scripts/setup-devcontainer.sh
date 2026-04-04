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
#   bash scripts/setup-devcontainer.sh          # Setup ALL configurations (dev, dev-rag)
#   bash scripts/setup-devcontainer.sh dev      # Setup only .devcontainer/dev/
#   bash scripts/setup-devcontainer.sh dev-rag  # Setup only .devcontainer/dev-rag/
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DEVCONTAINER_BASE="$PROJECT_DIR/.devcontainer"

# Subdirectory argument (optional)
# If not specified, process all available subdirectories (dev, dev-rag)
SUBDIR="${1:-}"

# Available DevContainer configurations
AVAILABLE_SUBDIRS=("dev" "dev-rag")

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

# Check if required files exist for a specific subdirectory
check_required_files() {
  local subdir="$1"
  local target_dir="$DEVCONTAINER_BASE/$subdir"

  if [ ! -f "$target_dir/devcontainer.json.wsl2" ]; then
    log_error "Missing: $target_dir/devcontainer.json.wsl2"
    return 1
  fi

  if [ ! -f "$target_dir/devcontainer.json.linux" ]; then
    log_error "Missing: $target_dir/devcontainer.json.linux"
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
  local subdir="$1"
  local env="$2"
  local target_dir="$DEVCONTAINER_BASE/$subdir"
  local source="$target_dir/devcontainer.json.$env"
  local dest_path="$target_dir/devcontainer.json"

  # Remove existing symlink or file
  if [ -L "$dest_path" ] || [ -f "$dest_path" ]; then
    log_debug "[$subdir] Removing existing devcontainer.json"
    rm -f "$dest_path"
  fi

  # Copy instead of symlink
  cp "$source" "$dest_path"

  if [ ! -f "$dest_path" ]; then
    log_error "[$subdir] Failed to copy $source"
    return 1
  fi

  return 0
}

# Setup a single subdirectory
setup_subdir() {
  local subdir="$1"
  local env="$2"

  log_info "Setting up .devcontainer/$subdir/"

  # Check required files
  if ! check_required_files "$subdir"; then
    log_error "[$subdir] Required configuration files not found"
    return 1
  fi

  # Copy config
  if copy_config "$subdir" "$env"; then
    log_info "[$subdir] Copied devcontainer.json.$env → devcontainer.json"
    return 0
  else
    log_error "[$subdir] Failed to copy config"
    return 1
  fi
}

# Main logic
main() {
  log_info "Detecting environment..."

  # Detect environment
  local env
  env=$(detect_environment)
  log_info "Environment detected: $env"

  if [ "$env" = "wsl2" ]; then
    # Check available drives
    DRIVES=$(get_wsl2_drives)
    if [ -n "$DRIVES" ]; then
      log_debug "Available drives: $DRIVES"
    fi
  fi

  # Determine which subdirectories to process
  local subdirs_to_process=()

  if [ -n "$SUBDIR" ]; then
    # Specific subdirectory specified
    subdirs_to_process=("$SUBDIR")
  else
    # Process all available subdirectories
    subdirs_to_process=("${AVAILABLE_SUBDIRS[@]}")
    log_info "Processing all DevContainer configurations..."
  fi

  # Process each subdirectory
  local success_count=0
  local fail_count=0

  for subdir in "${subdirs_to_process[@]}"; do
    if setup_subdir "$subdir" "$env"; then
      success_count=$((success_count + 1))
    else
      fail_count=$((fail_count + 1))
    fi
  done

  # Summary
  echo ""
  if [ $fail_count -eq 0 ]; then
    log_info "✅ Setup complete! ($success_count configuration(s) updated)"
    return 0
  else
    log_error "Setup completed with errors ($success_count success, $fail_count failed)"
    return 1
  fi
}

# Run main function
main "$@"

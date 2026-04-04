#!/bin/bash
#
# start-cdp.sh
# Starts Chrome in remote debugging mode and socat port forwarder
# for E2E testing from devcontainer via CDP.
#
# Chrome's --remote-debugging-address=0.0.0.0 is silently ignored due to
# Chrome's security restrictions, so socat is used to forward the port
# to all interfaces.
#
# Usage:
#   bash scripts/start-cdp.sh
#
# Environment variables:
#   CHROME_DEBUG_PORT  - Chrome remote debugging port (default: 9223)
#   CDP_PORT           - socat listen port exposed to containers (default: 9224)
#

set -e

# --- Configuration ---
CHROME_DEBUG_PORT="${CHROME_DEBUG_PORT:-9223}"
CDP_PORT="${CDP_PORT:-9224}"
CHROME_USER_DATA_DIR="/tmp/chrome-debug"

# --- Color codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[CDP]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[CDP]${NC} $1"; }
log_error() { echo -e "${RED}[CDP]${NC} $1"; }

# --- WSL2 detection: skip on WSL2 ---
if grep -qi microsoft /proc/version 2>/dev/null; then
  log_warn "WSL2 environment detected — skipping CDP setup"
  exit 0
fi

# --- Dependency checks ---
CHROME_BIN=""
for candidate in google-chrome google-chrome-stable chromium-browser chromium; do
  if command -v "$candidate" >/dev/null 2>&1; then
    CHROME_BIN="$candidate"
    break
  fi
done

if [ -z "$CHROME_BIN" ]; then
  log_warn "Chrome not found — skipping CDP setup"
  exit 0
fi

if ! command -v socat >/dev/null 2>&1; then
  log_error "socat is required but not installed"
  exit 1
fi

# --- Duplicate launch prevention ---
start_chrome() {
  if pgrep -f "remote-debugging-port=${CHROME_DEBUG_PORT}" >/dev/null 2>&1; then
    log_info "Chrome CDP already running on port ${CHROME_DEBUG_PORT}"
    return 0
  fi

  log_info "Starting ${CHROME_BIN} with remote-debugging-port=${CHROME_DEBUG_PORT}..."
  "$CHROME_BIN" \
    --remote-debugging-port="${CHROME_DEBUG_PORT}" \
    --user-data-dir="${CHROME_USER_DATA_DIR}" \
    --no-first-run \
    &
  disown

  # Wait briefly for Chrome to bind the port
  local retries=10
  while [ "$retries" -gt 0 ]; do
    if ss -tln "sport = :${CHROME_DEBUG_PORT}" | grep -q LISTEN; then
      log_info "Chrome CDP ready on port ${CHROME_DEBUG_PORT}"
      return 0
    fi
    sleep 0.5
    retries=$((retries - 1))
  done

  log_error "Chrome did not start listening on port ${CHROME_DEBUG_PORT} within timeout"
  exit 1
}

start_socat() {
  if pgrep -f "TCP-LISTEN:${CDP_PORT}" >/dev/null 2>&1; then
    log_info "socat already running on port ${CDP_PORT}"
    return 0
  fi

  log_info "Starting socat ${CDP_PORT} -> 127.0.0.1:${CHROME_DEBUG_PORT}..."
  socat "TCP-LISTEN:${CDP_PORT},fork,bind=0.0.0.0" "TCP:127.0.0.1:${CHROME_DEBUG_PORT}" &
  disown

  log_info "socat ready on port ${CDP_PORT}"
}

# --- Main ---
start_chrome
start_socat

log_info "CDP bridge active: container -> :${CDP_PORT} -> Chrome :${CHROME_DEBUG_PORT}"

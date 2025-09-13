#!/bin/bash
# Package Installation Speed Measurement Script
# Tests npm and pip installation speeds in the DevContainer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/.devcontainer"
RESULTS_DIR="$SCRIPT_DIR/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create results directory
mkdir -p "$RESULTS_DIR"

echo "📦 Package Installation Speed Measurement"
echo "========================================"
echo "Timestamp: $(date)"
echo "DevContainer: $DEVCONTAINER_DIR"
echo ""

# Build container first
cd "$DEVCONTAINER_DIR"
IMAGE_NAME="devcontainer-package-test"

echo "🏗️  Building DevContainer for package tests..."
docker build -t "$IMAGE_NAME" . > /dev/null 2>&1

# Function to test npm package installation
test_npm_speed() {
    echo "📏 Testing npm package installation speed..."

    start_time=$(date +%s.%N)

    # Test installing a common package (lodash)
    docker run --rm "$IMAGE_NAME" bash -c "
        cd /tmp &&
        npm init -y > /dev/null 2>&1 &&
        npm install lodash > /dev/null 2>&1
    "

    end_time=$(date +%s.%N)
    npm_time=$(echo "$end_time - $start_time" | bc)

    echo "   ✅ npm install lodash: ${npm_time}s"
    echo "$npm_time" > "$RESULTS_DIR/npm_speed_$TIMESTAMP.txt"
}

# Function to test pip package installation
test_pip_speed() {
    echo "📏 Testing pip package installation speed..."

    start_time=$(date +%s.%N)

    # Test installing a common package (requests)
    docker run --rm "$IMAGE_NAME" bash -c "
        pip install --user requests > /dev/null 2>&1
    "

    end_time=$(date +%s.%N)
    pip_time=$(echo "$end_time - $start_time" | bc)

    echo "   ✅ pip install requests: ${pip_time}s"
    echo "$pip_time" > "$RESULTS_DIR/pip_speed_$TIMESTAMP.txt"
}

# Function to test package manager cache status
test_cache_status() {
    echo "📏 Analyzing current cache configuration..."

    # Check npm cache
    npm_cache_info=$(docker run --rm "$IMAGE_NAME" bash -c "npm config get cache 2>/dev/null || echo 'not-configured'")

    # Check pip cache
    pip_cache_info=$(docker run --rm "$IMAGE_NAME" bash -c "pip cache dir 2>/dev/null || echo 'not-configured'")

    echo "   npm cache: $npm_cache_info"
    echo "   pip cache: $pip_cache_info"

    # Save cache info
    cat > "$RESULTS_DIR/cache_status_$TIMESTAMP.txt" << EOF
npm_cache: $npm_cache_info
pip_cache: $pip_cache_info
EOF
}

# Run package speed tests
test_npm_speed
test_pip_speed
test_cache_status

# Read results
npm_time=$(cat "$RESULTS_DIR/npm_speed_$TIMESTAMP.txt")
pip_time=$(cat "$RESULTS_DIR/pip_speed_$TIMESTAMP.txt")

echo ""
echo "📊 Package Installation Statistics"
echo "=================================="
echo "npm (lodash):   ${npm_time}s"
echo "pip (requests): ${pip_time}s"

# Save summary
cat > "$RESULTS_DIR/package_speed_summary_$TIMESTAMP.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "measurements": {
    "npm_install_time": $npm_time,
    "pip_install_time": $pip_time
  },
  "test_packages": {
    "npm": "lodash",
    "pip": "requests"
  },
  "devcontainer_path": "$DEVCONTAINER_DIR"
}
EOF

# Clean up test image
docker rmi "$IMAGE_NAME" > /dev/null 2>&1 || true

echo ""
echo "💾 Results saved to: $RESULTS_DIR/package_speed_summary_$TIMESTAMP.json"
echo "🗂️  Cache info: $RESULTS_DIR/cache_status_$TIMESTAMP.txt"
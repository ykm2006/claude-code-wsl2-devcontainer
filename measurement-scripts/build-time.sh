#!/bin/bash
# Build Time Measurement Script
# Measures DevContainer build time with multiple iterations
# Usage: ./build-time.sh [baseline|optimization]
#   baseline: Full clean build (removes ALL cache)
#   optimization: Normal build (keeps cache for incremental improvements)

set -e

# Parse mode argument (default: optimization)
MODE=${1:-optimization}

if [[ "$MODE" != "baseline" && "$MODE" != "optimization" ]]; then
    echo "❌ Invalid mode: $MODE"
    echo "Usage: $0 [baseline|optimization]"
    echo "  baseline:     Full clean build (removes ALL cache)"
    echo "  optimization: Normal build (keeps cache)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set DevContainer directory - use environment variable if provided, otherwise auto-detect
if [[ -z "$DEVCONTAINER_DIR" ]]; then
    if [[ "$MODE" == "baseline" ]]; then
        # Use parent directory's .devcontainer (original working config)
        DEVCONTAINER_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/.devcontainer"
    else
        # Use current directory's .devcontainer (optimization test)
        DEVCONTAINER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/.devcontainer"
    fi
fi

RESULTS_DIR="$SCRIPT_DIR/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create results directory
mkdir -p "$RESULTS_DIR"

echo "🏗️  DevContainer Build Time Measurement"
echo "======================================="
echo "Mode: $MODE"
echo "Timestamp: $(date)"
echo "DevContainer: $DEVCONTAINER_DIR"
echo ""

# Function to measure single build
measure_build() {
    local iteration=$1
    echo "📏 Build iteration $iteration/3..."

    if [[ "$MODE" == "baseline" ]]; then
        echo "   🧹 Cleaning ALL Docker build cache (baseline mode)..."
        # Remove ALL build cache for true baseline
        docker builder prune -af > /dev/null 2>&1 || true
        # Also remove any dangling images
        docker image prune -af > /dev/null 2>&1 || true
    else
        echo "   ♻️  Keeping build cache (optimization mode)..."
        # Only clean up containers/networks, keep build cache
        docker system prune -f > /dev/null 2>&1 || true
    fi

    # Set BuildKit based on mode
    if [[ "$MODE" == "optimization" ]]; then
        export DOCKER_BUILDKIT=1
        echo "   🚀 BuildKit enabled"
    else
        export DOCKER_BUILDKIT=0
        echo "   📦 BuildKit disabled (baseline)"
    fi

    # Measure build time
    start_time=$(date +%s.%N)

    # Build the devcontainer (using same method as VS Code)
    cd "$DEVCONTAINER_DIR"
    docker build -t devcontainer-build-test-$iteration . > /dev/null 2>&1

    end_time=$(date +%s.%N)
    build_time=$(echo "$end_time - $start_time" | bc)

    echo "   ✅ Iteration $iteration: ${build_time}s"
    echo "$build_time" >> "$RESULTS_DIR/build_times_$TIMESTAMP.txt"

    # Clean up test image
    docker rmi devcontainer-build-test-$iteration > /dev/null 2>&1 || true
}

# Run 3 build iterations
echo "Running 3 build iterations for accurate measurement..."
for i in {1..3}; do
    measure_build $i
done

# Calculate statistics
echo ""
echo "📊 Build Time Statistics"
echo "========================"

# Read results and calculate stats
times_file="$RESULTS_DIR/build_times_$TIMESTAMP.txt"
avg_time=$(awk '{sum+=$1} END {print sum/NR}' "$times_file")
min_time=$(sort -n "$times_file" | head -1)
max_time=$(sort -nr "$times_file" | head -1)

echo "Average: ${avg_time}s"
echo "Minimum: ${min_time}s"
echo "Maximum: ${max_time}s"

# Save summary with mode information
cat > "$RESULTS_DIR/build_summary_${MODE}_$TIMESTAMP.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "mode": "$MODE",
  "measurements": {
    "build_time_avg": $avg_time,
    "build_time_min": $min_time,
    "build_time_max": $max_time
  },
  "iterations": 3,
  "devcontainer_path": "$DEVCONTAINER_DIR",
  "buildkit_enabled": $([ "$MODE" == "optimization" ] && echo "true" || echo "false"),
  "cache_cleared": $([ "$MODE" == "baseline" ] && echo "true" || echo "false")
}
EOF

echo ""
echo "💾 Results saved to: $RESULTS_DIR/build_summary_${MODE}_$TIMESTAMP.json"
echo "📈 Raw data: $times_file"
echo ""
echo "📝 Mode: $MODE ($([ "$MODE" == "baseline" ] && echo "cache cleared, BuildKit disabled" || echo "cache preserved, BuildKit enabled"))"
#!/bin/bash
# Build Time Measurement Script
# Measures DevContainer build time with multiple iterations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/.devcontainer"
RESULTS_DIR="$SCRIPT_DIR/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create results directory
mkdir -p "$RESULTS_DIR"

echo "🏗️  DevContainer Build Time Measurement"
echo "======================================="
echo "Timestamp: $(date)"
echo "DevContainer: $DEVCONTAINER_DIR"
echo ""

# Function to measure single build
measure_build() {
    local iteration=$1
    echo "📏 Build iteration $iteration/3..."

    # Clean up any existing containers
    docker system prune -f > /dev/null 2>&1 || true

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

# Save summary
cat > "$RESULTS_DIR/build_summary_$TIMESTAMP.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "measurements": {
    "build_time_avg": $avg_time,
    "build_time_min": $min_time,
    "build_time_max": $max_time
  },
  "iterations": 3,
  "devcontainer_path": "$DEVCONTAINER_DIR"
}
EOF

echo ""
echo "💾 Results saved to: $RESULTS_DIR/build_summary_$TIMESTAMP.json"
echo "📈 Raw data: $times_file"
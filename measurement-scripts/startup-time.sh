#!/bin/bash
# Container Startup Time Measurement Script
# Measures DevContainer startup time with multiple iterations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use environment variable DEVCONTAINER_DIR if provided, otherwise default
if [[ -z "$DEVCONTAINER_DIR" ]]; then
    DEVCONTAINER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/.devcontainer"
fi
RESULTS_DIR="$SCRIPT_DIR/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create results directory
mkdir -p "$RESULTS_DIR"

echo "🚀 DevContainer Startup Time Measurement"
echo "========================================"
echo "Timestamp: $(date)"
echo "DevContainer: $DEVCONTAINER_DIR"
echo ""

# Function to measure single startup
measure_startup() {
    local iteration=$1
    echo "📏 Startup iteration $iteration/5..."

    # Build container first (if not exists)
    cd "$DEVCONTAINER_DIR"
    if ! docker images | grep -q "devcontainer-startup-test"; then
        echo "   🏗️  Building container for startup test..."
        docker build -t devcontainer-startup-test . > /dev/null 2>&1
    fi

    # Stop any existing containers
    docker stop devcontainer-startup-test-$iteration > /dev/null 2>&1 || true
    docker rm devcontainer-startup-test-$iteration > /dev/null 2>&1 || true

    # Measure startup time (container start + shell ready)
    start_time=$(date +%s.%N)

    # Start container with same mount configuration as devcontainer
    docker run -d \
        --name devcontainer-startup-test-$iteration \
        --mount type=bind,source=/workspace,target=/workspace \
        devcontainer-startup-test \
        sleep 30 > /dev/null

    # Wait for container to be fully ready (test shell access)
    until docker exec devcontainer-startup-test-$iteration echo "ready" > /dev/null 2>&1; do
        sleep 0.1
    done

    end_time=$(date +%s.%N)
    startup_time=$(echo "$end_time - $start_time" | bc)

    echo "   ✅ Iteration $iteration: ${startup_time}s"
    echo "$startup_time" >> "$RESULTS_DIR/startup_times_$TIMESTAMP.txt"

    # Clean up container
    docker stop devcontainer-startup-test-$iteration > /dev/null 2>&1
    docker rm devcontainer-startup-test-$iteration > /dev/null 2>&1
}

# Run 5 startup iterations
echo "Running 5 startup iterations for accurate measurement..."
for i in {1..5}; do
    measure_startup $i
done

# Calculate statistics
echo ""
echo "📊 Startup Time Statistics"
echo "=========================="

# Read results and calculate stats
times_file="$RESULTS_DIR/startup_times_$TIMESTAMP.txt"
avg_time=$(awk '{sum+=$1} END {print sum/NR}' "$times_file")
min_time=$(sort -n "$times_file" | head -1)
max_time=$(sort -nr "$times_file" | head -1)

echo "Average: ${avg_time}s"
echo "Minimum: ${min_time}s"
echo "Maximum: ${max_time}s"

# Save summary
cat > "$RESULTS_DIR/startup_summary_$TIMESTAMP.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "measurements": {
    "startup_time_avg": $avg_time,
    "startup_time_min": $min_time,
    "startup_time_max": $max_time
  },
  "iterations": 5,
  "devcontainer_path": "$DEVCONTAINER_DIR"
}
EOF

# Clean up test image
docker rmi devcontainer-startup-test > /dev/null 2>&1 || true

echo ""
echo "💾 Results saved to: $RESULTS_DIR/startup_summary_$TIMESTAMP.json"
echo "📈 Raw data: $times_file"
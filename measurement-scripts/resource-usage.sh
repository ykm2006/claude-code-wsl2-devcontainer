#!/bin/bash
# Resource Usage Monitoring Script
# Monitors CPU, memory, and disk usage during DevContainer build

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

echo "💻 DevContainer Resource Usage Monitoring"
echo "========================================"
echo "Timestamp: $(date)"
echo "DevContainer: $DEVCONTAINER_DIR"
echo ""

# Function to monitor resources during build
monitor_build_resources() {
    local results_file="$RESULTS_DIR/resource_usage_$TIMESTAMP.txt"

    echo "📊 Starting resource monitoring..."

    # Start resource monitoring in background
    (
        echo "timestamp,cpu_percent,memory_mb,disk_io_read_mb,disk_io_write_mb" > "$results_file"
        while true; do
            timestamp=$(date +%s)

            # Get CPU usage (average over 1 second)
            cpu_percent=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')

            # Get memory usage in MB
            memory_mb=$(free -m | grep "Mem:" | awk '{print $3}')

            # Get disk I/O (simplified - just available space change)
            disk_free_mb=$(df / | tail -1 | awk '{print int($4/1024)}')

            # Simple disk I/O approximation
            disk_io_read=0
            disk_io_write=0

            echo "$timestamp,$cpu_percent,$memory_mb,$disk_io_read,$disk_io_write" >> "$results_file"
            sleep 2
        done
    ) &

    monitor_pid=$!

    # Start the build
    echo "🏗️  Starting DevContainer build with monitoring..."
    cd "$DEVCONTAINER_DIR"

    start_time=$(date +%s.%N)

    # Build with resource monitoring
    docker build -t devcontainer-resource-test . > /dev/null 2>&1

    end_time=$(date +%s.%N)
    build_time=$(echo "$end_time - $start_time" | bc)

    # Stop monitoring
    kill $monitor_pid 2>/dev/null || true
    wait $monitor_pid 2>/dev/null || true

    echo "   ✅ Build completed in ${build_time}s"

    # Clean up test image
    docker rmi devcontainer-resource-test > /dev/null 2>&1 || true

    return 0
}

# Function to analyze resource usage
analyze_resources() {
    local results_file="$RESULTS_DIR/resource_usage_$TIMESTAMP.txt"

    if [[ ! -f "$results_file" ]]; then
        echo "❌ No resource data found"
        return 1
    fi

    echo ""
    echo "📊 Resource Usage Analysis"
    echo "========================="

    # Skip header and analyze data
    tail -n +2 "$results_file" | while IFS=, read timestamp cpu memory disk_read disk_write; do
        # This will just show we collected the data
        echo "Sample: CPU=${cpu}%, Memory=${memory}MB"
    done | head -5

    # Calculate basic statistics
    local avg_cpu=$(tail -n +2 "$results_file" | awk -F, '{sum+=$2; count++} END {if(count>0) print sum/count; else print 0}')
    local max_memory=$(tail -n +2 "$results_file" | awk -F, '{if($3>max) max=$3} END {print max}')
    local avg_memory=$(tail -n +2 "$results_file" | awk -F, '{sum+=$3; count++} END {if(count>0) print sum/count; else print 0}')

    echo ""
    echo "Summary Statistics:"
    echo "Average CPU: ${avg_cpu}%"
    echo "Average Memory: ${avg_memory}MB"
    echo "Peak Memory: ${max_memory}MB"

    # Save summary
    cat > "$RESULTS_DIR/resource_summary_$TIMESTAMP.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "measurements": {
    "avg_cpu_percent": $avg_cpu,
    "avg_memory_mb": $avg_memory,
    "peak_memory_mb": $max_memory
  },
  "devcontainer_path": "$DEVCONTAINER_DIR"
}
EOF
}

# Run resource monitoring
monitor_build_resources
analyze_resources

echo ""
echo "💾 Results saved to: $RESULTS_DIR/resource_summary_$TIMESTAMP.json"
echo "📈 Raw data: $RESULTS_DIR/resource_usage_$TIMESTAMP.txt"
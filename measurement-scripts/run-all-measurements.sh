#!/bin/bash
# Master Measurement Script
# Runs all measurement scripts and generates comprehensive report

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create results directory
mkdir -p "$RESULTS_DIR"

echo "🔬 DevContainer Comprehensive Performance Measurement"
echo "=================================================="
echo "Timestamp: $(date)"
echo "Results will be saved to: $RESULTS_DIR"
echo ""

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Docker environment cleanup for accurate measurements
echo "🧹 Cleaning up Docker environment for accurate measurements..."
echo "   This ensures clean baseline without interference from existing containers/images"

# Clean up Docker resources with progress indication
echo "   🗑️  Removing unused containers..."
docker container prune -f > /dev/null 2>&1 || true

echo "   🗑️  Removing unused images..."
docker image prune -af > /dev/null 2>&1 || true

echo "   🗑️  Removing unused volumes..."
docker volume prune -f > /dev/null 2>&1 || true

echo "   🗑️  Removing unused networks..."
docker network prune -f > /dev/null 2>&1 || true

echo "   🗑️  Final system cleanup..."
docker system prune -f > /dev/null 2>&1 || true

echo "   ✅ Docker environment cleaned"
echo ""

# Show current Docker status
echo "🐳 Current Docker Status:"
docker_images=$(docker images -q | wc -l)
docker_containers=$(docker ps -aq | wc -l)
echo "   Images: $docker_images"
echo "   Containers: $docker_containers"
echo "   Ready for clean baseline measurement"
echo ""

# Function to run measurement with error handling
run_measurement() {
    local script_name=$1
    local description=$2

    echo "🔄 Running $description..."

    # Create error log file
    local error_log="$RESULTS_DIR/error_${script_name%.*}_$TIMESTAMP.log"

    if bash "$SCRIPT_DIR/$script_name" 2>&1 | tee "$error_log.tmp"; then
        echo "   ✅ $description completed successfully"
        # Move successful output to info log
        mv "$error_log.tmp" "${error_log%.*}_success.log"
        return 0
    else
        echo "   ❌ $description failed"
        echo "   📝 Error details saved to: $error_log"
        # Keep error output in error log
        mv "$error_log.tmp" "$error_log"

        # Add error summary to main report
        echo "ERROR in $description:" >> "$RESULTS_DIR/error_summary_$TIMESTAMP.txt"
        echo "Script: $script_name" >> "$RESULTS_DIR/error_summary_$TIMESTAMP.txt"
        echo "Time: $(date)" >> "$RESULTS_DIR/error_summary_$TIMESTAMP.txt"
        echo "Details in: $error_log" >> "$RESULTS_DIR/error_summary_$TIMESTAMP.txt"
        echo "---" >> "$RESULTS_DIR/error_summary_$TIMESTAMP.txt"

        return 1
    fi
    echo ""
}

# Run all measurements
echo "Starting comprehensive measurement suite..."
echo ""

run_measurement "image-size.sh" "Image Size Analysis"
run_measurement "build-time.sh" "Build Time Measurement"
run_measurement "startup-time.sh" "Startup Time Measurement"
run_measurement "package-speed.sh" "Package Installation Speed"
run_measurement "resource-usage.sh" "Resource Usage Monitoring"

# Generate comprehensive report
echo "📋 Generating Comprehensive Report"
echo "=================================="

REPORT_FILE="$RESULTS_DIR/baseline_report_$TIMESTAMP.md"

cat > "$REPORT_FILE" << 'EOF'
# DevContainer Performance Baseline Report

**Generated**: $(date)
**Measurement Session**: $TIMESTAMP

## Executive Summary

This report provides baseline performance measurements for the DevContainer optimization project. All measurements represent the current working configuration before any optimizations.

## Measurement Results

### Build Performance
EOF

# Add build time results if available
BUILD_JSON=$(ls "$RESULTS_DIR"/build_summary_*.json 2>/dev/null | tail -1 || echo "")
if [[ -n "$BUILD_JSON" && -f "$BUILD_JSON" ]]; then
    BUILD_AVG=$(jq -r '.measurements.build_time_avg' "$BUILD_JSON" 2>/dev/null || echo "N/A")
    cat >> "$REPORT_FILE" << EOF
- **Average Build Time**: ${BUILD_AVG}s
- **Measurement Method**: 3 iterations with clean builds
EOF
fi

cat >> "$REPORT_FILE" << 'EOF'

### Startup Performance
EOF

# Add startup time results if available
STARTUP_JSON=$(ls "$RESULTS_DIR"/startup_summary_*.json 2>/dev/null | tail -1 || echo "")
if [[ -n "$STARTUP_JSON" && -f "$STARTUP_JSON" ]]; then
    STARTUP_AVG=$(jq -r '.measurements.startup_time_avg' "$STARTUP_JSON" 2>/dev/null || echo "N/A")
    cat >> "$REPORT_FILE" << EOF
- **Average Startup Time**: ${STARTUP_AVG}s
- **Measurement Method**: 5 iterations with container start + shell ready
EOF
fi

cat >> "$REPORT_FILE" << 'EOF'

### Image Size Analysis
EOF

# Add image size results if available
SIZE_JSON=$(ls "$RESULTS_DIR"/size_analysis_*.json 2>/dev/null | tail -1 || echo "")
if [[ -n "$SIZE_JSON" && -f "$SIZE_JSON" ]]; then
    IMAGE_SIZE=$(jq -r '.measurements.image_size_human' "$SIZE_JSON" 2>/dev/null || echo "N/A")
    CONTEXT_SIZE=$(jq -r '.measurements.build_context_size_human' "$SIZE_JSON" 2>/dev/null || echo "N/A")
    LAYER_COUNT=$(jq -r '.measurements.layer_count' "$SIZE_JSON" 2>/dev/null || echo "N/A")
    cat >> "$REPORT_FILE" << EOF
- **Final Image Size**: ${IMAGE_SIZE}
- **Build Context Size**: ${CONTEXT_SIZE}
- **Total Layers**: ${LAYER_COUNT}
EOF
fi

cat >> "$REPORT_FILE" << 'EOF'

### Package Installation Speed
EOF

# Add package speed results if available
PACKAGE_JSON=$(ls "$RESULTS_DIR"/package_speed_summary_*.json 2>/dev/null | tail -1 || echo "")
if [[ -n "$PACKAGE_JSON" && -f "$PACKAGE_JSON" ]]; then
    NPM_TIME=$(jq -r '.measurements.npm_install_time' "$PACKAGE_JSON" 2>/dev/null || echo "N/A")
    PIP_TIME=$(jq -r '.measurements.pip_install_time' "$PACKAGE_JSON" 2>/dev/null || echo "N/A")
    cat >> "$REPORT_FILE" << EOF
- **npm install (lodash)**: ${NPM_TIME}s
- **pip install (requests)**: ${PIP_TIME}s
EOF
fi

cat >> "$REPORT_FILE" << 'EOF'

### Resource Usage
EOF

# Add resource usage results if available
RESOURCE_JSON=$(ls "$RESULTS_DIR"/resource_summary_*.json 2>/dev/null | tail -1 || echo "")
if [[ -n "$RESOURCE_JSON" && -f "$RESOURCE_JSON" ]]; then
    AVG_CPU=$(jq -r '.measurements.avg_cpu_percent' "$RESOURCE_JSON" 2>/dev/null || echo "N/A")
    PEAK_MEMORY=$(jq -r '.measurements.peak_memory_mb' "$RESOURCE_JSON" 2>/dev/null || echo "N/A")
    cat >> "$REPORT_FILE" << EOF
- **Average CPU Usage**: ${AVG_CPU}%
- **Peak Memory Usage**: ${PEAK_MEMORY}MB
EOF
fi

cat >> "$REPORT_FILE" << 'EOF'

## Next Steps

These baseline measurements will be used to validate the success of optimization efforts in subsequent phases. Target improvements:

- **Build Time**: 10-20% reduction
- **Package Operations**: 15-30% faster
- **No startup time degradation**
- **Maintain identical functionality**

## Data Files

All raw measurement data is available in the results directory with timestamp: $TIMESTAMP

EOF

# Replace timestamp in report
sed -i "s/\$TIMESTAMP/$TIMESTAMP/g" "$REPORT_FILE"

# Check if any errors occurred
if [[ -f "$RESULTS_DIR/error_summary_$TIMESTAMP.txt" ]]; then
    echo "⚠️  Some measurements completed with errors!"
    echo ""
    echo "📊 Results Summary:"
    echo "   📋 Report: $REPORT_FILE"
    echo "   📁 Data: $RESULTS_DIR"
    echo "   🔢 Files: $(ls "$RESULTS_DIR"/*_$TIMESTAMP.* 2>/dev/null | wc -l) measurement files"
    echo "   ❌ Error Summary: $RESULTS_DIR/error_summary_$TIMESTAMP.txt"
    echo ""
    echo "🔍 Error Details:"
    cat "$RESULTS_DIR/error_summary_$TIMESTAMP.txt"
    echo ""
    echo "⚠️  Please review errors before proceeding to Phase 2"
else
    echo "✅ Comprehensive measurement complete!"
    echo ""
    echo "📊 Results Summary:"
    echo "   📋 Report: $REPORT_FILE"
    echo "   📁 Data: $RESULTS_DIR"
    echo "   🔢 Files: $(ls "$RESULTS_DIR"/*_$TIMESTAMP.* 2>/dev/null | wc -l) measurement files"
    echo ""
    echo "🎯 Baseline established! Ready for optimization phases."
fi
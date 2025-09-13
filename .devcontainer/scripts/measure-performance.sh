#!/bin/bash

# DevContainer Performance Measurement Script
# Measures build time, startup time, and file I/O performance

set -e

RESULTS_DIR=".devcontainer/performance-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULT_FILE="$RESULTS_DIR/baseline_${TIMESTAMP}.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${GREEN}=== DevContainer Performance Measurement ===${NC}"
echo "Timestamp: $TIMESTAMP"
echo ""

# Initialize JSON result
cat > "$RESULT_FILE" << EOF
{
  "timestamp": "$TIMESTAMP",
  "platform": "$(uname -a)",
  "docker_version": "$(docker --version)",
  "measurements": {
EOF

# Function to measure command execution time
measure_time() {
    local command="$1"
    local name="$2"

    echo -e "${YELLOW}Measuring: $name${NC}"

    local start=$(date +%s.%N)
    eval "$command" > /dev/null 2>&1
    local end=$(date +%s.%N)

    local duration=$(echo "$end - $start" | bc)
    echo "Duration: ${duration}s"
    echo ""

    echo "$duration"
}

# 1. Measure Docker build time (without cache)
echo -e "${GREEN}1. Docker Build Time (no cache)${NC}"
docker builder prune -af > /dev/null 2>&1 || true
BUILD_TIME=$(measure_time "docker build -f .devcontainer/Dockerfile -t devcontainer-baseline:test ." "Docker Build")

cat >> "$RESULT_FILE" << EOF
    "docker_build_no_cache": $BUILD_TIME,
EOF

# 2. Measure Docker build time (with cache)
echo -e "${GREEN}2. Docker Build Time (with cache)${NC}"
BUILD_TIME_CACHED=$(measure_time "docker build -f .devcontainer/Dockerfile -t devcontainer-baseline:test ." "Docker Build (Cached)")

cat >> "$RESULT_FILE" << EOF
    "docker_build_cached": $BUILD_TIME_CACHED,
EOF

# 3. Measure container startup time
echo -e "${GREEN}3. Container Startup Time${NC}"
STARTUP_TIME=$(measure_time "docker run --rm devcontainer-baseline:test echo 'Container started'" "Container Startup")

cat >> "$RESULT_FILE" << EOF
    "container_startup": $STARTUP_TIME,
EOF

# 4. Measure file I/O performance inside container
echo -e "${GREEN}4. File I/O Performance${NC}"
echo "Creating test container for I/O measurements..."

# Write test (1000 small files)
WRITE_TEST=$(docker run --rm devcontainer-baseline:test bash -c "
    start=\$(date +%s.%N)
    for i in {1..1000}; do
        echo 'test data' > /tmp/test_\$i.txt
    done
    end=\$(date +%s.%N)
    echo \$end - \$start | bc
")
echo "Write 1000 files: ${WRITE_TEST}s"

# Read test
READ_TEST=$(docker run --rm devcontainer-baseline:test bash -c "
    for i in {1..1000}; do
        echo 'test data' > /tmp/test_\$i.txt
    done
    start=\$(date +%s.%N)
    for i in {1..1000}; do
        cat /tmp/test_\$i.txt > /dev/null
    done
    end=\$(date +%s.%N)
    echo \$end - \$start | bc
")
echo "Read 1000 files: ${READ_TEST}s"
echo ""

cat >> "$RESULT_FILE" << EOF
    "file_io_write_1000": $WRITE_TEST,
    "file_io_read_1000": $READ_TEST,
EOF

# 5. Measure npm install performance
echo -e "${GREEN}5. NPM Install Performance${NC}"
# Create a test package.json
cat > /tmp/test-package.json << 'EOFPKG'
{
  "name": "test-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0",
    "axios": "^1.4.0",
    "lodash": "^4.17.21"
  }
}
EOFPKG

NPM_TIME=$(docker run --rm -v /tmp/test-package.json:/app/package.json -w /app devcontainer-baseline:test bash -c "
    start=\$(date +%s.%N)
    npm install > /dev/null 2>&1
    end=\$(date +%s.%N)
    echo \$end - \$start | bc
")
echo "NPM install time: ${NPM_TIME}s"
echo ""

# Close JSON
cat >> "$RESULT_FILE" << EOF
    "npm_install": $NPM_TIME
  },
  "summary": {
    "total_build_time_no_cache": $BUILD_TIME,
    "total_build_time_cached": $BUILD_TIME_CACHED,
    "startup_overhead": $STARTUP_TIME,
    "io_operations_per_second": $(echo "scale=2; 1000 / $WRITE_TEST" | bc),
    "npm_dependency_resolution": $NPM_TIME
  }
}
EOF

echo -e "${GREEN}=== Performance Measurement Complete ===${NC}"
echo "Results saved to: $RESULT_FILE"
echo ""
echo "Summary:"
cat "$RESULT_FILE" | grep -A 10 '"summary"' | tail -n +2 | head -n -1

# Clean up test image
docker rmi devcontainer-baseline:test > /dev/null 2>&1 || true
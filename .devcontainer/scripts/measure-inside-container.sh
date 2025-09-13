#!/bin/bash

# DevContainer Internal Performance Measurement Script
# Measures performance from inside the container

set -e

RESULTS_DIR=".devcontainer/performance-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULT_FILE="$RESULTS_DIR/internal_baseline_${TIMESTAMP}.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${GREEN}=== DevContainer Internal Performance Measurement ===${NC}"
echo "Timestamp: $TIMESTAMP"
echo "Environment: Inside DevContainer"
echo ""

# Function to measure command execution time
measure_time() {
    local command="$1"
    local name="$2"

    echo "Measuring: $name"

    local start=$(date +%s.%N)
    eval "$command" > /dev/null 2>&1
    local end=$(date +%s.%N)

    local duration=$(echo "$end - $start" | bc)
    echo "Duration: ${duration}s"
    echo ""

    echo "$duration"
}

# Initialize JSON result
cat > "$RESULT_FILE" << EOF
{
  "timestamp": "$TIMESTAMP",
  "environment": "devcontainer",
  "platform": "$(uname -a)",
  "node_version": "$(node --version)",
  "npm_version": "$(npm --version)",
  "python_version": "$(python3 --version)",
  "measurements": {
EOF

# 1. File I/O Performance Tests
echo -e "${GREEN}1. File I/O Performance (Current Workspace)${NC}"

# Write test (1000 small files)
WRITE_TIME=$(measure_time "
    mkdir -p /tmp/io_test
    for i in {1..1000}; do
        echo 'test data line 1
test data line 2
test data line 3' > /tmp/io_test/test_\$i.txt
    done
" "Write 1000 files")

# Read test
READ_TIME=$(measure_time "
    for i in {1..1000}; do
        cat /tmp/io_test/test_\$i.txt > /dev/null
    done
" "Read 1000 files")

# Delete test
DELETE_TIME=$(measure_time "rm -rf /tmp/io_test" "Delete 1000 files")

cat >> "$RESULT_FILE" << EOF
    "file_write_1000": $WRITE_TIME,
    "file_read_1000": $READ_TIME,
    "file_delete_1000": $DELETE_TIME,
EOF

# 2. NPM Performance Tests
echo -e "${GREEN}2. NPM Package Manager Performance${NC}"

# Create test package.json
mkdir -p /tmp/npm_test
cat > /tmp/npm_test/package.json << 'EOFPKG'
{
  "name": "perf-test",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0",
    "axios": "^1.4.0",
    "lodash": "^4.17.21",
    "moment": "^2.29.0",
    "uuid": "^9.0.0"
  }
}
EOFPKG

cd /tmp/npm_test
NPM_INSTALL=$(measure_time "npm install --no-audit --no-fund" "NPM Install (5 packages)")
NPM_CI=$(measure_time "rm -rf node_modules && npm ci --no-audit --no-fund" "NPM CI (clean install)")
cd - > /dev/null

cat >> "$RESULT_FILE" << EOF
    "npm_install": $NPM_INSTALL,
    "npm_ci": $NPM_CI,
EOF

# 3. Git Operations Performance
echo -e "${GREEN}3. Git Operations Performance${NC}"

# Clone a small repo
GIT_CLONE=$(measure_time "
    cd /tmp
    rm -rf test-repo
    git clone --depth 1 https://github.com/octocat/Hello-World.git test-repo
" "Git Clone (shallow)")

cat >> "$RESULT_FILE" << EOF
    "git_clone_shallow": $GIT_CLONE,
EOF

# 4. Compilation Performance (TypeScript)
echo -e "${GREEN}4. TypeScript Compilation Performance${NC}"

mkdir -p /tmp/ts_test
cat > /tmp/ts_test/tsconfig.json << 'EOFTS'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist"
  }
}
EOFTS

# Create 10 TypeScript files
for i in {1..10}; do
    cat > /tmp/ts_test/file$i.ts << EOFTS
export interface TestInterface$i {
    id: number;
    name: string;
    data: any[];
}

export class TestClass$i implements TestInterface$i {
    constructor(public id: number, public name: string, public data: any[]) {}

    process(): void {
        console.log(\`Processing \${this.name}\`);
    }
}

export function testFunction$i(input: string): string {
    return \`Processed: \${input}\`;
}
EOFTS
done

cd /tmp/ts_test
TSC_COMPILE=$(measure_time "tsc" "TypeScript Compile (10 files)")
cd - > /dev/null

cat >> "$RESULT_FILE" << EOF
    "typescript_compile": $TSC_COMPILE,
EOF

# 5. Python Performance
echo -e "${GREEN}5. Python Performance${NC}"

cat > /tmp/python_test.py << 'EOFPY'
import time

def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# Calculate fibonacci(30)
start = time.time()
result = fibonacci(30)
end = time.time()
print(f"{end - start}")
EOFPY

PYTHON_FIB=$(python3 /tmp/python_test.py)
echo "Python Fibonacci(30): ${PYTHON_FIB}s"

cat >> "$RESULT_FILE" << EOF
    "python_fibonacci_30": $PYTHON_FIB,
EOF

# 6. System Resource Check
echo -e "${GREEN}6. System Resources${NC}"

MEMORY_AVAILABLE=$(free -m | awk 'NR==2{printf "%.1f", $7/1024}')
CPU_CORES=$(nproc)
DISK_AVAILABLE=$(df -h /workspace | awk 'NR==2{print $4}')

echo "Available Memory: ${MEMORY_AVAILABLE}GB"
echo "CPU Cores: ${CPU_CORES}"
echo "Disk Available: ${DISK_AVAILABLE}"
echo ""

# Close JSON
cat >> "$RESULT_FILE" << EOF
    "memory_available_gb": $MEMORY_AVAILABLE,
    "cpu_cores": $CPU_CORES
  },
  "summary": {
    "io_operations_per_second": $(echo "scale=2; 1000 / $WRITE_TIME" | bc),
    "npm_package_install_rate": $(echo "scale=2; 5 / $NPM_INSTALL" | bc),
    "typescript_files_per_second": $(echo "scale=2; 10 / $TSC_COMPILE" | bc),
    "environment": "devcontainer_internal",
    "total_io_time": $(echo "scale=2; $WRITE_TIME + $READ_TIME + $DELETE_TIME" | bc),
    "total_npm_time": $(echo "scale=2; $NPM_INSTALL + $NPM_CI" | bc)
  }
}
EOF

echo -e "${GREEN}=== Performance Measurement Complete ===${NC}"
echo "Results saved to: $RESULT_FILE"
echo ""
echo "Key Metrics:"
echo "- I/O Performance: $(echo "scale=2; 1000 / $WRITE_TIME" | bc) files/sec"
echo "- NPM Install: ${NPM_INSTALL}s for 5 packages"
echo "- TypeScript Compile: ${TSC_COMPILE}s for 10 files"
echo "- Python Fibonacci(30): ${PYTHON_FIB}s"

# Cleanup
rm -rf /tmp/io_test /tmp/npm_test /tmp/ts_test /tmp/test-repo /tmp/python_test.py 2>/dev/null || true
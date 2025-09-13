#!/bin/bash
# Image Size Measurement Script
# Measures DevContainer image size and layer breakdown

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

echo "📦 DevContainer Image Size Measurement"
echo "======================================"
echo "Timestamp: $(date)"
echo "DevContainer: $DEVCONTAINER_DIR"
echo ""

# Build the image if it doesn't exist
cd "$DEVCONTAINER_DIR"
IMAGE_NAME="devcontainer-size-test"

echo "🏗️  Building DevContainer image..."
docker build -t "$IMAGE_NAME" . > /dev/null 2>&1

# Get image size
echo "📏 Measuring image size..."
image_size_human=$(docker images --format "table {{.Size}}" "$IMAGE_NAME" | tail -1)
# Convert to bytes with improved handling of Docker's format (e.g., "3.15GB")
image_size_bytes=$(echo "$image_size_human" | sed 's/B$//' | numfmt --from=iec)

echo "Image Size: $image_size_human (${image_size_bytes} bytes)"

# Get layer information
echo ""
echo "📋 Layer Analysis"
echo "=================="
docker history "$IMAGE_NAME" --format "table {{.CreatedBy}}\t{{.Size}}" | head -20

# Get detailed layer sizes
layer_info=$(docker history "$IMAGE_NAME" --format "{{.Size}}\t{{.CreatedBy}}" | head -20)

# Count layers
layer_count=$(docker history "$IMAGE_NAME" --quiet | wc -l)
echo ""
echo "Total Layers: $layer_count"

# Measure build context size
echo ""
echo "🏗️  Build Context Analysis"
echo "=========================="
context_size=$(du -sb . | cut -f1)
context_size_human=$(du -sh . | cut -f1)

echo "Build Context Size: $context_size_human (${context_size} bytes)"

# List largest files in build context
echo ""
echo "Largest files in build context:"
find . -type f -exec du -b {} \; | sort -rn | head -10 | while read size file; do
    size_human=$(numfmt --to=iec $size)
    echo "  $size_human - $file"
done

# Save detailed results
cat > "$RESULTS_DIR/size_analysis_$TIMESTAMP.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "measurements": {
    "image_size_bytes": $image_size_bytes,
    "image_size_human": "$image_size_human",
    "build_context_size_bytes": $context_size,
    "build_context_size_human": "$context_size_human",
    "layer_count": $layer_count
  },
  "devcontainer_path": "$DEVCONTAINER_DIR"
}
EOF

# Save layer details
echo "$layer_info" > "$RESULTS_DIR/layer_details_$TIMESTAMP.txt"

# Clean up test image
docker rmi "$IMAGE_NAME" > /dev/null 2>&1 || true

echo ""
echo "💾 Results saved to: $RESULTS_DIR/size_analysis_$TIMESTAMP.json"
echo "📈 Layer details: $RESULTS_DIR/layer_details_$TIMESTAMP.txt"
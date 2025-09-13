# DevContainer Performance Measurement Guide

## 🎯 Purpose
Accurate performance measurement for DevContainer optimization requires proper methodology to distinguish between cached builds and true baseline performance.

## 📊 Measurement Modes

### Baseline Mode
**Purpose**: Establish true build time without any cache
```bash
./build-time.sh baseline
```
- ✅ Uses `../../.devcontainer/` (original working configuration)
- ✅ Clears ALL Docker build cache
- ✅ Removes all dangling images
- ✅ BuildKit disabled (traditional build)
- ✅ Measures real from-scratch build time

### Optimization Mode
**Purpose**: Measure incremental improvements with cache
```bash
./build-time.sh optimization
```
- ✅ Uses `./.devcontainer/` (optimized test configuration)
- ✅ Preserves Docker build cache
- ✅ BuildKit enabled for parallel builds
- ✅ Measures optimized build performance
- ✅ Shows impact of layer consolidation

## 📁 Directory Structure
```
~/WORK/
├── .devcontainer/              # Original working config (baseline)
│   ├── Dockerfile              # 183 lines, proven working
│   └── devcontainer.json       # Production settings
│
└── claude-code-wsl2-devcontainer/
    ├── .devcontainer/          # Optimization test config
    │   ├── Dockerfile          # Modified with optimizations
    │   └── devcontainer.json   # Test settings
    │
    └── measurement-scripts/
        └── build-time.sh       # Measurement script
```

## 🔄 Proper Testing Workflow

### Step 1: Navigate to measurement scripts (from Host OS)
```bash
cd ~/WORK/claude-code-wsl2-devcontainer/measurement-scripts
```

### Step 2: Measure baseline (original config)
```bash
./build-time.sh baseline
# This uses ~/WORK/.devcontainer/
```

### Step 3: Measure optimization (test config)
```bash
./build-time.sh optimization
# This uses ~/WORK/claude-code-wsl2-devcontainer/.devcontainer/
```

### Step 4: Compare results
```bash
ls -la results/build_summary_*.json
```

## ⚠️ Important Notes

1. **MUST run from Host OS (WSL2)**, not from within DevContainer
2. **Baseline measurements take 2-3 minutes** (full build)
3. **First optimization run may be slow** (cache warming)
4. **Subsequent optimization runs show true cache benefit**

## 📈 Expected Results

### Baseline (no cache)
- First run: ~130-150 seconds
- Consistent across runs (no cache benefit)

### Optimization (with cache)
- First run: ~130-150 seconds (building cache)
- Second run: ~20-40 seconds (using cache)
- Shows true optimization benefit

## 🚨 Common Mistakes

❌ **Wrong**: Running baseline without clearing cache
- Result: 1-2 seconds (false positive)
- Reality: Just using existing layers

❌ **Wrong**: Comparing cached baseline to clean optimization
- Result: Optimization appears slower
- Reality: Comparing apples to oranges

✅ **Correct**: Compare clean baseline to cached optimization
- Shows real performance improvement
- Accurate representation of user experience

## 📝 Results Location
- Baseline: `results/build_summary_baseline_*.json`
- Optimization: `results/build_summary_optimization_*.json`
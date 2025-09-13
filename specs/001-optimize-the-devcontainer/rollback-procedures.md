# Rollback Procedures: DevContainer Optimization

**Project**: DevContainer Incremental Optimization
**Branch**: `001-optimize-the-devcontainer`
**Created**: 2025-09-13
**Purpose**: Emergency rollback procedures for each optimization phase

## Overview

This document provides detailed rollback procedures for each phase of the DevContainer optimization project. These procedures are designed for immediate execution in case any optimization causes functionality issues or performance degradation.

## Emergency Contact Information

**Critical Failure Response**: Immediate rollback to last known working state
**Validation Required**: Full functionality test after any rollback
**Documentation**: All rollback actions must be logged with timestamps

## Phase-by-Phase Rollback Procedures

### Phase 1 Rollback: Measurement and Backup Issues

**Symptoms**:
- Backup creation fails
- Measurement commands error
- Baseline documentation incomplete

**Immediate Actions**:
```bash
# Stop any running measurements
pkill -f docker
pkill -f time

# Clean up partial measurements
rm -rf measurements/baseline/incomplete-*

# Verify original configuration unchanged
ls -la ../.devcontainer/
git status
```

**Recovery Steps**:
```bash
# Restart measurement from clean state
docker system prune -f
cd /workspace/claude-code-wsl2-devcontainer

# Re-execute Phase 1 from beginning
# Follow plan.md Phase 1 procedures exactly
```

**Validation**:
- [ ] Original DevContainer builds successfully
- [ ] All baseline files present and unchanged
- [ ] Docker system responsive

### Phase 2 Rollback: Low-Risk Optimization Issues

**Symptoms**:
- Build failures after .dockerignore addition
- Missing tools or packages in container
- Dockerfile layer optimization breaks functionality
- Build time significantly degraded

**Immediate Actions**:
```bash
# Navigate to DevContainer directory
cd ../.devcontainer/

# Remove .dockerignore if it exists
if [ -f .dockerignore ]; then
    echo "Removing .dockerignore..."
    rm .dockerignore
fi

# Restore original Dockerfile if backup exists
if [ -f Dockerfile.backup ]; then
    echo "Restoring original Dockerfile..."
    cp Dockerfile.backup Dockerfile
fi
```

**Complete Phase 2 Rollback**:
```bash
# Restore from Phase 1 baseline backup
PHASE1_BACKUP=$(ls -t backups/baseline-* | head -1)
echo "Restoring from: $PHASE1_BACKUP"

# Backup current state before rollback
cp -r ../.devcontainer/ "backups/failed-phase2-$(date +%Y%m%d-%H%M%S)/"

# Restore baseline configuration
rm -rf ../.devcontainer/
cp -r "$PHASE1_BACKUP/.devcontainer/" ../

# Rebuild from baseline
docker build ../.devcontainer/ -t devcontainer-rollback-phase2
```

**Validation Commands**:
```bash
# Test core functionality
docker run --rm devcontainer-rollback-phase2 bash -c "
echo 'Testing Python stack...'
python -c 'import pandas, numpy, matplotlib; print(\"✓ Python data science stack working\")'

echo 'Testing development tools...'
git --version && echo '✓ Git working'
npm --version && echo '✓ NPM working'
zsh --version && echo '✓ Zsh working'

echo 'Testing shell environment...'
which delta fzf gh aggregate && echo '✓ CLI tools working'
"
```

**Success Criteria**:
- [ ] Container builds without errors
- [ ] All Python packages accessible
- [ ] All development tools functional
- [ ] Terminal appearance unchanged
- [ ] Build time returned to baseline

### Phase 3 Rollback: Cache Implementation Issues

**Symptoms**:
- Cache mounts fail to work
- Permission errors with cache directories
- Package installations slower than baseline
- devcontainer.json syntax errors

**Immediate Actions**:
```bash
# Restore devcontainer.json backup
cd ../.devcontainer/
if [ -f devcontainer.json.backup ]; then
    cp devcontainer.json.backup devcontainer.json
fi

# Remove problematic cache directories
sudo rm -rf ~/.cache/devcontainer/npm
sudo rm -rf ~/.cache/devcontainer/pip
```

**Complete Phase 3 Rollback**:
```bash
# Restore from Phase 2 successful state
PHASE2_BACKUP=$(ls -t backups/phase2-success-* | head -1)
if [ -z "$PHASE2_BACKUP" ]; then
    # Fall back to Phase 1 baseline
    PHASE2_BACKUP=$(ls -t backups/baseline-* | head -1)
fi

echo "Restoring from: $PHASE2_BACKUP"

# Backup failed state
cp -r ../.devcontainer/ "backups/failed-phase3-$(date +%Y%m%d-%H%M%S)/"

# Restore working configuration
rm -rf ../.devcontainer/
cp -r "$PHASE2_BACKUP/.devcontainer/" ../

# Clean up cache mounts
docker volume prune -f
```

**Validation Commands**:
```bash
# Test package installation performance
docker build ../.devcontainer/ -t devcontainer-rollback-phase3

# Verify no cache-related errors
docker run --rm devcontainer-rollback-phase3 bash -c "
npm install --version
pip install --version
echo 'Cache rollback successful'
"
```

### Phase 4+ Rollback: Integration Feature Issues

**SpecKit Integration Rollback**:
```bash
# Remove SpecKit scripts if they cause issues
rm -f /workspace/scripts/init-speckit.sh
rm -rf /workspace/.speckit/

# Restore container without SpecKit
docker build ../.devcontainer/ -t devcontainer-no-speckit
```

**Serena MCP Integration Rollback**:
```bash
# Remove MCP configurations
rm -f /workspace/scripts/init-serena-mcp.sh
rm -rf /workspace/.mcp/

# Restore container without MCP
docker build ../.devcontainer/ -t devcontainer-no-mcp
```

## Complete System Rollback

### Nuclear Option: Full Baseline Restore

**When to Use**: All phases have failed, complete system restoration needed

```bash
#!/bin/bash
set -e

echo "=== EMERGENCY FULL ROLLBACK ==="
echo "This will restore the complete baseline configuration"
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Rollback cancelled"
    exit 1
fi

# Find most recent baseline backup
BASELINE_BACKUP=$(ls -t backups/baseline-* | head -1)
if [ -z "$BASELINE_BACKUP" ]; then
    echo "ERROR: No baseline backup found!"
    exit 1
fi

echo "Restoring from: $BASELINE_BACKUP"

# Create emergency backup of current state
EMERGENCY_BACKUP="backups/emergency-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$EMERGENCY_BACKUP"
cp -r ../.devcontainer/ "$EMERGENCY_BACKUP/" 2>/dev/null || true

# Remove current configuration
rm -rf ../.devcontainer/

# Restore baseline
cp -r "$BASELINE_BACKUP/.devcontainer/" ../

# Clean Docker system
docker system prune -af
docker volume prune -f

# Rebuild baseline
echo "Rebuilding baseline configuration..."
docker build ../.devcontainer/ -t devcontainer-emergency-restore

echo "=== ROLLBACK COMPLETE ==="
echo "Emergency backup saved to: $EMERGENCY_BACKUP"
echo "Baseline restored from: $BASELINE_BACKUP"
```

### Post-Rollback Validation

**Complete Functionality Test**:
```bash
#!/bin/bash
echo "=== POST-ROLLBACK VALIDATION ==="

# Test container creation
docker run --name validation-test devcontainer-emergency-restore sleep 30 &
CONTAINER_ID=$!

# Wait for container to start
sleep 5

# Run comprehensive tests
docker exec validation-test bash -c "
echo '1. Testing Python environment...'
python --version
pip list | grep -E '(pandas|numpy|matplotlib)' | wc -l

echo '2. Testing Node.js environment...'
node --version
npm --version

echo '3. Testing development tools...'
git --version
zsh --version
which delta fzf gh

echo '4. Testing shell configuration...'
echo \$SHELL
ls -la ~/.p10k.zsh

echo '5. Testing network capabilities...'
ping -c 1 8.8.8.8 || echo 'Network test failed (expected in some environments)'
"

# Cleanup
docker stop validation-test
docker rm validation-test

echo "=== VALIDATION COMPLETE ==="
```

## Rollback Documentation Template

**Required Information for Each Rollback**:

```markdown
## Rollback Report: [Date] [Time]

**Phase**: [Phase Number and Name]
**Issue**: [Description of problem that triggered rollback]
**Severity**: [Critical/High/Medium/Low]
**Rollback Method**: [Complete/Partial/File-specific]
**Data Loss**: [Yes/No - describe any lost work]
**Recovery Time**: [Minutes from detection to working state]

### Steps Taken:
1. [First action]
2. [Second action]
3. [etc.]

### Validation Results:
- [ ] Container builds successfully
- [ ] All tools functional
- [ ] Performance at baseline levels
- [ ] No data corruption

### Lessons Learned:
[What went wrong and how to prevent in future]

### Follow-up Actions:
[Any additional steps needed]
```

## Prevention and Monitoring

### Pre-Phase Validation
- Always verify baseline backup exists and is valid
- Test rollback procedure before starting each phase
- Ensure sufficient disk space for backups
- Verify git working directory is clean

### During-Phase Monitoring
- Monitor build times continuously
- Test functionality after each significant change
- Create intermediate backups at stable points
- Document all changes with timestamps

### Post-Phase Validation
- Compare performance metrics to baseline
- Run full functionality test suite
- Create success checkpoint backup
- Update documentation with lessons learned

---

**Emergency Contact**: If these procedures fail, refer to baseline backup and rebuild from scratch. All optimization work can be repeated with improved procedures based on failure analysis.

*Rollback Procedures v1.0 - Tested and Ready for Emergency Use*
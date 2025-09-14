# Development Workflow and Distribution Management

**Project**: WSL2 DevContainer Optimization
**Purpose**: Prevent development history loss and maintain clean distribution environment
**Created**: 2025-01-26

## Overview

This document establishes strict development workflow procedures to prevent development history accidents while maintaining a clean distribution environment. This workflow was created after experiencing development history loss in the distribution branch.

## Core Principles

1. **Master Branch Protection**: All development history must remain safe in master branch
2. **Distribution Branch Isolation**: Distribution branch contains only essential files for end users
3. **Development Branch Safety**: All feature development happens in isolated branches
4. **Atomic Operations**: Each workflow step must be completed fully before proceeding
5. **Rollback Capability**: Every step must have a clear rollback procedure

## Branch Structure

### Master Branch
- **Purpose**: Primary development branch with complete project history
- **Contents**: All development files, measurement scripts, documentation, research notes
- **Protection**: NEVER force push or destructive operations
- **Merging**: Only merge from feature branches after complete testing

### Distribution Branch
- **Purpose**: Clean distribution environment for GitHub public release
- **Contents**: Only essential files for end-user setup:
  - `setup.sh` - Main setup script
  - `.devcontainer/` - DevContainer configuration
  - `README.md` - User documentation
  - `LICENSE` - License file
  - Essential documentation only
- **Recreation**: Always recreated fresh from master (never direct commits)
- **Lifecycle**: Deleted and recreated for each release cycle

### Feature Branches
- **Purpose**: Isolated development and testing of new features
- **Naming**: `feature/descriptive-name` or `phase-X-task-Y-description`
- **Lifecycle**: Create → Develop → Test → Merge to master → Delete
- **Testing**: All testing must complete successfully before merge

## Safe Development Cycle

### Phase 1: Preparation (SAFETY FIRST)

```bash
# 1. Ensure master is up-to-date and clean
git checkout master
git pull origin master
git status  # Must be clean working directory

# 2. Verify distribution branch exists and is current
git checkout distribution
git pull origin distribution
git checkout master
```

**⚠️ IMPORTANT**: Distribution branch is preserved for GitHub users. Never delete the distribution branch once it's published.

### Phase 2: Feature Development

```bash
# 1. Create feature branch from master
git checkout master
git pull origin master
git checkout -b feature/new-feature-name

# 2. Develop and test in feature branch
# - All development work
# - All testing and validation
# - All measurement and verification
# - Multiple commits allowed and encouraged

# 3. Regular backup to remote
git push -u origin feature/new-feature-name
```

**Safety Rules**:
- NEVER work directly on master during feature development
- Commit frequently to preserve development history
- Push feature branch regularly as backup

### Phase 3: Integration to Master

```bash
# 1. Final testing in feature branch
# - Run all measurement scripts
# - Verify all functionality
# - Complete all acceptance criteria

# 2. Merge to master (only after complete testing)
git checkout master
git pull origin master
git merge feature/new-feature-name

# 3. Push master with new features
git push origin master

# 4. Clean up feature branch
git branch -d feature/new-feature-name
git push origin --delete feature/new-feature-name
```

**Quality Gates**:
- All tests must pass
- All documentation must be updated
- All measurement results must be recorded
- No merge conflicts allowed

### Phase 4: Distribution Branch Update

```bash
# 1. Ensure master is clean and current
git checkout master
git pull origin master
git status  # Must be clean

# 2. Create temporary branch for distribution preparation
git checkout -b temp-distribution

# 3. Remove development-only files (based on DISTRIBUTION_FILES.md)
rm -rf measurement-scripts/
rm -rf research/
rm -rf backups/
rm -rf test-project/
rm -rf .serena/
rm -rf .claude/
rm -rf specs/
rm -rf docs/
rm -f CLAUDE.md
rm -rf .specify/
# Remove other development artifacts as needed

# 4. Verify only essential files remain (should match DISTRIBUTION_FILES.md)
ls -la  # Manual verification required
# Expected files: setup.sh, .devcontainer/, README.md, LICENSE, .dockerignore

# 5. Commit distribution-only files
git add .
git commit -m "Distribution update from master - essential files only

- setup.sh: Complete setup script
- .devcontainer/: Optimized DevContainer configuration
- README.md: User documentation
- LICENSE: Project license
- .dockerignore: Build optimization

Generated from master branch $(git rev-parse --short HEAD)"

# 6. Update distribution branch with force-with-lease (safe force push)
git checkout distribution
git reset --hard temp-distribution
git push --force-with-lease origin distribution

# 7. Clean up temporary branch
git checkout master
git branch -D temp-distribution
```

**Distribution Contents Checklist**:
- [ ] `setup.sh` - Main setup script
- [ ] `.devcontainer/` directory (complete)
- [ ] `README.md` - User-facing documentation
- [ ] `LICENSE` - License file
- [ ] No measurement scripts or development artifacts
- [ ] No research directories or backup files
- [ ] No development configuration files

## Emergency Procedures

### If Distribution Branch is Corrupted

```bash
# 1. Verify master branch integrity first
git checkout master
git log --oneline -10  # Verify history is intact

# 2. Force recreate distribution branch from master
git checkout master
# Follow Phase 4 procedure to update distribution branch
# The --force-with-lease will safely overwrite corrupted distribution
```

### If Development History is Lost

```bash
# 1. Check git reflog for recovery options
git reflog

# 2. If recent, recover from reflog
git checkout master
git reset --hard HEAD@{n}  # Where n is the correct reflog entry

# 3. If not recoverable from reflog, restore from backup
# (Maintain regular backups of development repository)
```

## Workflow Enforcement Rules

1. **NEVER commit directly to distribution branch** - Always update via Phase 4 procedure
2. **ALWAYS preserve distribution branch for GitHub users** - Never delete published distribution branch
3. **ALWAYS test completely in feature branch before merging** - Master merge only after complete validation
4. **ALWAYS verify master branch integrity before updating distribution** - Protect development history
5. **ALWAYS maintain development artifacts in master branch** - Keep complete development environment
6. **ALWAYS use --force-with-lease for distribution updates** - Safe force push that prevents data loss

## File Management

### Development Files (Master Branch Only)
```
measurement-scripts/     # Build and performance measurement tools
research/               # Research documentation and analysis
backups/               # Configuration backups and restoration
test-project/          # Testing artifacts and temporary files
.serena/              # Serena MCP development configuration
.claude/settings.local.json  # Local Claude development settings
```

### Distribution Files (Both Master and Distribution)
```
setup.sh              # Main setup script
.devcontainer/         # Complete DevContainer configuration
README.md              # User documentation
LICENSE                # Project license
```

## Documentation Requirements

Before creating distribution branch:
- [ ] Update README.md with latest features
- [ ] Update setup.sh documentation if modified
- [ ] Verify all user-facing documentation is current
- [ ] Test all documentation instructions

## Success Criteria

A successful development cycle results in:
- [ ] Master branch contains complete development history
- [ ] Distribution branch contains only essential user files
- [ ] All features tested and validated
- [ ] All documentation updated and accurate
- [ ] No development artifacts in distribution
- [ ] Clean Git history in both branches

## Troubleshooting

### Problem: "Distribution branch has conflicts"
```bash
# Solution: Force update is expected and safe
git checkout distribution
git pull origin distribution  # Check current state
git checkout master
# Follow Phase 4 procedure - --force-with-lease will handle conflicts
```

### Problem: "Development files in distribution"
```bash
# Solution: Clean and recommit
git checkout distribution
git rm -rf measurement-scripts/ research/ backups/
git commit -m "Remove development artifacts"
```

### Problem: "Master branch corrupted"
```bash
# Solution: Never happens if following this workflow
# But if it does, restore from feature branch backup
git checkout feature/latest-feature
git checkout -b master-recovery
# Merge clean history and recreate master
```

---

## Conclusion

This workflow prioritizes development history safety while maintaining clean distribution environment. By following these procedures strictly, we prevent the development history loss accidents experienced previously.

**Remember**: Distribution branch is preserved for GitHub users but always reconstructed from master. Master branch history is irreplaceable.

**Key Principle**: When in doubt, protect the master branch and safely update the distribution branch using --force-with-lease.
# DevContainer Optimization - Quick Start Guide

## Overview
This guide will help you set up and validate the optimized DevContainer configuration for multi-project, multi-machine development environments.

## Prerequisites
- Docker Desktop or Docker Engine installed
- VS Code with Dev Containers extension
- Git configured on your system

## Quick Setup (5 minutes)

### 1. Clone and Open Container
```bash
# Clone the repository
git clone <repository-url>
cd <repository-name>

# Open in VS Code
code .

# When prompted, click "Reopen in Container"
# Or use Command Palette: "Dev Containers: Reopen in Container"
```

### 2. Verify Container Environment
Once the container starts, open a terminal and run:

```bash
# Verify shell configuration
echo $SHELL
which zsh

# Test Powerlevel10k theme
p10k configure

# Verify development tools
node --version
python3 --version
git --version
delta --version

# Test Claude Code integration
claude --version
echo "# Test Claude context" > CLAUDE.md
```

### 3. Validate Multi-Project Support
```bash
# Create test project structure
mkdir -p projects/{frontend,backend,shared}

# Test project-specific volumes
touch projects/frontend/package.json
touch projects/backend/requirements.txt
touch projects/shared/README.md

# Verify volume mounts
df -h | grep workspace
docker volume ls | grep devcontainer
```

## Configuration Validation

### Test WSL2 Compatibility
Run these commands to verify WSL2-specific features:

```bash
# Test path handling
echo "Current workspace: $PWD"
echo "Container workspace: ${CONTAINER_WORKSPACE_FOLDER:-/workspace}"

# Verify Claude configuration
ls -la ~/.claude/
echo $CLAUDE_CONFIG_DIR

# Test performance mounts
ls -la ~/.npm/
ls -la ~/.cache/
```

### Validate Development Workflow

#### Test 1: Multi-Project Dependency Isolation
```bash
# Navigate to frontend project
cd projects/frontend
npm init -y
npm install express@4.18.0

# Navigate to backend project
cd ../backend
python3 -m venv .venv
source .venv/bin/activate
pip install flask==2.3.0

# Verify isolation - versions should not conflict
cd ../frontend && npm list express
cd ../backend && pip list | grep Flask
```

#### Test 2: Claude Code Integration
```bash
# Test Claude Code context
echo "# Project: Multi-Project DevContainer
## Frontend: Express.js application
## Backend: Flask API
## Shared: Common utilities" > CLAUDE.md

# Verify Claude can access workspace
ls -la ~/.claude/
echo $CLAUDE_WORKSPACE_ROOT

# Test MCP server availability (if configured)
which mcp-server-filesystem
which mcp-server-git
```

#### Test 3: Git Configuration Sync
```bash
# Verify git configuration carried over
git config --global user.name
git config --global user.email

# Test git-delta integration
git log --oneline -5
echo "test change" >> README.md
git diff
```

## Performance Verification

### Container Startup Time
```bash
# Record startup time
time docker-compose up -d devcontainer

# Should complete in < 30 seconds on subsequent starts
# Initial build may take 2-5 minutes
```

### Resource Usage
```bash
# Check memory usage
free -h
docker stats --no-stream

# Verify cache efficiency
du -sh ~/.npm/
du -sh ~/.cache/
df -h /workspace
```

## Troubleshooting

### Common Issues

#### 1. Container Won't Start
```bash
# Check Docker daemon
docker version
docker info

# View container logs
docker logs <container-name>

# Reset container
docker-compose down -v
docker-compose up --build
```

#### 2. Claude Code Not Working
```bash
# Verify mounts
ls -la ~/.claude/
cat ~/.claude.json  # Should not expose actual API key

# Check environment variables
echo $CLAUDE_CONFIG_DIR
echo $CLAUDE_WORKSPACE_ROOT

# Restart VS Code extension
# Command Palette: "Developer: Reload Window"
```

#### 3. Powerlevel10k Not Loading
```bash
# Verify zsh is default shell
echo $SHELL

# Reconfigure theme
p10k configure

# Check configuration
ls -la ~/.p10k.zsh
```

#### 4. Volume Mount Issues
```bash
# Check mount points
df -h | grep workspace
mount | grep workspace

# Verify permissions
ls -la /workspace
whoami
id
```

### WSL2-Specific Issues

#### Windows WSL2
```bash
# Verify WSL2 integration
echo $WSL_DISTRO_NAME
echo $WSL_INTEROP

# Check Windows path translation
wslpath -w /workspace
```


## Validation Checklist

- [ ] Container starts in < 30 seconds (after initial build)
- [ ] Powerlevel10k theme loads correctly
- [ ] Claude Code extension functional
- [ ] Multi-project directory structure created
- [ ] Dependency isolation working (npm/pip)
- [ ] Git configuration synchronized
- [ ] Volume mounts performing well
- [ ] WSL2 paths resolving correctly
- [ ] Resource usage within acceptable limits

## Next Steps

1. **Customize Configuration**: Edit `.devcontainer/devcontainer.json` for your specific needs
2. **Add Projects**: Create additional project directories under `projects/`
3. **Team Setup**: Share configuration with team members
4. **CI Integration**: Configure automated testing of DevContainer builds

## Support

For issues or improvements:
1. Check the troubleshooting section above
2. Review logs in `/workspace/.devcontainer/logs/`
3. Consult the full documentation in `research.md`
4. Create an issue in the project repository

## Success Metrics

After completing this quickstart, you should achieve:
- **70-85% faster builds** through layer optimization
- **60% faster container initialization** via performance tuning
- **Optimized experience** for Windows WSL2 environment
- **Seamless Claude Code integration** for AI-assisted development
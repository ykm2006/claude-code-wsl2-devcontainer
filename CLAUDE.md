# DevContainer Optimization Project - Claude Code Context

## Project Overview
This project provides incremental optimization of existing working DevContainer configurations for multi-project, multi-machine development environments on Windows WSL2 with enhanced Claude Code integration, SpecKit methodology, and Serena MCP support.

## Project Status
**Phase**: Phase 0 Complete - Ready for Phase 1 Implementation
**Branch**: `master` (research complete)
**Approach**: Risk-based incremental optimization with research-backed implementation plan
**Target Platform**: Windows WSL2 (exclusive focus)

## Current Working Configuration (Baseline)
- **Location**: `~/WORK/.devcontainer/` (WSL2 host) → `/workspace/.devcontainer/` (DevContainer mount) - (183-line Dockerfile, complete devcontainer.json)
- **Status**: Fully functional and proven across 3 machines
- **Base Image**: Node.js 20 on Debian Bullseye
- **Shell**: Zsh with Powerlevel10k theme (complete .p10k.zsh configuration)
- **Development Stack**: Python data science (40+ packages), Rust toolchain, modern CLI tools
- **AI Integration**: Claude Code with proper API key mounting
- **Network**: iptables firewall with NET_ADMIN/NET_RAW capabilities

## Key Optimization Requirements

### Functional Preservation (Non-Negotiable)
- **FR-001**: Exact multi-project workspace architecture (`~/WORK/` → `/workspace/`)
- **FR-002**: Current Claude Code mounting and integration (`~/.claude`, `~/.claude.json`)
- **FR-003**: Current firewall capabilities (NET_ADMIN, NET_RAW, init-firewall.sh)
- **FR-004**: Identical Powerlevel10k terminal configuration and appearance
- **FR-005**: All current Python packages and versions (40+ data science stack)
- **FR-006**: Current user permissions and sudo configuration for node user

### New Integrations
- **FR-014**: GitHub SpecKit integration with `uvx` for spec-driven development workflows
- **FR-015**: Rapid WSL2 DevContainer environment creation through GitHub clone
- **FR-016**: Serena MCP server integration with Claude Code via `claude mcp add` command

### Performance Targets (Conservative)
- **Build Time**: 10-20% improvement through layer consolidation
- **Package Operations**: 15-30% improvement through persistent caching
- **Startup Time**: Must not degrade from current baseline

## Architecture Decisions (Revised)
- **Incremental Approach**: Small, testable changes preserving all existing functionality
- **Risk Minimization**: Every change immediately reversible with documented rollback
- **Conservative Targets**: Realistic 10-30% improvements vs. speculative 70%+
- **Baseline Preservation**: Existing working configuration at `/workspace/.devcontainer/` unchanged
- **Function-First**: Performance secondary to maintaining proven functionality

## Documentation Structure
```
specs/001-optimize-the-devcontainer/
├── spec.md                        # Master specification (English) - Complete
├── spec-ja.md                     # Reference specification (Japanese) - Complete
├── plan.md                        # Implementation plan (English) - Complete
├── plan-ja.md                     # Implementation plan (Japanese) - Complete
├── task.md                        # Actionable task breakdown (English) - Complete
├── task-ja.md                     # Actionable task breakdown (Japanese) - Complete
├── rollback-procedures.md         # Rollback documentation (English) - Complete
└── rollback-procedures-ja.md      # Rollback documentation (Japanese) - Complete

/workspace/.devcontainer/           # ACTUAL WORKING BASELINE (Unchanged)
├── Dockerfile                     # 183 lines, proven working
├── devcontainer.json              # Complete configuration
├── .p10k.zsh                      # Powerlevel10k theme (95KB)
└── init-firewall.sh               # Network initialization
```

## Implementation Phases (Planned)
1. **Phase 1**: Measurement and Backup (create baseline, backup procedures)
2. **Phase 2**: Low-Risk Optimizations (.dockerignore, layer consolidation)
3. **Phase 3**: Cache Implementation (npm/pip cache mounts)
4. **Phase 4**: SpecKit Integration (project initialization scripts)
5. **Phase 5**: Serena MCP Integration (MCP server management)
6. **Phase 6**: GitHub Distribution Preparation (documentation, quick-start)
7. **Phase 7**: Validation and Rollback Testing

## Recent Accomplishments (2025-09-13)
- **Specification Revision**: Complete rewrite focusing on incremental optimization
- **Approach Correction**: Shifted from architectural changes to proven configuration enhancement
- **File Cleanup**: Removed 23 outdated files from wrong approach
- **Requirements Addition**: SpecKit, Serena MCP, and GitHub distribution support
- **Risk Mitigation**: Conservative performance targets and rollback procedures

## Implementation Constraints
- **NO** changes to fundamental architecture or mount points
- **NO** removal or modification of existing packages or tools
- **NO** changes to user experience or terminal appearance
- **NO** modification of Claude Code integration or configuration mounting
- **ALL** changes must be incrementally testable and immediately reversible

## Phase 0 Accomplishments (2025-09-14)
1. **✅ Research Infrastructure**: Complete research directory with systematic organization
2. **✅ Current State Analysis**: Comprehensive analysis of 183-line Dockerfile, 19 RUN commands, 32 Python packages
3. **✅ Optimization Research**: 2025 best practices research with specific applicability assessment
4. **✅ Risk Assessment**: Complete risk matrix with 🟢Low/🟡Medium/🔴High categorization and rollback procedures
5. **✅ Implementation Plan**: Updated task.md with research-backed targets and concrete success metrics
6. **✅ Documentation**: 1,000+ lines of detailed research documentation for informed decision-making

## AI Assistant Communication Profile
**Tone**: 33歳女性高校教師が教え子に話すような口調
- フランクで親しみやすい
- チャーミングで親近感のある表現
- 専門的内容も分かりやすく説明
- 適度な関西弁やくだけた表現を使用
- 「〜だよね♪」「〜しちゃった(笑)」などの表現

## Next Immediate Steps
1. **Begin Phase 1** - Baseline measurement and backup creation (Tasks 1.1-1.3)
2. **Execute Phase 2** - Low-risk optimizations (.dockerignore, BuildKit, cache mounts)
3. **Validate Results** - Performance measurements and functionality verification
4. **Optional Phase 3** - Advanced optimizations (RUN consolidation, layer ordering)

## Research-Backed Optimization Targets
- **Build Context**: 116KB → <60KB (50-80% reduction via .dockerignore)
- **Build Time**: 15-25% improvement (apt-get consolidation + BuildKit)
- **Package Operations**: 30-70% faster (cache mounts implementation)
- **Layer Count**: 19 → 12-15 RUN commands (optional advanced optimization)

## Success Criteria
- Configuration builds faster and caches better while being **functionally identical** to current working setup
- All existing tools, integrations, and workflows continue working exactly as before
- SpecKit and Serena MCP integrations add value without disrupting existing functionality
- Any optimization that breaks existing functionality will be immediately reverted

---
*Updated: 2025-09-14 - Phase 0 research complete, ready for Phase 1 implementation*
*Documentation Structure: English master specifications with Japanese reference versions*
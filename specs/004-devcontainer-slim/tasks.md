# Tasks: DevContainer スリム化

**Input**: Design documents from `/specs/004-devcontainer-slim/`
**Prerequisites**: plan.md, spec.md, research.md
**Branch**: `004-devcontainer-slim`
**Updated**: 2026-01-31

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

```
.devcontainer/
├── docker-compose.yml       # サービス定義
├── Dockerfile.minimal       # US1: Minimal 環境
├── Dockerfile.dev           # US2: Dev 環境
├── Dockerfile.dev-rag       # US3: Dev-RAG 環境
├── minimal/
│   └── devcontainer.json    # US1: Minimal 設定
├── dev/
│   └── devcontainer.json    # US2: Dev 設定
├── dev-rag/
│   └── devcontainer.json    # US3: Dev-RAG 設定
└── shared/
    ├── .p10k.zsh            # 共有: Powerlevel10k 設定
    └── shell-setup.sh       # 共有: シェル設定スクリプト
```

---

## Phase 0: Cleanup (準備作業)

**Purpose**: 古いファイルの削除と作業環境の整理

- [ ] T001 Delete backup files in .devcontainer/ (*.backup_*, *.bak, *.problem, *.fixed)
- [ ] T002 [P] Investigate claude-global/ folder and remove if unused
- [ ] T003 [P] Rename existing .devcontainer/Dockerfile to .devcontainer/Dockerfile.legacy
- [ ] T065 [P] Update branch name references in spec.md, plan.md (replace `feature/devcontainer-slim` → `004-devcontainer-slim`)
- [ ] T066 [P] Update plan.md Dev-RAG section with Qdrant selection from research.md (replace placeholders)

**Checkpoint**: クリーンな作業環境が準備完了

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 共有設定ファイルと Docker Compose 基盤の作成

- [ ] T004 Create .devcontainer/shared/ directory structure
- [ ] T005 [P] Copy existing .devcontainer/.p10k.zsh to .devcontainer/shared/.p10k.zsh
- [ ] T006 [P] Create shell-setup.sh in .devcontainer/shared/shell-setup.sh
- [ ] T007 Create docker-compose.yml skeleton in .devcontainer/docker-compose.yml
- [ ] T008 [P] Determine and document current debian:bookworm-slim fixed tag version

**Checkpoint**: 共有基盤が準備完了、各環境の実装を開始可能

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 全 User Story に必要な共通設定

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T009 Define common build args and environment variables in docker-compose.yml
- [ ] T010 [P] Configure volume mounts (~/.claude, /workspace) in docker-compose.yml
- [ ] T011 [P] Setup BuildKit configuration in docker-compose.yml

**Checkpoint**: Foundation ready - User Story implementation can begin

---

## Phase 3: User Story 1 - Minimal 環境 (Priority: P1) 🎯 MVP

**Goal**: Claude Code が使える軽量な事務作業環境（言語ランタイムなし）

**Independent Test**: `docker compose build minimal && devcontainer up --config .devcontainer/minimal/devcontainer.json` → `claude --version` が動作

### Implementation for User Story 1

- [ ] T012 [US1] Create Dockerfile.minimal base structure in .devcontainer/Dockerfile.minimal
- [ ] T013 [US1] Add basic system packages (git, curl, wget, jq, vim, nano, less, procps, sudo, unzip, ca-certificates, gnupg2) to Dockerfile.minimal
- [ ] T014 [US1] Add Zsh and Oh My Zsh installation to Dockerfile.minimal
- [ ] T015 [US1] Add Powerlevel10k and zsh plugins (autosuggestions, syntax-highlighting) to Dockerfile.minimal
- [ ] T016 [US1] Add GitHub CLI (gh) installation to Dockerfile.minimal
- [ ] T017 [US1] Add git-delta and fzf installation to Dockerfile.minimal
- [ ] T018 [US1] Add Claude Code native binary installation to Dockerfile.minimal
- [ ] T019 [US1] Configure non-root user (node) with sudo access in Dockerfile.minimal
- [ ] T020 [US1] Add shell configuration sourcing shared/shell-setup.sh to Dockerfile.minimal
- [ ] T021 [US1] Create minimal/devcontainer.json in .devcontainer/minimal/devcontainer.json
- [ ] T022 [US1] Add minimal service definition to docker-compose.yml
- [ ] T023 [US1] Test: Build minimal image and verify size < 500MB
- [ ] T024 [US1] Test: Start minimal container and verify Claude Code works

**Checkpoint**: Minimal 環境が独立して動作、ビルド 3分以内、サイズ 500MB 以下

---

## Phase 4: User Story 2 - Dev 環境 (Priority: P2)

**Goal**: Python + Bun でのプログラミング開発環境（Minimal ベース）

**Independent Test**: `docker compose build dev && devcontainer up --config .devcontainer/dev/devcontainer.json` → `python --version`, `bun --version` が動作

### Implementation for User Story 2

- [ ] T025 [US2] Create Dockerfile.dev extending Minimal concepts in .devcontainer/Dockerfile.dev
- [ ] T026 [US2] Add Python 3.11 (system) and python3-dev, build-essential to Dockerfile.dev
- [ ] T027 [US2] Add uv package manager installation to Dockerfile.dev
- [ ] T028 [US2] Add Bun installation to Dockerfile.dev
- [ ] T029 [US2] Add network tools (iproute2, dnsutils) to Dockerfile.dev
- [ ] T030 [US2] Add shellcheck to Dockerfile.dev
- [ ] T031 [US2] Review existing init-speckit.sh and init-serena-mcp.sh, then add to Dockerfile.dev (check .devcontainer/ for existing scripts)
- [ ] T032 [US2] Create dev/devcontainer.json in .devcontainer/dev/devcontainer.json
- [ ] T033 [US2] Add dev service definition to docker-compose.yml
- [ ] T034 [US2] Test: Build dev image and verify size < 1.5GB
- [ ] T035 [US2] Test: Verify uv venv creation works
- [ ] T036 [US2] Test: Verify bun init works

**Checkpoint**: Dev 環境が独立して動作、ビルド 5分以内、サイズ 1.5GB 以下

---

## Phase 5: User Story 3 - Dev-RAG 環境 (Priority: P3)

**Goal**: RAG/ナレッジベース機能を持つ開発環境（Dev ベース + ML/RAG）

**Independent Test**: `docker compose --profile rag build dev-rag && devcontainer up --config .devcontainer/dev-rag/devcontainer.json` → Qdrant + Embedding が動作

### Implementation for User Story 3

- [ ] T037 [US3] Create Dockerfile.dev-rag extending Dev concepts in .devcontainer/Dockerfile.dev-rag
- [ ] T038 [US3] Add PyTorch with CUDA support to Dockerfile.dev-rag
- [ ] T039 [US3] Add sentence-transformers installation to Dockerfile.dev-rag
- [ ] T040 [US3] Add multilingual embedding model download (paraphrase-multilingual-mpnet-base-v2) to Dockerfile.dev-rag
- [ ] T041 [US3] Add Qdrant client library to Dockerfile.dev-rag
- [ ] T042 [US3] Add FastAPI and uvicorn for RAG server to Dockerfile.dev-rag
- [ ] T043 [US3] Create RAG server skeleton in .devcontainer/dev-rag/rag-server/
- [ ] T044 [US3] Add Qdrant container service definition to docker-compose.yml (profile: rag)
- [ ] T045 [US3] Add NVIDIA GPU configuration to docker-compose.yml for dev-rag service
- [ ] T046 [US3] Create dev-rag/devcontainer.json in .devcontainer/dev-rag/devcontainer.json
- [ ] T047 [US3] Add dev-rag service definition to docker-compose.yml (profile: rag)
- [ ] T048 [US3] Test: Build dev-rag image and verify size < 10GB
- [ ] T049 [US3] Test: Verify GPU detection works (nvidia-smi)
- [ ] T050 [US3] Test: Verify embedding generation works

**Checkpoint**: Dev-RAG 環境が独立して動作、ビルド 15分以内、サイズ 10GB 以下

---

## Phase 6: User Story 4 - 環境切り替え (Priority: P4)

**Goal**: VS Code から直感的に環境を選択・切り替え可能

**Independent Test**: VS Code で「Reopen in Container」→ 3つの環境が選択肢に表示

### Implementation for User Story 4

- [ ] T051 [US4] Verify VS Code shows environment selection menu with multiple devcontainer.json files
- [ ] T052 [US4] Add environment identifier to shell prompt (DEVCONTAINER_ENV variable) in shell-setup.sh
- [ ] T053 [US4] Configure container names for easy identification in docker-compose.yml
- [ ] T054 [US4] Test: Switch between Minimal and Dev environments
- [ ] T055 [US4] Test: Switch between Dev and Dev-RAG environments
- [ ] T056 [US4] Verify environment identifier is visible in terminal prompt

**Checkpoint**: 全環境の切り替えが 3クリック以内で可能

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: ドキュメント整備と移行完了

- [ ] T057 [P] Update README.md with new environment setup instructions
- [ ] T058 [P] Update CLAUDE.md with new devcontainer structure reference
- [ ] T059 Document troubleshooting guide for common issues
- [ ] T067 [P] Create .devcontainer/README.md with architecture documentation (3環境構成、RAG/Qdrant/Volume説明、再利用手順)
- [ ] T060 Cross-platform test: Verify all environments work on WSL2
- [ ] T061 Cross-platform test: Verify all environments work on KDE Neon
- [ ] T062 Performance validation: Measure actual build times and image sizes
- [ ] T063 Migration: Apply new configuration to /workspace/.devcontainer/
- [ ] T064 Cleanup: Remove Dockerfile.legacy after successful migration

**Checkpoint**: ドキュメント完成、全環境がクロスプラットフォームで動作確認済み

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 0 (Cleanup)
    ↓
Phase 1 (Setup)
    ↓
Phase 2 (Foundational) ← BLOCKS all user stories
    ↓
┌───────────────────────────────────────┐
│  Phase 3 (US1: Minimal) 🎯 MVP        │
│      ↓                                │
│  Phase 4 (US2: Dev)                   │
│      ↓                                │
│  Phase 5 (US3: Dev-RAG)               │
│      ↓                                │
│  Phase 6 (US4: 環境切り替え)           │
└───────────────────────────────────────┘
    ↓
Phase 7 (Polish)
```

### User Story Dependencies

- **US1 (Minimal)**: Foundation 完了後すぐに開始可能。他の US に依存なし。
- **US2 (Dev)**: US1 の Dockerfile パターンを参考にするが、独立してテスト可能。
- **US3 (Dev-RAG)**: US2 の Dockerfile パターンを参考にするが、独立してテスト可能。
- **US4 (環境切り替え)**: US1, US2, US3 の devcontainer.json が必要。

### Parallel Opportunities

- **Phase 0**: T001, T002, T003 は並列実行可能（ただし T003 は git commit 前に）
- **Phase 1**: T005, T006, T008 は並列実行可能
- **Phase 2**: T010, T011 は並列実行可能
- **Phase 7**: T057, T058 は並列実行可能

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 0: Cleanup
2. Complete Phase 1: Setup
3. Complete Phase 2: Foundational
4. Complete Phase 3: User Story 1 (Minimal)
5. **STOP and VALIDATE**: Test Minimal environment independently
6. If successful, proceed to User Story 2

### Incremental Delivery

1. Setup + Foundational → Minimal (MVP!) → Validate
2. Add Dev → Validate both Minimal and Dev
3. Add Dev-RAG → Validate all three
4. Add environment switching → Full validation
5. Polish and migrate

---

## Summary

| Phase | Tasks | Parallel | Story |
|-------|-------|----------|-------|
| 0: Cleanup | T001-T003, T065-T066 | 4 | - |
| 1: Setup | T004-T008 | 3 | - |
| 2: Foundational | T009-T011 | 2 | - |
| 3: Minimal | T012-T024 | 0 | US1 |
| 4: Dev | T025-T036 | 0 | US2 |
| 5: Dev-RAG | T037-T050 | 0 | US3 |
| 6: 環境切り替え | T051-T056 | 0 | US4 |
| 7: Polish | T057-T064 | 2 | - |

**Total Tasks**: 66
**MVP Scope**: Phase 0-3 (T001-T024, T065-T066, 26 tasks)

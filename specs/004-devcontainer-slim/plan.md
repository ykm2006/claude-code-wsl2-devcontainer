# Implementation Plan: DevContainer スリム化

**Branch**: `004-devcontainer-slim` | **Date**: 2026-01-31 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-devcontainer-slim/spec.md`

## Summary

Docker Compose によるサービス分離で、用途別に最適化された 3 つの DevContainer 環境（Minimal, Dev, Dev-RAG）を提供する。ビルド時間を 10分+ → 3分（Minimal）に短縮し、イメージサイズを大幅に削減。Claude Code ネイティブバイナリの採用により Node.js 依存を排除。

## Technical Context

**Project Type**: Infrastructure/Configuration（DevContainer 構成管理）
**Target Platform**: WSL2 (Windows 10/11), KDE Neon (Native Linux)
**Container Runtime**: Docker Desktop (WSL2), Docker Engine (Native Linux)

**Primary Technologies**:
| コンポーネント | 選定 | バージョン |
|---------------|------|-----------|
| ベースイメージ | debian:bookworm-slim | 固定タグ（設定時最新） |
| コンテナオーケストレーション | Docker Compose | v2.x |
| DevContainer 統合 | Dev Containers 拡張 | 最新 |
| Claude Code | ネイティブバイナリ | 最新 |
| Python 管理 | uv + venv | uv 最新 |
| TypeScript/JS 管理 | Bun | 最新 |
| シェル | Zsh + Oh My Zsh + Powerlevel10k | 最新 |
| GPU サポート | NVIDIA CUDA | ホスト依存 |

**Storage**: ファイルシステムのみ（ホストマウント: ~/.claude, ~/.claude.json, /workspace）

**Testing Strategy**:
1. `docker compose build` - イメージビルド検証
2. `devcontainer up --workspace-folder .` - CLI 起動検証
3. VS Code「Reopen in Container」- GUI 統合検証

**Performance Goals** (from spec):
- Minimal ビルド: 3分以内、500MB 以下
- Dev ビルド: 5分以内、1.5GB 以下
- Dev-RAG ビルド: 15分以内、10GB 以下
- キャッシュ起動: 30秒以内（Minimal/Dev）、1分以内（Dev-RAG）

**Constraints** (from constitution):
- グローバル pip/npm install 禁止
- WSL2/Linux 固有コードのハードコーディング禁止
- Docker-in-Docker 不要

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Environment Portability | ✅ PASS | WSL2 + KDE Neon 両対応を明記（SC-006） |
| II. Minimal by Default | ✅ PASS | 3 階層（Minimal → Dev → Dev-RAG）で設計 |
| III. Native Tools First | ✅ PASS | Claude Code ネイティブ、uv、Bun 採用 |
| IV. Compose-Based Architecture | ✅ PASS | Docker Compose + profiles で設計 |
| V. Reproducible Builds | ✅ PASS | バージョン固定方針を clarify で確認済み |

**Gate Result**: ✅ PASS - 全原則を遵守

## Project Structure

### Documentation (this feature)

```text
specs/004-devcontainer-slim/
├── spec.md              # 機能仕様書
├── plan.md              # このファイル
├── research.md          # Phase 0: RAG 技術選定調査
├── tasks.md             # 既存（/speckit.tasks で更新予定）
├── checklists/
│   └── requirements.md  # 品質チェックリスト
└── analysis/
    └── feature-inventory.md  # 機能棚卸し表
```

### Source Code (DevContainer Configuration)

```text
.devcontainer/
├── docker-compose.yml       # サービス定義（必須）
├── Dockerfile.minimal       # Minimal 環境用
├── Dockerfile.dev           # Dev 環境用
├── Dockerfile.dev-rag       # Dev-RAG 環境用
├── minimal/
│   └── devcontainer.json    # Minimal 環境設定
├── dev/
│   └── devcontainer.json    # Dev 環境設定
├── dev-rag/
│   └── devcontainer.json    # Dev-RAG 環境設定
└── shared/
    ├── .p10k.zsh            # Powerlevel10k 設定
    └── shell-setup.sh       # 共通シェル設定スクリプト
```

**Structure Decision**: Constitution のファイル構成規約に従い、各環境に独立した Dockerfile と devcontainer.json を配置。共有設定は `shared/` ディレクトリに集約。

## Environment Design

### Minimal 環境

```
┌─────────────────────────────────────────┐
│ debian:bookworm-slim (固定タグ)          │
├─────────────────────────────────────────┤
│ 基本ツール                               │
│ - git, curl, wget, jq, vim, nano        │
│ - less, procps, sudo, unzip             │
│ - ca-certificates, gnupg2               │
├─────────────────────────────────────────┤
│ シェル環境                               │
│ - Zsh + Oh My Zsh + Powerlevel10k       │
│ - zsh-autosuggestions                   │
│ - zsh-syntax-highlighting               │
├─────────────────────────────────────────┤
│ 開発ツール                               │
│ - gh (GitHub CLI)                       │
│ - git-delta, fzf                        │
├─────────────────────────────────────────┤
│ AI ツール                                │
│ - Claude Code (ネイティブバイナリ)       │
└─────────────────────────────────────────┘
推定サイズ: ~400MB
```

### Dev 環境 (Minimal + 言語ランタイム)

```
┌─────────────────────────────────────────┐
│ Minimal 環境のすべて                     │
├─────────────────────────────────────────┤
│ Python 環境                             │
│ - Python 3.11 (system)                  │
│ - python3-dev, build-essential          │
│ - uv (パッケージマネージャー)            │
├─────────────────────────────────────────┤
│ TypeScript/JS 環境                      │
│ - Bun (ランタイム + パッケージ管理)      │
├─────────────────────────────────────────┤
│ 追加ツール                               │
│ - iproute2, dnsutils                    │
│ - shellcheck                            │
│ - init-speckit, init-serena-mcp         │
└─────────────────────────────────────────┘
推定サイズ: ~1GB
```

### Dev-RAG 環境 (Dev + ML/RAG)

```
┌─────────────────────────────────────────┐
│ Dev 環境のすべて                         │
├─────────────────────────────────────────┤
│ ML/RAG 基盤                             │
│ - PyTorch (CUDA 対応)                   │
│ - sentence-transformers                 │
│ - 多言語 Embedding モデル               │
├─────────────────────────────────────────┤
│ ベクトル DB / 検索                       │
│ - Qdrant (Docker container)             │
│ - qdrant-client                         │
├─────────────────────────────────────────┤
│ MCP / API                               │
│ - FastAPI + uvicorn (RAG server)        │
│ - markitdown-mcp                        │
└─────────────────────────────────────────┘
推定サイズ: ~8-10GB（モデル込み）
GPU: NVIDIA CUDA サポート
```

## Phase 0: Research Items

以下の項目は `research.md` で調査・決定する：

1. **ベクトルデータベース選定**
   - ChromaDB vs Qdrant vs Milvus Lite vs ファイルベース
   - 評価軸: サイズ、起動速度、MCP 以外での利用可能性

2. **Embedding サービス構成**
   - sentence-transformers 直接利用 vs TEI (Text Embeddings Inference)
   - 評価軸: 汎用性、API 提供、リソース使用量

3. **RAG サーバー構成**
   - 既存 MCP-Markdown-RAG 継続 vs 新規実装
   - 評価軸: MCP 以外からの利用、拡張性、メンテナンス性

## Complexity Tracking

> 現時点で Constitution 違反なし。追加の正当化は不要。

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (なし) | - | - |

## Next Steps

1. **Phase 0 完了**: `research.md` で RAG 技術選定を実施
2. **Phase 1 完了**: 詳細設計（docker-compose.yml, Dockerfile 構成）
3. **Tasks 更新**: `/speckit.tasks` で既存 tasks.md を更新
4. **実装**: ホストからビルドテスト → VS Code 統合テスト

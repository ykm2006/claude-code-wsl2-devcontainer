<!--
  SYNC IMPACT REPORT
  ===================
  Version change: 0.0.0 → 1.0.0
  Bump type: MAJOR (initial constitution ratification)

  Modified principles: N/A (initial creation)
  Added sections:
    - Core Principles (5 principles)
    - Infrastructure Constraints
    - Development Workflow
    - Governance
  Removed sections: N/A

  Templates requiring updates:
    - .specify/templates/plan-template.md: ✅ compatible (Constitution Check section exists)
    - .specify/templates/spec-template.md: ✅ compatible (requirements format matches)
    - .specify/templates/tasks-template.md: ✅ compatible (phase-based structure aligns)

  Follow-up TODOs: None
-->

# DevContainer Cross-Platform Constitution

## Core Principles

### I. Environment Portability

DevContainer 構成は複数の環境（WSL2, Native Linux）で一貫して動作しなければならない。

- 環境固有のハードコーディングは禁止
- 環境検出は自動化する（ホスト OS 判定スクリプト等）
- SyncThing 経由での設定同期を前提とした設計
- パスやマウントポイントは変数化して柔軟性を確保

**根拠**: 3台の WSL2 マシン + 1台の KDE Neon で同一構成を維持するため。

### II. Minimal by Default

基本構成は最小限とし、追加機能は必要に応じて層として追加する。

- 基本環境は最小限の依存のみで構成
- 追加機能（言語ランタイム、RAG 等）は別レイヤーまたは別サービスとして提供
- オプション機能は Docker Compose profiles で分離・制御
- プリインストールパッケージは厳選し、プロジェクト依存は venv/node_modules で管理

**根拠**: ビルド時間短縮とイメージサイズ削減のため。

**具体的な環境構成は `/speckit.specify` で定義する。**

### III. Native Tools First

可能な限りネイティブバイナリやシステムパッケージを優先する。

- Claude Code: ネイティブインストーラー使用（Node.js ランタイム不要）
- Python: uv + venv でプロジェクト別管理
- TypeScript: Bun でプロジェクト別管理（必要時のみ）
- システムツール: apt パッケージを優先、pip/npm グローバルインストールは最小限

**根拠**: 依存関係の削減とビルドキャッシュ効率向上のため。

### IV. Compose-Based Architecture

Docker Compose を使用してサービス分離とスケーラビリティを確保する。

- 各サービス（minimal, dev, rag 等）は独立した Dockerfile を持つ
- profiles 機能でオプションサービスを制御
- DevContainer は Compose サービスを参照（dockerComposeFile 指定）
- 共通設定は docker-compose.yml のトップレベルで定義

**根拠**: DevContainer 公式サポートの構成であり、環境切り替えが容易なため。

### V. Reproducible Builds

ビルド結果は環境に依存せず再現可能でなければならない。

- Dockerfile は BuildKit 形式で記述
- バージョン固定: ベースイメージタグ、主要パッケージバージョンを明記
- キャッシュ戦略: 頻繁に変更されるレイヤーは後半に配置
- クリーンアップ: apt-get clean, rm -rf /var/lib/apt/lists/* を徹底

**根拠**: チームメンバー間、マシン間での動作一貫性確保のため。

## Infrastructure Constraints

### 技術スタック

| コンポーネント | 選定 | バージョン |
|---------------|------|-----------|
| ベースイメージ | debian:bookworm-slim | 最新 stable |
| Claude Code | ネイティブバイナリ | 最新 |
| Python（dev） | System + uv | Python 3.11+ |
| シェル | Zsh + Oh My Zsh | 最新 |
| ターミナル | Powerlevel10k | 最新 |

### 禁止事項

- グローバル pip install（システム Python 汚染防止）
- グローバル npm install -g（minimal では Node.js 自体不要）
- ルートでのサービス実行（セキュリティ）
- 固定 IP / MAC アドレスの想定
- WSL2 専用または Linux 専用のハードコーディング

### ファイル構成規約

```
.devcontainer/
├── docker-compose.yml       # サービス定義（必須）
├── Dockerfile.minimal       # minimal 環境用（必須）
├── Dockerfile.dev           # dev 環境用（必須）
├── minimal/
│   └── devcontainer.json    # minimal 選択時の設定
├── dev/
│   └── devcontainer.json    # dev 選択時の設定
└── shared/                  # 共有設定ファイル（.p10k.zsh 等）
```

## Development Workflow

### 変更プロセス

1. **Spec First**: `/speckit.specify` で要件を明文化
2. **Plan**: `/speckit.plan` で技術設計・検証
3. **Tasks**: `/speckit.tasks` でタスク分解
4. **Implement**: ホストからビルドテスト → VS Code 統合テスト

### テスト方針

DevContainer 変更は以下の順序でテスト:

1. `docker compose build` - イメージビルド成功
2. `devcontainer up --workspace-folder .` - CLI からの起動
3. VS Code「Reopen in Container」- GUI 統合

### ロールバック

問題発生時:
- git で前バージョンに戻す
- `Dockerfile.legacy` を参照してリカバリ可能

## Governance

### 改定手続き

1. Constitution 変更は `/speckit.constitution` コマンドで実施
2. バージョン番号は Semantic Versioning に従う
   - MAJOR: 原則の追加・削除・根本的変更
   - MINOR: 制約・ガイドラインの追加・拡張
   - PATCH: 誤字修正・明確化
3. 変更時は Sync Impact Report を更新

### 遵守確認

- PR/コードレビュー時に Constitution 適合を確認
- plan.md の「Constitution Check」セクションで違反を明示
- 違反がある場合は正当性を Complexity Tracking に記録

### 参照ドキュメント

- CLAUDE.md: AI アシスタントの振る舞いガイド
- specs/004-devcontainer-slim/tasks.md: 現行タスクリスト
- .serena/memories/: プロジェクト履歴・コンテキスト

**Version**: 1.0.0 | **Ratified**: 2026-01-31 | **Last Amended**: 2026-01-31

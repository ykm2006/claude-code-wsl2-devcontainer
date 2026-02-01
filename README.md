# 003 - DevContainer Cross-Platform Project

**ワークスペース DevContainer 環境の改善・最適化プロジェクト**

## 概要

このプロジェクトは `/workspace/.devcontainer/` の DevContainer 設定を改善・最適化するための開発プロジェクトです。

**目標:**
- 用途別に最適化された 3 つの DevContainer 環境を提供
- ビルド時間の短縮とイメージサイズの削減
- WSL2 と Native Linux（KDE Neon）の両方で動作するクロスプラットフォーム対応

## 3 環境アーキテクチャ

| 環境 | 用途 | サイズ目安 | ビルド時間 |
|------|------|-----------|-----------|
| **Minimal** | Claude Code のみの軽量事務作業環境 | ~500MB | ~3分 |
| **Dev** | Python + Bun のプログラミング開発環境 | ~1.5GB | ~5分 |
| **Dev-RAG** | RAG/ナレッジベース機能付き開発環境 | ~8GB | ~15分 |

### Minimal 環境
言語ランタイムなし。Claude Code ネイティブバイナリ + シェル環境（Zsh + Oh My Zsh + Powerlevel10k）のみ。ドキュメント編集、Git 操作、AI との対話など軽量な事務作業向け。

### Dev 環境
Minimal + Python 3.11（uv）+ Bun。日常的なプログラミング開発向け。

### Dev-RAG 環境
Dev + PyTorch（CUDA）+ sentence-transformers + Qdrant。RAG やナレッジベース構築向け。

## プロジェクト構造

```
.devcontainer/
├── docker-compose.yml       # 全サービス定義
├── minimal/
│   ├── Dockerfile
│   └── devcontainer.json
├── dev/
│   ├── Dockerfile
│   └── devcontainer.json
├── dev-rag/
│   ├── Dockerfile
│   └── devcontainer.json
└── README.md                # アーキテクチャ詳細ドキュメント
```

## ドキュメント

- **[.devcontainer/README.md](.devcontainer/README.md)** - アーキテクチャ詳細、使い方、トラブルシューティング
- **[specs/004-devcontainer-slim/](specs/004-devcontainer-slim/)** - 設計ドキュメント（spec.md, plan.md, tasks.md）

## デプロイ

開発完了後、`scripts/deploy.sh` で設定ファイルをデプロイできます。

### 基本的な使い方

```bash
# DevContainer 内から実行（/workspace にデプロイ）
./scripts/deploy.sh

# ホストから実行（ターゲット指定）
./scripts/deploy.sh --target ~/WORK
```

### オプション

| オプション | 説明 |
|-----------|------|
| `--target DIR` | デプロイ先ディレクトリを指定 |
| `--dry-run` | 実行内容を表示（実際には実行しない） |
| `--rollback` | 最新のバックアップから復元 |
| `--list` | バックアップ一覧を表示 |
| `--force` | 確認なしで実行 |

### デプロイされるファイル

```
TARGET/
├── .devcontainer/           # DevContainer 設定
│   ├── docker-compose.yml
│   ├── README.md
│   ├── TROUBLESHOOTING.md
│   ├── minimal/
│   ├── dev/
│   ├── dev-rag/
│   └── shared/
└── scripts/                 # 環境検出スクリプト
    ├── code                 # VS Code 起動ラッパー
    └── setup-devcontainer.sh
```

### バックアップとロールバック

デプロイ時に既存の設定は自動でバックアップされます（`TARGET/.devcontainer-backups/`）。

```bash
# バックアップ一覧
./scripts/deploy.sh --list

# 最新のバックアップから復元
./scripts/deploy.sh --rollback
```

## 関連 Issue

- [Open Issues](https://github.com/ykm2006/claude-code-wsl2-devcontainer/issues?q=is%3Aopen)
- Phase 7（仕上げ）のタスクが進行中

## ライセンス

MIT License

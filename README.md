# 003 - DevContainer Cross-Platform Project

**ワークスペース DevContainer 環境の改善・最適化プロジェクト**

## 概要

このプロジェクトは `/workspace/.devcontainer/` の DevContainer 設定を改善・最適化するための開発プロジェクトです。

**目標:**
- 用途別に最適化された DevContainer 環境を提供
- ビルド時間の短縮とイメージサイズの削減
- WSL2 と Native Linux（KDE Neon）の両方で動作するクロスプラットフォーム対応

## 環境アーキテクチャ

| 環境 | 用途 | サイズ目安 | ビルド時間 |
|------|------|-----------|-----------|
| **Dev** | Python + Bun のプログラミング開発環境 | ~1.5GB | ~5分 |
| **Dev-RAG** | RAG/ナレッジベース機能付き開発環境 | ~8GB | ~15分 |

### Dev 環境
Python 3.11（uv）+ Bun + Claude Code ネイティブバイナリ。日常的なプログラミング開発向け。

### Dev-RAG 環境
Dev + PyTorch（CUDA）+ sentence-transformers + Qdrant。RAG やナレッジベース構築向け。

## プロジェクト構造

```
.devcontainer/
├── docker-compose.yml       # 全サービス定義
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
| `-h, --help` | ヘルプを表示 |

### デプロイされるファイル

```
TARGET/
├── .devcontainer/           # DevContainer 設定
│   ├── docker-compose.yml
│   ├── README.md
│   ├── TROUBLESHOOTING.md
│   ├── dev/
│   ├── dev-rag/
│   └── shared/
└── scripts/                 # 環境検出スクリプト
    ├── code                 # VS Code 起動ラッパー
    ├── setup-devcontainer.sh
    └── start-cdp.sh         # Chrome CDP + socat 自動起動
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

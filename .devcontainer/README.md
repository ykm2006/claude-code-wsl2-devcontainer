# DevContainer Architecture

> **Status**: Draft - Phase 7 T067
>
> このドキュメントは Dev-RAG 環境のアーキテクチャを説明し、他プロジェクトでの再利用を容易にすることを目的としています。

## 概要

本プロジェクトでは、用途に応じた3つの DevContainer 環境を提供しています。

| 環境 | 用途 | サイズ目安 |
|------|------|-----------|
| **Minimal** | Claude Code のみの軽量事務作業環境 | ~500MB |
| **Dev** | Python + Bun のプログラミング開発環境 | ~1.5GB |
| **Dev-RAG** | RAG/ナレッジベース機能付き開発環境 | ~8GB |

## アーキテクチャ図

### 全体構成

```
.devcontainer/
├── docker-compose.yml        # 全サービス定義
├── Dockerfile.minimal        # Minimal 環境
├── Dockerfile.dev            # Dev 環境
├── Dockerfile.dev-rag        # Dev-RAG 環境
├── minimal/
│   └── devcontainer.json
├── dev/
│   └── devcontainer.json
├── dev-rag/
│   ├── devcontainer.json
│   └── rag-server/           # 自前RAGサーバー
└── shared/
    ├── .p10k.zsh
    └── shell-setup.sh
```

### Minimal 環境

```
┌─────────────────────────────────────────┐
│  Minimal Container                      │
│  ├─ debian:bookworm-slim ベース          │
│  ├─ Zsh + Oh My Zsh + Powerlevel10k     │  ← シェル環境
│  ├─ Git + GitHub CLI (gh)               │  ← バージョン管理
│  ├─ git-delta + fzf                     │  ← CLI ツール
│  └─ Claude Code                         │  ← AI アシスタント
└─────────────────────────────────────────┘
```

言語ランタイムなし。ドキュメント編集、Git 操作、Claude との対話など軽量な事務作業向け。

### Dev 環境

```
┌─────────────────────────────────────────┐
│  Dev Container                          │
│  ├─ Minimal の全機能                     │
│  ├─ Python 3.11 + uv                    │  ← Python 開発
│  ├─ Bun                                 │  ← JavaScript/TypeScript
│  ├─ build-essential                     │  ← ビルドツール
│  └─ shellcheck, iproute2, dnsutils      │  ← 開発支援ツール
└─────────────────────────────────────────┘
```

日常的なプログラミング開発向け。Python と JavaScript/TypeScript の両方に対応。

### Dev-RAG 環境

```
┌─────────────────────────────────────────┐
│  Dev-RAG Container                      │
│  ├─ Dev の全機能                         │
│  ├─ PyTorch + CUDA 12.1                 │  ← GPU利用可
│  ├─ sentence-transformers               │  ← ベクトル化
│  │   └─ paraphrase-multilingual-mpnet   │  ← 日本語対応モデル
│  ├─ FastAPI + uvicorn                   │  ← RAG API サーバー
│  └─ qdrant-client                       │  ← DB接続ライブラリ
└────────────────┬────────────────────────┘
                 │ HTTP (port 6333)
                 ▼
┌─────────────────────────────────────────┐
│  Qdrant Container                       │
│  (公式イメージ: qdrant/qdrant:latest)    │  ← ベクトルDB本体
└────────────────┬────────────────────────┘
                 │ マウント
                 ▼
┌─────────────────────────────────────────┐
│  Docker Volume: qdrant_storage          │  ← データ永続化
└─────────────────────────────────────────┘
```

RAG（検索拡張生成）やナレッジベース構築向け。GPU による高速なベクトル化が可能。

## コンポーネント説明

### sentence-transformers

テキストをベクトル（数値の配列）に変換するライブラリ。

```
"Dockerfileの書き方" → [0.123, -0.456, 0.789, ...] (768次元)
```

本環境では `paraphrase-multilingual-mpnet-base-v2` モデルを使用し、日本語テキストに対応。

### Qdrant

オープンソースのベクトルデータベース。

- **役割**: ベクトルの保存と類似検索
- **運用形態**: Docker コンテナ（公式イメージ使用）
- **データ永続化**: Docker Volume (`qdrant_storage`)

### Docker Volume によるデータ永続化

```
Docker の3つの主要コンセプト
───────────────────────────────
Image (イメージ)    ... 設計図・テンプレート（読み取り専用）
Container           ... イメージから起動した実行環境（一時的）
Volume              ... データ保存領域（永続的）
```

**重要ポイント**:
- コンテナを削除しても Volume のデータは残る
- イメージを更新しても Volume のデータは残る
- `docker system prune -a` でも Volume は消えない（`--volumes` オプションをつけない限り）

```bash
# Volume の確認
docker volume ls

# 危険！Volume を削除するとデータが消える
docker volume rm qdrant_storage  # ⚠️ 注意
```

### FastAPI RAG サーバー

ベクトル化と検索を API として提供する自前サーバー。

```
POST /embed      ... テキストをベクトル化
POST /index      ... ドキュメントをベクトルDBに登録
POST /search     ... 類似ドキュメントを検索
GET  /health     ... ヘルスチェック
```

## 使い方

### 環境の起動

VS Code で「Reopen in Container」→ 使いたい環境を選択。

または CLI から：

```bash
# Minimal 環境
docker compose build minimal
devcontainer up --config .devcontainer/minimal/devcontainer.json

# Dev 環境
docker compose build dev
devcontainer up --config .devcontainer/dev/devcontainer.json

# Dev-RAG 環境（Qdrant も一緒に起動）
docker compose --profile rag build dev-rag
devcontainer up --config .devcontainer/dev-rag/devcontainer.json
```

### RAG サーバーの利用

```bash
# サーバー起動（Dev-RAG コンテナ内で）
cd /workspace/.devcontainer/dev-rag/rag-server
uvicorn main:app --host 0.0.0.0 --port 8000

# ドキュメントのインデックス
curl -X POST http://localhost:8000/index \
  -H "Content-Type: application/json" \
  -d '{"documents": [{"id": "1", "content": "Dockerfileの書き方"}]}'

# 検索
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "Docker", "top_k": 5}'
```

## 他プロジェクトでの再利用

### 最小構成でコピーするファイル

```
.devcontainer/
├── docker-compose.yml          # qdrant サービス定義を含む
├── Dockerfile.dev-rag          # または必要部分を抽出
└── dev-rag/
    ├── devcontainer.json
    └── rag-server/
        ├── main.py
        ├── qdrant_store.py
        └── requirements.txt
```

### カスタマイズポイント

| 項目 | ファイル | 説明 |
|------|----------|------|
| Embedding モデル | `rag-server/main.py` | `MODEL_NAME` を変更 |
| Collection 名 | `rag-server/qdrant_store.py` | `COLLECTION_NAME` を変更 |
| GPU 設定 | `docker-compose.yml` | `deploy.resources` セクション |
| ポート番号 | `docker-compose.yml` | 各サービスの `ports` |

## トラブルシューティング

よくある問題と解決方法は **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** を参照してください。

カバーしている内容：
- ビルドエラー（Docker デーモン、ディスク容量、Dockerfile）
- GPU 関連（ドライバ、CUDA バージョン、メモリ）
- ボリュームマウント（パーミッション、パス）
- ネットワーク（プロキシ、DNS、コンテナ間通信）
- VS Code 拡張機能
- クイックリファレンス・完全リセット手順

---

**Related**:
- `specs/004-devcontainer-slim/` - 設計ドキュメント
- `specs/004-devcontainer-slim/research.md` - 技術選定の経緯

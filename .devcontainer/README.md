# DevContainer Architecture

> **Status**: Draft - Phase 7 T067
>
> このドキュメントは Dev-RAG 環境のアーキテクチャを説明し、他プロジェクトでの再利用を容易にすることを目的としています。

## 概要

本プロジェクトでは、用途に応じた2つの DevContainer 環境を提供しています。

| 環境 | 用途 | サイズ目安 |
|------|------|-----------|
| **Dev** | Python + Bun のプログラミング開発環境 | ~1.5GB |
| **Dev-RAG** | RAG/ナレッジベース機能付き開発環境 | ~8GB |

## アーキテクチャ図

### 全体構成

```
.devcontainer/
├── docker-compose.yml        # 全サービス定義
├── dev/
│   ├── Dockerfile
│   └── devcontainer.json
├── dev-rag/
│   ├── Dockerfile
│   ├── devcontainer.json
│   └── rag-server/           # 自前RAGサーバー
└── shared/
    ├── .p10k.zsh
    └── shell-setup.sh
```

### Dev 環境

```
┌─────────────────────────────────────────┐
│  Dev Container                          │
│  ├─ debian:bookworm-slim ベース          │
│  ├─ Zsh + Oh My Zsh + Powerlevel10k     │  ← シェル環境
│  ├─ Git + GitHub CLI (gh)               │  ← バージョン管理
│  ├─ git-delta + fzf                     │  ← CLI ツール
│  ├─ Claude Code                         │  ← AI アシスタント
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

### クロスプラットフォーム対応（推奨）

本プロジェクトは **WSL2** と **Native Linux** の両環境に対応しています。`scripts/code` コマンドを使用すると、環境を自動検出して適切な設定で VS Code を起動できます。

#### セットアップ

```bash
# scripts ディレクトリを PATH に追加（~/.zshrc または ~/.bashrc）
export PATH="/workspace/scripts:$PATH"
```

または、エイリアスを設定：

```bash
# ~/.zshrc または ~/.bashrc
alias code='/workspace/scripts/code'
```

#### 使用方法

```bash
# 自動環境検出 + VS Code 起動
code /workspace

# 内部動作:
# 1. WSL2 か Native Linux かを自動判定
# 2. 適切な devcontainer.json を設定
#    - WSL2 → devcontainer.json.wsl2 を使用
#    - Linux → devcontainer.json.linux を使用
# 3. VS Code を起動
```

#### 仕組み

```
scripts/
├── code                    # VS Code 起動ラッパー
└── setup-devcontainer.sh   # 環境検出 & 設定切替
```

- `setup-devcontainer.sh` が `/proc/version` を確認して環境を判定
- WSL2 の場合は `microsoft` という文字列が含まれる
- 判定結果に応じて `devcontainer.json.wsl2` または `devcontainer.json.linux` を `devcontainer.json` にコピー

### 手動での環境起動

VS Code で「Reopen in Container」→ 使いたい環境を選択。

または CLI から：

```bash
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

### 一括動作確認スクリプト（推奨）

Dev-RAG 環境のすべてのコンポーネントを一括で確認できるスクリプトを用意しています。

```bash
# Dev-RAG コンテナ内で実行
bash /workspace/.devcontainer/dev-rag/verify-environment.sh
```

確認項目：
- 基本環境（Node.js, Python, uv, Git, gh CLI）
- GPU / CUDA 認識
- PyTorch + CUDA 動作
- sentence-transformers（Embedding 生成テスト含む）
- Qdrant サーバー接続
- FastAPI / uvicorn

### GPU / PyTorch の動作確認（手動）

```bash
# NVIDIA GPU が認識されているか確認
nvidia-smi

# PyTorch + CUDA の動作確認
python3 -c "
import torch
print(f'PyTorch: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
print(f'CUDA version: {torch.version.cuda}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
"

# sentence-transformers の動作確認
python3 -c "
from sentence_transformers import SentenceTransformer
model = SentenceTransformer('paraphrase-multilingual-mpnet-base-v2')
embedding = model.encode('テスト文章')
print(f'Embedding dimension: {len(embedding)}')
print('sentence-transformers OK')
"
```

### Qdrant の動作確認

```bash
# Qdrant のバージョン・状態確認（ルートエンドポイント）
curl http://qdrant:6333/

# コレクション一覧
curl http://qdrant:6333/collections
```

> **Note**: `/health` エンドポイントは存在しません。`/` でバージョン情報が返れば正常動作しています。

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

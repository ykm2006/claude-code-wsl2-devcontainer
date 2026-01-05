# タスクリスト: DevContainer スリム化

**プロジェクト**: Docker Compose によるサービス分離でビルド時間短縮・イメージ軽量化
**ブランチ**: `feature/devcontainer-slim`
**作成日**: 2026-01-05
**ステータス**: 🌼 作業中

## 🌸 タスク運用ガイド

### 進捗管理システム

かわいいアイコンを使って進捗を管理します〜 ♪

**ステータスインジケータ**:

- **[🌱]** = 未着手 (種まき前)
- **[🌼]** = 作業中 (お花が育ってる〜)
- **[🌺]** = 完了！(きれいに咲いたよ！)

### アイコン凡例 ✨

- 📝 = ドキュメント作成 (お手紙書いてる)
- 🔍 = 調査・評価 (探索中〜)
- 🛠️ = 実装作業 (がんばって作ってる)
- 🧪 = テスト・検証 (実験中！)
- 📦 = 統合・デプロイ (まとめてお届け)
- 🎯 = マイルストーン (目標達成！)
- ⚠️ = リスク管理 (要注意だよ)

---

## 📋 プロジェクト概要

### 背景・動機

現状の問題点：

1. **Dockerfile肥大化**: ビルド時間 10分以上
2. **Python環境**: 38パッケージがプリインストール（多くは不要）
3. **RAG環境**: sentence-transformers + モデルで **9GB** 占有
4. **Milvus**: ほとんどのプロジェクトで不要なのに常に含まれる

### 📊 プロジェクト目標

- Docker Compose でサービス分離
- TEI (Text Embeddings Inference) でembeddingを外部サービス化
- `runServices` で必要なサービスだけ起動
- `Dockerfile.slim` で最小限のPython環境
- ビルド時間を **10分+ → 2-3分** に短縮

### 技術選定

| コンポーネント | 選定 | 理由 |
|---------------|------|------|
| **Embedding** | HuggingFace TEI | 公式サポート、最速、paraphrase-multilingual-mpnet-base-v2対応確認済み |
| **サービス分離** | Docker Compose | DevContainerがネイティブサポート（`runServices`） |
| **Python管理** | uv | プロジェクトごとの依存管理 |

---

## フェーズ 0: お掃除

### 📝 タスク 0.1: バックアップファイル整理 🌱

**目的**: `.backup_*`, `.bak`, `.problem` 等の古いファイルを削除

**対象ディレクトリ**:
- `/workspace/.devcontainer/`
- `/workspace/003-claude-code-wsl2-devcontainer/.devcontainer/`

**実行項目**:

- [ ] `/workspace/.devcontainer/` 内のバックアップファイル一覧確認
- [ ] `/workspace/003-.../.devcontainer/` 内のバックアップファイル一覧確認
- [ ] 削除対象ファイルの選定
- [ ] バックアップファイル削除実行
- [ ] git コミット

**受け入れ基準**:

- [ ] 不要なバックアップファイルが削除されている
- [ ] 必要なファイルのみ残っている

---

### 📝 タスク 0.2: Dockerfile 同期 🌱

**目的**: `/workspace/.devcontainer/Dockerfile` と `003/.devcontainer/Dockerfile` の差分解消

**実行項目**:

- [ ] 両Dockerfileの差分確認
- [ ] 最新版の特定
- [ ] 同期実行
- [ ] git コミット

**受け入れ基準**:

- [ ] 両Dockerfileが同一内容

---

### 📝 タスク 0.3: プロジェクトルート・各フォルダのお掃除 🌱

**目的**: プロジェクト全体の不要ファイル・一時ファイルを整理

**対象（現在の未追跡ファイル）**:

```
プロジェクトルート:
- .mcp.json.bak
- .mcp.sync-conflict-20250930-062442-J5I5O62.json
- devcontainer.startup.warnings
- tmp/

.devcontainer/:
- Dockerfile.backup_20251003_224305
- Dockerfile.backup_20251004_074552
- Dockerfile.fixed
- Dockerfile.problem
- devcontainer.json.backup_20251004_074552
- devcontainer.json.bak
- mcp-markdown-rag-multilingual.patch
- mcp-markdown-rag-multilingual.patch.backup_20251004_074552
```

**実行項目**:

- [ ] 各ファイルの必要性を確認
- [ ] 不要ファイルの削除
- [ ] `tmp/` ディレクトリの整理（必要なら `.gitignore` 追加）
- [ ] SyncThing競合ファイル（`.sync-conflict-*`）の削除
- [ ] git コミット

**受け入れ基準**:

- [ ] 未追跡の不要ファイルが整理されている
- [ ] プロジェクトルートがスッキリしている
- [ ] `.gitignore` が適切に設定されている

---

## フェーズ 1: 研究・プロトタイプ

### 🔍 タスク 1.1: Docker Compose + DevContainer 最小構成検証 🌱

**目的**: コンセプトが動くか検証

**検証項目**:

- [ ] `dockerComposeFile` + `service` + `runServices` の基本動作
- [ ] VS Code が正しくコンテナに接続できるか
- [ ] 複数の `devcontainer.json` の切り替え

**成果物**:

- [ ] 最小構成の `docker-compose.yml`
- [ ] テスト用 `devcontainer.json`
- [ ] 検証結果ドキュメント

---

### 🔍 タスク 1.2: TEI embedding サービス起動確認 🌱

**目的**: HuggingFace TEI が動作するか検証

**検証項目**:

- [ ] `ghcr.io/huggingface/text-embeddings-inference` イメージ起動
- [ ] `paraphrase-multilingual-mpnet-base-v2` モデル読み込み
- [ ] GPU 対応（`--gpus all`）
- [ ] API エンドポイント動作確認

**コマンド例**:

```bash
docker run --gpus all -p 8080:80 \
  ghcr.io/huggingface/text-embeddings-inference:cuda-latest \
  --model-id sentence-transformers/paraphrase-multilingual-mpnet-base-v2 \
  --pooling mean
```

---

### 🔍 タスク 1.3: runServices 切り替え確認 🌱

**目的**: サービスの選択的起動が動作するか検証

**検証項目**:

- [ ] `devcontainer.json` → `dev` のみ起動
- [ ] `devcontainer.rag.json` → `dev` + `embedding` 起動
- [ ] VS Code での切り替え操作確認

---

### 🔍 タスク 1.4: サービス間通信確認 🌱

**目的**: dev コンテナから embedding サービスへの通信確認

**検証項目**:

- [ ] `http://embedding:80/v1/embeddings` へのリクエスト
- [ ] レスポンスのベクトル形式確認
- [ ] 既存RAGコードとの互換性確認

---

## フェーズ 2: 本実装（検証成功後）

### 🛠️ タスク 2.1: Dockerfile.slim 作成 🌱

**目的**: Python最小化した軽量Dockerfile

**含めるもの**:

- Node.js 20 + Python3 + uv
- zsh / oh-my-zsh / Powerlevel10k
- 基本ツール（git, gh, fzf, delta等）
- Claude Code / Gemini CLI
- 最小限のPythonパッケージ:
  - pytest, black, flake8, mypy, isort
  - markitdown, markitdown-mcp
  - requests, python-dotenv, rich, tqdm

**削除するもの**:

- numpy, pandas, matplotlib, seaborn, jupyter 等
- fastapi, flask, django, sqlalchemy 等
- sentence-transformers, RAG関連全て
- poetry, pipenv, virtualenvwrapper

---

### 🛠️ タスク 2.2: docker-compose.yml 作成 🌱

**目的**: サービス定義

**サービス構成**:

```yaml
services:
  dev:        # メイン開発環境（Dockerfile.slim）
  embedding:  # TEI embedding サービス
  milvus:     # ベクトルDB（オプション）
```

---

### 🛠️ タスク 2.3: devcontainer.json 分離 🌱

**目的**: 用途別の設定ファイル

**ファイル**:

- `devcontainer.json`: 通常開発（devのみ）
- `devcontainer.rag.json`: RAG開発（dev + embedding + milvus）

---

### 🧪 タスク 2.4: 互換性確認 🌱

**目的**: 既存機能が動作するか確認

**確認項目**:

- [ ] Claude Code 動作
- [ ] MCP（Serena, Context7, MarkItDown）動作
- [ ] Git / GitHub CLI 動作
- [ ] zsh / Powerlevel10k 動作
- [ ] Python環境（uv）動作

---

## フェーズ 3: 移行・完了

### 📦 タスク 3.1: 既存環境からの移行 🌱

**目的**: 現行Dockerfileからの移行

**実行項目**:

- [ ] 既存Dockerfileのバックアップ
- [ ] 新構成への切り替え
- [ ] 動作確認
- [ ] 問題発生時のロールバック手順確認

---

### 📝 タスク 3.2: ドキュメント更新 🌱

**目的**: 新構成のドキュメント整備

**実行項目**:

- [ ] CLAUDE.md 更新
- [ ] 新しいセットアップ手順
- [ ] RAG環境の起動方法
- [ ] トラブルシューティング

---

### 🎯 タスク 3.3: プロジェクト完了 🌱

**受け入れ基準**:

- [ ] ビルド時間が 2-3分 に短縮
- [ ] 通常開発でRAG環境が起動しない
- [ ] RAG必要時に正しく起動する
- [ ] 既存機能がすべて動作する
- [ ] ドキュメント完成

---

## 📊 期待効果

| 項目 | Before | After |
|------|--------|-------|
| ビルド時間 | 10分+ | 2-3分 |
| devコンテナサイズ | +9GB | 軽量 |
| RAG利用 | 常に含む | 必要時のみ |
| Python管理 | プリインストール | uv/プロジェクト別 |

---

## 📚 参考リンク

- [HuggingFace TEI](https://github.com/huggingface/text-embeddings-inference)
- [TEI paraphrase-multilingual-mpnet-base-v2 対応](https://huggingface.co/sentence-transformers/paraphrase-multilingual-mpnet-base-v2)
- [DevContainer Docker Compose Reference](https://containers.dev/implementors/json_reference/)
- [runServices Issue](https://github.com/devcontainers/spec/discussions/494)

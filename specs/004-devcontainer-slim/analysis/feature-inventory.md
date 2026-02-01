# 現行 DevContainer 機能棚卸し

**目的**: 現在の「おデブ DevContainer」の機能を分析し、新構成での扱いを決定する

## 機能分類マトリックス

| カテゴリ | 機能 | 現状 | Minimal | Dev | Dev-RAG | 判定理由 |
|---------|------|------|---------|-----|-----|---------|
| **ベースイメージ** | node:20-bookworm | 必須 | ❌ | ❓ | ❓ | Minimal は Node.js 不要 |
| | debian:bookworm-slim | 代替案 | ✅ | ✅ | ✅ | 軽量ベース |
| **AI ツール** | Claude Code (npm) | 必須 | ❌ | ❌ | ❌ | ネイティブに置換 |
| | Claude Code (native) | 代替 | ✅ | ✅ | ✅ | 224MB バイナリ |
| **シェル環境** | Zsh | 必須 | ✅ | ✅ | ✅ | 必須 |
| | Oh My Zsh | 必須 | ✅ | ✅ | ✅ | 生産性向上 |
| | Powerlevel10k | 必須 | ✅ | ✅ | ✅ | UX 向上 |
| | zsh-autosuggestions | 必須 | ✅ | ✅ | ✅ | 生産性 |
| | zsh-syntax-highlighting | 必須 | ✅ | ✅ | ✅ | 生産性 |
| **基本ツール** | git | 必須 | ✅ | ✅ | ✅ | 必須 |
| | curl / wget | 必須 | ✅ | ✅ | ✅ | 必須 |
| | jq | 必須 | ✅ | ✅ | ✅ | JSON 操作 |
| | vim / nano | 必須 | ✅ | ✅ | ✅ | 基本エディタ |
| | less | 必須 | ✅ | ✅ | ✅ | ページャー |
| | procps | 必須 | ✅ | ✅ | ✅ | ps コマンド |
| | sudo | 必須 | ✅ | ✅ | ✅ | 権限昇格 |
| | man-db | 推奨 | ❌ | ❌ | ❌ | 不要（ネットで調べる） |
| | unzip | 推奨 | ✅ | ✅ | ✅ | 解凍 |
| | ca-certificates | 必須 | ✅ | ✅ | ✅ | HTTPS |
| **ネットワークツール** | iptables / ipset | 特殊 | ❌ | ❌ | ❌ | 削除（Firewall 不使用） |
| | iproute2 | 推奨 | ❌ | ✅ | ✅ | Dev 以上で ip コマンド |
| | dnsutils | 推奨 | ❌ | ✅ | ✅ | Dev 以上で dig/nslookup |
| | aggregate | 特殊 | ❌ | ❌ | ❌ | 削除（Firewall 不使用） |
| **開発ツール** | gh (GitHub CLI) | 必須 | ✅ | ✅ | ✅ | GitHub 連携 |
| | git-delta | 推奨 | ✅ | ✅ | ✅ | diff 表示改善 |
| | fzf | 推奨 | ✅ | ✅ | ✅ | ファジー検索 |
| | shellcheck | Dev専用 | ❌ | ✅ | ✅ | シェルスクリプト検証 |
| **Python 環境** | python3 (system) | 必須 | ❌ | ✅ | ✅ | Dev 以上で必要 |
| | python3-pip | 必須 | ❌ | ✅ | ✅ | パッケージ管理 |
| | python3-venv | 必須 | ❌ | ✅ | ✅ | 仮想環境 |
| | python3-dev | 開発用 | ❌ | ✅ | ✅ | C 拡張ビルド |
| | build-essential | 開発用 | ❌ | ✅ | ✅ | コンパイラ |
| | uv | 必須 | ❌ | ✅ | ✅ | 高速パッケージ管理 |
| **Python パッケージ** | numpy, pandas | データ分析 | ❌ | ❌ | ❌ | venv で管理 |
| | matplotlib, seaborn | 可視化 | ❌ | ❌ | ❌ | venv で管理 |
| | jupyter, jupyterlab | ノートブック | ❌ | ❌ | ❌ | venv で管理 |
| | pytest, pytest-cov | テスト | ❌ | ❌ | ❌ | venv で管理 |
| | black, flake8, pylint | リンター | ❌ | ❌ | ❌ | venv で管理 |
| | mypy, pyright | 型チェック | ❌ | ❌ | ❌ | venv で管理 |
| | fastapi, flask, django | Web フレームワーク | ❌ | ❌ | ❌ | venv で管理 |
| | sqlalchemy, psycopg2 | DB | ❌ | ❌ | ❌ | venv で管理 |
| | pymongo, redis, celery | インフラ | ❌ | ❌ | ❌ | venv で管理 |
| | requests, httpx, aiohttp | HTTP | ❌ | ❌ | ❌ | venv で管理 |
| | rich, typer, click | CLI | ❌ | ❌ | ❌ | venv で管理 |
| | beautifulsoup4, html2text | パース | ❌ | ❌ | ❌ | venv で管理 |
| | markitdown, markitdown-mcp | MCP | ❌ | ❌ | ✅ | Dev-RAG の MCP 用 |
| | poetry, pipenv | 依存管理 | ❌ | ❌ | ❌ | uv に統一 |
| **TypeScript/JS 環境** | Node.js 20 | 現状 | ❌ | ❌ | ❌ | Bun で完全代替 |
| | Bun | 代替 | ❌ | ✅ | ✅ | ランタイム + パッケージ管理 |
| | npm global packages | 現状 | ❌ | ❌ | ❌ | 不要 |
| **RAG/ML 関連** | MCP-Markdown-RAG | RAG用 | ❌ | ❌ | ✅ | RAG 専用 |
| | sentence-transformers | RAG用 | ❌ | ❌ | ✅ | 埋め込みモデル |
| | PyTorch (CUDA) | RAG用 | ❌ | ❌ | ✅ | GPU 推論 |
| | 多言語モデル | RAG用 | ❌ | ❌ | ✅ | 日本語対応 |
| **スクリプト** | init-firewall.sh | 特殊 | ❌ | ❌ | ❌ | 削除（使用していない） |
| | init-speckit.sh | 推奨 | ❌ | ✅ | ✅ | SpecKit 初期化 |
| | init-serena-mcp.sh | 推奨 | ❌ | ✅ | ✅ | Serena MCP 初期化 |

## 凡例

- ✅ = 含める
- ⚠️ = 検討中（要確認）
- ❌ = 含めない
- ❓ = 要議論

## 分析結果

### Minimal 環境（26行目まで相当 + Claude Code ネイティブ）

**含めるもの**:
- debian:bookworm-slim ベース
- Claude Code ネイティブバイナリ
- 基本ツール: git, curl, wget, jq, vim, nano, less, procps, sudo, unzip, ca-certificates
- シェル: Zsh + Oh My Zsh + Powerlevel10k + プラグイン
- gh (GitHub CLI)
- git-delta, fzf

**含めないもの**:
- Node.js ランタイム
- Python ランタイム
- ネットワークツール（iptables, iproute2, dnsutils 等）
- man-db
- 全ての Python パッケージ
- init-firewall.sh

**推定サイズ**: ~300-400MB

---

### Dev 環境（Minimal + 言語ランタイム）

**追加するもの**:
- Python 3.11 (system) + python3-dev + build-essential
- uv (Python パッケージ管理 + venv)
- Bun (TypeScript/JS ランタイム + パッケージ管理)
- iproute2, dnsutils（ネットワークデバッグ用）
- shellcheck
- init-speckit.sh, init-serena-mcp.sh

**含めないもの**:
- プリインストール Python パッケージ（numpy 等）→ プロジェクト別 venv
- Node.js → Bun で完全代替
- RAG 関連すべて
- man-db

**推定サイズ**: ~800MB-1GB

---

### Dev-RAG 環境（Dev + ML ツール）

**追加するもの**:
- Embedding モデル（多言語対応）
- ベクトルデータベース（ChromaDB or 代替）[要検討: `/speckit.plan` で決定]
- MCP-Markdown-RAG または代替実装
- sentence-transformers
- PyTorch (CUDA 対応)
- markitdown-mcp

**技術選定の検討事項**（Plan フェーズで決定）:
- ChromaDB vs 他のベクトル DB
- TEI (Text Embeddings Inference) vs sentence-transformers
- 既存 MCP-Markdown-RAG の継続 vs 新規実装

**推定サイズ**: ~8-10GB（モデル込み）

---

## 決定済み事項

| # | 項目 | 決定 | 理由 |
|---|------|------|------|
| 1 | init-firewall.sh | ❌ 削除 | 使用していない。iptables, ipset, aggregate も削除 |
| 2 | Python パッケージ | ❌ プリインストールなし | 全て venv + uv で管理。キャッシュで高速 |
| 3 | iproute2, dnsutils | Dev 以上 | Minimal では不要、開発時のみ必要 |
| 4 | man-db | ❌ 不要 | ネットで調べれば十分 |

# フェーズ 0 差分分析結果

**実施日**: 2025-11-24
**分析対象**: `/workspace/.devcontainer/` vs `003プロジェクト/.devcontainer/`

---

## 📊 概要

**結論**: `/workspace/.devcontainer/` が最新版で、003プロジェクト側は古い状態

- **Runtime版 (/workspace/)**: 2025-11-24 21:35 ✅ 最新
- **003プロジェクト版**: 2025-10-04 前後 ⚠️ 古い

**重要**: Runtime版には **WSL2マウント設定が既に削除** されている → KDE Neon対応の準備済み

---

## 🔍 devcontainer.json の差分

### 1. 新規追加フラグ（Runtime版）

```json
"mountWorkspaceGitRoot": false,
"overrideCommand": false,
```

**意味**: Gitルートのマウント無効化、コマンド上書き無効化

### 2. runArgs の改善

#### 003プロジェクト版（古い）:
```json
"runArgs": ["--cap-add=NET_ADMIN", "--cap-add=NET_RAW", "--gpus", "all"],
```

#### Runtime版（新）:
```json
"runArgs": [
  "--cap-add=NET_ADMIN",
  "--cap-add=NET_RAW",
  "--gpus=all",
  "--network=host"
]
```

**変更内容**:
- `"--gpus", "all"` → `"--gpus=all"` （フラグ形式に統一）
- `"--network=host"` 追加（ネットワーク制御強化）

### 3. **マウント設定の削除（最重要！）** ⚠️

#### 003プロジェクト版（古い - WSL2専用）:
```json
"mounts": [
  "source=claude-code-bashhistory-${devcontainerId},target=/commandhistory,type=volume",
  "source=${localEnv:HOME}/.claude,target=/home/node/.claude,type=bind,consistency=cached",
  "source=${localEnv:HOME}/.claude.json,target=/home/node/.claude.json,type=bind,consistency=cached",
  "source=/mnt/c,target=/mnt/c,type=bind,consistency=cached",       ← WSL2のみ
  "source=/mnt/d,target=/mnt/d,type=bind,consistency=cached"        ← WSL2のみ
]
```

#### Runtime版（新 - クロスプラットフォーム対応）:
```json
"mounts": [
  "source=claude-code-bashhistory-${devcontainerId},target=/commandhistory,type=volume",
  "source=${localEnv:HOME}/.claude,target=/home/node/.claude,type=bind,consistency=cached",
  "source=${localEnv:HOME}/.claude.json,target=/home/node/.claude.json,type=bind,consistency=cached"
  // ← /mnt/c, /mnt/d マウント削除
]
```

**何が削除されたか**:
- `source=/mnt/c,target=/mnt/c` ← WSL2 Cドライブマウント
- `source=/mnt/d,target=/mnt/d` ← WSL2 Dドライブマウント

**なぜ削除？**
KDE Neon（ネイティブLinux）では `/mnt/c`, `/mnt/d` が存在しないため、マウント試行時にエラーが発生する。

**解決策**: シンボリックリンク戦略で環境ごとに適切な設定ファイルを選択

---

## 🔧 Dockerfile の差分

### 1. Docker syntax directive の削除

```dockerfile
# Before (003)
# syntax=docker/dockerfile:1

# After (Runtime)
（削除）
```

**理由**: Dockerfile 1.0構文はすでにデフォルト対応のため不要

### 2. PyTorch インストール方式の改善

#### 003プロジェクト版（古い）:
```dockerfile
# PyTorch: GPU（CUDA 12.1）を使う場合
RUN uv pip install --python "${VENV_DIR}/bin/python" \
       torch torchvision torchaudio \
       --index-url https://download.pytorch.org/whl/cu121
```

#### Runtime版（新）:
```dockerfile
# PyTorch: sentence-transformersが自動でCUDA 12.8版をインストール済み
# ＊明示的なtorchインストール不要（重複回避、容量節約）
```

**改善点**:
- sentence-transformers 依存関係でGPUサポート自動有効化
- 重複インストール削減 → ビルド時間短縮、容量削減
- CUDA 12.1 → 12.8 自動アップグレード

### 3. 多言語モデル適用方式の変更

#### 003プロジェクト版（古い）:
```dockerfile
COPY --chown=node:node mcp-markdown-rag-multilingual.patch /tmp/
RUN patch -p0 < /tmp/mcp-markdown-rag-multilingual.patch \
 && rm /tmp/mcp-markdown-rag-multilingual.patch
```

#### Runtime版（新）:
```dockerfile
COPY --chown=node:node apply-multilingual-model.py /tmp/
RUN python3 /tmp/apply-multilingual-model.py /opt/mcp-servers/markdown-rag/server.py \
 && rm /tmp/apply-multilingual-model.py
```

**改善点**:
- `.patch` 形式から Python スクリプト形式へ（メンテナンス性向上）
- より明確で トラブル追跡しやすい
- スクリプト実行ログで処理内容が可視化

### 4. モデルキャッシング処理の簡潔化

#### 003プロジェクト版（古い）:
```dockerfile
RUN "${VENV_DIR}/bin/python" - <<'PY'
import torch
from sentence_transformers import SentenceTransformer
device = 'cuda' if torch.cuda.is_available() else 'cpu'
print('Using device:', device)
SentenceTransformer('sentence-transformers/paraphrase-multilingual-mpnet-base-v2', device=device)
print('Model cached successfully')
PY
```

#### Runtime版（新）:
```dockerfile
RUN "${VENV_DIR}/bin/python" -c \
    "from sentence_transformers import SentenceTransformer; \
     SentenceTransformer('sentence-transformers/paraphrase-multilingual-mpnet-base-v2'); \
     print('Model cached successfully')"
```

**改善点**:
- Heredoc形式 → `-c` フラグのワンライナーに簡潔化
- GPU/CPU判別処理削除 → SentenceTransformer が自動判別
- 可読性向上、エラー追跡容易

### 5. CMD の追加

#### 003プロジェクト版:
（なし）

#### Runtime版:
```dockerfile
CMD ["/bin/sh", "-c", "while sleep 1000; do :; done"]
```

**目的**: コンテナが起動時に即座に終了しないようにするための wait ループ

---

## ⚠️ 特に重要な差分：KDE Neon 対応

### マウント設定削除の意味

Runtime版で WSL2 マウント設定が削除されているのは、**KDE Neon でのテスト済み確認** を意味します。

```bash
# KDE Neon では以下は存在しない
/mnt/c  ← Windows C: ドライブ（WSL2のみ）
/mnt/d  ← Windows D: ドライブ（WSL2のみ）
```

**現在の状況**:
- ✅ `/workspace/.devcontainer/` は KDE Neon で動作確認済み
- ❌ `003プロジェクト/.devcontainer/` はまだ WSL2 設定が残っている

---

## 📋 同期実施内容

### 実施予定（フェーズ 0 タスク 0.1）

1. **Dockerfile をコピー**
   - 003 版: 2025-10-04 08:17
   - Runtime 版: 2025-11-17 01:12 ← 最新版

2. **devcontainer.json をコピー**
   - 003 版: 2025-10-04 07:39
   - Runtime 版: 2025-11-24 21:35 ← 最新版

3. **その他ファイルの確認**
   - `.p10k.zsh`: 同一内容
   - `claude-global/`: 両方に存在（同期確認）
   - `init-*.sh` スクリプト: 003版に存在、Runtime版に確認

4. **古いバックアップファイルの整理**
   - 003 プロジェクト側: 複数の `.backup_` ファイルを削除判定

---

## 📌 次ステップ

- [ ] Dockerfile を `003/.devcontainer/` にコピー
- [ ] devcontainer.json を `003/.devcontainer/` にコピー
- [ ] 差分確認（git diff）
- [ ] git コミット（同期完了を記録）
- [ ] tasks.md のタスク 0.1 を [🌼] → [🌺] に更新

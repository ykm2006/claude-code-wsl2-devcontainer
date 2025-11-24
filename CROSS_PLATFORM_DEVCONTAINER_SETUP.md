# クロスプラットフォーム DevContainer セットアップガイド

このドキュメントは、WSL2 環境とネイティブ Linux（KDE Neon）環境で、統一された DevContainer 設定を自動的に適用する仕組みのセットアップ手順を説明しています。

## 概要

本プロジェクトでは、以下の環境で同一の DevContainer 設定を運用しています：

- **WSL2 マシン × 3**（会社 ThinkPad、個人 Lenovo、自宅 Windows）
- **ネイティブ Linux × 1**（KDE Neon - メイン開発環境）
- **同期ツール**: SyncThing

各環境では異なるドライブマウント設定が必要なため、**自動環境判定とシンボリックリンク戦略**を採用しています。

## 仕組み

### ファイル構成

```
/workspace/
├── .devcontainer/
│   ├── devcontainer.json         ← シンボリックリンク（環境ごとに自動切り替え）
│   ├── devcontainer.json.wsl2    ← WSL2 向け（/mnt/c, /mnt/d マウント付き）
│   └── devcontainer.json.linux   ← KDE Neon 向け（マウント設定なし）
└── scripts/
    ├── code                      ← code コマンドラッパー
    └── setup-devcontainer-symlink.sh  ← 環境判定スクリプト

003-claude-code-wsl2-devcontainer/
├── .devcontainer/
│   ├── devcontainer.json         ← シンボリックリンク
│   ├── devcontainer.json.wsl2    ← WSL2 向け
│   └── devcontainer.json.linux   ← KDE Neon 向け
└── scripts/
    ├── code                      ← code コマンドラッパー
    └── setup-devcontainer-symlink.sh  ← 環境判定スクリプト
```

### 動作フロー

```
ユーザーが実行：
$ code .
  ↓
PATH から /workspace/scripts/code が見つかる
  ↓
code ラッパーが実行される
  ↓
setup-devcontainer-symlink.sh を呼び出す
  ↓
環境判定：
  - WSL2 なら: devcontainer.json → devcontainer.json.wsl2 へ symlink
  - KDE Neon なら: devcontainer.json → devcontainer.json.linux へ symlink
  ↓
/usr/bin/code を実行（VSCode 起動）
  ↓
VSCode が devcontainer.json（正しい symlink 先）を読み込む
  ↓
環境に合わせた DevContainer ビルド＆起動 ✅
```

## セットアップ手順

### Step 1: PATH 環境変数の設定

**ホスト側**（KDE Neon または WSL2）の `~/.bashrc` に以下の行を追加してください：

⚠️ **重要**: `~/.zshrc` ではなく **`~/.bashrc`** に追加してください。このスクリプトはホスト側で動作するため、DevContainer 内のシェル設定ではなく、ホスト側のシェル設定が必要です。

```bash
# DevContainer クロスプラットフォーム対応
export PATH="/workspace/scripts:$PATH"
```

**編集コマンド例**:
```bash
echo 'export PATH="/workspace/scripts:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Step 2: 初回確認

新しいターミナルウィンドウを開いて、PATH が正しく設定されたか確認：

```bash
which code
# 出力: /workspace/scripts/code
```

### Step 3: DevContainer 再構築

`code .` を実行すると、自動的に環境判定とシンボリックリンク作成が行われます：

```bash
cd /workspace
code .
```

**出力例**:
```
[INFO] Setting up devcontainer.json symlink...
[INFO] Detecting environment...
[INFO] Environment detected: linux
[INFO] Native Linux environment detected
[DEBUG] Removing existing devcontainer.json
[INFO] Created symlink to devcontainer.json.linux
[INFO] ✅ Setup complete for Linux environment
[INFO] Launching VS Code...
```

### Step 4: VSCode DevContainer 再構築

VSCode で DevContainer の再構築を実行：

1. **VS Code コマンドパレット** を開く（`Ctrl+Shift+P` / `Cmd+Shift+P`）
2. **"Dev Containers: Rebuild Container"** を検索して実行
3. ビルド完了を待つ

## 環境別の違い

### WSL2 環境（会社・個人・自宅）

**マウント設定**:
```json
"mounts": [
  "source=/mnt/c,target=/mnt/c,type=bind,consistency=cached",
  "source=/mnt/d,target=/mnt/d,type=bind,consistency=cached"
]
```

**自動判定方法**: `grep -qi microsoft /proc/version`

### ネイティブ Linux（KDE Neon）

**マウント設定**: なし（Windows ドライブアクセスは不要）

**自動判定方法**: `/proc/version` に "microsoft" がない

## SyncThing 同期時の注意

SyncThing で `/workspace/.devcontainer/devcontainer.json` が同期される場合：

1. **symlink は同期されない**（`.gitignore` で除外）
2. **各マシンで `code .` を実行するだけで自動設定される**
   - ただし、初回は `~/.bashrc` に PATH を設定しておく必要があります
3. マニュアル調整は **不要**

## トラブルシューティング

### 問題: `code` コマンドが見つからない

**原因**: PATH が設定されていない

**解決方法**:
```bash
# ~/.bashrc に追加されているか確認
grep "export PATH.*workspace/scripts" ~/.bashrc

# 設定後、ターミナルをリロード
source ~/.bashrc
# または新しいターミナルウィンドウを開く
```

### 問題: setup-devcontainer-symlink.sh がエラーを出す

**原因**: `/workspace/.devcontainer/devcontainer.json.wsl2` または `.linux` が見つからない

**解決方法**:
```bash
# ファイルの存在確認
ls -la /workspace/.devcontainer/devcontainer.json.*

# 003 プロジェクトからコピー（もし削除されていた場合）
cp 003-claude-code-wsl2-devcontainer/.devcontainer/devcontainer.json.* /workspace/.devcontainer/
```

### 問題: VSCode で devcontainer.json のパスが古いままの場合

**解決方法**:
```bash
# 手動で setup スクリプトを実行
bash /workspace/scripts/setup-devcontainer-symlink.sh

# symlink が正しく作成されたか確認
ls -la /workspace/.devcontainer/devcontainer.json
```

## 運用上のベストプラクティス

### 1. 定期的な確認

定期的に symlink が正しく設定されているか確認：

```bash
# WSL2 の場合、このようになるはず
ls -la /workspace/.devcontainer/devcontainer.json
# lrwxrwxrwx ... .devcontainer/devcontainer.json -> devcontainer.json.wsl2

# KDE Neon の場合
ls -la /workspace/.devcontainer/devcontainer.json
# lrwxrwxrwx ... .devcontainer/devcontainer.json -> devcontainer.json.linux
```

### 2. 新マシンへの展開

新しいマシンに SyncThing で同期後：

```bash
# 1. PATH を ~/.bashrc に追加
echo 'export PATH="/workspace/scripts:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 2. code . を実行（自動セットアップ）
cd /workspace
code .
```

### 3. 手動でのセットアップ

`code .` が実行できない場合の手動セットアップ：

```bash
# 環境判定スクリプトを手動実行
bash /workspace/scripts/setup-devcontainer-symlink.sh

# symlink が作成されたか確認
ls -la /workspace/.devcontainer/devcontainer.json

# VSCode を手動で起動
/usr/bin/code .
```

## ファイルの更新・保守

### devcontainer.json を更新する場合

1. **両方のファイルを更新**:
   ```bash
   # 003 プロジェクト側
   vi 003-claude-code-wsl2-devcontainer/.devcontainer/devcontainer.json.wsl2
   vi 003-claude-code-wsl2-devcontainer/.devcontainer/devcontainer.json.linux

   # /workspace 側にコピー
   cp 003-claude-code-wsl2-devcontainer/.devcontainer/devcontainer.json.* /workspace/.devcontainer/
   ```

2. **git にコミット**:
   ```bash
   git add .devcontainer/devcontainer.json.wsl2
   git add .devcontainer/devcontainer.json.linux
   git commit -m "Update devcontainer configuration for cross-platform support"
   ```

3. **各マシンで DevContainer を再構築**:
   ```bash
   # VSCode: "Dev Containers: Rebuild Container"
   ```

### scripts を更新する場合

1. **003 プロジェクト側を更新**:
   ```bash
   vi 003-claude-code-wsl2-devcontainer/scripts/code
   vi 003-claude-code-wsl2-devcontainer/scripts/setup-devcontainer-symlink.sh
   ```

2. **/workspace 側にコピー**:
   ```bash
   cp 003-claude-code-wsl2-devcontainer/scripts/* /workspace/scripts/
   ```

3. **git にコミット**:
   ```bash
   git add scripts/
   git commit -m "Update DevContainer setup scripts"
   ```

## 参考資料

- `.devcontainer/devcontainer.json.wsl2`: WSL2 環境用の設定
- `.devcontainer/devcontainer.json.linux`: ネイティブ Linux 用の設定
- `scripts/code`: code コマンドラッパー
- `scripts/setup-devcontainer-symlink.sh`: 環境判定・シンボリックリンク作成スクリプト

---

**作成日**: 2025-11-24
**最終更新**: 2025-11-24
**対応環境**: WSL2 × 3 + KDE Neon × 1

# DevContainer最適化 - クイックスタートガイド

> **注意**: これは参照用の日本語版です。正式なクイックスタートガイドは英語版 (`quickstart.md`) を参照してください。
> **Note**: This is a Japanese reference version. The official quickstart guide is the English version (`quickstart.md`).

## 概要
このガイドは、マルチプロジェクト・マルチマシン開発環境向けに最適化されたDevContainer設定のセットアップと検証を支援します。

## 前提条件
- Docker DesktopまたはDocker Engineがインストール済み
- Dev Containers拡張機能付きのVS Code
- システムでGitが設定済み

## クイックセットアップ（5分）

### 1. クローンとコンテナオープン
```bash
# リポジトリをクローン
git clone <repository-url>
cd <repository-name>

# VS Codeで開く
code .

# プロンプトが表示されたら「Reopen in Container」をクリック
# またはコマンドパレット: 「Dev Containers: Reopen in Container」を使用
```

### 2. コンテナ環境の確認
コンテナが起動したら、ターミナルを開いて実行：

```bash
# シェル設定の確認
echo $SHELL
which zsh

# Powerlevel10kテーマのテスト
p10k configure

# 開発ツールの確認
node --version
python3 --version
git --version
delta --version

# Claude Code統合のテスト
claude --version
echo "# Test Claude context" > CLAUDE.md
```

### 3. マルチプロジェクトサポートの検証
```bash
# テストプロジェクト構造を作成
mkdir -p projects/{frontend,backend,shared}

# プロジェクト固有のボリュームをテスト
touch projects/frontend/package.json
touch projects/backend/requirements.txt
touch projects/shared/README.md

# ボリュームマウントを確認
df -h | grep workspace
docker volume ls | grep devcontainer
```

## 設定検証

### WSL2互換性のテスト
WSL2固有の機能を確認するために以下のコマンドを実行：

```bash
# パス処理のテスト
echo "Current workspace: $PWD"
echo "Container workspace: ${CONTAINER_WORKSPACE_FOLDER:-/workspace}"

# Claude設定の確認
ls -la ~/.claude/
echo $CLAUDE_CONFIG_DIR

# パフォーマンスマウントのテスト
ls -la ~/.npm/
ls -la ~/.cache/
```

### 開発ワークフローの検証

#### テスト1: マルチプロジェクト依存関係の分離
```bash
# フロントエンドプロジェクトに移動
cd projects/frontend
npm init -y
npm install express@4.18.0

# バックエンドプロジェクトに移動
cd ../backend
python3 -m venv .venv
source .venv/bin/activate
pip install flask==2.3.0

# 分離の確認 - バージョンが競合していないはず
cd ../frontend && npm list express
cd ../backend && pip list | grep Flask
```

#### テスト2: Claude Code統合
```bash
# Claude Codeコンテキストのテスト
echo "# Project: Multi-Project DevContainer
## Frontend: Express.js application
## Backend: Flask API
## Shared: Common utilities" > CLAUDE.md

# Claudeがワークスペースにアクセスできることを確認
ls -la ~/.claude/
echo $CLAUDE_WORKSPACE_ROOT

# MCPサーバーの可用性をテスト（設定されている場合）
which mcp-server-filesystem
which mcp-server-git
```

#### テスト3: Git設定同期
```bash
# git設定が引き継がれていることを確認
git config --global user.name
git config --global user.email

# git-delta統合のテスト
git log --oneline -5
echo "test change" >> README.md
git diff
```

## パフォーマンス検証

### コンテナ起動時間
```bash
# 起動時間を記録
time docker-compose up -d devcontainer

# 2回目以降の起動は30秒未満で完了する必要がある
# 初回ビルドは2-5分かかる場合がある
```

### リソース使用状況
```bash
# メモリ使用量の確認
free -h
docker stats --no-stream

# キャッシュ効率の確認
du -sh ~/.npm/
du -sh ~/.cache/
df -h /workspace
```

## トラブルシューティング

### よくある問題

#### 1. コンテナが起動しない
```bash
# Dockerデーモンの確認
docker version
docker info

# コンテナログの確認
docker logs <container-name>

# コンテナのリセット
docker-compose down -v
docker-compose up --build
```

#### 2. Claude Codeが動作しない
```bash
# マウントの確認
ls -la ~/.claude/
cat ~/.claude.json  # 実際のAPIキーは表示されないはず

# 環境変数の確認
echo $CLAUDE_CONFIG_DIR
echo $CLAUDE_WORKSPACE_ROOT

# VS Code拡張機能の再起動
# コマンドパレット: 「Developer: Reload Window」
```

#### 3. Powerlevel10kが読み込まれない
```bash
# zshがデフォルトシェルであることを確認
echo $SHELL

# テーマの再設定
p10k configure

# 設定の確認
ls -la ~/.p10k.zsh
```

#### 4. ボリュームマウントの問題
```bash
# マウントポイントの確認
df -h | grep workspace
mount | grep workspace

# 権限の確認
ls -la /workspace
whoami
id
```

### WSL2固有の問題

#### Windows WSL2
```bash
# WSL2統合の確認
echo $WSL_DISTRO_NAME
echo $WSL_INTEROP

# Windowsパス変換の確認
wslpath -w /workspace
```

## 検証チェックリスト

- [ ] コンテナが30秒未満で起動（初回ビルド後）
- [ ] Powerlevel10kテーマが正しく読み込まれる
- [ ] Claude Code拡張機能が機能する
- [ ] マルチプロジェクトディレクトリ構造が作成される
- [ ] 依存関係分離が動作する（npm/pip）
- [ ] Git設定が同期される
- [ ] ボリュームマウントが良好に動作する
- [ ] WSL2パスが正しく解決される
- [ ] リソース使用量が許容範囲内である

## 次のステップ

1. **設定のカスタマイズ**: 特定のニーズに合わせて `.devcontainer/devcontainer.json` を編集
2. **プロジェクトの追加**: `projects/` の下に追加のプロジェクトディレクトリを作成
3. **チーム設定**: チームメンバーと設定を共有
4. **CI統合**: DevContainerビルドの自動テストを設定

## サポート

問題や改善について：
1. 上記のトラブルシューティングセクションを確認
2. `/workspace/.devcontainer/logs/` のログを確認
3. `research.md` の完全なドキュメントを参照
4. プロジェクトリポジトリでissueを作成

## 成功指標

このクイックスタートを完了した後、以下を達成できるはずです：
- **70-85%高速なビルド** レイヤー最適化による
- **60%高速なコンテナ初期化** パフォーマンスチューニングによる
- **Windows WSL2環境での最適化された体験**
- **AI支援開発のためのシームレスなClaude Code統合**
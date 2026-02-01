# DevContainer トラブルシューティングガイド

DevContainer 使用時によくある問題と解決方法をまとめています。

## 目次

- [1. ビルドエラー](#1-ビルドエラー)
- [2. GPU 関連の問題](#2-gpu-関連の問題)
- [3. ボリュームマウントの問題](#3-ボリュームマウントの問題)
- [4. ネットワーク関連](#4-ネットワーク関連)
- [5. VS Code 拡張機能の問題](#5-vs-code-拡張機能の問題)
- [6. その他の問題](#6-その他の問題)

---

## 1. ビルドエラー

### 1.1 Docker デーモンが起動していない

**エラーメッセージ例**:
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
error during connect: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/json": dial unix /var/run/docker.sock: connect: no such file or directory
```

**解決方法**:

```bash
# Linux / WSL2
sudo systemctl start docker
sudo systemctl enable docker  # 自動起動を有効化

# Docker Desktop (Windows/Mac)
# Docker Desktop アプリケーションを起動
```

**WSL2 特有の注意点**:
- Docker Desktop の「Use the WSL 2 based engine」が有効になっているか確認
- Settings → Resources → WSL Integration で対象の WSL ディストリビューションが有効か確認

---

### 1.2 ディスク容量不足

**エラーメッセージ例**:
```
no space left on device
write /var/lib/docker/...: no space left on device
```

**解決方法**:

```bash
# Docker が使用しているディスク容量を確認
docker system df

# 未使用のイメージ・コンテナ・ネットワークを削除
docker system prune

# より積極的なクリーンアップ（未使用イメージも削除）
docker system prune -a

# ⚠️ Volume も削除する場合（データが消えるので注意！）
docker system prune -a --volumes
```

**WSL2 の場合**:
WSL2 の仮想ディスクは自動で縮小しないため、手動で最適化が必要な場合がある：

```powershell
# PowerShell (管理者権限)
wsl --shutdown
Optimize-VHD -Path "$env:LOCALAPPDATA\Docker\wsl\data\ext4.vhdx" -Mode Full
```

---

### 1.3 Dockerfile のビルドエラー

**エラーメッセージ例**:
```
failed to solve: process "/bin/sh -c apt-get install -y ..." did not complete successfully
E: Unable to locate package ...
```

**解決方法**:

```bash
# パッケージリストを更新してから再ビルド
docker compose build --no-cache <service-name>

# キャッシュを完全にクリアして再ビルド
docker builder prune -a
docker compose build --no-cache
```

**よくある原因**:
- `apt-get update` が `apt-get install` の前に実行されていない
- パッケージ名の typo
- ベースイメージのバージョン変更でパッケージ名が変わった

---

### 1.4 ベースイメージの取得失敗

**エラーメッセージ例**:
```
pull access denied for <image-name>, repository does not exist
manifest for <image>:<tag> not found
```

**解決方法**:

```bash
# イメージ名とタグを確認
docker search <image-name>

# 手動でプル（詳細なエラーを確認）
docker pull <image-name>:<tag>

# 認証が必要な場合
docker login <registry>
```

---

## 2. GPU 関連の問題

### 2.1 GPU が認識されない

**エラーメッセージ例**:
```
docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]
NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver
```

**解決方法**:

```bash
# 1. ホストで NVIDIA ドライバが動作しているか確認
nvidia-smi

# 2. NVIDIA Container Toolkit がインストールされているか確認
dpkg -l | grep nvidia-container-toolkit

# 3. インストールされていない場合
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 4. Docker デーモンを再起動
sudo systemctl restart docker
```

**WSL2 での注意点**:
- Windows 側に NVIDIA GPU ドライバ（WSL対応版）がインストールされている必要がある
- WSL2 内には Linux 用ドライバを**インストールしない**（Windows ドライバを使用）

---

### 2.2 CUDA バージョン不一致

**エラーメッセージ例**:
```
CUDA error: CUBLAS_STATUS_NOT_INITIALIZED
RuntimeError: CUDA error: no kernel image is available for execution on the device
```

**解決方法**:

```bash
# 1. ホストの CUDA バージョンを確認
nvidia-smi  # 右上に表示される CUDA Version

# 2. コンテナ内の CUDA バージョンを確認
nvcc --version

# 3. PyTorch の CUDA バージョンを確認
python -c "import torch; print(torch.version.cuda)"
```

**バージョン互換性のルール**:
- コンテナ内の CUDA バージョン ≤ ホストのドライバがサポートする CUDA バージョン
- PyTorch の CUDA バージョン = コンテナの CUDA バージョン

**docker-compose.yml での GPU 設定例**:
```yaml
services:
  dev-rag:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all  # または "1" で特定の数
              capabilities: [gpu]
```

---

### 2.3 GPU メモリ不足

**エラーメッセージ例**:
```
CUDA out of memory. Tried to allocate X MiB
RuntimeError: CUDA error: out of memory
```

**解決方法**:

```bash
# 1. GPU メモリ使用状況を確認
nvidia-smi

# 2. 他のプロセスが GPU を使用していれば終了
# 3. バッチサイズを小さくする
# 4. モデルを小さいものに変更
# 5. gradient checkpointing を有効化
```

---

## 3. ボリュームマウントの問題

### 3.1 パーミッションエラー

**エラーメッセージ例**:
```
permission denied
EACCES: permission denied, open '/workspace/...'
```

**解決方法**:

```jsonc
// devcontainer.json
{
  // コンテナ内のユーザー UID/GID をホストに合わせる
  "updateRemoteUserUID": true,

  // または明示的にユーザーを指定
  "remoteUser": "node",
  "containerUser": "node"
}
```

```bash
# ホストでの UID/GID を確認
id

# コンテナ内での UID/GID を確認
id

# 一致しない場合、ホスト側でディレクトリの所有権を変更
sudo chown -R $(id -u):$(id -g) /path/to/workspace
```

**WSL2 特有の問題**:
Windows ファイルシステム（`/mnt/c/...`）と Linux ファイルシステム（`~/...`）でパーミッションの扱いが異なる。可能な限り WSL2 の Linux ファイルシステム内で作業する。

---

### 3.2 ファイルが見つからない / マウントされていない

**エラーメッセージ例**:
```
bind mount source path does not exist
Error: ENOENT: no such file or directory
```

**解決方法**:

```bash
# 1. マウント元のパスが存在するか確認
ls -la /path/to/source

# 2. コンテナ内でマウントを確認
docker exec -it <container-name> mount | grep workspace

# 3. docker-compose.yml のボリューム設定を確認
```

```yaml
# docker-compose.yml
services:
  dev:
    volumes:
      # 相対パスは docker-compose.yml からの相対パス
      - ..:/workspace:cached

      # 絶対パスを使用する場合
      - /home/user/project:/workspace:cached
```

---

### 3.3 ファイル変更が反映されない / 遅い

**解決方法**:

```yaml
# docker-compose.yml - パフォーマンス改善
services:
  dev:
    volumes:
      # macOS/Windows: cached オプションでパフォーマンス改善
      - ..:/workspace:cached

      # node_modules は named volume で高速化
      - node-modules:/workspace/node_modules

volumes:
  node-modules:
```

```jsonc
// devcontainer.json - WSL2 での設定
{
  "mounts": [
    {
      "source": "node-modules-${devcontainerId}",
      "target": "${containerWorkspaceFolder}/node_modules",
      "type": "volume"
    }
  ]
}
```

---

## 4. ネットワーク関連

### 4.1 プロキシ環境でのビルド失敗

**エラーメッセージ例**:
```
Could not resolve host: github.com
Temporary failure in name resolution
Connection timed out
```

**解決方法**:

```dockerfile
# Dockerfile でプロキシを設定
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}
```

```yaml
# docker-compose.yml
services:
  dev:
    build:
      args:
        - HTTP_PROXY=${HTTP_PROXY}
        - HTTPS_PROXY=${HTTPS_PROXY}
        - NO_PROXY=${NO_PROXY}
    environment:
      - HTTP_PROXY=${HTTP_PROXY}
      - HTTPS_PROXY=${HTTPS_PROXY}
      - NO_PROXY=${NO_PROXY}
```

```bash
# Docker デーモン自体にプロキシを設定
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080"
Environment="HTTPS_PROXY=http://proxy.example.com:8080"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

### 4.2 DNS 解決の問題

**エラーメッセージ例**:
```
Temporary failure resolving 'deb.debian.org'
Could not resolve host
```

**解決方法**:

```bash
# 1. ホストの DNS 設定を確認
cat /etc/resolv.conf

# 2. Docker の DNS 設定を変更
sudo tee /etc/docker/daemon.json << EOF
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF
sudo systemctl restart docker
```

```yaml
# docker-compose.yml で個別に設定
services:
  dev:
    dns:
      - 8.8.8.8
      - 8.8.4.4
```

**WSL2 での注意点**:
WSL2 の `/etc/resolv.conf` は自動生成される。カスタム DNS を使用する場合：

```bash
# /etc/wsl.conf
[network]
generateResolvConf = false

# その後 WSL を再起動して /etc/resolv.conf を手動作成
```

---

### 4.3 コンテナ間通信ができない

**エラーメッセージ例**:
```
Connection refused
Could not connect to qdrant:6333
```

**解決方法**:

```bash
# 1. 対象コンテナが起動しているか確認
docker ps

# 2. 同じネットワークにいるか確認
docker network inspect <network-name>

# 3. コンテナ内から疎通確認
docker exec -it <container> ping <other-container>
docker exec -it <container> curl http://<other-container>:<port>/

# Qdrant の場合（/health は存在しない、/ でバージョン情報が返る）
curl http://qdrant:6333/
```

```yaml
# docker-compose.yml - 明示的にネットワークを定義
services:
  dev:
    networks:
      - app-network

  qdrant:
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

---

### 4.4 ポートが既に使用されている

**エラーメッセージ例**:
```
Bind for 0.0.0.0:8080 failed: port is already allocated
address already in use
```

**解決方法**:

```bash
# 1. ポートを使用しているプロセスを確認
sudo lsof -i :8080
# または
sudo netstat -tlnp | grep 8080

# 2. プロセスを終了するか、別のポートを使用
```

```yaml
# docker-compose.yml - ポートを変更
services:
  dev:
    ports:
      - "8081:8080"  # ホストの 8081 → コンテナの 8080
```

---

## 5. VS Code 拡張機能の問題

### 5.1 拡張機能がインストールされない

**解決方法**:

```jsonc
// devcontainer.json
{
  "customizations": {
    "vscode": {
      "extensions": [
        // 拡張機能 ID を正確に指定（Publisher.ExtensionName）
        "ms-python.python",
        "dbaeumer.vscode-eslint"
      ]
    }
  }
}
```

```bash
# 拡張機能 ID を確認
# VS Code で拡張機能を右クリック → "Copy Extension ID"

# コンテナ内で手動インストール
code --install-extension <extension-id>
```

---

### 5.2 拡張機能が動作しない

**よくある原因と解決方法**:

1. **依存関係が不足**
   ```dockerfile
   # Python 拡張機能には Python が必要
   RUN apt-get install -y python3 python3-pip
   ```

2. **ワークスペース設定の競合**
   ```jsonc
   // .vscode/settings.json と devcontainer.json の設定が競合
   // devcontainer.json で明示的に設定
   {
     "customizations": {
       "vscode": {
         "settings": {
           "python.defaultInterpreterPath": "/usr/local/bin/python"
         }
       }
     }
   }
   ```

3. **拡張機能のバージョン問題**
   ```jsonc
   // 特定バージョンを指定
   {
     "customizations": {
       "vscode": {
         "extensions": [
           "ms-python.python@2024.0.1"
         ]
       }
     }
   }
   ```

---

### 5.3 Dev Containers 拡張機能自体の問題

**解決方法**:

```bash
# 1. VS Code の Dev Containers 拡張機能を再インストール
# 2. コンテナを完全に削除して再作成
docker rm -f <container-name>
docker volume rm <related-volumes>

# 3. VS Code の設定をリセット
# Ctrl+Shift+P → "Dev Containers: Reset Container"
```

---

## 6. その他の問題

### 6.1 コンテナが起動直後に終了する

**解決方法**:

```bash
# 1. コンテナのログを確認
docker logs <container-name>

# 2. エントリーポイントを確認
docker inspect <image-name> --format='{{.Config.Entrypoint}}'
docker inspect <image-name> --format='{{.Config.Cmd}}'
```

```jsonc
// devcontainer.json - コマンドを上書き
{
  "overrideCommand": true  // デフォルトは true
}
```

---

### 6.2 シェルが正しく動作しない

**解決方法**:

```jsonc
// devcontainer.json
{
  // デフォルトシェルを指定
  "settings": {
    "terminal.integrated.defaultProfile.linux": "zsh"
  },

  // または postCreateCommand で設定
  "postCreateCommand": "chsh -s $(which zsh)"
}
```

---

### 6.3 環境変数が設定されていない

**解決方法**:

```jsonc
// devcontainer.json
{
  // コンテナ環境変数
  "containerEnv": {
    "MY_VAR": "value"
  },

  // リモート環境変数（コンテナ起動後）
  "remoteEnv": {
    "PATH": "${containerEnv:PATH}:/custom/path"
  }
}
```

```yaml
# docker-compose.yml
services:
  dev:
    environment:
      - MY_VAR=value
    env_file:
      - .env  # 機密情報は .env ファイルから読み込む
```

---

## クイックリファレンス

### よく使う診断コマンド

```bash
# Docker の状態確認
docker info
docker system df
docker ps -a

# ネットワーク確認
docker network ls
docker network inspect bridge

# ログ確認
docker logs <container-name> --tail 100 -f

# コンテナ内に入る
docker exec -it <container-name> /bin/bash

# イメージの詳細
docker inspect <image-name>
```

### 完全リセット手順

問題が解決しない場合の最終手段：

```bash
# 1. 全コンテナを停止・削除
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# 2. 全イメージを削除
docker rmi $(docker images -q)

# 3. ビルドキャッシュを削除
docker builder prune -a

# 4. ネットワークを削除（デフォルト以外）
docker network prune

# 5. ⚠️ Volume も削除する場合（データが消える！）
docker volume prune

# 6. VS Code でコンテナを再作成
# Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

---

**関連ドキュメント**:
- [README.md](./README.md) - アーキテクチャ概要
- [DevContainer 公式ドキュメント](https://containers.dev/)
- [Docker 公式トラブルシューティング](https://docs.docker.com/config/daemon/#troubleshoot-the-daemon)

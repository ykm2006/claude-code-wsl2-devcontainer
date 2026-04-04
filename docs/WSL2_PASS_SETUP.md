# WSL2 で pass を使った GH_TOKEN 管理

WSL2 環境で GitHub Token を安全に管理し、DevContainer に渡す方法。

## 背景

- KDE Neon では KWallet でトークン管理
- WSL2 は GUI なし環境なので KWallet は使いにくい
- **pass** (GPG ベースのパスワードマネージャー) が最適

## 前提条件

- WSL2 環境（Ubuntu/Debian系）
- GPG キーがあること（なければ作成）

## セットアップ手順

### 1. pass のインストール

```bash
sudo apt update && sudo apt install pass
```

### 2. GPG キーの確認

```bash
gpg --list-secret-keys --keyid-format LONG
```

出力例：
```
/home/yuichi/.gnupg/pubring.kbx
-------------------------------
sec   rsa4096 2026-02-01 [SC] [expires: 2026-07-31]
      AFF5E9CCD92CD26A2EC75F254C3DB3496F280951
uid           [ultimate] Yuichi Kawamoto <ykm2006083001@gmail.com>
ssb   rsa4096 2026-02-01 [E] [expires: 2026-07-31]
```

キーがなければ作成：
```bash
gpg --full-generate-key
# → RSA, 4096bit, 有効期限お好みで
```

### 3. pass の初期化

メールアドレスまたはキーIDを使用：
```bash
pass init "ykm2006083001@gmail.com"
# または
pass init "6F280951"  # キーID（末尾8文字）
```

### 4. GitHub Token の保存

```bash
pass insert github/token
# → トークンを入力（2回）
```

#### GitHub Token の作成（必要な場合）

1. GitHub → Settings → Developer settings → Personal access tokens
2. Classic Token を選択
3. 必要なスコープ：
   - **`repo`** - リポジトリへのフルアクセス（必須）
   - `workflow` - GitHub Actions 編集（任意）
   - `read:org` - Organization リポジトリアクセス（任意）

### 5. シェル設定

#### bash の場合（`~/.bashrc`）

```bash
echo 'export GH_TOKEN=$(pass show github/token 2>/dev/null)' >> ~/.bashrc
source ~/.bashrc
```

#### zsh の場合（`~/.zshrc`）

```bash
echo 'export GH_TOKEN=$(pass show github/token 2>/dev/null)' >> ~/.zshrc
source ~/.zshrc
```

### 6. GPG パスフレーズのキャッシュ設定

毎回パスフレーズを入力するのは面倒なので、gpg-agent でキャッシュ：

```bash
mkdir -p ~/.gnupg
cat >> ~/.gnupg/gpg-agent.conf << 'EOF'
default-cache-ttl 86400
max-cache-ttl 604800
EOF
```

- `default-cache-ttl 86400` → 24時間キャッシュ
- `max-cache-ttl 604800` → 最大7日間

設定反映：
```bash
gpgconf --kill gpg-agent
```

### 7. 動作確認

```bash
# トークンが設定されているか確認（先頭10文字のみ表示）
echo $GH_TOKEN | head -c 10
```

## DevContainer での利用

`docker-compose.yml` で環境変数として渡す：

```yaml
x-common-env: &common-env
  GH_TOKEN: ${GH_TOKEN:-}    # 未設定でもエラーにならない（KDE では空）
```

DevContainer 起動時にホストの `GH_TOKEN` が自動的にコンテナに渡される。

### `--force-disable-user-env` の注意事項（Issue #77）

VS Code が `--force-disable-user-env` フラグを使用する場合、`.bashrc` の環境変数がコンテナに渡らないことがある。

- **ターミナルから `code .` で起動** → GH_TOKEN が渡る（親プロセスの環境変数を継承）
- **デスクトップアイコンから起動** → GH_TOKEN が渡らない場合がある

WSL2 では常にターミナルから起動するため影響は少ないが、動作しない場合は起動方法を確認すること。

> KDE Neon 環境では D-Bus ソケット転送による KWallet 直接アクセスで、この問題を回避している。
> 詳細は [KDE_NEON_KWALLET_VSCODE.md](KDE_NEON_KWALLET_VSCODE.md) を参照。

## トラブルシューティング

### パスフレーズが毎回聞かれる

- `gpg-agent.conf` の設定を確認
- `gpgconf --kill gpg-agent` で再起動

### DevContainer で GH_TOKEN が空

- WSL2 ホスト側で `echo $GH_TOKEN` を確認
- シェル設定ファイルを `source` したか確認
- VS Code の起動方法を確認（ターミナルから `code .` で起動しているか）
- DevContainer を再起動（Rebuild Container）

### pass show でエラー

```bash
# ストアの状態確認
pass
pass show github/token
```

## 参考リンク

- [pass - The Standard Unix Password Manager](https://www.passwordstore.org/)
- [GnuPG](https://gnupg.org/)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

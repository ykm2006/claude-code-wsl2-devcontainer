# KDE Neon (Plasma 6) で VS Code の KWallet ワーニングを解消する

KDE Neon ホスト上で VS Code 起動時に「OS キーリングを暗号化に使用できません」ワーニングが出る場合の対処法。

## 症状

VS Code 起動時に以下のワーニングが表示される：

> KDE 環境で実行していますが、OS キーリングを暗号化に使用できません。kwallet が実行されていることを確認してください。

## 原因

2つの要因が重なっている：

1. **VS Code に KWallet の使用が指定されていない** — `~/.vscode/argv.json` に `password-store` 設定がない
2. **kwalletd6 デーモンが起動していない** — KDE Plasma 6 では `kwalletd6` が必要

## 解決手順

### 1. VS Code の password-store 設定

`~/.vscode/argv.json` に `"password-store": "kwallet6"` を追加：

```json
{
  "enable-crash-reporter": true,
  "crash-reporter-id": "xxxxx",
  "locale": "ja",
  "password-store": "kwallet6"
}
```

> **注意**: KDE Plasma 6 環境では `"kwallet6"` を指定する。Plasma 5 の場合は `"kwallet5"` または `"kwallet"`。

### 2. kwalletd6 デーモンの自動起動設定

`~/.config/autostart/kwalletd6.desktop` を作成（または修正）：

```ini
[Desktop Entry]
Type=Application
Name=KWallet6
Exec=/usr/bin/kwalletd6
```

> **重要**: 以下の状態だと起動しないので必ず確認すること：
> - `Exec=` が空 → 実行ファイルが指定されていない
> - `Hidden=true` が含まれている → autostart エントリが無効化される
>
> **`Hidden=true` は .desktop ファイルの「無効化フラグ」であり、このエントリが存在しても自動起動しなくなる。** 修正時に見落としやすいので特に注意。

不要な kwalletd5 の自動起動設定があれば削除：

```bash
rm ~/.config/autostart/kwalletd5.desktop
```

### 3. 手動起動（即座に反映したい場合）

```bash
kwalletd6 &
```

GLib の CRITICAL メッセージが出ることがあるが、デーモン自体は正常に起動する。

### 4. VS Code の再起動

**VS Code は全ウィンドウを閉じてから再起動すること。**

2つ目のウィンドウを新たに開いただけでは `argv.json` の変更は反映されない。

## 確認方法

```bash
# kwalletd6 が起動しているか
ps aux | grep kwalletd6

# 自動起動設定の確認
cat ~/.config/autostart/kwalletd6.desktop
```

## DevContainer から KWallet へのアクセス（D-Bus ソケット転送）

VS Code の `--force-disable-user-env` により、ホストの `.bashrc` で設定した `GH_TOKEN` がコンテナに渡らないことがある（Issue #77）。

KDE 環境では D-Bus ソケットをコンテナにマウントすることで、コンテナ内の `gh` CLI がホストの KWallet に直接アクセスできる。

### トークンの保存経路

```
gh auth login
  → go-keyring ライブラリ
    → D-Bus (Secret Service API)
      → ksecretd
        → KWallet
```

### docker-compose.yml の設定

```yaml
x-common-env: &common-env
  GH_TOKEN: ${GH_TOKEN:-}                                # WSL2 フォールバック用
  DBUS_SESSION_BUS_ADDRESS: unix:path=/run/user/1000/bus  # KWallet アクセス用

x-volumes: &common-volumes
  - /run/user/1000/bus:/run/user/1000/bus                 # D-Bus ソケット
  - ${HOME}/.config/gh:/home/node/.config/gh:ro           # gh 設定（読み取り専用）

services:
  dev:
    security_opt:
      - apparmor:unconfined    # D-Bus 通信に必要
```

### 必要な条件

1. **ホスト側**: `ksecretd` と `kwalletd6` が起動していること
2. **AppArmor**: `apparmor:unconfined` がないとコンテナからの D-Bus 通信がブロックされる
3. **UID 一致**: ホストユーザーとコンテナユーザーが同じ UID（1000）であること

### 確認方法

```bash
# コンテナ内で
gh auth status
# → ✓ Logged in to github.com account ykm2006 (keyring) と表示されれば成功
```

### 技術的知見

- `go-keyring` はトークンをバイナリ形式で保存する
  - `secret-tool search service "gh:github.com"` → 平文トークンが見える
  - `secret-tool lookup service "gh:github.com"` → "does not contain a textual password" で失敗
- WSL2 で D-Bus ソケットが存在しない場合、Docker が空ディレクトリを作成するだけでエラーにならない

## 補足

- `kwalletmanager5 --kwalletd` が動いていても、VS Code が必要とするのは `kwalletd6` デーモン本体
- KDE セッション再起動後に自動起動が有効になる
- `argv.json` は `~/.config/Code/argv.json` ではなく **`~/.vscode/argv.json`** にある

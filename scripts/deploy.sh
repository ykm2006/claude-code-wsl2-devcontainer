#!/bin/bash
#
# DevContainer デプロイスクリプト
# 新構成を /workspace/.devcontainer/ にデプロイする
#

set -euo pipefail

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# パス定義
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$PROJECT_ROOT/.devcontainer"
TARGET_DIR="/workspace/.devcontainer"
BACKUP_DIR="/workspace/.devcontainer-backups"

# ヘルパー関数
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# バナー表示
show_banner() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║   DevContainer Deploy Script           ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 使用方法
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run     実行内容を表示するだけで実際には実行しない"
    echo "  --rollback    最新のバックアップから復元"
    echo "  --list        バックアップ一覧を表示"
    echo "  --force       確認なしで実行"
    echo "  -h, --help    このヘルプを表示"
    echo ""
    echo "Examples:"
    echo "  $0              # 通常デプロイ（確認あり）"
    echo "  $0 --dry-run    # ドライラン"
    echo "  $0 --rollback   # ロールバック"
}

# バックアップ一覧表示
list_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        info "バックアップはありません"
        return
    fi

    echo -e "${BLUE}バックアップ一覧:${NC}"
    ls -lt "$BACKUP_DIR" 2>/dev/null | head -10 || info "バックアップはありません"
}

# バックアップ作成
create_backup() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/backup_$timestamp"

    mkdir -p "$BACKUP_DIR"

    if [[ -d "$TARGET_DIR" ]]; then
        info "バックアップを作成中: $backup_path"
        cp -r "$TARGET_DIR" "$backup_path"
        success "バックアップ完了: $backup_path"
        echo "$backup_path"
    else
        warn "デプロイ先が存在しません。バックアップはスキップします。"
        echo ""
    fi
}

# ロールバック
rollback() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        error "バックアップディレクトリが存在しません"
    fi

    local latest_backup
    latest_backup=$(ls -t "$BACKUP_DIR" 2>/dev/null | head -1)

    if [[ -z "$latest_backup" ]]; then
        error "バックアップが見つかりません"
    fi

    local backup_path="$BACKUP_DIR/$latest_backup"
    info "ロールバック元: $backup_path"

    read -p "ロールバックを実行しますか？ [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "キャンセルしました"
        exit 0
    fi

    # 現在の状態をバックアップ
    create_backup

    # ロールバック実行
    rm -rf "$TARGET_DIR"
    cp -r "$backup_path" "$TARGET_DIR"

    success "ロールバック完了"
}

# デプロイ実行
deploy() {
    local dry_run=${1:-false}
    local force=${2:-false}

    # ソースの確認
    if [[ ! -d "$SOURCE_DIR" ]]; then
        error "ソースディレクトリが存在しません: $SOURCE_DIR"
    fi

    # デプロイ内容の表示
    echo -e "${BLUE}デプロイ内容:${NC}"
    echo "  ソース: $SOURCE_DIR"
    echo "  デプロイ先: $TARGET_DIR"
    echo ""
    echo -e "${BLUE}コピーされるファイル:${NC}"

    # コピー対象
    local files=(
        "docker-compose.yml"
        "README.md"
        "TROUBLESHOOTING.md"
        "minimal/"
        "dev/"
        "dev-rag/"
        "shared/"
    )

    for file in "${files[@]}"; do
        if [[ -e "$SOURCE_DIR/$file" ]]; then
            echo "  - $file"
        fi
    done

    echo ""

    if [[ "$dry_run" == "true" ]]; then
        warn "ドライランモード: 実際の変更は行われません"
        return
    fi

    # 確認
    if [[ "$force" != "true" ]]; then
        read -p "デプロイを実行しますか？ [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "キャンセルしました"
            exit 0
        fi
    fi

    # バックアップ作成
    local backup_path
    backup_path=$(create_backup)

    # ターゲットディレクトリの準備
    mkdir -p "$TARGET_DIR"

    # ファイルのコピー
    info "ファイルをコピー中..."

    for file in "${files[@]}"; do
        if [[ -e "$SOURCE_DIR/$file" ]]; then
            cp -r "$SOURCE_DIR/$file" "$TARGET_DIR/"
            success "  $file"
        fi
    done

    # 既存の設定ファイルを保持（上書きしない）
    local preserve_files=(
        ".claude"
        "devcontainer.json.wsl2"
        "devcontainer.json.linux"
    )

    if [[ -n "$backup_path" ]]; then
        for file in "${preserve_files[@]}"; do
            if [[ -e "$backup_path/$file" && ! -e "$TARGET_DIR/$file" ]]; then
                cp -r "$backup_path/$file" "$TARGET_DIR/"
                info "  既存設定を保持: $file"
            fi
        done
    fi

    echo ""
    success "デプロイ完了！"
    echo ""
    echo -e "${BLUE}次のステップ:${NC}"
    echo "  1. VS Code で /workspace を開く"
    echo "  2. 「Reopen in Container」で環境を選択"
    echo "  3. 動作確認"
    echo ""
    if [[ -n "$backup_path" ]]; then
        echo -e "${YELLOW}ロールバック方法:${NC}"
        echo "  $0 --rollback"
    fi
}

# メイン処理
main() {
    show_banner

    local dry_run=false
    local force=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run=true
                shift
                ;;
            --rollback)
                rollback
                exit 0
                ;;
            --list)
                list_backups
                exit 0
                ;;
            --force)
                force=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "不明なオプション: $1"
                ;;
        esac
    done

    deploy "$dry_run" "$force"
}

main "$@"

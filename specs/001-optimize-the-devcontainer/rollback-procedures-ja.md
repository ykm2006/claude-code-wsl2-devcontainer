# ロールバック手順: DevContainer最適化

**プロジェクト**: DevContainer段階的最適化
**ブランチ**: `001-optimize-the-devcontainer`
**作成日**: 2025-09-13
**目的**: 各最適化フェーズの緊急ロールバック手順

## 概要

本文書は、DevContainer最適化プロジェクトの各フェーズに対する詳細なロールバック手順を提供します。これらの手順は、最適化による機能問題やパフォーマンス低下が発生した場合の即座の実行を想定して設計されています。

## 緊急連絡先情報

**重要な障害対応**: 最後の動作確認済み状態への即座のロールバック
**検証必須**: すべてのロールバック後の完全な機能テスト
**文書化**: すべてのロールバック操作はタイムスタンプとともに記録すること

## フェーズ別ロールバック手順

### フェーズ1ロールバック: 測定とバックアップの問題

**症状**:
- バックアップ作成の失敗
- 測定コマンドのエラー
- ベースライン文書化の不完全

**即座の対応**:
```bash
# 実行中の測定を停止
pkill -f docker
pkill -f time

# 部分的な測定をクリーンアップ
rm -rf measurements/baseline/incomplete-*

# 元の設定が変更されていないことを確認
ls -la ../.devcontainer/
git status
```

**復旧手順**:
```bash
# クリーンな状態から測定を再開
docker system prune -f
cd /workspace/claude-code-wsl2-devcontainer

# フェーズ1を最初から再実行
# plan.mdのフェーズ1手順を正確に従う
```

**検証**:
- [ ] 元のDevContainerが正常にビルドされる
- [ ] すべてのベースラインファイルが存在し、変更されていない
- [ ] Dockerシステムが応答する

### フェーズ2ロールバック: 低リスク最適化の問題

**症状**:
- .dockerignore追加後のビルド失敗
- コンテナ内のツールやパッケージの欠落
- Dockerfileレイヤー最適化による機能の破損
- ビルド時間の大幅な低下

**即座の対応**:
```bash
# DevContainerディレクトリに移動
cd ../.devcontainer/

# .dockerignoreが存在する場合は削除
if [ -f .dockerignore ]; then
    echo "Removing .dockerignore..."
    rm .dockerignore
fi

# バックアップが存在する場合は元のDockerfileを復元
if [ -f Dockerfile.backup ]; then
    echo "Restoring original Dockerfile..."
    cp Dockerfile.backup Dockerfile
fi
```

**完全なフェーズ2ロールバック**:
```bash
# フェーズ1ベースラインバックアップから復元
PHASE1_BACKUP=$(ls -t backups/baseline-* | head -1)
echo "Restoring from: $PHASE1_BACKUP"

# ロールバック前に現在の状態をバックアップ
cp -r ../.devcontainer/ "backups/failed-phase2-$(date +%Y%m%d-%H%M%S)/"

# ベースライン設定を復元
rm -rf ../.devcontainer/
cp -r "$PHASE1_BACKUP/.devcontainer/" ../

# ベースラインから再ビルド
docker build ../.devcontainer/ -t devcontainer-rollback-phase2
```

**検証コマンド**:
```bash
# コア機能をテスト
docker run --rm devcontainer-rollback-phase2 bash -c "
echo 'Testing Python stack...'
python -c 'import pandas, numpy, matplotlib; print(\"✓ Python data science stack working\")'

echo 'Testing development tools...'
git --version && echo '✓ Git working'
npm --version && echo '✓ NPM working'
zsh --version && echo '✓ Zsh working'

echo 'Testing shell environment...'
which delta fzf gh aggregate && echo '✓ CLI tools working'
"
```

**成功基準**:
- [ ] コンテナがエラーなくビルドされる
- [ ] すべてのPythonパッケージにアクセス可能
- [ ] すべての開発ツールが機能する
- [ ] ターミナルの外観が変更されていない
- [ ] ビルド時間がベースラインに戻っている

### フェーズ3ロールバック: キャッシュ実装の問題

**症状**:
- キャッシュマウントの動作失敗
- キャッシュディレクトリの権限エラー
- パッケージインストールがベースラインより遅い
- devcontainer.jsonの構文エラー

**即座の対応**:
```bash
# devcontainer.jsonバックアップを復元
cd ../.devcontainer/
if [ -f devcontainer.json.backup ]; then
    cp devcontainer.json.backup devcontainer.json
fi

# 問題のあるキャッシュディレクトリを削除
sudo rm -rf ~/.cache/devcontainer/npm
sudo rm -rf ~/.cache/devcontainer/pip
```

**完全なフェーズ3ロールバック**:
```bash
# フェーズ2の成功状態から復元
PHASE2_BACKUP=$(ls -t backups/phase2-success-* | head -1)
if [ -z "$PHASE2_BACKUP" ]; then
    # フェーズ1ベースラインにフォールバック
    PHASE2_BACKUP=$(ls -t backups/baseline-* | head -1)
fi

echo "Restoring from: $PHASE2_BACKUP"

# 失敗状態をバックアップ
cp -r ../.devcontainer/ "backups/failed-phase3-$(date +%Y%m%d-%H%M%S)/"

# 動作する設定を復元
rm -rf ../.devcontainer/
cp -r "$PHASE2_BACKUP/.devcontainer/" ../

# キャッシュマウントをクリーンアップ
docker volume prune -f
```

**検証コマンド**:
```bash
# パッケージインストールパフォーマンスをテスト
docker build ../.devcontainer/ -t devcontainer-rollback-phase3

# キャッシュ関連エラーがないことを確認
docker run --rm devcontainer-rollback-phase3 bash -c "
npm install --version
pip install --version
echo 'Cache rollback successful'
"
```

### フェーズ4+ロールバック: 統合機能の問題

**SpecKit統合ロールバック**:
```bash
# 問題を引き起こすSpecKitスクリプトを削除
rm -f /workspace/scripts/init-speckit.sh
rm -rf /workspace/.speckit/

# SpecKitなしでコンテナを復元
docker build ../.devcontainer/ -t devcontainer-no-speckit
```

**Serena MCP統合ロールバック**:
```bash
# MCP設定を削除
rm -f /workspace/scripts/init-serena-mcp.sh
rm -rf /workspace/.mcp/

# MCPなしでコンテナを復元
docker build ../.devcontainer/ -t devcontainer-no-mcp
```

## 完全なシステムロールバック

### 最終手段: 完全なベースライン復元

**使用時**: すべてのフェーズが失敗し、完全なシステム復元が必要な場合

```bash
#!/bin/bash
set -e

echo "=== 緊急完全ロールバック ==="
echo "これは完全なベースライン設定を復元します"
read -p "続行しますか？ (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "ロールバックがキャンセルされました"
    exit 1
fi

# 最新のベースラインバックアップを検索
BASELINE_BACKUP=$(ls -t backups/baseline-* | head -1)
if [ -z "$BASELINE_BACKUP" ]; then
    echo "エラー: ベースラインバックアップが見つかりません！"
    exit 1
fi

echo "復元元: $BASELINE_BACKUP"

# 現在の状態の緊急バックアップを作成
EMERGENCY_BACKUP="backups/emergency-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$EMERGENCY_BACKUP"
cp -r ../.devcontainer/ "$EMERGENCY_BACKUP/" 2>/dev/null || true

# 現在の設定を削除
rm -rf ../.devcontainer/

# ベースラインを復元
cp -r "$BASELINE_BACKUP/.devcontainer/" ../

# Dockerシステムをクリーン
docker system prune -af
docker volume prune -f

# ベースラインを再ビルド
echo "ベースライン設定を再ビルドしています..."
docker build ../.devcontainer/ -t devcontainer-emergency-restore

echo "=== ロールバック完了 ==="
echo "緊急バックアップ保存先: $EMERGENCY_BACKUP"
echo "ベースライン復元元: $BASELINE_BACKUP"
```

### ロールバック後の検証

**完全機能テスト**:
```bash
#!/bin/bash
echo "=== ロールバック後検証 ==="

# コンテナ作成をテスト
docker run --name validation-test devcontainer-emergency-restore sleep 30 &
CONTAINER_ID=$!

# コンテナの開始を待機
sleep 5

# 包括的なテストを実行
docker exec validation-test bash -c "
echo '1. Python環境をテスト中...'
python --version
pip list | grep -E '(pandas|numpy|matplotlib)' | wc -l

echo '2. Node.js環境をテスト中...'
node --version
npm --version

echo '3. 開発ツールをテスト中...'
git --version
zsh --version
which delta fzf gh

echo '4. シェル設定をテスト中...'
echo \$SHELL
ls -la ~/.p10k.zsh

echo '5. ネットワーク機能をテスト中...'
ping -c 1 8.8.8.8 || echo 'ネットワークテスト失敗（一部環境では予想される）'
"

# クリーンアップ
docker stop validation-test
docker rm validation-test

echo "=== 検証完了 ==="
```

## ロールバック文書化テンプレート

**各ロールバックに必要な情報**:

```markdown
## ロールバックレポート: [日付] [時刻]

**フェーズ**: [フェーズ番号と名前]
**問題**: [ロールバックを引き起こした問題の説明]
**重要度**: [重大/高/中/低]
**ロールバック方法**: [完全/部分/ファイル特定]
**データ損失**: [はい/いいえ - 失われた作業を説明]
**復旧時間**: [検出から動作状態まての分数]

### 実施された手順:
1. [最初のアクション]
2. [2番目のアクション]
3. [その他]

### 検証結果:
- [ ] コンテナが正常にビルドされる
- [ ] すべてのツールが機能する
- [ ] パフォーマンスがベースラインレベル
- [ ] データ破損なし

### 学んだ教訓:
[何が悪かったか、将来の防止方法]

### フォローアップアクション:
[追加で必要な手順]
```

## 防止と監視

### フェーズ前検証
- ベースラインバックアップが存在し、有効であることを常に確認
- 各フェーズ開始前にロールバック手順をテスト
- バックアップに十分なディスク容量を確保
- git作業ディレクトリがクリーンであることを確認

### フェーズ中の監視
- ビルド時間を継続的に監視
- 重要な変更後に機能をテスト
- 安定ポイントで中間バックアップを作成
- タイムスタンプ付きですべての変更を文書化

### フェーズ後検証
- パフォーマンス指標をベースラインと比較
- 完全機能テストスイートを実行
- 成功チェックポイントバックアップを作成
- 学んだ教訓で文書を更新

---

**緊急連絡先**: これらの手順が失敗した場合は、ベースラインバックアップを参照し、一から再ビルドしてください。すべての最適化作業は、失敗分析に基づいて改善された手順で繰り返すことができます。

*ロールバック手順 v1.0 - テスト済み、緊急使用準備完了*
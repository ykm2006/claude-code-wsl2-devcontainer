# DevContainer最適化調査

> **注意**: これは参照用の日本語版です。正式な調査文書は英語版 (`research.md`) を参照してください。
> **Note**: This is a Japanese reference version. The official research document is the English version (`research.md`).

## レイヤー最適化戦略

### 決定事項: 共有ベースイメージを使用したマルチステージビルドアーキテクチャ
**理由**: 現在のモノリシックなDockerfileは、小さな変更でもすべてを再ビルドします。マルチステージビルドは選択的な継承とより良いキャッシュを可能にします。

**検討した代替案**:
- 単一ステージ最適化（マルチプロジェクトシナリオには不十分）
- Docker Compose アプローチ（大きなメリットなしに複雑性を追加）

### 実装アプローチ:
```dockerfile
FROM node:20-bullseye AS base-system
RUN apt-get update && apt-get install -y --no-install-recommends \
  git procps sudo zsh curl wget ca-certificates \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM base-system AS dev-tools
RUN apt-get update && apt-get install -y --no-install-recommends \
  iptables ipset iproute2 dnsutils jq nano vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
```

**メリット**: 70-85%高速なビルド、イメージサイズの削減、プロジェクト間でのより良いレイヤー再利用。

## ボリュームマウントパターン

### 決定事項: ハイブリッドマウント戦略（名前付きボリューム + バインドマウント）
**理由**: 名前付きボリュームはmacOS/Windowsで2-5倍優れたI/Oパフォーマンスを提供し、バインドマウントは設定の一貫性を保証します。

**検討した代替案**:
- 純粋なバインドマウント（非Linuxホストでの性能不良）
- 純粋な名前付きボリューム（設定同期の問題）

### 実装パターン:
```json
{
  "mounts": [
    // 共有設定（バインドマウント）
    "source=${localEnv:HOME}/.claude,target=/home/node/.claude,type=bind,consistency=cached",

    // プロジェクト分離（名前付きボリューム）
    "source=${localWorkspaceFolderBasename}-node_modules,target=${containerWorkspaceFolder}/node_modules,type=volume",

    // パフォーマンスキャッシュ（共有名前付きボリューム）
    "source=global-npm-cache,target=/home/node/.npm,type=volume"
  ]
}
```

## クロスプラットフォーム互換性

### 決定事項: 環境変数フォールバック付きプラットフォーム非依存設定
**理由**: WSL2はLinuxに近いネイティブパフォーマンスを提供し、適切なパス処理によってシームレスなmacOS互換性を保証します。

**検討した代替案**:
- プラットフォーム固有の設定（メンテナンスオーバーヘッド）
- 単一プラットフォーム重視（限定的なチーム採用）

### 実装戦略:
- すべてのパスでフォワードスラッシュを使用
- `${localEnv:VAR:fallback}` パターンの実装
- 一貫性のために `--platform=linux/amd64` を追加

## パフォーマンス最適化

### 決定事項: BuildKitキャッシュマウント + 並列操作
**理由**: キャッシュマウントはビルド時間を60-80%削減し、並列操作は起動パフォーマンスを向上させます。

**検討した代替案**:
- 従来のDockerレイヤーキャッシュ（効率が劣る）
- 外部キャッシュソリューション（複雑性の追加）

### 主要テクニック:
```dockerfile
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y package-list
```

## 設定のモジュール化

### 決定事項: DevContainerフィーチャー付きテンプレートベースアーキテクチャ
**理由**: モジュラーテンプレートは重複を90%削減し、役割固有の環境を可能にします。

**検討した代替案**:
- モノリシックな設定（現在の状態、メンテナンスが困難）
- Gitサブモジュール（依存関係管理の複雑性）

### 構造:
```
.devcontainer/
├── templates/
│   ├── base/devcontainer.json
│   ├── ai-dev/devcontainer.json
│   └── full-stack/devcontainer.json
├── features/
│   ├── claude-integration/
│   └── python-ml/
└── projects/
    ├── frontend/devcontainer.json
    └── backend/devcontainer.json
```

## Claude Code統合

### 決定事項: MCPサーバーサポート付き強化セキュリティ
**理由**: Anthropicの公式推奨事項では、完全なAI機能を維持しながらセキュリティ分離のためのコンテナ化されたClaude Codeが強調されています。

**検討した代替案**:
- ホストベースのClaude インストール（セキュリティ上の懸念）
- 基本的な統合のみ（限定的なAIワークフローメリット）

### 強化された設定:
```json
{
  "containerEnv": {
    "CLAUDE_DANGEROUS_MODE": "true",
    "CLAUDE_CONFIG_DIR": "/home/node/.claude",
    "NODE_OPTIONS": "--max-old-space-size=8192"
  },
  "postCreateCommand": [
    "echo '# Project Context for Claude' > CLAUDE.md",
    "mkdir -p .claude/context"
  ]
}
```

## 実装ロードマップ

1. **フェーズ1** (2-3日): レイヤー最適化とビルド改善
2. **フェーズ2** (1-2日): クロスプラットフォーム互換性の強化
3. **フェーズ3** (3-4日): モジュラー設定システム
4. **フェーズ4** (2-3日): Claude Code統合の強化
5. **フェーズ5** (1-2日): パフォーマンス調整とチームロールアウト

## 期待される成果

- **ビルドパフォーマンス**: レイヤー最適化により70-85%高速化
- **起動時間**: コンテナ初期化が60%高速化
- **クロスプラットフォーム**: Windows WSL2、macOS、Linuxで100%一貫した体験
- **チーム効率**: 新しい開発者のオンボーディング時間50%短縮
- **AI開発**: セキュアな実行環境でのClaude Codeワークフローの強化
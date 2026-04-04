# Feature Specification: DevContainer スリム化

**Feature Branch**: `004-devcontainer-slim`
**Created**: 2026-01-31
**Status**: Draft
**Input**: Docker Compose によるサービス分離で、用途別に最適化された DevContainer 環境を提供。ビルド時間短縮とイメージ軽量化を実現。

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 軽量な事務作業環境（Minimal）(Priority: P1)

ユーザーは、ドキュメント作成やメール処理などの事務作業のために、Claude Code が使える軽量な DevContainer 環境を素早く起動したい。プログラミング言語のランタイムは不要で、AI アシスタントとの対話とテキスト編集ができれば十分。

**Why this priority**: これが最も基本的なユースケース。全ての作業の土台となる最小構成であり、ビルド時間短縮の効果が最も大きい。

**Independent Test**: VS Code で「Reopen in Container」を選択し、Minimal 環境を起動。Claude Code コマンドが実行でき、テキストファイルの編集ができることを確認。

**Acceptance Scenarios**:

1. **Given** DevContainer が未起動の状態, **When** ユーザーが Minimal 環境を選択して起動, **Then** 3分以内にコンテナが利用可能になる
2. **Given** Minimal 環境が起動している状態, **When** ユーザーが `claude` コマンドを実行, **Then** Claude Code が正常に動作する
3. **Given** Minimal 環境が起動している状態, **When** ユーザーがテキストファイルを編集, **Then** 変更が正しく保存される

---

### User Story 2 - プログラミング開発環境（Dev）(Priority: P2)

ユーザーは、Python や TypeScript でのプログラミング作業のために、言語ランタイムとパッケージマネージャーが含まれた開発環境を起動したい。ただし、プロジェクト固有の依存関係は venv や node_modules で管理する。

**Why this priority**: Minimal の次に必要な環境。開発者の日常業務に必須だが、Minimal が動かないと意味がない。

**Independent Test**: VS Code で Dev 環境を選択して起動。Python と TypeScript/JavaScript のバージョンコマンドが実行でき、新しいプロジェクトで venv や npm init ができることを確認。

**Acceptance Scenarios**:

1. **Given** DevContainer が未起動の状態, **When** ユーザーが Dev 環境を選択して起動, **Then** 5分以内にコンテナが利用可能になる
2. **Given** Dev 環境が起動している状態, **When** ユーザーが Python プロジェクトで `uv venv` を実行, **Then** 仮想環境が作成される
3. **Given** Dev 環境が起動している状態, **When** ユーザーが Node.js プロジェクトで `bun init` を実行, **Then** プロジェクトが初期化される

---

### User Story 3 - RAG/ナレッジベース環境（Dev-RAG）(Priority: P3)

ユーザーは、ローカルドキュメントに対して AI で質問応答するために、Embedding モデルとベクトルデータベースを含む RAG 環境を起動したい。Dev 環境をベースに、ML/RAG 機能を追加した構成。

**Why this priority**: 特殊用途の拡張機能。Minimal と Dev が動いてから構築する。

**Independent Test**: Dev-RAG 環境を起動し、ローカルの Markdown ファイルに対して自然言語で質問し、関連する内容が返ってくることを確認。

**Acceptance Scenarios**:

1. **Given** DevContainer が未起動の状態, **When** ユーザーが Dev-RAG 環境を選択して起動, **Then** 10分以内にコンテナが利用可能になる（モデルダウンロード含む初回）
2. **Given** Dev-RAG 環境が起動している状態, **When** ユーザーが MCP 経由でドキュメント検索を実行, **Then** 関連するドキュメントが返される
3. **Given** Dev-RAG 環境が起動している状態, **When** ユーザーが日本語でクエリを投げる, **Then** 多言語対応モデルにより適切な結果が返る

---

### User Story 4 - 環境の切り替え（Choice）(Priority: P4)

ユーザーは、用途に応じて Minimal / Dev / Dev-RAG の環境を簡単に切り替えたい。VS Code の UI から直感的に選択でき、現在どの環境で作業しているかが明確にわかる。

**Why this priority**: ユーザビリティの向上。基本機能（P1, P2, P3）が動いた後の利便性向上。

**Independent Test**: VS Code で環境を切り替え、正しい環境が起動することを確認。コンテナ名やプロンプトで現在の環境が識別できる。

**Acceptance Scenarios**:

1. **Given** Minimal 環境で作業中, **When** ユーザーが Dev 環境への切り替えを選択, **Then** Dev 環境が起動し開発ツールが利用可能になる
2. **Given** 複数の devcontainer.json が存在, **When** ユーザーが「Reopen in Container」を選択, **Then** 環境選択メニューが表示される
3. **Given** 環境が起動している状態, **When** ユーザーがターミナルを開く, **Then** プロンプトまたは環境変数で現在の環境が識別できる

---

### Edge Cases

- **Docker が起動していない場合**: 分かりやすいエラーメッセージを表示し、Docker 起動を促す
- **ホストとの UID/GID 不一致**: コンテナ内ユーザーの UID/GID をホストに合わせる仕組みを提供
- **SyncThing 同期中のビルド**: 同期完了を待つか、部分的な設定でも起動できる
- **ネットワーク不通時**: キャッシュされたイメージを使用可能にする

## Clarifications

### Session 2026-01-31

- Q: Dev-RAG 環境で GPU（CUDA）を使用するか？ → A: GPU 対応（CUDA サポート）。全環境で NVIDIA GPU 搭載、既存 DevContainer も CUDA サポート済み。
- Q: DevContainer 内から docker コマンドを実行する必要があるか？ → A: 不要。Docker-in-Docker は使用しない。
- Q: ベースイメージのバージョン固定方針は？ → A: 固定バージョン使用。設定時点の最新タグを固定し、明示的な更新まで維持。
- Q: 既存環境からの移行戦略は？ → A: 即時置換。003 プロジェクトで動作確認後、既存を新構成に置換。共存は難しいため。
- Q: RAG の MCP サーバー構成は？ → A: Plan フェーズで技術検討。MCP 限定ではなく汎用 RAG 基盤として設計したい。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: システムは Docker Compose を使用して複数の DevContainer 環境を定義できなければならない
- **FR-002**: Minimal 環境は Claude Code のネイティブバイナリのみを含み、言語ランタイムを含まない
- **FR-003**: Dev 環境は Python（uv）と Bun を含み、プロジェクト別の依存管理をサポートする
- **FR-004**: 各環境は独立した devcontainer.json を持ち、VS Code から選択可能
- **FR-005**: ユーザーは環境間を VS Code の UI から切り替えられなければならない
- **FR-006**: 全環境で Zsh + Oh My Zsh + Powerlevel10k が利用可能
- **FR-007**: 全環境でホストの `~/.claude` 設定がマウントされ、認証情報が共有される
- **FR-008**: ビルドは BuildKit を使用し、レイヤーキャッシュを最大限活用する
- **FR-009**: Dev-RAG 環境は Embedding モデル（多言語対応）を含み、ローカルドキュメント検索が可能
- **FR-010**: RAG 機能は Docker Compose profiles で制御され、必要時のみ起動できる
- **FR-011**: Embedding モデルはビルド時にダウンロードされ、起動時のダウンロード待ちがない
- **FR-012**: Dev-RAG 環境は NVIDIA GPU（CUDA）をサポートし、GPU 推論が可能

### Key Entities

- **Environment（環境）**: Minimal, Dev などの DevContainer 構成。Dockerfile、devcontainer.json、サービス定義を含む
- **Service（サービス）**: Docker Compose で定義される個別のコンテナ。profiles で有効化/無効化を制御
- **Host Mount（ホストマウント）**: ホストOS とコンテナ間で共有されるディレクトリ（`~/.claude`, `~/.claude.json`, ワークスペースなど）。Claude Code の認証永続化には `~/.claude` ディレクトリと `~/.claude.json` ファイルの両方が必要

### Assumptions

- Docker Desktop または Docker Engine がホストにインストール済み
- VS Code の Dev Containers 拡張がインストール済み
- ホストに 8GB 以上のメモリがある
- WSL2 環境では WSL2 統合が有効化されている
- KDE Neon 環境では Docker がネイティブに動作している

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Minimal 環境のビルド時間が 3分以内に完了する（初回ビルド、キャッシュなし）
- **SC-002**: Dev 環境のビルド時間が 5分以内に完了する（初回ビルド、キャッシュなし）
- **SC-003**: キャッシュがある場合、環境起動が 30秒以内に完了する
- **SC-004**: Minimal 環境のイメージサイズが 500MB 以下
- **SC-005**: Dev 環境のイメージサイズが 1.5GB 以下
- **SC-006**: 同一設定が WSL2 環境と KDE Neon 環境の両方で動作する
- **SC-007**: ユーザーが環境選択から作業開始まで 3クリック以内で到達できる
- **SC-008**: Dev-RAG 環境のビルド時間が 15分以内に完了する（初回ビルド、モデルダウンロード含む）
- **SC-009**: Dev-RAG 環境のイメージサイズが 10GB 以下
- **SC-010**: キャッシュ済みの Dev-RAG 環境起動が 1分以内に完了する

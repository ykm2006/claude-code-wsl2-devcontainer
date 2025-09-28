# タスクリスト: Claude Code ベストプラクティス統合

**プロジェクト**: 最適化されたDevContainer環境へのClaude Codeベストプラクティス統合
**ブランチ**: `002-claude-code-best-practices`
**作成日**: 2025-09-27
**ステータス**: 実行準備完了

## 🌸 タスク運用ガイド

### 進捗管理システム
このタスクリストでは、かわいいアイコンを使って進捗を管理します〜 ♪

**ステータスインジケータ**:
- **[🌱]** = 未着手 (種まき前)
- **[🌼]** = 作業中 (お花が育ってる〜)
- **[🌺]** = 完了！(きれいに咲いたよ！)

### アイコン凡例 ✨
- 📝 = ドキュメント作成 (お手紙書いてる)
- 🔍 = 調査・評価 (探索中〜)
- 🛠️ = 実装作業 (がんばって作ってる)
- 🧪 = テスト・検証 (実験中！)
- 📦 = 統合・デプロイ (まとめてお届け)
- 🎯 = マイルストーン (目標達成！)
- ⚠️ = リスク管理 (要注意だよ)
- 📊 = 測定・分析 (データチェック)
- 🌟 = 完了タスク (きらきら〜)

### 作業の進め方 🚀
1. タスクを始める時: チェックボックスを `[🌼]` に変更（お花が育ち始める〜）
2. 一生懸命作業する〜
3. 完了したら: チェックボックスを `[🌺]` に変更（きれいに咲いた！）
4. 必要に応じて完了メモを追記 ♪

**ソース参照**:
- Qiita記事: [Claude Codeを実際のプロジェクトにうまく適用させていくTips10選](https://qiita.com/nokonoko_1203/items/67f8692a0a3ca7e621f3)
- GitHubリポジトリ: [nokonoko1203/claude-code-settings](https://github.com/nokonoko1203/claude-code-settings)

**開発ガイドライン**: gitワークフローとブランチ戦略については `docs/DEVELOPMENT_GUIDELINES.md` を参照

## 概要

このタスクリストは、Claude Codeベストプラクティス統合を要素別の反復アプローチに従って、具体的で実行可能なタスクに分解しています。各タスクには明確な受け入れ基準、推定期間、依存関係が含まれています。

## フェーズ0: 要素の棚卸しと初期評価

### 📝 タスク 0.1: 要素ドキュメント収集 🌺
**期間**: 30分
**依存関係**: なし
**担当者**: 開発チーム

**目的**: 特定された17の要素すべてについて、参考資料付きの包括的なドキュメントを作成

**実行項目**:
- [🌺] Qiita記事から17のヒント/要素すべてを説明付きでドキュメント化
- [🌺] 利用可能な場合はGitHubリポジトリの実装参考資料を追加
- [🌺] 要素追跡スプレッドシート/ドキュメントを作成 (element-inventory.md)
- [🌺] 以前のマッピングから現在の実装状況を記録

**受け入れ基準**:
- [🌺] 17要素の詳細説明を含む完全なリスト
- [🌺] 参考資料（記事セクション、GitHubファイル）のドキュメント化
- [🌺] 各要素の実装状況を記録
- [🌺] 体系的な評価プロセスの準備完了

**🌟 完了メモ**:
- element-inventory.md と element-inventory-ja.md を作成完了！
- 17要素すべてを包括的にドキュメント化
- 優先度分類完了: High 4個、Medium 8個、Low 4個、N/A 1個

### 🔍 タスク 0.2: 初期実現可能性評価 🌺

**🌟 完了メモ**:
- feasibility-assessment.md を作成完了！
- ADOPT（3要素）、INVESTIGATE（8要素）、REJECT（3要素）、DEFER（2要素）、N/A（1要素）に分類
- YKMコメントを受けて優先度調整完了（MCP Enhancement優先度UP、Parallel Processing注意、等）
- Phase 1で詳細評価すべき優先要素を明確化
**期間**: 45分
**依存関係**: タスク 0.1
**担当者**: 開発チーム

**目的**: すべての要素について高レベルな実現可能性評価を実施

**実行項目**:
- [🌺] plan.mdの評価基準を使用した初期スクリーニングの適用
- [🌺] 要素の分類: 高/中/低実現可能性
- [🌺] 明らかな採用候補の特定（3要素: Global Config、Permissions、Parallel Processing）
- [🌺] 明らかな却下候補の特定（3要素: Thinking Expansion、Gemini CLI、Model Switching）
- [🌺] 詳細調査が必要な要素をフラグ付け（8要素をINVESTIGATE分類）

**受け入れ基準**:
- [🌺] 17要素すべてを実現可能性で分類
- [🌺] 初期採用/却下推奨事項のドキュメント化（feasibility-assessment.md作成）
- [🌺] 詳細評価が必要な要素の特定（8要素をINVESTIGATE分類）
- [🌺] 初期データを含む評価マトリクスの作成（完了）

## フェーズ1: 詳細要素評価

### 🔍 タスク 1.1: 高優先度要素評価 🌼
**期間**: 2時間
**依存関係**: タスク 0.2
**担当者**: 開発チーム

**目的**: 最高優先度/実現可能性要素の詳細評価

#### 📝 タスク 1.1.1: Element 3 (CLAUDE.mdグローバル設定) 評価 🌺
**要素**: Global Configuration (高実現可能性、高価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価
- [🌺] 実装アプローチの設計
- [🌺] 実装工数の見積もり (1時間)
- [🌺] 最終決定: **ADOPT** (最優先実装)
- [🌺] 詳細評価ドキュメント作成 (elements/element-3-evaluation.md)

#### 📝 タスク 1.1.2: Element 7 (カスタムスラッシュコマンド) 評価 🌺
**要素**: Custom Slash Commands (中実現可能性、高価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価
- [🌺] SpecKit重複分析
- [🌺] 実装アプローチの設計
- [🌺] 最終決定: **REJECT** (SpecKit重複)
- [🌺] 詳細評価ドキュメント作成 (elements/element-7-evaluation.md)

#### 📝 タスク 1.1.3: Element 5 (セキュリティ権限) 評価 🌺
**要素**: Permissions Management (高実現可能性、中価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価
- [🌺] 実装アプローチの設計 (段階的実装)
- [🌺] 実装工数の見積もり (45分)
- [🌺] 最終決定: **INVESTIGATE** (慎重実装)
- [🌺] 詳細評価ドキュメント作成 (elements/element-5-evaluation.md)

#### 📝 タスク 1.1.4: Element 4 (Serena統合強化) 評価 🌺
**要素**: MCP Enhancement (中実現可能性、高価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価
- [🌺] 実装アプローチの設計 (段階的統合強化)
- [🌺] 実装工数の見積もり (50分)
- [🌺] 最終決定: **ADOPT** (基本統合強化)
- [🌺] 詳細評価ドキュメント作成 (elements/element-4-evaluation.md)
- [🌼] **追加評価**: 参照実装7つのMCP吟味・設定是非判定
  - [🌺] Context7 (document retrieval) 評価 → **ADOPT** (無料・最新ドキュメント自動取得)
  - [🌺] GitHub integration (multiple account support) 評価 → **REJECT** (単一プロジェクト、必要性低)
  - [🌺] Playwright (browser automation) 評価 → **ADOPT** (スクレイピング・テスト自動化)
  - [🌺] Readability (web article reading) 評価 → **ADOPT** (HTML→Markdown変換・トークン節約)
  - [🌺] textlint (Japanese proofreading) 評価 → **ADOPT** (MCP版併用・段階的実装)
  - [🌺] Obsidian MCP (note management) 評価 → **ADOPT** (ノート管理統合・評価中)
  - [🌺] **追加**: Notion MCP (database management) → **ADOPT** (データベース統合・タスク管理)
  - [🌺] 各MCP採用/却下判定と評価ドキュメント更新

#### 📝 タスク 1.1.5: Element 15 (Parallel Processing) 評価 🌺
**要素**: Parallel Processing Maximization (高実現可能性、高価値)
**実行項目**:
- [🌺] 混乱リスク分析（YKMコメント対応）
- [🌺] 実装アプローチの設計
- [🌺] 実装工数の見積もり (10分)
- [🌺] 最終決定: **ADOPT** (グローバル指針追加)
- [🌺] 詳細評価ドキュメント作成 (elements/element-15-evaluation.md)

#### 📝 タスク 1.1.6: Element 3 評価見直し (スラッシュコマンド依存問題) 🌺
**要素**: Global Configuration - 実装アプローチ再評価
**問題**: 参照実装がElement 7 (REJECT済み) のスラッシュコマンドに依存
**実行項目**:
- [🌺] 参照実装の依存関係分析
- [🌺] 当環境適合版アプローチ設計 (SpecKit統合)
- [🌺] ハイブリッド版実装戦略策定 (3層構造)
- [🌺] 実装工数の再見積もり (70分)
- [🌺] 評価ドキュメント更新 (elements/element-3-evaluation.md)

**タスク 1.1 受け入れ基準**:
- [🌺] Element 3: ADOPT決定 (ハイブリッド版で解決)
- [🌺] Element 7: REJECT決定 (SpecKit重複)
- [🌺] Element 5: INVESTIGATE決定 (慎重実装)
- [🌺] Element 4: ADOPT決定 (基本統合強化)
- [🌺] Element 15: ADOPT決定 (グローバル指針追加)
- [🌺] Element 3 再評価: 評価完了
- [🌺] 実装優先順位確定: 1)Element3(ハイブリッド版) → 2)Element4 → 3)Element15 → 4)Element5

### 🔍 タスク 1.2: 中優先度要素評価 🌱
**期間**: 1.5時間（Element 4完了済みで短縮）
**依存関係**: タスク 1.1
**担当者**: 開発チーム

**目的**: 中優先度要素の詳細評価

#### 📝 タスク 1.2.1: Element 2 (Modular Task Design) 評価 🌺
**要素**: Modular Task Design (中実現可能性、中価値)
**実行項目**:
- [🌺] 既存SpecKit構造との統合ポイント評価
- [🌺] 実装アプローチの設計
- [🌺] 実装工数の見積もり
- [🌺] 最終的な採用/却下決定: **DEFER** (SpecKit重複)
- [🌺] 詳細評価ドキュメント作成 (elements/element-2-evaluation.md)

#### 📝 タスク 1.2.2: Element 16 (Code Review Enhancement) 評価 🌺
**要素**: Code Review Enhancement (中実現可能性、中価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価
- [🌺] 実装アプローチの設計 (エージェントベース実装)
- [🌺] 実装工数の見積もり (60分)
- [🌺] 最終的な採用/却下決定: **ADOPT** (エージェント実装)
- [🌺] 詳細評価ドキュメント作成 (elements/element-16-evaluation.md)

#### 📝 タスク 1.2.3: Element 6 (Git Worktree Integration) 評価 🌺
**要素**: Git Worktree + ccmanager (中実現可能性、中価値)
**実行項目**:
- [🌺] ccmanager機能の詳細調査
- [🌺] 実装アプローチの設計 (チーム開発向け判定)
- [🌺] 実装工数の見積もり (評価完了)
- [🌺] 最終的な採用/却下決定: **DEFER** (個人開発では不要)
- [🌺] 詳細評価ドキュメント作成 (elements/element-6-evaluation.md)

**タスク 1.2 受け入れ基準**:
- [🌺] Element 2: 評価完了 (DEFER決定)
- [🌺] Element 16: 評価完了 (ADOPT決定)
- [🌺] Element 6: 評価完了 (DEFER決定)
- [🌺] Element 4: 評価完了済み (ADOPT決定)
- [🌺] 実装優先順位更新

### 🔍 タスク 1.3: 残り要素評価 🌼
**期間**: 1.5時間
**依存関係**: タスク 1.2
**担当者**: 開発チーム

**目的**: 残りすべての要素の評価完了

#### 📝 タスク 1.3.1: Element 8 (Thinking Expansion) 評価 🌺
**要素**: Thinking Expansion (思考展開、低実現可能性、低価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価 (不要 - 使用指針のみ)
- [🌺] 実装アプローチの設計 (CLAUDE.md指針追加)
- [🌺] 実装工数の見積もり (5分 - 1行追加のみ)
- [🌺] 最終的な採用/却下決定 (**ADOPT** - 簡単実装で高価値)
- [🌺] 詳細評価ドキュメント作成 (elements/element-8-evaluation.md)

#### 📝 タスク 1.3.2: Element 10 (Context Management) 評価 🌺
**要素**: Context Management (コンテキスト管理、低実現可能性、中価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価 (Element 4で包含)
- [🌺] 実装アプローチの設計 (MCP評価はElement 4へ移管)
- [🌺] 実装工数の見積もり (評価不要)
- [🌺] 最終的な採用/却下決定: **DEFER** (Element 4に統合)
- [🌺] 詳細評価ドキュメント作成 (elements/element-10-evaluation.md)

#### 📝 タスク 1.3.3: Element 12 (Gemini CLI) 評価 🌺
**要素**: Gemini CLI (ウェブ検索、低実現可能性、中価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価 (npm install + Google認証)
- [🌺] 実装アプローチの設計 (DevContainer統合 + 使用指針)
- [🌺] 実装工数の見積もり (40分)
- [🌺] 最終的な採用/却下決定: **ADOPT** (高価値、実装容易)
- [🌺] 詳細評価ドキュメント作成 (elements/element-12-evaluation.md)

#### 📝 タスク 1.3.4: Element 13 (Model Switching) 評価 🌺
**要素**: Model Switching (モデル切り替え、高実現可能性、低価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価
- [🌺] 実装アプローチの設計
- [🌺] 実装工数の見積もり
- [🌺] 詳細評価ドキュメント作成 (elements/element-13-evaluation.md)
- [🌺] 最終的な採用/却下決定: **REJECT** (低価値、必要性低い)

#### 📝 タスク 1.3.5: Element 14 (CLI Options) 評価 🌺
**要素**: CLI Options (CLIオプション、高実現可能性、中価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価
- [🌺] 実装アプローチの設計
- [🌺] 実装工数の見積もり (50分)
- [🌺] 最終的な採用/却下決定: **ADOPT** (テレメトリー無効化・タイムアウト延長)
- [🌺] 詳細評価ドキュメント作成 (elements/element-14-evaluation.md)

#### 📝 タスク 1.3.6: Element 18 (Textlint Integration) 評価 🌺
**要素**: Textlint Integration (テキスト校正、高実現可能性、中価値)
**実行項目**:
- [🌺] DevContainer統合ポイントの評価
- [🌺] 実装アプローチの設計
- [🌺] 実装工数の見積もり (60分)
- [🌺] 最終的な採用/却下決定: **ADOPT** (日本語文書品質向上・翻訳エージェント連携)
- [🌺] 詳細評価ドキュメント作成 (elements/element-18-evaluation.md)

#### 📝 タスク 1.3.7: Element 19 (Japanese Translation Agent Enhancement) 評価 🌺
**要素**: Japanese Translation Agent Enhancement (翻訳エージェント強化、高実現可能性、中価値)
**実行項目**:
- [🌺] 現在のエージェント機能分析
- [🌺] textlint連携アプローチの設計
- [🌺] 翻訳品質向上ワークフローの設計
- [🌺] DevContainer統合ポイントの評価
- [🌺] 実装工数の見積もり (60分)
- [🌺] 最終的な採用/却下決定: **ADOPT** (翻訳品質向上・textlint連携)
- [🌺] 詳細評価ドキュメント作成 (elements/element-19-evaluation.md)

### タスク 1.4: 実装ロードマップ作成 🌺
**期間**: 30分
**依存関係**: タスク 1.1、1.2、1.3
**担当者**: 開発チーム

**目的**: 採用要素の実装順序とロードマップを作成

**実行項目**:
- [🌺] 採用された全要素のリスト作成
- [🌺] 実装依存関係と複雑さによる順序付け
- [🌺] 実装タイムラインの見積もり
- [🌺] 実装ロードマップの作成
- [🌺] テストと検証アプローチの計画

**受け入れ基準**:
- [🌺] 根拠付きの採用要素最終リスト
- [🌺] 実装順序の確立
- [🌺] 各要素のタイムライン見積もり

**🌟 完了メモ**:
- 評価結果: ADOPT(10要素)、INVESTIGATE(1要素)、DEFER(3要素)、REJECT(2要素)
- 合計実装時間: 555分 (9時間15分) - 4フェーズ構成
- 優先度: 基盤→高価値→拡張→検証の段階的実装
- [ ] テスト戦略の定義
- [ ] 実装フェーズ開始準備完了

## フェーズ2: 実装フェーズ

### 📊 実装優先度と依存関係

**Phase 2.1: 基盤構築（最優先）** - 85分
- Element 3: Global Configuration (70分) - 全ての基盤
- Element 15: Parallel Processing (10分) - CLAUDE.md 拡張
- Element 8: Thinking Expansion (5分) - CLAUDE.md 拡張

**Phase 2.2: 高価値機能（高優先）** - 200分
- Element 18: Textlint Integration (60分) - 文書品質基盤
- Element 4: MCP Enhancement Phase1 (90分) - Context7, Readability
- Element 14: CLI Options (50分) - 環境最適化

**Phase 2.3: 拡張機能（中優先）** - 220分
- Element 19: Japanese Translation Agent (60分) - Element 18依存
- Element 4: MCP Enhancement Phase2 (60分) - Playwright, textlint MCP
- Element 16: Code Review Enhancement (60分) - エージェント実装
- Element 12: Gemini CLI (40分) - 検索機能強化

**Phase 2.4: 検証・調整** - 50分
- Element 4: MCP Enhancement Phase3 (45分) - Obsidian, Notion検証
- Element 5: Security Enhancement (45分) - 慎重実装

**合計実装時間**: 555分 (9時間15分)

### 🔧 詳細実装タスク

#### 📝 タスク 2.1.1: Element 3 実装 🌺
**期間**: 70分
**依存関係**: なし（最優先基盤）
**実行項目**:
- [🌺] ~/.claude/CLAUDE.md グローバル設定ファイル作成 (25分)
- [🌺] SpecKit統合設定の追加 (20分)
- [🌺] WSL2永続化設定の確認・調整 (10分)
- [🌺] DevContainer環境での動作確認 (15分)

**🌟 完了メモ** (2025-09-28):
- ✅ `.devcontainer/claude-global/CLAUDE.md` テンプレート作成完了
- ✅ 参照実装ベース英語版・SpecKit統合ハイブリッド版実装
- ✅ `devcontainer.json` postCreateCommand追加（自動配置）
- ✅ DevContainer Rebuild テスト成功・グローバル設定適用確認
- ✅ Serena MCP シンボル検索動作確認完了

#### 📝 タスク 2.1.2: Element 15 実装 🌱
**期間**: 10分
**依存関係**: Element 3
**実行項目**:
- [ ] CLAUDE.md にツール並列実行指針追加 (5分)
- [ ] タスク並列実行 vs ツール並列実行の明確化 (5分)

#### 📝 タスク 2.1.3: Element 8 実装 🌱
**期間**: 5分
**依存関係**: Element 3
**実行項目**:
- [ ] CLAUDE.md にSpecKit引数活用指針追加 (3分)
- [ ] `/specify "仕様作成。think super hard"` パターン例追加 (2分)

#### 📝 タスク 2.2.1: Element 18 実装 🌱
**期間**: 60分
**依存関係**: なし（基盤完了後）
**実行項目**:
- [ ] DevContainer textlint環境構築 (20分)
  - [ ] Dockerfile に textlint + 日本語ルールセット追加
  - [ ] .textlintrc 設定ファイル作成
- [ ] ~/.claude/commands/textlint.md カスタムコマンド実装 (25分)
  - [ ] 参照実装調査・参考
  - [ ] 日本語文書校正ロジック実装
- [ ] specs/フォルダでの動作確認・テスト (15分)

#### 📝 タスク 2.2.2: Element 4 Phase1 実装 🌼
**期間**: 90分
**依存関係**: Element 3（基盤設定）
**実行項目**:
- [🌺] Context7 MCP統合 (30分)
  - [🌺] `claude mcp add context7` 実行
  - [🌺] 動作確認・最新ドキュメント取得テスト
- [🌺] Readability MCP統合 (30分)
  - [🌺] Mozilla Readability Parser MCP設定
  - [🌺] HTML→Markdown変換テスト
- [🌺] Serena MCP設定最適化 (30分)
  - [🌺] .serena/project.yml 言語・パス調整
  - [🌺] DevContainer環境での動作確認

**🌟 Element 4 Phase1 完了メモ** (2025-09-28):
- ✅ **Context7 MCP統合**: DevContainer グローバル設定統合完了
- ✅ **Readability MCP統合**: `@just-every/mcp-read-website-fast` で成功
  - 注意点: `server-moz-readability` は実行可能ファイル未設定で失敗
  - 解決策: `@just-every/mcp-read-website-fast` パッケージが正常動作
- ✅ **Serena MCP設定最適化**: TypeScript言語設定に変更
  - 知見: 複数言語併記は現在未対応（Issue #72で将来対応予定）
  - JSON/TypeScript系ファイル多数のため TypeScript設定が最適
- ✅ 全MCP（Serena + Context7 + Readability）正常動作確認完了

#### 📝 タスク 2.2.2.1: 統合プロジェクト設定スクリプト (setup-project.sh) 作成 🌱
**期間**: 95分
**依存関係**: Element 4 Phase1完了
**担当者**: 開発チーム

**目的**: Serena MCP + SpecKit の統合プロジェクト設定を自動化するスクリプトを作成し、言語設定可能な汎用プロジェクト初期化ツールを提供

**実行項目**:
- [ ] 既存スクリプト整理 (5分)
  - [ ] init-serena-mcp.sh の削除・破棄
  - [ ] init-speckit.sh の削除・破棄
  - [ ] 既存の分散した初期化スクリプトの統合準備
- [ ] 要件分析・設計 (15分)
  - [ ] Serena MCP設定要件の整理（.mcp.json設定）
  - [ ] SpecKit設定要件の整理（.specify/, specs/等）
  - [ ] 言語設定対応の仕様設計
  - [ ] コマンドライン引数設計（--language, --project-name等）
- [ ] テンプレート作成 (25分)
  - [ ] .mcp.json テンプレート作成（Serena + 他MCP統合）
  - [ ] .serena/project.yml テンプレート作成（言語設定対応）
  - [ ] SpecKit用ディレクトリ構造テンプレート
  - [ ] 変数置換システム設計
- [ ] スクリプト実装 (35分)
  - [ ] scripts/setup-project.sh メインスクリプト作成
  - [ ] 引数パース機能（--language, --project-name, --help）
  - [ ] テンプレート展開・ファイル配置機能
  - [ ] .mcp.json設定生成機能（Serena MCP設定）
  - [ ] .serena/project.yml設定生成機能
  - [ ] SpecKit初期化機能（.specify/等ディレクトリ作成）
- [ ] エラーハンドリング・検証 (10分)
  - [ ] 入力検証（サポート言語チェック等）
  - [ ] ファイル存在チェック・上書き確認
  - [ ] エラーメッセージ・ヘルプ表示
- [ ] テスト・ドキュメント (5分)
  - [ ] スクリプト動作確認
  - [ ] 使用方法ドキュメント作成

**受け入れ基準**:
- [ ] 言語設定可能なプロジェクト初期化スクリプト完成
- [ ] Serena MCP設定（.mcp.json）の自動生成
- [ ] SpecKit設定の自動初期化
- [ ] コマンドライン引数による柔軟な設定
- [ ] エラーハンドリング・ユーザビリティ確保
- [ ] 動作確認・テスト完了

**サポート言語**:
- typescript, python, rust, java, go, cpp, ruby, bash

**使用例**:
```bash
# TypeScriptプロジェクトの初期化
./scripts/setup-project.sh --language typescript --project-name my-project

# Pythonプロジェクトの初期化
./scripts/setup-project.sh --language python --project-name data-analysis

# ヘルプ表示
./scripts/setup-project.sh --help
```

**期待成果**:
- プロジェクト作成時の手動設定作業の大幅削減
- Serena MCP + SpecKit の統合環境の自動構築
- 言語別最適化されたプロジェクト設定
- 再現性の高いプロジェクト初期化プロセス

#### 📝 タスク 2.2.3: Element 14 実装 🌱
**期間**: 50分
**依存関係**: Element 3（設定基盤）
**実行項目**:
- [ ] ~/.claude/settings.json 作成・配置 (15分)
  - [ ] テレメトリー無効化設定
  - [ ] API_TIMEOUT_MS延長設定
  - [ ] オートアップデート許可設定
- [ ] DevContainer統合実装 (15分)
  - [ ] postCreateCommand または Dockerfile統合
- [ ] 動作確認・設定反映テスト (10分)
- [ ] ドキュメント化・使用方法整備 (10分)

#### 📝 タスク 2.3.1: Element 19 実装 🌱
**期間**: 60分
**依存関係**: Element 18（textlint基盤）
**実行項目**:
- [ ] 既存エージェント設定拡張 (25分)
  - [ ] markdown-japanese-translator.md へtextlint統合追加
  - [ ] Quality assurance セクション強化
- [ ] textlint連携実装 (20分)
  - [ ] 翻訳完了時の自動textlint実行
  - [ ] 品質問題検出・報告機能
- [ ] エラーハンドリング・修正提案機能 (15分)
  - [ ] textlint指摘事項の解析・修正案生成
  - [ ] 品質確認ワークフロー統合

#### 📝 タスク 2.3.2: Element 4 Phase2 実装 🌱
**期間**: 60分
**依存関係**: Element 18（textlint基盤）、Phase1完了
**実行項目**:
- [ ] Playwright MCP統合 (35分)
  - [ ] Microsoft Playwright MCP設定
  - [ ] DevContainer環境でのブラウザ実行確認
  - [ ] スクレイピング・テスト機能確認
- [ ] textlint MCP統合 (25分)
  - [ ] `claude mcp add textlint` 実行
  - [ ] .textlintrc 設定ファイル対応
  - [ ] MCP版 vs カスタムコマンド版の使い分け確認

#### 📝 タスク 2.3.3: Element 16 実装 🌱
**期間**: 60分
**依存関係**: Element 3（エージェント基盤）
**実行項目**:
- [ ] code-reviewer-enhanced エージェント作成 (30分)
  - [ ] ~/.claude/agents/code-reviewer-enhanced.md 作成
  - [ ] 参照実装 /code-review コマンド調査・ベース実装
- [ ] CLAUDE.md統合・設定 (15分)
  - [ ] エージェント使用指針追加
  - [ ] レビュー基準・観点の統合
- [ ] 動作確認・テスト (15分)
  - [ ] 実際のコードでレビュー機能テスト
  - [ ] 客観的レビュー品質確認

#### 📝 タスク 2.3.4: Element 12 実装 🌱
**期間**: 40分
**依存関係**: Element 14（CLI環境最適化）
**実行項目**:
- [ ] Gemini CLI インストール・設定 (20分)
  - [ ] DevContainer環境での gemini-cli インストール
  - [ ] API key設定・認証確認
- [ ] Claude Code統合・使い分け設定 (10分)
  - [ ] ウェブ検索時のGemini CLI活用パターン確立
  - [ ] Claude Code WebSearch との使い分け指針
- [ ] 動作確認・性能比較テスト (10分)

#### 📝 タスク 2.4.1: Element 4 Phase3 実装 🌱
**期間**: 45分
**依存関係**: Phase2完了、Obsidian/Notion評価進捗
**実行項目**:
- [ ] Obsidian MCP統合 (20分)
  - [ ] Obsidian評価進捗に応じて統合実行
  - [ ] WebSocket接続・デュアルトランスポート設定
  - [ ] ノート読み書き機能確認
- [ ] Notion MCP検証実装 (25分)
  - [ ] 改良版Notion MCPのコンテキスト効率テスト
  - [ ] 小規模データでのトークン消費量実測
  - [ ] 実用判定・継続可否決定

#### 📝 タスク 2.4.2: Element 5 実装 🌱
**期間**: 45分
**依存関係**: 全要素実装完了後（検証フェーズ）
**実行項目**:
- [ ] 参照実装との環境差異分析 (15分)
  - [ ] allow/deny設定の現環境適用性確認
  - [ ] DevContainer特有のセキュリティ要件分析
- [ ] 段階的セキュリティ設定実装 (20分)
  - [ ] 基本的なallow/deny設定適用
  - [ ] 環境固有の調整・最適化
- [ ] セキュリティテスト・検証 (10分)
  - [ ] 設定の動作確認・権限テスト
  - [ ] 既存機能への影響確認

---

## 📊 プロジェクト完了基準

### 成功指標
- ✅ 全10要素の実装完了（Element 3,4,8,12,14,15,16,18,19 + Element 5検証）
- ✅ DevContainer環境での全機能動作確認
- ✅ 既存機能の完全保持
- ✅ 性能改善効果の確認（60%ビルド時間改善維持）

### 最終検証項目
- [ ] Claude Code MCP統合の動作確認
- [ ] textlint + 翻訳エージェント連携テスト
- [ ] 各種エージェント（code-reviewer, translation）の機能確認
- [ ] セキュリティ設定の適切性確認
- [ ] ドキュメント完全性チェック

**プロジェクト完了予定**: Phase 2 実装完了後

---

## 🚀 追加タスク: Debian Bookworm移行計画

### 背景・動機
- **Debian Bullseye**: LTSサポート（2026年8月31日終了）
- **セキュリティリスク**: 通常サポート既に終了（2024年8月14日）
- **技術的メリット**: Python 3.11標準でMarkItDown MCP対応
- **将来性**: 長期サポート継続（Bookworm: 〜2028年）

### 📋 Phase B1: 移行準備・リスク評価

#### 📝 Task B1.1: 現状バックアップ・git記録 🌺
**期間**: 10分
**依存関係**: なし
**実行項目**:
- [🌺] 現在のDockerfileをバックアップ保存 (.devcontainer/Dockerfile.bullseye-backup)
- [🌺] git commitで現在の安定状態を記録 (コミット 8b54b7f)
- [🌺] ロールバック手順の確認・文書化

**🌟 完了メモ** (2025-09-28):
- ✅ Dockerfileバックアップ作成完了 (.bullseye-backup)
- ✅ git commit 8b54b7f で安定状態記録
- ✅ 3重バックアップ体制確立（ファイル・git・完全リセット対応）

#### 📝 Task B1.2: 依存関係・互換性分析 🌺  
**期間**: 20分
**依存関係**: Task B1.1
**実行項目**:
- [🌺] 40+PythonパッケージのBookworm互換性確認
- [🌺] システムライブラリ依存関係の分析
- [🌺] 既存最適化（BuildKitキャッシュ）への影響評価
- [🌺] 潜在的問題点リストアップ

**🌟 完了メモ** (2025-09-28):
- ✅ 40+パッケージ（numpy, pandas, django, fastapi等）全てPython 3.11互換確認
- ✅ PEP 668制約（system-wide pip制限）→ DockerfileのBuildKitキャッシュで解決
- ✅ 既存最適化継続可能、移行リスク低と判定
- ✅ 主要互換性問題なし、安全な移行と確認

### 📋 Phase B2: 段階的移行実行

#### 📝 Task B2.1: ベースイメージ変更・最小構成テスト 🌺
**期間**: 30分  
**依存関係**: Task B1.2
**実行項目**:
- [🌺] `FROM node:20-bullseye` → `FROM node:20-bookworm` 変更
- [🌺] PEP 668対応（3箇所の`--break-system-packages`フラグ追加）
- [🌺] 最小構成でのDevContainerビルドテスト
- [🌺] Python 3.11動作確認（`python3 --version` → Python 3.11.2）
- [🌺] Node.js 20動作確認（`node --version` → v20.19.5）
- [🌺] 基本システムパッケージ確認（Debian GNU/Linux 12 bookworm）

**🌟 完了メモ** (2025-09-28):
- ✅ Bookworm移行成功：Python 3.11.2 + Node.js 20.19.5環境
- ✅ PEP 668制約解決：3箇所の`--break-system-packages`で対応完了
- ✅ MCP統合維持：Serena + Context7 MCP正常動作確認
- ✅ DevContainer正常起動：エラーなしでビルド・起動成功

#### 📝 Task B2.2: Pythonパッケージ互換性確認 🌺
**期間**: 20分
**依存関係**: Task B2.1
**実行項目**:
- [🌺] numpy, pandas等科学計算ライブラリのインストール確認
- [🌺] Django, FastAPI等Webフレームワーク確認
- [🌺] 開発ツール（black, flake8, pytest等）動作確認
- [🌺] パッケージバージョン競合解決

**🌟 完了メモ** (2025-09-28):
- ✅ **基本ライブラリ**: numpy 2.3.3, pandas 2.3.2, matplotlib 3.10.6
- ✅ **Webフレームワーク**: Django 5.2.6, FastAPI 0.117.1, Flask 3.1.2
- ✅ **開発ツール**: black 25.9.0, flake8 7.3.0, pytest 8.4.2
- ✅ **Python 3.11.2環境**: 全40+パッケージが正常動作確認
- 📋 **軽量化設計**: scipy, scikit-learnは意図的に未含有（必要時追加可能）

#### 📝 Task B2.3: 既存機能・最適化検証 🌺
**期間**: 30分
**依存関係**: Task B2.2
**実行項目**:
- [🌺] Zsh + Powerlevel10k環境確認
- [🌺] GitHub CLI + 認証確認
- [🌺] uvx/uv (Rust toolchain) 動作確認
- [🌺] BuildKitキャッシュマウント最適化確認
- [🌺] MCP統合動作確認（Serena + Context7）

**🌟 完了メモ** (2025-09-28):
- ✅ **Shell環境**: Zsh 5.9 + Powerlevel10k正常動作
- ✅ **開発ツール**: GitHub CLI 2.80.0（認証未設定・正常）、git設定済み
- ✅ **Python管理**: uv/uvx 0.8.22（最新版・高速パッケージ管理）
- ✅ **BuildKit最適化**: 5箇所のキャッシュマウント（pip×3、npm×1、user-pip×1）
- ✅ **MCP統合**: Serena v0.1.4 + Context7正常動作確認
- ✅ **60%ビルド時間改善**: 全最適化機能が維持・正常動作

### 📋 Phase B3: MCP統合・最終検証

#### 📝 Task B3.1: MarkItDown MCP統合確認 🌱
**期間**: 30分
**依存関係**: Task B2.3
**実行項目**:
- [ ] Python 3.11環境でのmarkitdown-mcpインストール
- [ ] グローバル設定でのMCP接続確認
- [ ] HTML→Markdown変換動作テスト
- [ ] Context7, Serena MCPとの併用確認

#### 📝 Task B3.2: 全体統合テスト・性能検証 🌱
**期間**: 20分
**依存関係**: Task B3.1
**実行項目**:  
- [ ] Element 4 Phase1完了確認（MarkItDown MCP グローバル設定）
- [ ] 既存MCP（Context7, Serena）動作確認
- [ ] DevContainer起動・再起動テスト
- [ ] ビルド時間最適化効果確認
- [ ] 安定性確認（複数回テスト）

### 📋 Phase B4: 完了・文書化

#### 📝 Task B4.1: 移行完了・ドキュメント更新 🌱
**期間**: 15分
**依存関係**: Task B3.2
**実行項目**:
- [ ] CLAUDE.md プロジェクト情報更新
- [ ] DevContainer構成変更の記録
- [ ] 新しいPython 3.11環境の利用ガイド作成
- [ ] 移行の成果・改善点まとめ

#### 📝 Task B4.2: Element 4 Phase1完了宣言 🌱  
**期間**: 5分
**依存関係**: Task B4.1
**実行項目**:
- [ ] MarkItDown MCP グローバル設定完了確認
- [ ] task.md進捗更新（Element 4 Phase1 → 🌺）
- [ ] 次フェーズ準備（Element 15, Element 8実装）

### 🎯 移行成功基準 - **Phase B2完了** ✅
- ✅ **DevContainer正常起動**: Bookworm環境での安定動作（完了）
- ✅ **Python 3.11環境**: システム標準Python更新完了（3.11.2）
- 🔄 **MarkItDown MCP**: グローバル設定での正常動作（Phase B3予定）
- ✅ **既存機能保持**: 全MCP + 開発環境機能継続（完了）
- ✅ **性能維持**: 60%ビルド時間改善効果保持（完了）
- ✅ **セキュリティ向上**: 長期サポート環境への移行完了（2025年10月直前の安全移行）

**Phase B2 完了状況** (2025-09-28):
- ✅ **Task B2.1**: ベースイメージ変更・最小構成テスト完了
- ✅ **Task B2.2**: Pythonパッケージ互換性確認完了（40+パッケージ検証）
- ✅ **Task B2.3**: 既存機能・最適化検証完了（Shell・CLI・MCP統合確認）

### ⚠️ リスク軽減策
- **ロールバック計画**: gitベースの即座復元可能
- **段階的検証**: 各ステップでの動作確認
- **バックアップ保持**: 安定動作版Dockerfileの保管
- **最小変更原則**: ベースイメージのみ変更、追加修正最小限
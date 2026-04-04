# Research: Dev-RAG 技術選定

**Date**: 2026-01-31
**Purpose**: Dev-RAG 環境の技術スタック選定

## 1. ベクトルデータベース比較

| 項目 | ChromaDB | Qdrant | Milvus Lite | FAISS |
|------|----------|--------|-------------|-------|
| **イメージサイズ** | ~162 MB | ~50 MB | ライブラリのみ | ライブラリのみ |
| **起動時間** | 数秒 | 数秒 | インスタント | インスタント |
| **Python API** | ◎ 優秀 | ◎ 優秀 | ◎ 優秀 | ○ 良好 |
| **スタンドアロン動作** | ◎ サーバー/埋込み両対応 | ◎ サーバー/ローカル | ◎ 3モード対応 | △ ライブラリのみ |
| **GPU対応** | ✕ CPUのみ | ◎ GPU indexing | ○ 一部対応 | ◎ faiss-gpu |
| **永続化** | ◎ SQLite/DuckDB | ◎ RocksDB | ◎ 自動永続化 | △ pickle手動 |
| **本番運用** | △ プロト向け | ◎ 本番対応 | ◎ 本番対応 | △ 単独マシン |

### Decision: Qdrant

**理由**:
- Rust 製で軽量・高速（イメージ ~50MB）
- GPU indexing 対応
- サーバー/ローカルモード両対応
- 高度なフィルタリング機能
- 本番スケールでも安定動作

**代替案として検討**: Milvus Lite（pymilvus 統一 API でスケールアップ容易）

---

## 2. Embedding サービス比較

| 項目 | sentence-transformers | TEI (Text Embeddings Inference) |
|------|----------------------|--------------------------------|
| **デプロイ方式** | Python ライブラリ | Docker コンテナ |
| **API 提供** | Python 関数呼び出し | HTTP REST / gRPC |
| **多言語対応** | ◎ 50+ 言語 | ◎ モデル依存 |
| **GPU 利用** | ◎ CUDA 自動検出 | ◎ Flash Attention 対応 |
| **スループット** | ○ 良好 | ◎ 高速（バッチ最適化） |
| **運用オーバーヘッド** | ◎ 低い | △ コンテナ管理必要 |
| **既存 MCP 互換性** | ◎ 使用実績あり | △ 別途連携必要 |

### Decision: sentence-transformers

**理由**:
- 既存 MCP-Markdown-RAG で使用実績あり
- `paraphrase-multilingual-mpnet-base-v2` モデルで日本語対応済み
- DevContainer 内でのシンプルな統合
- GPU 自動検出対応
- 運用オーバーヘッドが低い

**将来検討**: 高スループット要件発生時に TEI へ移行

---

## 3. RAG サーバーアーキテクチャ比較

| 項目 | 既存 MCP-Markdown-RAG | FastAPI カスタム | LangChain ベース |
|------|----------------------|-----------------|------------------|
| **MCP 統合** | ◎ ネイティブ | △ ラッパー必要 | ○ langchain-mcp |
| **REST API** | ✕ MCP のみ | ◎ 完全対応 | ◎ 完全対応 |
| **拡張性** | ○ Tool 追加可能 | ◎ 自由度最高 | ◎ 多数 Integration |
| **メンテナンス** | ○ 外部依存少 | △ 全て自前 | △ 依存関係複雑 |
| **デバッグ容易性** | ○ 良好 | ◎ 明確 | △ 5+ 層抽象化 |

### Decision: FastAPI カスタム実装

**理由**:
- MCP 限定ではなく汎用 RAG 基盤という要件
- REST API 完全対応で他ツールからも利用可能
- 軽量で依存関係がシンプル
- async 対応、OpenAPI 自動生成
- 必要に応じて MCP アダプター追加可能

**代替案**: 既存 MCP-Markdown-RAG を拡張（開発コスト低、既存資産活用）

---

## 4. 総合推奨構成

### Primary Configuration

| コンポーネント | 選定技術 | バージョン |
|--------------|---------|-----------|
| ベクトル DB | **Qdrant** | latest |
| Embedding | **sentence-transformers** | latest |
| モデル | paraphrase-multilingual-mpnet-base-v2 | - |
| RAG サーバー | **FastAPI** + カスタム実装 | FastAPI 0.100+ |
| MCP 統合 | オプショナルアダプター | - |

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ Dev-RAG Container                                           │
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │ FastAPI      │───▶│ sentence-    │───▶│ Qdrant       │  │
│  │ REST Server  │    │ transformers │    │ Vector DB    │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         │                                       │          │
│         │            ┌──────────────┐           │          │
│         └───────────▶│ MCP Adapter  │◀──────────┘          │
│                      │ (optional)   │                      │
│                      └──────────────┘                      │
│                             │                              │
└─────────────────────────────│──────────────────────────────┘
                              │
                              ▼
                      ┌──────────────┐
                      │ Claude Code  │
                      │ (MCP Client) │
                      └──────────────┘
```

### Alternative Configuration (Simpler)

既存資産を活用する場合：

| コンポーネント | 選定技術 |
|--------------|---------|
| ベクトル DB | Milvus Lite（既存 MCP-Markdown-RAG で使用） |
| Embedding | sentence-transformers（既存パッチ適用済み） |
| RAG サーバー | MCP-Markdown-RAG 拡張 |

---

## 5. 実装フェーズ

### Phase 1: 基盤構築
- Qdrant コンテナ起動設定
- sentence-transformers + 多言語モデルセットアップ
- 基本的な Document インデックス機能

### Phase 2: REST API 実装
- FastAPI サーバー構築
- `/embed` - テキスト埋め込み API
- `/search` - ベクトル検索 API
- `/index` - ドキュメントインデックス API

### Phase 3: MCP 統合（オプション）
- MCP Tool アダプター実装
- Claude Code からの直接利用対応

### Phase 4: 最適化
- バッチ処理最適化
- キャッシュ戦略
- TEI 移行検討（必要に応じて）

---

## 6. リスクと対策

| リスク | 対策 |
|--------|------|
| Qdrant イメージサイズ増加 | profiles で分離、必要時のみ起動 |
| GPU メモリ不足 | CPU フォールバック実装 |
| モデルダウンロード時間 | ビルド時にダウンロード、イメージに含める |
| 既存 MCP との互換性 | アダプター層で吸収 |

---

## 7. 参考リンク

- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [sentence-transformers](https://www.sbert.net/)
- [FastAPI](https://fastapi.tiangolo.com/)
- [TEI (Text Embeddings Inference)](https://huggingface.co/docs/text-embeddings-inference/)
- [MCP-Markdown-RAG](https://github.com/Zackriya-Solutions/MCP-Markdown-RAG)

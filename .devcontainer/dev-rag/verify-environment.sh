#!/bin/bash
# Dev-RAG 環境の動作確認スクリプト
# Usage: bash verify-environment.sh

set -euo pipefail

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 結果カウンター
PASS=0
FAIL=0
WARN=0

print_header() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
}

print_check() {
    echo -e "${BLUE}▶${NC} $1"
}

print_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    ((PASS++))
}

print_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((FAIL++))
}

print_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    ((WARN++))
}

print_info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

# ============================================================
# 基本環境
# ============================================================
print_header "基本環境"

print_check "Node.js"
if command -v node &> /dev/null; then
    print_pass "node $(node -v)"
else
    print_fail "Node.js がインストールされていません"
fi

print_check "Python"
if command -v python3 &> /dev/null; then
    print_pass "python3 $(python3 --version 2>&1 | cut -d' ' -f2)"
else
    print_fail "Python3 がインストールされていません"
fi

print_check "uv"
if command -v uv &> /dev/null; then
    print_pass "uv $(uv --version 2>&1 | cut -d' ' -f2)"
else
    print_fail "uv がインストールされていません"
fi

print_check "Git"
if command -v git &> /dev/null; then
    print_pass "git $(git --version | cut -d' ' -f3)"
else
    print_fail "Git がインストールされていません"
fi

print_check "GitHub CLI"
if command -v gh &> /dev/null; then
    print_pass "gh $(gh --version | head -1 | cut -d' ' -f3)"
    # 認証状態確認
    if gh auth status &> /dev/null; then
        print_pass "gh auth: 認証済み"
    else
        print_warn "gh auth: 未認証（gh auth login が必要）"
    fi
else
    print_fail "GitHub CLI がインストールされていません"
fi

# ============================================================
# GPU / CUDA
# ============================================================
print_header "GPU / CUDA"

print_check "NVIDIA GPU"
if command -v nvidia-smi &> /dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    GPU_MEMORY=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1)
    if [ -n "$GPU_NAME" ]; then
        print_pass "$GPU_NAME ($GPU_MEMORY)"
    else
        print_fail "GPU が認識されていません"
    fi
else
    print_warn "nvidia-smi が見つかりません（GPU なし環境の可能性）"
fi

# ============================================================
# PyTorch + CUDA
# ============================================================
print_header "PyTorch + CUDA"

print_check "PyTorch"
PYTORCH_CHECK=$(python3 -c "
import sys
try:
    import torch
    print(f'version:{torch.__version__}')
    print(f'cuda_available:{torch.cuda.is_available()}')
    print(f'cuda_version:{torch.version.cuda}')
    if torch.cuda.is_available():
        print(f'gpu_name:{torch.cuda.get_device_name(0)}')
except ImportError:
    print('error:PyTorch not installed')
except Exception as e:
    print(f'error:{e}')
" 2>&1)

if echo "$PYTORCH_CHECK" | grep -q "^error:"; then
    print_fail "$(echo "$PYTORCH_CHECK" | grep "^error:" | cut -d: -f2)"
else
    TORCH_VER=$(echo "$PYTORCH_CHECK" | grep "^version:" | cut -d: -f2)
    CUDA_AVAIL=$(echo "$PYTORCH_CHECK" | grep "^cuda_available:" | cut -d: -f2)
    CUDA_VER=$(echo "$PYTORCH_CHECK" | grep "^cuda_version:" | cut -d: -f2)

    print_pass "PyTorch $TORCH_VER"

    if [ "$CUDA_AVAIL" = "True" ]; then
        GPU_NAME=$(echo "$PYTORCH_CHECK" | grep "^gpu_name:" | cut -d: -f2)
        print_pass "CUDA $CUDA_VER (GPU: $GPU_NAME)"
    else
        print_warn "CUDA 利用不可（CPU モードで動作）"
    fi
fi

# ============================================================
# sentence-transformers
# ============================================================
print_header "sentence-transformers"

print_check "sentence-transformers インポート"
ST_CHECK=$(python3 -c "
try:
    from sentence_transformers import SentenceTransformer
    print('ok')
except ImportError:
    print('error:not installed')
except Exception as e:
    print(f'error:{e}')
" 2>&1)

if [ "$ST_CHECK" = "ok" ]; then
    print_pass "sentence-transformers インポート成功"

    print_check "Embedding 生成テスト"
    EMBED_CHECK=$(python3 -c "
from sentence_transformers import SentenceTransformer
model = SentenceTransformer('paraphrase-multilingual-mpnet-base-v2')
embedding = model.encode('テスト')
print(f'dim:{len(embedding)}')
" 2>&1)

    if echo "$EMBED_CHECK" | grep -q "^dim:"; then
        DIM=$(echo "$EMBED_CHECK" | grep "^dim:" | cut -d: -f2)
        print_pass "Embedding 生成成功 (${DIM}次元)"
    else
        print_fail "Embedding 生成失敗"
    fi
else
    print_fail "sentence-transformers がインストールされていません"
fi

# ============================================================
# Qdrant
# ============================================================
print_header "Qdrant"

print_check "qdrant-client"
QDRANT_CLIENT_CHECK=$(python3 -c "
try:
    from qdrant_client import QdrantClient
    print('ok')
except ImportError:
    print('error')
" 2>&1)

if [ "$QDRANT_CLIENT_CHECK" = "ok" ]; then
    print_pass "qdrant-client インポート成功"
else
    print_fail "qdrant-client がインストールされていません"
fi

print_check "Qdrant サーバー接続"
QDRANT_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://qdrant:6333/ 2>/dev/null || echo "000")

if [ "$QDRANT_RESPONSE" = "200" ]; then
    QDRANT_VERSION=$(curl -s http://qdrant:6333/ 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    print_pass "Qdrant 接続成功 (v$QDRANT_VERSION)"
else
    print_warn "Qdrant サーバーに接続できません（起動していない可能性）"
    print_info "docker compose --profile rag up -d で起動してください"
fi

# ============================================================
# FastAPI / uvicorn
# ============================================================
print_header "FastAPI / uvicorn"

print_check "FastAPI"
FASTAPI_CHECK=$(python3 -c "
try:
    import fastapi
    print(f'version:{fastapi.__version__}')
except ImportError:
    print('error')
" 2>&1)

if echo "$FASTAPI_CHECK" | grep -q "^version:"; then
    FASTAPI_VER=$(echo "$FASTAPI_CHECK" | grep "^version:" | cut -d: -f2)
    print_pass "FastAPI $FASTAPI_VER"
else
    print_fail "FastAPI がインストールされていません"
fi

print_check "uvicorn"
if command -v uvicorn &> /dev/null; then
    UVICORN_VER=$(uvicorn --version 2>&1 | cut -d' ' -f2)
    print_pass "uvicorn $UVICORN_VER"
else
    print_fail "uvicorn がインストールされていません"
fi

# ============================================================
# サマリー
# ============================================================
print_header "サマリー"

echo ""
echo -e "  ${GREEN}✓ PASS${NC}: $PASS"
echo -e "  ${YELLOW}⚠ WARN${NC}: $WARN"
echo -e "  ${RED}✗ FAIL${NC}: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}🎉 Dev-RAG 環境は正常に動作しています！${NC}"
    exit 0
else
    echo -e "${RED}⚠️  一部のコンポーネントに問題があります。上記を確認してください。${NC}"
    exit 1
fi

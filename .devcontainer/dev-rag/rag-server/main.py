"""RAG Server - FastAPI application for embedding and semantic search."""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from embeddings import encode_texts, get_embedding_dimension
from qdrant_store import index_documents, search_documents

app = FastAPI(
    title="RAG Server",
    description="Embedding and semantic search API using sentence-transformers and Qdrant",
    version="1.0.0",
)


# =============================================================================
# Request/Response Models
# =============================================================================


class EmbedRequest(BaseModel):
    """Request model for embedding generation."""

    texts: list[str] = Field(..., description="List of texts to embed", min_length=1)


class EmbedResponse(BaseModel):
    """Response model for embedding generation."""

    embeddings: list[list[float]] = Field(..., description="List of embedding vectors")
    dimension: int = Field(..., description="Embedding dimension")


class IndexRequest(BaseModel):
    """Request model for document indexing."""

    texts: list[str] = Field(
        ..., description="List of document texts to index", min_length=1
    )
    metadata: list[dict] | None = Field(
        None, description="Optional metadata for each document"
    )


class IndexResponse(BaseModel):
    """Response model for document indexing."""

    ids: list[str] = Field(..., description="List of document IDs")
    count: int = Field(..., description="Number of documents indexed")


class SearchRequest(BaseModel):
    """Request model for semantic search."""

    query: str = Field(..., description="Search query text", min_length=1)
    limit: int = Field(5, description="Maximum number of results", ge=1, le=100)
    score_threshold: float | None = Field(
        None, description="Minimum similarity score", ge=0.0, le=1.0
    )


class SearchResult(BaseModel):
    """Single search result."""

    id: str
    text: str
    score: float
    metadata: dict


class SearchResponse(BaseModel):
    """Response model for semantic search."""

    results: list[SearchResult]
    count: int


# =============================================================================
# Endpoints
# =============================================================================


@app.get("/health")
async def health_check() -> dict:
    """Health check endpoint."""
    return {"status": "healthy"}


@app.post("/embed", response_model=EmbedResponse)
async def embed(request: EmbedRequest) -> EmbedResponse:
    """
    Generate embeddings for the given texts.

    Returns embedding vectors that can be used for similarity search.
    """
    try:
        embeddings = encode_texts(request.texts)
        return EmbedResponse(
            embeddings=embeddings,
            dimension=get_embedding_dimension(),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


@app.post("/index", response_model=IndexResponse)
async def index(request: IndexRequest) -> IndexResponse:
    """
    Index documents into the vector store.

    Documents are embedded and stored in Qdrant for later search.
    """
    try:
        if request.metadata and len(request.metadata) != len(request.texts):
            raise HTTPException(
                status_code=400,
                detail="metadata length must match texts length",
            )

        ids = index_documents(request.texts, request.metadata)
        return IndexResponse(ids=ids, count=len(ids))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


@app.post("/search", response_model=SearchResponse)
async def search(request: SearchRequest) -> SearchResponse:
    """
    Search for similar documents.

    Returns documents ranked by semantic similarity to the query.
    """
    try:
        results = search_documents(
            query=request.query,
            limit=request.limit,
            score_threshold=request.score_threshold,
        )
        return SearchResponse(
            results=[SearchResult(**r) for r in results],
            count=len(results),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)

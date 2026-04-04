"""Qdrant vector store operations."""

import os
from typing import Optional
from uuid import uuid4

from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, PointStruct, VectorParams

from embeddings import encode_texts, get_embedding_dimension

# Configuration from environment
QDRANT_HOST = os.getenv("QDRANT_HOST", "qdrant")
QDRANT_PORT = int(os.getenv("QDRANT_PORT", "6333"))
COLLECTION_NAME = os.getenv("QDRANT_COLLECTION", "documents")


def get_client() -> QdrantClient:
    """Get Qdrant client instance."""
    return QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)


def ensure_collection(client: QdrantClient) -> None:
    """Ensure the collection exists, create if not."""
    collections = client.get_collections().collections
    collection_names = [c.name for c in collections]

    if COLLECTION_NAME not in collection_names:
        client.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(
                size=get_embedding_dimension(),
                distance=Distance.COSINE,
            ),
        )
        print(f"Created collection: {COLLECTION_NAME}")


def index_documents(
    texts: list[str],
    metadata: Optional[list[dict]] = None,
) -> list[str]:
    """
    Index documents into Qdrant.

    Args:
        texts: List of document texts
        metadata: Optional list of metadata dicts for each document

    Returns:
        List of document IDs
    """
    client = get_client()
    ensure_collection(client)

    embeddings = encode_texts(texts)
    ids = [str(uuid4()) for _ in texts]

    points = [
        PointStruct(
            id=doc_id,
            vector=embedding,
            payload={
                "text": text,
                **(meta or {}),
            },
        )
        for doc_id, embedding, text, meta in zip(
            ids,
            embeddings,
            texts,
            metadata or [None] * len(texts),
        )
    ]

    client.upsert(collection_name=COLLECTION_NAME, points=points)
    return ids


def search_documents(
    query: str,
    limit: int = 5,
    score_threshold: Optional[float] = None,
) -> list[dict]:
    """
    Search for similar documents.

    Args:
        query: Search query text
        limit: Maximum number of results
        score_threshold: Minimum similarity score (optional)

    Returns:
        List of search results with text, score, and metadata
    """
    client = get_client()
    ensure_collection(client)

    query_embedding = encode_texts([query])[0]

    results = client.search(
        collection_name=COLLECTION_NAME,
        query_vector=query_embedding,
        limit=limit,
        score_threshold=score_threshold,
    )

    return [
        {
            "id": str(hit.id),
            "text": hit.payload.get("text", ""),
            "score": hit.score,
            "metadata": {k: v for k, v in hit.payload.items() if k != "text"},
        }
        for hit in results
    ]

"""Embedding service using sentence-transformers."""

from functools import lru_cache

import torch
from sentence_transformers import SentenceTransformer

# Model configuration
MODEL_NAME = "paraphrase-multilingual-mpnet-base-v2"


@lru_cache(maxsize=1)
def get_model() -> SentenceTransformer:
    """Get or create the embedding model (cached singleton)."""
    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Loading model {MODEL_NAME} on {device}")
    model = SentenceTransformer(MODEL_NAME, device=device)
    return model


def encode_texts(texts: list[str], normalize: bool = True) -> list[list[float]]:
    """
    Encode texts into embeddings.

    Args:
        texts: List of texts to encode
        normalize: Whether to normalize embeddings (default: True)

    Returns:
        List of embedding vectors
    """
    model = get_model()
    embeddings = model.encode(
        texts,
        convert_to_numpy=True,
        normalize_embeddings=normalize,
    )
    return embeddings.tolist()


def get_embedding_dimension() -> int:
    """Get the dimension of the embedding vectors."""
    model = get_model()
    return model.get_sentence_embedding_dimension()

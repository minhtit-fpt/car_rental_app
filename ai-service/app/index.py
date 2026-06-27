"""Dựng index RAG: corpus chunk → embedding (bge-m3) → InMemoryVectorStore.

Chạy như script để build index lúc khởi động service (cần LM Studio chạy):
    python3 -m app.index

Vì corpus tĩnh nhỏ (~60–200 chunk), embed cả corpus trong 1 lần gọi batch là đủ
nhanh và đơn giản; chưa cần cache trên đĩa ở phase này.
"""

from __future__ import annotations

from app.corpus import Chunk, load_corpus
from app.embedder import Embedder, LMStudioEmbedder
from app.config import get_settings
from app.vectorstore import InMemoryVectorStore, VectorStore


def build_index(
    chunks: list[Chunk],
    embedder: Embedder,
    store: VectorStore | None = None,
) -> VectorStore:
    """Embed `embedding_text()` của từng chunk rồi nạp vào store."""
    target = store if store is not None else InMemoryVectorStore()
    vectors = embedder.embed([c.embedding_text() for c in chunks])
    for chunk, vector in zip(chunks, vectors):
        target.add(chunk, vector)
    return target


def build_default_index() -> VectorStore:
    """Dựng index từ corpus + embedder cấu hình trong settings (cần LM Studio)."""
    settings = get_settings()
    chunks = load_corpus(settings.corpus_path)
    embedder = LMStudioEmbedder.from_settings(settings)
    return build_index(chunks, embedder)


if __name__ == "__main__":
    idx = build_default_index()
    print(f"Index dựng xong: {len(idx)} chunk.")  # type: ignore[arg-type]

"""Dựng index RAG: corpus chunk → embedding (bge-m3) → InMemoryVectorStore.

Chạy như script để build index lúc khởi động service (cần LM Studio chạy):
    python3 -m app.index

Vì corpus tĩnh nhỏ (~60–200 chunk), embed cả corpus trong 1 lần gọi batch là đủ
nhanh và đơn giản. Cache index → .pkl file để reuse, rebuild khi đổi embedding model.
"""

from __future__ import annotations

import pickle
from pathlib import Path

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


def save_index(store: VectorStore, path: Path) -> None:
    """Lưu index vào file .pkl để tái sử dụng (tránh rebuild mỗi lần khởi động)."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "wb") as f:
        pickle.dump(store, f)


def load_index_from_cache(path: Path) -> VectorStore | None:
    """Tải index từ cache nếu tồn tại, trả None nếu không."""
    if not path.exists():
        return None
    try:
        with open(path, "rb") as f:
            return pickle.load(f)
    except Exception:
        return None


def build_default_index(use_cache: bool = True) -> VectorStore:
    """Dựng index từ corpus + embedder cấu hình trong settings (cần LM Studio).

    Nếu `use_cache=True`: load từ .pkl nếu tồn tại, không thì build + save.
    Nếu `use_cache=False`: luôn rebuild (dùng sau khi đổi embedding model).
    """
    settings = get_settings()
    cache_path = settings.corpus_path.parent / "index.pkl"

    # Thử load cache
    if use_cache:
        cached = load_index_from_cache(cache_path)
        if cached is not None:
            print(f"Đã tải index từ cache: {cache_path}")
            return cached

    # Build từ scratch
    chunks = load_corpus(settings.corpus_path)
    embedder = LMStudioEmbedder.from_settings(settings)
    idx = build_index(chunks, embedder)

    # Lưu cache
    save_index(idx, cache_path)
    print(f"Index dựng + lưu vào cache: {cache_path}")
    return idx


if __name__ == "__main__":
    import sys

    rebuild = "--rebuild" in sys.argv
    idx = build_default_index(use_cache=not rebuild)
    print(f"Index sẵn sàng: {len(idx)} chunk.")  # type: ignore[arg-type]

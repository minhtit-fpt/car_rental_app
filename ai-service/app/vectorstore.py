"""Interface retriever + cài đặt in-memory cosine.

Chốt kiến trúc (xem plan): corpus tĩnh nhỏ (~60–200 chunk) → in-memory cosine là
đủ nhanh, KHÔNG cần vector DB. Nhưng tách sau interface `VectorStore` để sau này
cắm `PgVectorStore` (tận dụng Postgres + pgvector) mà không sửa chat engine.

Cosine tính bằng pure Python (không cần numpy) cho dễ test và ít phụ thuộc; quy mô
corpus nhỏ nên thừa nhanh.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Protocol, Sequence

from app.corpus import Chunk


@dataclass(frozen=True)
class SearchResult:
    chunk: Chunk
    score: float


class VectorStore(Protocol):
    """Hợp đồng tối thiểu để chat engine không phụ thuộc cách lưu vector."""

    def add(self, chunk: Chunk, vector: Sequence[float]) -> None: ...

    def search(
        self,
        query_vector: Sequence[float],
        top_k: int = 5,
        category: str | None = None,
    ) -> list[SearchResult]: ...


def _cosine(a: Sequence[float], b: Sequence[float]) -> float:
    if len(a) != len(b):
        raise ValueError(f"Vector lệch chiều: {len(a)} vs {len(b)}")
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(y * y for y in b))
    if na == 0 or nb == 0:
        return 0.0
    return dot / (na * nb)


class InMemoryVectorStore:
    """Cài đặt cosine in-memory. Implement VectorStore (structural typing)."""

    def __init__(self) -> None:
        self._entries: list[tuple[Chunk, tuple[float, ...]]] = []

    def __len__(self) -> int:
        return len(self._entries)

    def add(self, chunk: Chunk, vector: Sequence[float]) -> None:
        self._entries.append((chunk, tuple(vector)))

    def search(
        self,
        query_vector: Sequence[float],
        top_k: int = 5,
        category: str | None = None,
    ) -> list[SearchResult]:
        scored = [
            SearchResult(chunk=chunk, score=_cosine(query_vector, vec))
            for chunk, vec in self._entries
            if category is None or chunk.category == category
        ]
        scored.sort(key=lambda r: r.score, reverse=True)
        return scored[:top_k]

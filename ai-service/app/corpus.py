"""Tải corpus tri thức xe (JSONL) thành các Chunk.

Phân tách RAG: ở đây CHỈ là kiến thức TĨNH (luật, bảo hiểm, thủ tục, thông số).
Dữ liệu ĐỘNG (giá, xe trống, booking) đi qua tool-calling, KHÔNG nhúng vào corpus.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path


@dataclass(frozen=True)
class Chunk:
    id: str
    category: str
    title: str
    text: str
    tags: tuple[str, ...] = ()
    # Cách người dùng hay hỏi (từ đồng nghĩa, viết tắt) — tăng recall khi rerank.
    keywords: tuple[str, ...] = ()
    source: str | None = None

    # Văn bản đưa đi embedding: gộp title + keywords + text để bắt được cả tiêu
    # đề lẫn cách hỏi, không chỉ thân bài.
    def embedding_text(self) -> str:
        parts = [self.title, " ".join(self.keywords), self.text]
        return "\n".join(p for p in parts if p).strip()


def _to_chunk(raw: dict) -> Chunk:
    return Chunk(
        id=raw["id"],
        category=raw.get("category", "uncategorized"),
        title=raw.get("title", ""),
        text=raw["text"],
        tags=tuple(raw.get("tags", [])),
        keywords=tuple(raw.get("keywords", [])),
        source=raw.get("source"),
    )


def load_corpus(path: Path) -> list[Chunk]:
    """Đọc file JSONL (1 chunk / dòng). Bỏ qua dòng trống; lỗi parse thì fail
    sớm kèm số dòng để dễ sửa corpus."""
    chunks: list[Chunk] = []
    with path.open(encoding="utf-8") as f:
        for lineno, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                chunks.append(_to_chunk(json.loads(line)))
            except (json.JSONDecodeError, KeyError) as err:
                raise ValueError(f"Corpus lỗi tại dòng {lineno}: {err}") from err
    return chunks

"""Test embedder + index builder — mock LM Studio bằng httpx.MockTransport,
KHÔNG cần LM Studio chạy thật."""

from __future__ import annotations

import json

import httpx
import pytest

from app.corpus import Chunk
from app.embedder import LMStudioEmbedder
from app.index import build_index


def _fake_transport(captured: list[dict]) -> httpx.MockTransport:
    """Trả embedding giả: vector 3 chiều suy ra từ độ dài input để test xác định."""

    def handler(request: httpx.Request) -> httpx.Response:
        body = json.loads(request.content)
        captured.append(body)
        inputs = body["input"]
        data = [
            {"index": i, "embedding": [float(len(t)), 1.0, 0.0]}
            for i, t in enumerate(inputs)
        ]
        return httpx.Response(200, json={"data": data, "model": body["model"]})

    return httpx.MockTransport(handler)


def _embedder(captured: list[dict]) -> LMStudioEmbedder:
    client = httpx.Client(
        base_url="http://test/v1", transport=_fake_transport(captured)
    )
    return LMStudioEmbedder(model="bge-m3", client=client)


def test_embed_returns_vector_per_text() -> None:
    captured: list[dict] = []
    vecs = _embedder(captured).embed(["a", "abc"])
    assert vecs == [[1.0, 1.0, 0.0], [3.0, 1.0, 0.0]]
    assert captured[0]["model"] == "bge-m3"


def test_embed_empty_skips_http_call() -> None:
    captured: list[dict] = []
    assert _embedder(captured).embed([]) == []
    assert captured == []  # không gọi mạng khi rỗng


def test_embed_query_returns_single_vector() -> None:
    captured: list[dict] = []
    assert _embedder(captured).embed_query("hello") == [5.0, 1.0, 0.0]


def test_embed_preserves_order_when_response_shuffled() -> None:
    """LM Studio có thể trả data không theo thứ tự input — phải sort theo index."""

    def handler(request: httpx.Request) -> httpx.Response:
        inputs = json.loads(request.content)["input"]
        data = [{"index": i, "embedding": [float(i)]} for i in range(len(inputs))]
        data.reverse()
        return httpx.Response(200, json={"data": data})

    client = httpx.Client(base_url="http://test/v1", transport=httpx.MockTransport(handler))
    vecs = LMStudioEmbedder(model="m", client=client).embed(["x", "y", "z"])
    assert vecs == [[0.0], [1.0], [2.0]]


def test_embed_raises_on_http_error() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        return httpx.Response(500, json={"error": "model not loaded"})

    client = httpx.Client(base_url="http://test/v1", transport=httpx.MockTransport(handler))
    with pytest.raises(httpx.HTTPStatusError):
        LMStudioEmbedder(model="m", client=client).embed(["x"])


def test_build_index_embeds_and_stores_all_chunks() -> None:
    captured: list[dict] = []
    chunks = [
        Chunk(id="c1", category="faq", title="T1", text="body one"),
        Chunk(id="c2", category="faq", title="T2", text="body two longer"),
    ]
    store = build_index(chunks, _embedder(captured))
    assert len(store) == 2
    # embedding_text gộp title + keywords + text → đã gửi đi embedding.
    sent = captured[0]["input"]
    assert any("T1" in s for s in sent)
    # search trả lại đúng chunk.
    results = store.search([1.0, 1.0, 0.0], top_k=1)
    assert results[0].chunk.id in {"c1", "c2"}

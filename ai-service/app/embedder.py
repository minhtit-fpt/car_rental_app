"""Client embedding gọi LM Studio `/v1/embeddings` (định dạng OpenAI), model bge-m3.

Bất biến (xem README/plan B2): ĐỔI embedding model → BẮT BUỘC rebuild index vì
không gian vector thay đổi; vector cũ không so sánh được với vector mới.

Embedder tách sau Protocol để chat engine / index builder không phụ thuộc HTTP cụ
thể — test bơm `httpx.MockTransport`, không cần LM Studio chạy.
"""

from __future__ import annotations

from typing import Protocol, Sequence

import httpx

from app.config import Settings, get_settings

_DEFAULT_TIMEOUT = 60.0


class Embedder(Protocol):
    """Hợp đồng tối thiểu cho mọi nguồn embedding."""

    def embed(self, texts: Sequence[str]) -> list[list[float]]: ...

    def embed_query(self, text: str) -> list[float]: ...


class LMStudioEmbedder:
    """Gọi endpoint OpenAI-compatible `/embeddings` của LM Studio."""

    def __init__(
        self,
        model: str,
        *,
        base_url: str | None = None,
        api_key: str | None = None,
        client: httpx.Client | None = None,
    ) -> None:
        self._model = model
        # Cho phép tiêm client (test) hoặc tự dựng từ base_url (chạy thật).
        if client is not None:
            self._client = client
        else:
            if base_url is None:
                raise ValueError("Cần base_url hoặc client")
            headers = {"Authorization": f"Bearer {api_key or 'lm-studio'}"}
            self._client = httpx.Client(
                base_url=base_url, headers=headers, timeout=_DEFAULT_TIMEOUT
            )

    @classmethod
    def from_settings(cls, settings: Settings | None = None) -> "LMStudioEmbedder":
        s = settings or get_settings()
        return cls(
            model=s.embedding_model,
            base_url=s.lmstudio_base_url,
            api_key=s.lmstudio_api_key,
        )

    def embed(self, texts: Sequence[str]) -> list[list[float]]:
        texts = list(texts)
        if not texts:
            return []
        resp = self._client.post(
            "/embeddings", json={"model": self._model, "input": texts}
        )
        resp.raise_for_status()
        data = resp.json()["data"]
        # LM Studio không đảm bảo thứ tự → sắp lại theo `index` để khớp input.
        ordered = sorted(data, key=lambda d: d["index"])
        return [d["embedding"] for d in ordered]

    def embed_query(self, text: str) -> list[float]:
        return self.embed([text])[0]

"""Client LLM chat gọi LM Studio `/v1/chat/completions` (định dạng OpenAI), model
Qwen2.5. Hỗ trợ cả gọi thường (`complete`) lẫn streaming SSE (`stream_complete`).

Migrate từ Gemini sang OpenAI messages (xem plan B3): role `model`→`assistant`,
`contents`→`messages`. Bỏ chain Gemini; model local cấu hình qua settings.
"""

from __future__ import annotations

import json
from typing import Any, Iterator

import httpx

from app.config import Settings, get_settings

_DEFAULT_TIMEOUT = 120.0  # LLM local có thể chậm vài giây.
_DEFAULT_TEMPERATURE = 0.3


class LMStudioChat:
    def __init__(
        self,
        model: str,
        *,
        base_url: str | None = None,
        api_key: str | None = None,
        client: httpx.Client | None = None,
        temperature: float = _DEFAULT_TEMPERATURE,
    ) -> None:
        self._model = model
        self._temperature = temperature
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
    def from_settings(cls, settings: Settings | None = None) -> "LMStudioChat":
        s = settings or get_settings()
        return cls(model=s.chat_model, base_url=s.lmstudio_base_url, api_key=s.lmstudio_api_key)

    def _payload(self, messages: list[dict], tools: list[dict] | None, stream: bool) -> dict:
        payload: dict[str, Any] = {
            "model": self._model,
            "messages": messages,
            "temperature": self._temperature,
            "stream": stream,
        }
        if tools:
            payload["tools"] = tools
        return payload

    def complete(self, messages: list[dict], tools: list[dict] | None = None) -> dict:
        """Gọi 1 lần, trả message của assistant (có thể chứa `tool_calls`)."""
        resp = self._client.post(
            "/chat/completions", json=self._payload(messages, tools, stream=False)
        )
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]

    def stream_complete(
        self, messages: list[dict], tools: list[dict] | None = None
    ) -> Iterator[tuple[str, Any]]:
        """Stream SSE. Yield ("content", str) cho từng delta văn bản; sự kiện CUỐI
        luôn là ("tool_calls", list|None) — None nếu model không gọi tool."""
        tool_calls: dict[int, dict] = {}
        with self._client.stream(
            "POST", "/chat/completions", json=self._payload(messages, tools, stream=True)
        ) as resp:
            resp.raise_for_status()
            for line in resp.iter_lines():
                if not line or not line.startswith("data:"):
                    continue
                data = line[len("data:") :].strip()
                if data == "[DONE]":
                    break
                delta = json.loads(data)["choices"][0].get("delta", {})
                content = delta.get("content")
                if content:
                    yield ("content", content)
                for tc in delta.get("tool_calls", []) or []:
                    _merge_tool_call(tool_calls, tc)
        yield ("tool_calls", _finalize_tool_calls(tool_calls))


def _merge_tool_call(acc: dict[int, dict], delta: dict) -> None:
    """Gộp các mảnh tool_call streaming theo `index` (id + name 1 lần, arguments nối)."""
    idx = delta.get("index", 0)
    slot = acc.setdefault(idx, {"id": None, "type": "function", "function": {"name": None, "arguments": ""}})
    if delta.get("id"):
        slot["id"] = delta["id"]
    fn = delta.get("function", {})
    if fn.get("name"):
        slot["function"]["name"] = fn["name"]
    if fn.get("arguments"):
        slot["function"]["arguments"] += fn["arguments"]


def _finalize_tool_calls(acc: dict[int, dict]) -> list[dict] | None:
    if not acc:
        return None
    return [acc[i] for i in sorted(acc)]

"""Test client LLM (LM Studio /v1/chat/completions) — mock bằng httpx.MockTransport.
Bao gồm parse SSE streaming (content delta + tool_calls delta). KHÔNG cần LM Studio."""

from __future__ import annotations

import json

import httpx

from app.llm import LMStudioChat


def _chat(handler) -> LMStudioChat:
    client = httpx.Client(base_url="http://test/v1", transport=httpx.MockTransport(handler))
    return LMStudioChat(model="qwen", client=client)


def test_complete_returns_assistant_message() -> None:
    def handler(req: httpx.Request) -> httpx.Response:
        body = json.loads(req.content)
        assert body["stream"] is False
        return httpx.Response(
            200,
            json={"choices": [{"message": {"role": "assistant", "content": "Chào bạn"}}]},
        )

    msg = _chat(handler).complete([{"role": "user", "content": "hi"}])
    assert msg["content"] == "Chào bạn"


def test_complete_forwards_tools() -> None:
    seen: dict = {}

    def handler(req: httpx.Request) -> httpx.Response:
        seen["body"] = json.loads(req.content)
        return httpx.Response(200, json={"choices": [{"message": {"content": "ok"}}]})

    _chat(handler).complete([{"role": "user", "content": "x"}], tools=[{"type": "function"}])
    assert seen["body"]["tools"] == [{"type": "function"}]


def _sse(*chunks: dict) -> bytes:
    lines = [f"data: {json.dumps(c)}" for c in chunks]
    lines.append("data: [DONE]")
    return ("\n\n".join(lines) + "\n\n").encode()


def test_stream_complete_yields_content_deltas() -> None:
    payload = _sse(
        {"choices": [{"delta": {"content": "Xin "}}]},
        {"choices": [{"delta": {"content": "chào"}}]},
        {"choices": [{"delta": {}, "finish_reason": "stop"}]},
    )

    def handler(req: httpx.Request) -> httpx.Response:
        assert json.loads(req.content)["stream"] is True
        return httpx.Response(200, content=payload, headers={"content-type": "text/event-stream"})

    events = list(_chat(handler).stream_complete([{"role": "user", "content": "hi"}]))
    contents = [text for kind, text in events if kind == "content"]
    assert "".join(contents) == "Xin chào"
    # sự kiện cuối báo tool_calls (None khi không có).
    assert events[-1][0] == "tool_calls"
    assert events[-1][1] is None


def test_stream_complete_accumulates_tool_calls() -> None:
    payload = _sse(
        {"choices": [{"delta": {"tool_calls": [{"index": 0, "id": "call_1", "function": {"name": "get_my_bookings", "arguments": ""}}]}}]},
        {"choices": [{"delta": {"tool_calls": [{"index": 0, "function": {"arguments": "{}"}}]}}]},
        {"choices": [{"delta": {}, "finish_reason": "tool_calls"}]},
    )

    def handler(req: httpx.Request) -> httpx.Response:
        return httpx.Response(200, content=payload, headers={"content-type": "text/event-stream"})

    events = list(_chat(handler).stream_complete([{"role": "user", "content": "chuyến của tôi"}]))
    kind, tool_calls = events[-1]
    assert kind == "tool_calls"
    assert tool_calls[0]["id"] == "call_1"
    assert tool_calls[0]["function"]["name"] == "get_my_bookings"
    assert tool_calls[0]["function"]["arguments"] == "{}"

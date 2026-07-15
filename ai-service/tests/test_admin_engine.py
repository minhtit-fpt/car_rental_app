"""Test engine hỏi-đáp admin: nạp snapshot JSON → nhồi context → gọi LLM 1 lần.
Dùng LLM GIẢ (fake) nên xác định, KHÔNG cần LM Studio hay backend."""

from __future__ import annotations

import json

from app.admin_engine import load_snapshot, run_admin_chat


class FakeLLM:
    def __init__(self, completions):
        self._completions = list(completions)
        self.complete_calls: list[dict] = []

    def complete(self, messages, tools=None):
        self.complete_calls.append({"messages": list(messages), "tools": tools})
        return self._completions.pop(0)


_SNAPSHOT = {
    "generatedAt": "2026-07-07T00:00:00Z",
    "metrics": {"totalUsers": 120, "totalBookings": 45},
    "riskFlags": [{"userId": "u1", "score": 88, "tier": "HIGH"}],
}


def test_answer_uses_snapshot_context() -> None:
    llm = FakeLLM([{"content": "Có 120 người dùng."}])

    result = run_admin_chat(llm, _SNAPSHOT, "Bao nhiêu người dùng?")

    assert result == {"answer": "Có 120 người dùng.", "toolsUsed": []}
    # Snapshot phải được nhồi vào system prompt, KHÔNG gọi tool.
    system = llm.complete_calls[0]["messages"][0]
    assert system["role"] == "system"
    assert "120" in system["content"]
    assert "DỮ LIỆU NỀN TẢNG" in system["content"]
    assert llm.complete_calls[0]["tools"] is None


def test_history_forwarded_between_system_and_user() -> None:
    llm = FakeLLM([{"content": "ok"}])
    history = [{"role": "user", "content": "trước đó"}]

    run_admin_chat(llm, _SNAPSHOT, "câu mới", history)

    roles = [m["role"] for m in llm.complete_calls[0]["messages"]]
    assert roles == ["system", "user", "user"]


def test_missing_snapshot_returns_hint_without_calling_llm() -> None:
    llm = FakeLLM([])  # rỗng: nếu lỡ gọi complete sẽ IndexError

    result = run_admin_chat(llm, None, "gì cũng được")

    assert result["toolsUsed"] == []
    assert "snapshot:admin" in result["answer"]
    assert llm.complete_calls == []


def test_load_snapshot_reads_json(tmp_path) -> None:
    path = tmp_path / "snap.json"
    path.write_text(json.dumps(_SNAPSHOT), encoding="utf-8")

    assert load_snapshot(path) == _SNAPSHOT


def test_load_snapshot_missing_file_returns_none(tmp_path) -> None:
    assert load_snapshot(tmp_path / "nope.json") is None

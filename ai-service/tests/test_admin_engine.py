"""Test engine hỏi-đáp admin: vòng tool-calling với bộ tool admin GIẢ (fake) →
xác định, KHÔNG cần LM Studio hay backend."""

from __future__ import annotations

from app.admin_engine import run_admin_chat
from app.admin_tools import AdminToolClient, dispatch_admin_tool


class FakeLLM:
    def __init__(self, completions):
        self._completions = list(completions)
        self.complete_calls: list[dict] = []

    def complete(self, messages, tools=None):
        self.complete_calls.append({"messages": list(messages), "tools": tools})
        return self._completions.pop(0)


class FakeHttpClient:
    """Giả httpx.Client: trả response cố định cho .get(), ghi lại headers gửi lên."""

    def __init__(self, payload):
        self._payload = payload
        self.last_headers: dict | None = None

    def get(self, path, params=None, headers=None):
        self.last_headers = headers

        class _Resp:
            status_code = 200
            is_error = False

            def json(_self):
                return {"success": True, "data": self._payload}

        return _Resp()


def test_answer_direct_without_tools() -> None:
    llm = FakeLLM([{"content": "Nền tảng có 10 người dùng."}])
    client = AdminToolClient(client=FakeHttpClient({}), auth_token="tok")
    result = run_admin_chat(llm, client, "tổng quan?")
    assert result["answer"] == "Nền tảng có 10 người dùng."
    assert result["toolsUsed"] == []
    assert llm.complete_calls[0]["messages"][0]["role"] == "system"


def test_answer_runs_tool_loop_and_forwards_admin_token() -> None:
    http = FakeHttpClient({"kpi": {"totalUsers": 10}})
    client = AdminToolClient(client=http, auth_token="admin-jwt")
    llm = FakeLLM(
        [
            {
                "content": None,
                "tool_calls": [
                    {"id": "c1", "function": {"name": "get_metrics", "arguments": "{}"}}
                ],
            },
            {"content": "Có 10 người dùng."},
        ]
    )
    result = run_admin_chat(llm, client, "bao nhiêu người dùng?")
    assert result["answer"] == "Có 10 người dùng."
    assert result["toolsUsed"] == ["get_metrics"]
    # token admin của phiên phải được forward xuống API admin.
    assert http.last_headers == {"Authorization": "Bearer admin-jwt"}
    # kết quả tool được nối vào hội thoại cho lần gọi thứ 2.
    assert "tool" in [m["role"] for m in llm.complete_calls[1]["messages"]]


def test_tool_refuses_without_token() -> None:
    # Không token → tool tự từ chối, KHÔNG gọi API admin ẩn danh.
    client = AdminToolClient(client=FakeHttpClient({}), auth_token=None)
    out = dispatch_admin_tool(client, "get_metrics", {})
    assert "error" in out


def test_forces_final_when_rounds_exhausted() -> None:
    tool_call = {
        "content": None,
        "tool_calls": [
            {"id": "c", "function": {"name": "get_metrics", "arguments": "{}"}}
        ],
    }
    llm = FakeLLM([tool_call, {"content": "Câu trả lời cuối."}])
    client = AdminToolClient(client=FakeHttpClient({}), auth_token="tok")
    result = run_admin_chat(llm, client, "?", max_tool_rounds=1)
    assert result["answer"] == "Câu trả lời cuối."
    assert llm.complete_calls[-1]["tools"] is None

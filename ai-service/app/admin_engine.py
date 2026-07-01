"""Engine hỏi-đáp cho ADMIN: vòng tool-calling quanh LLM local, KHÔNG RAG (admin
hỏi dữ liệu sống, không phải kiến thức tĩnh). Tách khỏi ChatEngine người dùng để
prompt + bộ tool của admin độc lập (xem plan admin-enhancement).

ponytail: vòng lặp tool ở đây lặp lại có chủ đích logic của ChatEngine.answer với
bộ tool admin. Giữ riêng để KHÔNG đụng vào đường RAG người dùng đã chạy ổn; nếu sau
này cần thêm engine thứ 3, hãy tách vòng lặp ra hàm dùng chung.
"""

from __future__ import annotations

import json
from typing import Any

from app.admin_tools import ADMIN_TOOL_SPECS, AdminToolClient, dispatch_admin_tool

_DEFAULT_MAX_TOOL_ROUNDS = 4

_SYSTEM_PROMPT = (
    "Bạn là trợ lý phân tích cho ADMIN nền tảng cho thuê xe RideVN. Trả lời bằng "
    "tiếng Việt, ngắn gọn, chính xác, có số liệu.\n"
    "- LUÔN gọi tool phù hợp để lấy số liệu THỰC; TUYỆT ĐỐI không bịa số.\n"
    "- Có thể gọi nhiều tool để trả lời câu hỏi tổng hợp.\n"
    "- Nếu tool trả về lỗi hoặc không đủ dữ liệu, nói rõ hạn chế đó, không suy đoán.\n"
    "- Trình bày tiền tệ theo VND, phần trăm gọn gàng; nêu con số cụ thể khi có."
)


def run_admin_chat(
    llm: Any,
    tool_client: AdminToolClient,
    message: str,
    history: list[dict] | None = None,
    *,
    max_tool_rounds: int = _DEFAULT_MAX_TOOL_ROUNDS,
) -> dict:
    """Chạy vòng tool-calling; trả {"answer": str, "toolsUsed": [str, ...]}."""
    messages: list[dict] = [{"role": "system", "content": _SYSTEM_PROMPT}]
    if history:
        messages.extend(history)
    messages.append({"role": "user", "content": message})

    tools_used: list[str] = []
    for _ in range(max_tool_rounds):
        msg = llm.complete(messages, tools=ADMIN_TOOL_SPECS)
        tool_calls = msg.get("tool_calls")
        if not tool_calls:
            return {"answer": msg.get("content") or "", "toolsUsed": tools_used}
        messages.append(
            {
                "role": "assistant",
                "content": msg.get("content"),
                "tool_calls": tool_calls,
            }
        )
        for tc in tool_calls:
            name = tc["function"]["name"]
            tools_used.append(name)
            args = _parse_args(tc["function"].get("arguments"))
            content = dispatch_admin_tool(tool_client, name, args)
            messages.append(
                {"role": "tool", "tool_call_id": tc.get("id"), "content": content}
            )

    # Hết lượt tool → ép 1 câu trả lời cuối, không cho gọi tool nữa.
    final = llm.complete(messages, tools=None)
    return {"answer": final.get("content") or "", "toolsUsed": tools_used}


def _parse_args(raw: Any) -> dict:
    if isinstance(raw, dict):
        return raw
    if not raw:
        return {}
    try:
        return json.loads(raw)
    except (json.JSONDecodeError, TypeError):
        return {}

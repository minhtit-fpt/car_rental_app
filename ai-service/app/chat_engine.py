"""Chat engine RAG: ghép retrieval (kiến thức tĩnh) + vòng tool-calling (dữ liệu
sống) quanh LLM Qwen local (xem plan B3 + B5).

Luồng:
  1. embed câu hỏi → search corpus → nhét context tĩnh vào system prompt;
  2. gọi LLM kèm TOOL_SPECS → nếu LLM gọi tool thì dispatch (read-only, userId từ
     phiên) rồi đưa kết quả lại LLM; lặp đến khi LLM trả lời hoặc hết lượt;
  3. `answer()` không stream (dễ test); `stream_answer()` stream từng delta.

Phân tách dữ liệu: giá/xe trống/booking KHÔNG nằm trong corpus mà lấy qua tool.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any, Iterator

from app.embedder import Embedder
from app.tools import BackendToolClient, TOOL_SPECS, dispatch_tool
from app.vectorstore import SearchResult, VectorStore

_DEFAULT_MAX_TOOL_ROUNDS = 3
_DEFAULT_TOP_K = 5

_SYSTEM_PROMPT = (
    "Bạn là trợ lý ảo của ứng dụng cho thuê xe RideVN. Trả lời bằng tiếng Việt, "
    "ngắn gọn, chính xác và thân thiện.\n"
    "- Dùng phần 'KIẾN THỨC THAM KHẢO' bên dưới cho câu hỏi về luật, bảo hiểm, thủ "
    "tục, thông số xe. Nếu không có thông tin, nói rõ là chưa chắc, KHÔNG bịa.\n"
    "- Với dữ liệu sống (xe đang trống, giá thuê thực tế, chuyến của người dùng) hãy "
    "GỌI TOOL phù hợp, không tự suy đoán giá hay tình trạng xe.\n"
    "- Tuyệt đối không tiết lộ dữ liệu của người dùng khác."
)


@dataclass(frozen=True)
class ChatResult:
    answer: str
    sources: tuple[str, ...]
    tools_used: tuple[str, ...]


class ChatEngine:
    def __init__(
        self,
        *,
        embedder: Embedder,
        store: VectorStore,
        llm: Any,  # LMStudioChat hoặc tương đương (complete/stream_complete).
        tool_client: BackendToolClient | Any,
        top_k: int = _DEFAULT_TOP_K,
        max_tool_rounds: int = _DEFAULT_MAX_TOOL_ROUNDS,
        system_prompt: str = _SYSTEM_PROMPT,
    ) -> None:
        self._embedder = embedder
        self._store = store
        self._llm = llm
        self._tool_client = tool_client
        self._top_k = top_k
        self._max_tool_rounds = max_tool_rounds
        self._system_prompt = system_prompt

    # ---- retrieval ----
    def _retrieve(self, query: str) -> list[SearchResult]:
        query_vec = self._embedder.embed_query(query)
        return self._store.search(query_vec, top_k=self._top_k)

    def _build_messages(self, query: str, history: list[dict] | None, results: list[SearchResult]) -> list[dict]:
        context = "\n\n".join(f"[{r.chunk.title}]\n{r.chunk.text}" for r in results)
        system = self._system_prompt
        if context:
            system = f"{system}\n\n=== KIẾN THỨC THAM KHẢO ===\n{context}"
        messages: list[dict] = [{"role": "system", "content": system}]
        if history:
            messages.extend(history)
        messages.append({"role": "user", "content": query})
        return messages

    # ---- tool dispatch dùng chung ----
    def _run_tool_calls(self, messages: list[dict], assistant_content: Any, tool_calls: list[dict]) -> list[str]:
        messages.append({"role": "assistant", "content": assistant_content, "tool_calls": tool_calls})
        used: list[str] = []
        for tc in tool_calls:
            name = tc["function"]["name"]
            used.append(name)
            args = _parse_args(tc["function"].get("arguments"))
            content = dispatch_tool(self._tool_client, name, args)
            messages.append({"role": "tool", "tool_call_id": tc.get("id"), "content": content})
        return used

    # ---- non-streaming ----
    def answer(self, query: str, history: list[dict] | None = None) -> ChatResult:
        results = self._retrieve(query)
        sources = tuple(r.chunk.title for r in results)
        messages = self._build_messages(query, history, results)
        tools_used: list[str] = []

        for _ in range(self._max_tool_rounds):
            msg = self._llm.complete(messages, tools=TOOL_SPECS)
            tool_calls = msg.get("tool_calls")
            if not tool_calls:
                return ChatResult(answer=msg.get("content") or "", sources=sources, tools_used=tuple(tools_used))
            tools_used.extend(self._run_tool_calls(messages, msg.get("content"), tool_calls))

        # Hết lượt tool → ép 1 câu trả lời cuối, không cho gọi tool nữa.
        final = self._llm.complete(messages, tools=None)
        return ChatResult(answer=final.get("content") or "", sources=sources, tools_used=tuple(tools_used))

    # ---- streaming ----
    def stream_answer(self, query: str, history: list[dict] | None = None) -> Iterator[str]:
        results = self._retrieve(query)
        messages = self._build_messages(query, history, results)

        for _ in range(self._max_tool_rounds):
            collected: list[str] = []
            tool_calls: list[dict] | None = None
            for kind, payload in self._llm.stream_complete(messages, tools=TOOL_SPECS):
                if kind == "content":
                    collected.append(payload)
                    yield payload
                else:  # "tool_calls" — sự kiện cuối của mỗi lượt stream
                    tool_calls = payload
            if not tool_calls:
                return  # LLM đã trả lời trực tiếp (đã stream ở trên)
            self._run_tool_calls(messages, "".join(collected) or None, tool_calls)

        # Hết lượt tool → stream câu trả lời cuối, không kèm tools.
        for kind, payload in self._llm.stream_complete(messages, tools=None):
            if kind == "content":
                yield payload


def _parse_args(raw: Any) -> dict:
    if isinstance(raw, dict):
        return raw
    if not raw:
        return {}
    try:
        return json.loads(raw)
    except (json.JSONDecodeError, TypeError):
        return {}

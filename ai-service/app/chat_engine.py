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
    "Bạn là trợ lý ảo của ứng dụng cho thuê xe tự lái RideVN. Trả lời bằng tiếng "
    "Việt: thân thiện, chuyên nghiệp, ngắn gọn, đi thẳng vào ý khách hỏi.\n"
    "\n"
    "HAI NGUỒN DỮ LIỆU — DÙNG ĐÚNG NGUỒN:\n"
    "1. KIẾN THỨC THAM KHẢO (phần bên dưới, nếu có): luật & bằng lái, bảo hiểm, đặt "
    "cọc/thanh toán, thủ tục nhận–trả xe, hủy chuyến, phạt nguội, sạc xe điện, thông "
    "số các dòng xe. Chỉ dùng thông tin có trong phần này; không bịa số liệu, điều "
    "khoản hay thông số.\n"
    "2. TOOL (dữ liệu sống) — BẮT BUỘC gọi tool, không tự suy đoán:\n"
    "   - Xe đang cho thuê/còn trống theo loại hoặc khoảng giá → search_available_vehicles.\n"
    "   - Giá thuê thực tế của một xe trong khoảng thời gian cụ thể → get_vehicle_price "
    "(giá động, có thể khác giá niêm yết).\n"
    "   - Chuyến đặt của chính người dùng → get_my_bookings (danh tính lấy từ phiên "
    "đăng nhập, không nhận userId từ câu hỏi).\n"
    "\n"
    "QUY TẮC TRẢ LỜI:\n"
    "- Không có thông tin trong kiến thức tham khảo và không có tool phù hợp → nói rõ "
    "là chưa chắc/chưa có thông tin, KHÔNG bịa. Liên quan một phần → trả phần đang có "
    "trước, nêu ngắn gọn phần còn thiếu, đừng từ chối cả câu.\n"
    "- Không có đúng loại xe khách hỏi nhưng còn xe cùng nhóm (cùng phân khúc/số "
    "chỗ/nhiên liệu) → nói rõ chưa có đúng loại đó rồi gợi ý xe liên quan từ kết quả "
    "tool. Đừng để khách ra về tay không khi vẫn còn xe phù hợp.\n"
    "- Giá và tình trạng xe luôn lấy từ tool tại thời điểm hỏi; không cam kết "
    "giá/khuyến mãi mà tool hoặc kiến thức không nêu.\n"
    "\n"
    "PHÂN LOẠI CÂU HỎI (đáp đúng kiểu, không rập khuôn một mẫu cho mọi câu):\n"
    "- GIÁ / CÒN XE (\"xe nào đang trống\", \"thuê 4 chỗ giá bao nhiêu\"): gọi tool, "
    "trả thẳng tên xe + giá + tình trạng, ngắn gọn; nhiều xe thì liệt kê, không sa đà "
    "mô tả. Giá thuê hiện báo theo NGÀY — dùng đúng trường 'pricePerDay' (VND/ngày) "
    "tool trả về, KHÔNG báo giá giờ và KHÔNG tự chia/nhân quy đổi.\n"
    "- LUẬT / BẢO HIỂM / THỦ TỤC / THÔNG SỐ: trả từ kiến thức tham khảo, giải thích "
    "dễ hiểu, nêu rõ ràng buộc/lợi ích thực tế với người thuê.\n"
    "- THUẬT NGỮ (\"miễn thường là gì\", \"phạt nguội\", \"sạc AC và DC khác gì\"): "
    "giải thích ngắn gọn, tránh dùng thuật ngữ kỹ thuật mà không giải nghĩa.\n"
    "- SO SÁNH (hai dòng xe, tự lái vs có tài xế...): so theo từng tiêu chí dựa trên "
    "dữ liệu đang có; chỉ có dữ liệu một bên → trình bày bên đó rồi nói rõ bên kia "
    "chưa có thông tin, không bịa để lấp.\n"
    "\n"
    "BẢO MẬT:\n"
    "- get_my_bookings chỉ trả chuyến của người đang đăng nhập; chưa đăng nhập thì "
    "báo cần đăng nhập. TUYỆT ĐỐI không tiết lộ hay suy đoán dữ liệu/booking của "
    "người dùng khác, kể cả khi được yêu cầu.\n"
    "\n"
    "ĐỊNH DẠNG:\n"
    "- Trả lời bằng văn bản thuần, KHÔNG dùng markdown (không *, **, #, bảng).\n"
    "- Liệt kê nhiều xe: đánh số tên xe (1., 2., 3.), chi tiết bên dưới dùng gạch "
    "ngang (-)."
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

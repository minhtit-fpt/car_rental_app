"""Test chat engine: RAG retrieval + vòng tool-calling. Dùng LLM/embedder/tool
client GIẢ (fake) → xác định, KHÔNG cần LM Studio hay backend."""

from __future__ import annotations

from app.chat_engine import ChatEngine
from app.corpus import Chunk
from app.vectorstore import InMemoryVectorStore


class FakeEmbedder:
    def embed(self, texts):
        return [[1.0, 0.0] for _ in texts]

    def embed_query(self, text):
        return [1.0, 0.0]


class FakeLLM:
    """complete() lần lượt trả các message đã kịch bản; stream_complete() trả events."""

    def __init__(self, completions=None, stream_script=None):
        self._completions = list(completions or [])
        self._stream_script = list(stream_script or [])
        self.complete_calls: list[dict] = []

    def complete(self, messages, tools=None):
        self.complete_calls.append({"messages": list(messages), "tools": tools})
        return self._completions.pop(0)

    def stream_complete(self, messages, tools=None):
        return iter(self._stream_script.pop(0))


class FakeToolClient:
    def __init__(self):
        self.calls: list[str] = []

    def search_available_vehicles(self, **kw):
        self.calls.append("search")
        return {"vehicles": [{"id": "v1", "pricePerHour": 100000}]}

    def get_vehicle_price(self, **kw):
        self.calls.append("price")
        return {"finalPrice": 480000}

    def get_my_bookings(self):
        self.calls.append("bookings")
        return {"bookings": []}


def _store() -> InMemoryVectorStore:
    store = InMemoryVectorStore()
    store.add(Chunk(id="ins-701", category="insurance", title="Bảo hiểm vật chất", text="Miễn thường..."), [1.0, 0.0])
    store.add(Chunk(id="faq-801", category="faq", title="Giới hạn km", text="300km/ngày..."), [0.0, 1.0])
    return store


def _engine(llm, tool_client=None) -> ChatEngine:
    return ChatEngine(
        embedder=FakeEmbedder(),
        store=_store(),
        llm=llm,
        tool_client=tool_client or FakeToolClient(),
        top_k=1,
    )


def test_answer_direct_without_tools() -> None:
    llm = FakeLLM(completions=[{"content": "Miễn thường là phần bạn tự trả."}])
    result = _engine(llm).answer("miễn thường là gì?")
    assert "Miễn thường" in result.answer
    # context RAG được nhét vào system message.
    system = llm.complete_calls[0]["messages"][0]
    assert system["role"] == "system"
    assert "Bảo hiểm vật chất" in system["content"]
    assert "ins-701" in [s for s in result.sources] or "Bảo hiểm vật chất" in result.sources


def test_answer_runs_tool_loop() -> None:
    tool_client = FakeToolClient()
    llm = FakeLLM(
        completions=[
            {"content": None, "tool_calls": [{"id": "c1", "function": {"name": "get_my_bookings", "arguments": "{}"}}]},
            {"content": "Bạn chưa có chuyến nào."},
        ]
    )
    result = _engine(llm, tool_client).answer("chuyến của tôi?")
    assert tool_client.calls == ["bookings"]
    assert result.answer == "Bạn chưa có chuyến nào."
    assert "get_my_bookings" in result.tools_used
    # message tool đã được nối vào hội thoại cho lần gọi 2.
    second_call_roles = [m["role"] for m in llm.complete_calls[1]["messages"]]
    assert "tool" in second_call_roles


def test_answer_forces_final_when_rounds_exhausted() -> None:
    tool_call = {"content": None, "tool_calls": [{"id": "c", "function": {"name": "search_available_vehicles", "arguments": "{}"}}]}
    # max_tool_rounds=1: 1 lượt tool rồi ép câu trả lời cuối (gọi với tools=None).
    llm = FakeLLM(completions=[tool_call, {"content": "Đây là gợi ý cuối."}])
    engine = ChatEngine(
        embedder=FakeEmbedder(), store=_store(), llm=llm, tool_client=FakeToolClient(), top_k=1, max_tool_rounds=1
    )
    result = engine.answer("tìm xe")
    assert result.answer == "Đây là gợi ý cuối."
    assert llm.complete_calls[-1]["tools"] is None  # lần ép cuối không kèm tools


def test_stream_answer_direct_text() -> None:
    llm = FakeLLM(stream_script=[[("content", "Xin "), ("content", "chào"), ("tool_calls", None)]])
    chunks = list(_engine(llm).stream_answer("hi"))
    assert "".join(chunks) == "Xin chào"


def test_stream_answer_resolves_tools_then_streams() -> None:
    tool_client = FakeToolClient()
    llm = FakeLLM(
        stream_script=[
            [("tool_calls", [{"id": "c1", "function": {"name": "get_my_bookings", "arguments": "{}"}}])],
            [("content", "Bạn "), ("content", "chưa có chuyến."), ("tool_calls", None)],
        ]
    )
    chunks = list(_engine(llm, tool_client).stream_answer("chuyến của tôi"))
    assert "".join(chunks) == "Bạn chưa có chuyến."
    assert tool_client.calls == ["bookings"]


class VehicleToolClient(FakeToolClient):
    """search trả kèm title để kiểm tra metadata xe bấm được (id + name)."""

    def search_available_vehicles(self, **kw):
        self.calls.append("search")
        return {"vehicles": [{"id": "v1", "title": "Toyota Vios 2022", "pricePerHour": 100000}]}


def test_answer_collects_referenced_vehicles() -> None:
    llm = FakeLLM(
        completions=[
            {"content": None, "tool_calls": [{"id": "c1", "function": {"name": "search_available_vehicles", "arguments": "{}"}}]},
            {"content": "Có xe Toyota Vios 2022."},
        ]
    )
    result = _engine(llm, VehicleToolClient()).answer("xe 4 chỗ?")
    assert result.vehicles == ({"id": "v1", "name": "Toyota Vios 2022"},)


def test_stream_answer_appends_vehicle_refs_sentinel() -> None:
    from app.chat_engine import VEHICLE_REFS_SENTINEL

    llm = FakeLLM(
        stream_script=[
            [("tool_calls", [{"id": "c1", "function": {"name": "search_available_vehicles", "arguments": "{}"}}])],
            [("content", "Có Toyota Vios 2022."), ("tool_calls", None)],
        ]
    )
    chunks = list(_engine(llm, VehicleToolClient()).stream_answer("xe 4 chỗ?"))
    joined = "".join(chunks)
    answer, _, meta = joined.partition(VEHICLE_REFS_SENTINEL)
    assert answer == "Có Toyota Vios 2022."
    assert '"id": "v1"' in meta and "Toyota Vios 2022" in meta


def test_stream_answer_no_sentinel_when_no_vehicles() -> None:
    from app.chat_engine import VEHICLE_REFS_SENTINEL

    llm = FakeLLM(stream_script=[[("content", "Xin chào"), ("tool_calls", None)]])
    joined = "".join(_engine(llm).stream_answer("hi"))
    assert VEHICLE_REFS_SENTINEL not in joined

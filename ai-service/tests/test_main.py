"""Test endpoint FastAPI /chat — TestClient + components GIẢ (fake LLM/embedder/
store). KHÔNG cần LM Studio. Tool path đã test ở test_chat_engine."""

from __future__ import annotations

from fastapi.testclient import TestClient

from app.corpus import Chunk
from app.main import ChatComponents, create_app, get_components
from app.vectorstore import InMemoryVectorStore


class FakeEmbedder:
    def embed(self, texts):
        return [[1.0, 0.0] for _ in texts]

    def embed_query(self, text):
        return [1.0, 0.0]


class FakeLLM:
    def __init__(self, *, content="Câu trả lời mẫu", deltas=("Câu ", "trả lời")):
        self._content = content
        self._deltas = deltas

    def complete(self, messages, tools=None):
        return {"content": self._content}

    def stream_complete(self, messages, tools=None):
        for d in self._deltas:
            yield ("content", d)
        yield ("tool_calls", None)


def _components(llm=None) -> ChatComponents:
    store = InMemoryVectorStore()
    store.add(Chunk(id="faq-801", category="faq", title="Giới hạn km", text="300km/ngày"), [1.0, 0.0])
    return ChatComponents(embedder=FakeEmbedder(), store=store, llm=llm or FakeLLM())


def _client(components: ChatComponents | None = None) -> TestClient:
    app = create_app()
    if components is not None:
        app.dependency_overrides[get_components] = lambda: components
    return TestClient(app)


def test_health_ok() -> None:
    resp = _client().get("/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


def test_chat_non_stream_returns_answer_and_sources() -> None:
    resp = _client(_components()).post("/chat", json={"message": "giới hạn km?", "stream": False})
    assert resp.status_code == 200
    body = resp.json()
    assert body["success"] is True
    assert body["data"]["answer"] == "Câu trả lời mẫu"
    assert "Giới hạn km" in body["data"]["sources"]


def test_chat_stream_returns_concatenated_text() -> None:
    resp = _client(_components()).post("/chat", json={"message": "hi", "stream": True})
    assert resp.status_code == 200
    assert resp.text == "Câu trả lời"


def test_chat_accepts_bearer_token_header() -> None:
    resp = _client(_components()).post(
        "/chat",
        json={"message": "hi", "stream": False},
        headers={"Authorization": "Bearer jwt-xyz"},
    )
    assert resp.status_code == 200


def test_chat_returns_503_when_components_not_ready() -> None:
    # Không override get_components → app.state chưa có (LM Studio/index chưa nạp).
    resp = _client().post("/chat", json={"message": "hi", "stream": False})
    assert resp.status_code == 503


def test_chat_validates_empty_message() -> None:
    resp = _client(_components()).post("/chat", json={"message": "  ", "stream": False})
    assert resp.status_code == 422

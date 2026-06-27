"""FastAPI service cho chatbot RAG (plan B6).

Endpoint:
  GET  /health  → kiểm tra sống + index đã nạp chưa.
  POST /chat    → hỏi đáp; `stream=true` (mặc định) trả text/plain streaming để
                  giảm cảm giác chậm (nút thắt là LLM local, không phải search).

Bảo mật: token người dùng lấy từ header `Authorization: Bearer ...` rồi tiêm vào
BackendToolClient — userId KHÔNG bao giờ đến từ LLM (xem plan Risk HIGH).

Khởi động: thử dựng index từ corpus qua LM Studio. Nếu LM Studio chưa chạy thì
service vẫn lên nhưng /chat trả 503 cho tới khi index sẵn sàng.
"""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from dataclasses import dataclass
from typing import Any

from fastapi import Depends, FastAPI, Header, HTTPException, Request
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field, field_validator

from app.chat_engine import ChatEngine
from app.config import get_settings
from app.embedder import Embedder
from app.tools import BackendToolClient
from app.vectorstore import VectorStore

logger = logging.getLogger("ai-service")


@dataclass
class ChatComponents:
    """Thành phần dùng chung toàn app (nặng) — dựng 1 lần lúc khởi động."""

    embedder: Embedder
    store: VectorStore
    llm: Any


class ChatRequest(BaseModel):
    message: str = Field(min_length=1)
    history: list[dict] = Field(default_factory=list)
    stream: bool = True

    @field_validator("message")
    @classmethod
    def _not_blank(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("message không được rỗng")
        return v

    def normalized_message(self) -> str:
        return self.message.strip()


def get_components(request: Request) -> ChatComponents:
    components = getattr(request.app.state, "components", None)
    if components is None:
        raise HTTPException(
            status_code=503,
            detail="AI service chưa sẵn sàng: chưa nạp được index (kiểm tra LM Studio).",
        )
    return components


def _extract_bearer(authorization: str | None) -> str | None:
    if authorization and authorization.lower().startswith("bearer "):
        return authorization[len("bearer ") :].strip() or None
    return None


@asynccontextmanager
async def _lifespan(app: FastAPI):
    # Dựng index lúc khởi động (cần LM Studio). Lỗi → để None, /chat trả 503.
    try:
        from app.embedder import LMStudioEmbedder
        from app.index import build_index
        from app.corpus import load_corpus
        from app.llm import LMStudioChat

        settings = get_settings()
        embedder = LMStudioEmbedder.from_settings(settings)
        store = build_index(load_corpus(settings.corpus_path), embedder)
        app.state.components = ChatComponents(
            embedder=embedder, store=store, llm=LMStudioChat.from_settings(settings)
        )
        logger.info("Index nạp xong: %d chunk", len(store))  # type: ignore[arg-type]
    except Exception as err:  # noqa: BLE001 — khởi động không được làm sập service.
        app.state.components = None
        logger.warning("Chưa nạp được index (LM Studio?): %s", err)
    yield


def create_app() -> FastAPI:
    app = FastAPI(title="RideVN AI Chatbot", lifespan=_lifespan)

    @app.get("/health")
    def health(request: Request) -> dict:
        ready = getattr(request.app.state, "components", None) is not None
        return {"status": "ok", "indexReady": ready}

    @app.post("/chat")
    def chat(
        body: ChatRequest,
        components: ChatComponents = Depends(get_components),
        authorization: str | None = Header(default=None),
    ):
        token = _extract_bearer(authorization)
        tool_client = BackendToolClient.from_settings(auth_token=token)
        engine = ChatEngine(
            embedder=components.embedder,
            store=components.store,
            llm=components.llm,
            tool_client=tool_client,
        )
        message = body.normalized_message()
        if body.stream:
            return StreamingResponse(
                engine.stream_answer(message, body.history),
                media_type="text/plain; charset=utf-8",
            )
        result = engine.answer(message, body.history)
        return {
            "success": True,
            "data": {
                "answer": result.answer,
                "sources": list(result.sources),
                "toolsUsed": list(result.tools_used),
            },
        }

    return app


app = create_app()

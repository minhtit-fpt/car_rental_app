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

import httpx
from fastapi import Depends, FastAPI, Header, HTTPException, Request
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field, field_validator

from app.admin_engine import load_snapshot, run_admin_chat
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


class Msg(BaseModel):
    role: str = Field(min_length=1)
    content: str


class CompleteRequest(BaseModel):
    """Hoàn thành 1 lượt chat có cấu trúc (không RAG, không stream) — dùng cho các
    tính năng admin ở backend Next.js (trợ lý tranh chấp, giải thích rủi ro).
    Backend đã gom facts + soạn prompt; service chỉ lo gọi LM Studio."""

    messages: list[Msg] = Field(min_length=1)


class AdminChatRequest(BaseModel):
    """Hỏi-đáp phân tích của admin. Engine đọc snapshot JSON (backend xuất) làm
    ngữ cảnh — KHÔNG tool-calling, KHÔNG chạm DB (yêu cầu đề bài)."""

    message: str = Field(min_length=1)
    history: list[dict] = Field(default_factory=list)

    @field_validator("message")
    @classmethod
    def _not_blank(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("message không được rỗng")
        return v


def get_components(request: Request) -> ChatComponents:
    components = getattr(request.app.state, "components", None)
    if components is None:
        raise HTTPException(
            status_code=503,
            detail="AI service chưa sẵn sàng: chưa nạp được index (kiểm tra LM Studio).",
        )
    return components


def get_llm(request: Request) -> Any:
    """LLM chat client — độc lập với RAG index (admin không cần index)."""
    llm = getattr(request.app.state, "llm", None)
    if llm is None:
        raise HTTPException(
            status_code=503,
            detail="AI service chưa sẵn sàng: chưa dựng được LLM client.",
        )
    return llm


def _extract_bearer(authorization: str | None) -> str | None:
    if authorization and authorization.lower().startswith("bearer "):
        return authorization[len("bearer ") :].strip() or None
    return None


@asynccontextmanager
async def _lifespan(app: FastAPI):
    # Tải index lúc khởi động: từ cache nếu có, không thì build (cần LM Studio).
    # Lỗi → để None, /chat trả 503.
    try:
        from app.embedder import LMStudioEmbedder
        from app.index import build_default_index
        from app.llm import LMStudioChat

        settings = get_settings()
        # LLM client chỉ dựng httpx client (không gọi mạng) → set độc lập để
        # endpoint admin dùng được kể cả khi build index lỗi.
        app.state.llm = LMStudioChat.from_settings(settings)
        store = build_default_index(use_cache=True)
        embedder = LMStudioEmbedder.from_settings(settings)
        app.state.components = ChatComponents(
            embedder=embedder, store=store, llm=app.state.llm
        )
        logger.info("Index nạp xong: %d chunk", len(store))  # type: ignore[arg-type]
    except Exception as err:  # noqa: BLE001 — khởi động không được làm sập service.
        app.state.components = None
        app.state.llm = getattr(app.state, "llm", None)
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
                "vehicles": list(result.vehicles),
            },
        }

    # ponytail: endpoint nội bộ (backend Next.js gọi server-to-server trên
    # localhost). Cùng mức tin cậy với /chat (vốn cũng không auth). Nâng cấp:
    # thêm shared-secret header nếu deploy tách máy.
    @app.post("/admin/complete")
    def admin_complete(
        body: CompleteRequest,
        llm: Any = Depends(get_llm),
    ) -> dict:
        messages = [m.model_dump() for m in body.messages]
        try:
            msg = llm.complete(messages)
        except httpx.HTTPError as err:
            # LM Studio offline / lỗi mạng → 503 để backend fallback "chưa phân tích".
            raise HTTPException(
                status_code=503, detail="LM Studio không phản hồi."
            ) from err
        return {"success": True, "data": {"content": msg.get("content") or ""}}

    # ponytail: cùng mức tin cậy nội bộ với /admin/complete (backend gọi trên
    # localhost). Chatbot admin ĐỌC snapshot JSON (backend xuất) làm ngữ cảnh —
    # KHÔNG tool-calling vào DB (yêu cầu đề bài). Đọc file mỗi request để luôn
    # lấy snapshot mới nhất; file nhỏ nên chi phí không đáng kể.
    @app.post("/admin/chat")
    def admin_chat(
        body: AdminChatRequest,
        llm: Any = Depends(get_llm),
    ) -> dict:
        snapshot = load_snapshot(get_settings().admin_snapshot_path)
        try:
            result = run_admin_chat(llm, snapshot, body.message.strip(), body.history)
        except httpx.HTTPError as err:
            raise HTTPException(
                status_code=503, detail="LM Studio không phản hồi."
            ) from err
        return {
            "success": True,
            "data": {"answer": result["answer"], "toolsUsed": result["toolsUsed"]},
        }

    return app


app = create_app()

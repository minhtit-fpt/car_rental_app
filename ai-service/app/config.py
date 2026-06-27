"""Cấu hình service RAG. Tất cả điểm cắm model local qua LM Studio đều ở đây.

LM Studio expose API tương thích OpenAI tại http://localhost:1234/v1.
Đổi model = đổi env, KHÔNG hardcode trong code nghiệp vụ.

Bất biến quan trọng: đổi EMBEDDING_MODEL → BẮT BUỘC rebuild index
(không gian vector thay đổi). Xem README.
"""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

# ai-service/app/config.py -> thư mục ai-service là 1 cấp lên.
_SERVICE_ROOT = Path(__file__).resolve().parents[1]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="RAG_", env_file=".env")

    # LM Studio (OpenAI-compatible). LM Studio không cần key thật nhưng client
    # OpenAI yêu cầu 1 chuỗi bất kỳ.
    lmstudio_base_url: str = "http://localhost:1234/v1"
    lmstudio_api_key: str = "lm-studio"

    # Model local — đặt đúng tên đã tải trong LM Studio.
    embedding_model: str = "text-embedding-bge-m3"
    chat_model: str = "qwen2.5-14b-instruct"

    # Đường dẫn corpus (JSONL) — đặt trong service để self-contained + version-control.
    corpus_path: Path = _SERVICE_ROOT / "data" / "corpus_vi.jsonl"

    # Backend Next.js để tool-calling truy vấn dữ liệu sống (xe trống, giá, booking).
    backend_base_url: str = "http://localhost:3000"

    top_k: int = 5


@lru_cache
def get_settings() -> Settings:
    return Settings()

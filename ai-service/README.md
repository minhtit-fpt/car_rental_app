# ai-service — Chatbot RAG về xe (local LLM)

Service Python dựng mới cho **Workstream B** (plan: `.claude/ai-standout-features-plan.md`).
Chạy LLM/embedding/VLM **local** qua **LM Studio** (OpenAI-compatible `localhost:1234/v1`).

## Kiến trúc (đã chốt)
- **RAG in-memory cosine** cho corpus tĩnh nhỏ (~60–200 chunk) → không cần vector DB.
- Tách sau interface `VectorStore` → sau này cắm `PgVectorStore` (pgvector) không sửa chat engine.
- Phân tách dữ liệu: **tĩnh** (luật, bảo hiểm, thủ tục, thông số) trong corpus;
  **động** (giá, xe trống, booking) qua **tool-calling** vào backend Next.js.
- Giá xe **LẤY TỪ DB** (qua tool-calling → `GET /api/vehicles/:id/price-quote`,
  đã có ở Workstream C), KHÔNG nhúng vào RAG.

## Model local (đặt tên khớp LM Studio, cấu hình qua env `RAG_*`)
| Việc | Model | Endpoint |
|---|---|---|
| Embedding | bge-m3 | `/v1/embeddings` |
| LLM chat | Qwen2.5-14B-Instruct (7B nếu cần nhanh) | `/v1/chat/completions` |

## Cấu trúc
```
ai-service/
├── app/
│   ├── config.py       # settings RAG_* (LM Studio URL, model, corpus path)
│   ├── corpus.py       # Chunk + load_corpus(JSONL)
│   ├── vectorstore.py  # VectorStore interface + InMemoryVectorStore (cosine)
│   ├── embedder.py     # [TODO B2] client LM Studio /v1/embeddings (bge-m3)
│   ├── chat_engine.py  # [TODO B3/B5] Qwen + vòng tool-calling
│   └── main.py         # [TODO B6] FastAPI: POST /chat (streaming)
└── tests/              # pytest pure-Python (không cần LM Studio)
```

## Chạy
```bash
cd ai-service
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python3 -m pytest tests/ -q          # test pure-Python (không cần LM Studio)
# uvicorn app.main:app --reload      # [TODO B6]
```

## Trạng thái plan B
- [x] **B1** — interface `VectorStore` + `InMemoryVectorStore` (cosine, pure Python, đã test)
- [x] **B4 (phần loader)** — `load_corpus` đọc `.claude/rag/car_rag_corpus_vi.jsonl` (21 chunk)
- [ ] **B4 (mở rộng)** — nâng corpus lên 60–100 chunk, thêm `keywords` (cách user hay hỏi)
- [ ] **B2** — `embedder.py` gọi LM Studio bge-m3 (⚠ đổi embedding → BẮT BUỘC rebuild index)
- [ ] **B3** — `chat_engine.py` Qwen qua `/v1/chat/completions` (format OpenAI messages)
- [ ] **B5** — tool-calling vào DB: `search_available_vehicles`, `get_vehicle_price`,
      `get_my_bookings`. Bảo mật: `userId` lấy từ phiên auth, KHÔNG để LLM tự bịa.
- [ ] **B6** — FastAPI `POST /chat` + streaming; giữ contract cũ để FE Flutter gọi.

## Phụ thuộc ngoài (Workstream A — việc thủ công)
Cần LM Studio chạy + đã tải `bge-m3`, `qwen2.5-14b-instruct`, bật headless server
trước khi build index / chạy chat.

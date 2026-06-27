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
│   ├── embedder.py     # B2: client LM Studio /v1/embeddings (bge-m3)
│   ├── index.py        # B2: build_index(corpus → embedding → store)
│   ├── tools.py        # B5: tool-calling read-only vào backend Next.js
│   ├── llm.py          # B3: client Qwen /v1/chat/completions (+ SSE stream)
│   ├── chat_engine.py  # B3/B5: RAG retrieval + vòng tool-calling
│   └── main.py         # B6: FastAPI POST /chat (streaming) + GET /health
├── data/
│   └── corpus_vi.jsonl # B4: corpus tri thức tĩnh (62 chunk, có keywords)
└── tests/              # pytest mock httpx (không cần LM Studio)
```

## Chạy
```bash
cd ai-service
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python3 -m pytest tests/ -q          # 35 test mock httpx (không cần LM Studio)

# Khi đã bật LM Studio (Workstream A) + backend Next.js:
python3 -m app.index                 # build index từ corpus qua bge-m3
uvicorn app.main:app --reload --port 8001
# POST /chat  {"message": "...", "history": [], "stream": true}
#   header tùy chọn: Authorization: Bearer <jwt>  (cho get_my_bookings)
```

## Trạng thái plan B
- [x] **B1** — interface `VectorStore` + `InMemoryVectorStore` (cosine, pure Python, đã test)
- [x] **B4** — corpus `data/corpus_vi.jsonl` **62 chunk** + `keywords`; categories: thông số
      dòng xe, nhận/trả xe, hủy theo bậc, phạt nguội, sạc EV, giao xe, bảo hiểm, FAQ.
- [x] **B2** — `embedder.py` gọi LM Studio bge-m3 + `index.py` build index
      (⚠ đổi embedding model → BẮT BUỘC rebuild index).
- [x] **B3** — `llm.py` (Qwen `/v1/chat/completions`, non-stream + SSE) + `chat_engine.py`
      (RAG retrieval + vòng tool-calling, format OpenAI messages).
- [x] **B5** — `tools.py`: `search_available_vehicles`, `get_vehicle_price` (qua endpoint
      dynamic pricing của C), `get_my_bookings`. Bảo mật: `userId` lấy từ token phiên,
      LLM KHÔNG truyền được userId (đã có test chống lộ dữ liệu).
- [x] **B6** — FastAPI `POST /chat` (+ streaming) & `GET /health`.

> Tất cả code B2–B6 đã viết + unit test (mock httpx). Việc còn lại thuần vận hành
> (Workstream A): bật LM Studio + tải `bge-m3`/`qwen2.5-14b-instruct`, rồi build index
> và chạy thật. Tùy chọn nâng cao: rerank `bge-reranker`, mở corpus 60→100, Qwen 7B cho tốc độ.

## Phụ thuộc ngoài (Workstream A — việc thủ công)
Cần LM Studio chạy + đã tải `bge-m3`, `qwen2.5-14b-instruct`, bật headless server
trước khi build index / chạy chat.

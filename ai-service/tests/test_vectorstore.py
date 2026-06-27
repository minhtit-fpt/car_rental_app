"""Test pure-Python cho retriever in-memory — chạy không cần LM Studio."""

from app.corpus import Chunk, load_corpus
from app.vectorstore import InMemoryVectorStore, _cosine


def _chunk(cid: str, category: str = "policy") -> Chunk:
    return Chunk(id=cid, category=category, title=cid, text=f"text {cid}")


def test_cosine_orthogonal_is_zero() -> None:
    assert _cosine([1, 0, 0], [0, 1, 0]) == 0.0


def test_cosine_identical_is_one() -> None:
    assert _cosine([1, 2, 3], [1, 2, 3]) == 1.0


def test_search_ranks_by_similarity() -> None:
    store = InMemoryVectorStore()
    store.add(_chunk("near"), [1.0, 0.0])
    store.add(_chunk("far"), [0.0, 1.0])
    results = store.search([0.9, 0.1], top_k=2)
    assert [r.chunk.id for r in results] == ["near", "far"]
    assert results[0].score > results[1].score


def test_search_respects_top_k() -> None:
    store = InMemoryVectorStore()
    for i in range(5):
        store.add(_chunk(f"c{i}"), [float(i), 1.0])
    assert len(store.search([1.0, 1.0], top_k=3)) == 3


def test_search_filters_by_category() -> None:
    store = InMemoryVectorStore()
    store.add(_chunk("a", category="insurance"), [1.0, 0.0])
    store.add(_chunk("b", category="policy"), [1.0, 0.0])
    results = store.search([1.0, 0.0], top_k=5, category="insurance")
    assert [r.chunk.id for r in results] == ["a"]


def test_load_real_corpus() -> None:
    from app.config import get_settings

    chunks = load_corpus(get_settings().corpus_path)
    assert len(chunks) >= 20
    assert all(c.id and c.text for c in chunks)
    # embedding_text gộp title + text.
    assert chunks[0].title in chunks[0].embedding_text()

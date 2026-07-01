"""Test tool-calling vào backend Next.js — mock bằng httpx.MockTransport.

Trọng tâm bảo mật (plan B5 + Risk HIGH): chatbot CHỈ đọc; `userId` LẤY TỪ phiên
auth (token), KHÔNG để LLM tự bịa. get_my_bookings phải bỏ qua mọi userId do LLM
truyền và dùng token đã tiêm.
"""

from __future__ import annotations

import json

import httpx
import pytest

from app.tools import BackendToolClient, TOOL_SPECS, dispatch_tool


def _client(handler, *, auth_token: str | None = None) -> BackendToolClient:
    http = httpx.Client(base_url="http://backend", transport=httpx.MockTransport(handler))
    return BackendToolClient(client=http, auth_token=auth_token)


def test_search_available_vehicles_builds_query_and_unwraps_data() -> None:
    seen: dict = {}

    def handler(req: httpx.Request) -> httpx.Response:
        seen["path"] = req.url.path
        seen["params"] = dict(req.url.params)
        # Shape thật của /api/vehicles: data = {items, total} (xem vehicleService.list).
        return httpx.Response(
            200,
            json={"success": True, "data": {"items": [{"id": "v1", "pricePerHour": 80000}], "total": 1}},
        )

    out = _client(handler).search_available_vehicles(vehicle_type="CAR", max_price=200000, limit=5)
    assert seen["path"] == "/api/vehicles"
    assert seen["params"]["type"] == "CAR"
    assert seen["params"]["maxPrice"] == "200000"
    assert seen["params"]["limit"] == "5"
    # Tool bóc `items` ra mảng phẳng + gắn pricePerDay = pricePerHour × 24 (giá ngày).
    assert out["vehicles"] == [{"id": "v1", "pricePerHour": 80000, "pricePerDay": 1920000}]


def test_get_vehicle_price_calls_quote_endpoint() -> None:
    seen: dict = {}

    def handler(req: httpx.Request) -> httpx.Response:
        seen["path"] = req.url.path
        seen["params"] = dict(req.url.params)
        return httpx.Response(200, json={"success": True, "data": {"finalPrice": 480000, "currency": "VND"}})

    out = _client(handler).get_vehicle_price(
        "veh-9", start_time="2026-07-01T08:00:00+07:00", end_time="2026-07-02T08:00:00+07:00"
    )
    assert seen["path"] == "/api/vehicles/veh-9/price-quote"
    assert seen["params"]["startTime"].startswith("2026-07-01")
    assert out["finalPrice"] == 480000


def test_get_my_bookings_sends_auth_token() -> None:
    seen: dict = {}

    def handler(req: httpx.Request) -> httpx.Response:
        seen["auth"] = req.headers.get("authorization")
        return httpx.Response(200, json={"success": True, "data": [{"id": "b1"}]})

    out = _client(handler, auth_token="jwt-abc").get_my_bookings()
    assert seen["auth"] == "Bearer jwt-abc"
    assert out["bookings"] == [{"id": "b1"}]


def test_get_my_bookings_without_token_errors_without_calling_backend() -> None:
    called = False

    def handler(req: httpx.Request) -> httpx.Response:
        nonlocal called
        called = True
        return httpx.Response(200, json={"success": True, "data": []})

    out = _client(handler, auth_token=None).get_my_bookings()
    assert "error" in out
    assert called is False  # không gọi backend khi chưa đăng nhập


def test_backend_error_envelope_surfaced() -> None:
    def handler(req: httpx.Request) -> httpx.Response:
        return httpx.Response(404, json={"success": False, "error": "Không tìm thấy xe", "code": "NOT_FOUND"})

    out = _client(handler).get_vehicle_price("missing", "2026-07-01T08:00:00+07:00", "2026-07-02T08:00:00+07:00")
    assert "error" in out


def test_dispatch_ignores_llm_supplied_userid_for_bookings() -> None:
    """Dù LLM cố truyền userId người khác, get_my_bookings phải dùng token tiêm."""
    seen: dict = {}

    def handler(req: httpx.Request) -> httpx.Response:
        seen["auth"] = req.headers.get("authorization")
        seen["params"] = dict(req.url.params)
        return httpx.Response(200, json={"success": True, "data": []})

    client = _client(handler, auth_token="jwt-me")
    content = dispatch_tool(client, "get_my_bookings", {"userId": "victim-123"})
    parsed = json.loads(content)
    assert seen["auth"] == "Bearer jwt-me"
    assert "victim-123" not in json.dumps(seen)  # userId của LLM bị bỏ qua
    assert "bookings" in parsed


def test_dispatch_unknown_tool_returns_error_json() -> None:
    content = dispatch_tool(_client(lambda r: httpx.Response(200, json={})), "drop_tables", {})
    assert "error" in json.loads(content)


def test_tool_specs_are_openai_function_format() -> None:
    names = {spec["function"]["name"] for spec in TOOL_SPECS}
    assert names == {"search_available_vehicles", "get_vehicle_price", "get_my_bookings"}
    for spec in TOOL_SPECS:
        assert spec["type"] == "function"
        assert "parameters" in spec["function"]

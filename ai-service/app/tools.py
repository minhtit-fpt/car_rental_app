"""Tool-calling vào backend Next.js để chatbot trả lời DỮ LIỆU SỐNG (xe trống,
giá động, booking) — phần tách khỏi RAG tĩnh (xem plan B5).

BẢO MẬT (Risk HIGH trong plan):
- Chatbot CHỈ đọc (GET), không tạo/sửa/xóa.
- `userId` LẤY TỪ phiên auth (token tiêm vào client), KHÔNG nhận từ LLM. Tool
  get_my_bookings bỏ qua mọi tham số userId do LLM sinh ra để tránh lộ dữ liệu
  người khác — backend tự suy renterId từ token.

Giá xe đi qua endpoint price-quote của Workstream C (dynamic pricing), KHÔNG
nhúng vào corpus RAG.
"""

from __future__ import annotations

import json
from typing import Any

import httpx

from app.config import Settings, get_settings

_DEFAULT_TIMEOUT = 30.0

# Giá niêm yết hiện tại là giá NGÀY: cột DB `pricePerHour` đang giữ giá theo giờ,
# quy ước 1 ngày = 24 giờ → giá ngày = pricePerHour × 24. Tính sẵn để LLM khỏi
# tự làm toán (hay chia sai). ponytail: bỏ phép nhân này khi DB có cột giá ngày riêng.
_HOURS_PER_DAY = 24


def _with_daily_price(vehicles: Any) -> Any:
    """Gắn `pricePerDay` (VND/ngày) cho mỗi xe từ `pricePerHour`."""
    if not isinstance(vehicles, list):
        return vehicles
    out = []
    for v in vehicles:
        if isinstance(v, dict) and isinstance(v.get("pricePerHour"), (int, float)):
            out.append({**v, "pricePerDay": round(v["pricePerHour"] * _HOURS_PER_DAY)})
        else:
            out.append(v)
    return out


def _unwrap(resp: httpx.Response) -> Any:
    """Bóc envelope chuẩn {success, data} | {success, error}. Trả dict lỗi nếu fail."""
    try:
        body = resp.json()
    except ValueError:
        return {"error": f"Backend trả về không phải JSON (HTTP {resp.status_code})"}
    if isinstance(body, dict) and body.get("success") is False:
        return {"error": body.get("error", "Lỗi không xác định"), "code": body.get("code")}
    if resp.is_error:
        return {"error": f"Backend lỗi HTTP {resp.status_code}"}
    return body.get("data") if isinstance(body, dict) else body


class BackendToolClient:
    """Client read-only gọi API backend cho các tool của chatbot."""

    def __init__(
        self,
        *,
        base_url: str | None = None,
        auth_token: str | None = None,
        client: httpx.Client | None = None,
    ) -> None:
        self._auth_token = auth_token
        if client is not None:
            self._client = client
        else:
            if base_url is None:
                raise ValueError("Cần base_url hoặc client")
            self._client = httpx.Client(base_url=base_url, timeout=_DEFAULT_TIMEOUT)

    @classmethod
    def from_settings(
        cls, settings: Settings | None = None, *, auth_token: str | None = None
    ) -> "BackendToolClient":
        s = settings or get_settings()
        return cls(base_url=s.backend_base_url, auth_token=auth_token)

    def search_available_vehicles(
        self,
        vehicle_type: str | None = None,
        min_price: float | None = None,
        max_price: float | None = None,
        limit: int = 10,
    ) -> dict:
        params: dict[str, Any] = {"limit": limit}
        if vehicle_type:
            params["type"] = vehicle_type
        if min_price is not None:
            params["minPrice"] = min_price
        if max_price is not None:
            params["maxPrice"] = max_price
        data = _unwrap(self._client.get("/api/vehicles", params=params))
        if isinstance(data, dict) and "error" in data:
            return data
        # /api/vehicles trả {items, total}; bóc `items` ra để LLM thấy thẳng danh
        # sách xe (kèm pricePerHour) thay vì object lồng → tránh bịa giá.
        vehicles = data["items"] if isinstance(data, dict) and "items" in data else data
        return {"vehicles": _with_daily_price(vehicles)}

    def get_vehicle_price(self, vehicle_id: str, start_time: str, end_time: str) -> dict:
        data = _unwrap(
            self._client.get(
                f"/api/vehicles/{vehicle_id}/price-quote",
                params={"startTime": start_time, "endTime": end_time},
            )
        )
        return data if isinstance(data, dict) else {"quote": data}

    def get_my_bookings(self) -> dict:
        # userId KHÔNG đến từ LLM — suy từ token phiên. Chưa đăng nhập → từ chối.
        if not self._auth_token:
            return {"error": "Bạn cần đăng nhập để xem chuyến của mình."}
        data = _unwrap(
            self._client.get(
                "/api/bookings",
                headers={"Authorization": f"Bearer {self._auth_token}"},
            )
        )
        if isinstance(data, dict) and "error" in data:
            return data
        return {"bookings": data}


# Khai báo tool theo định dạng OpenAI function-calling (Qwen2.5 hỗ trợ).
# Lưu ý: get_my_bookings KHÔNG khai báo tham số userId — token quyết định danh tính.
TOOL_SPECS: list[dict] = [
    {
        "type": "function",
        "function": {
            "name": "search_available_vehicles",
            "description": "Tìm xe đang cho thuê theo loại và khoảng giá. Trả về mảng xe; mỗi xe có 'pricePerDay' là GIÁ THUÊ THEO NGÀY (VND/ngày) — đây là giá niêm yết phải báo cho khách. Báo đúng con số 'pricePerDay', KHÔNG dùng 'pricePerHour' và KHÔNG tự quy đổi.",
            "parameters": {
                "type": "object",
                "properties": {
                    "vehicle_type": {"type": "string", "description": "Loại xe (ví dụ CAR, MOTORBIKE) — tùy chọn."},
                    "min_price": {"type": "number", "description": "Giá tối thiểu mỗi giờ (VND) — tùy chọn."},
                    "max_price": {"type": "number", "description": "Giá tối đa mỗi giờ (VND) — tùy chọn."},
                    "limit": {"type": "integer", "description": "Số xe tối đa trả về.", "default": 10},
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_vehicle_price",
            "description": "Báo giá động CÓ GIẢI THÍCH cho một xe trong khoảng thời gian thuê cụ thể.",
            "parameters": {
                "type": "object",
                "properties": {
                    "vehicle_id": {"type": "string", "description": "ID xe cần báo giá."},
                    "start_time": {"type": "string", "description": "Giờ nhận xe (ISO 8601, có offset)."},
                    "end_time": {"type": "string", "description": "Giờ trả xe (ISO 8601, có offset)."},
                },
                "required": ["vehicle_id", "start_time", "end_time"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_my_bookings",
            "description": "Lấy danh sách chuyến đặt của CHÍNH người dùng đang đăng nhập. Không cần và không nhận userId.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
]


def dispatch_tool(client: BackendToolClient, name: str, arguments: dict) -> str:
    """Định tuyến lời gọi tool của LLM tới client; trả CHUỖI JSON để đưa lại LLM.

    get_my_bookings cố tình KHÔNG nhận arguments → mọi userId LLM bịa ra bị loại."""
    try:
        if name == "search_available_vehicles":
            result = client.search_available_vehicles(
                vehicle_type=arguments.get("vehicle_type"),
                min_price=arguments.get("min_price"),
                max_price=arguments.get("max_price"),
                limit=int(arguments.get("limit", 10)),
            )
        elif name == "get_vehicle_price":
            result = client.get_vehicle_price(
                vehicle_id=arguments["vehicle_id"],
                start_time=arguments["start_time"],
                end_time=arguments["end_time"],
            )
        elif name == "get_my_bookings":
            result = client.get_my_bookings()  # bỏ qua arguments có chủ đích
        else:
            result = {"error": f"Tool không tồn tại: {name}"}
    except KeyError as err:
        result = {"error": f"Thiếu tham số bắt buộc: {err}"}
    except httpx.HTTPError as err:
        result = {"error": f"Không gọi được backend: {err}"}
    return json.dumps(result, ensure_ascii=False)

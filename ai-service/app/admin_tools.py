"""Tool-calling ĐỌC-ONLY cho trợ lý phân tích của ADMIN (tách khỏi tool người dùng
ở tools.py). Admin có prompt + bộ tool RIÊNG: hỏi sâu về số liệu nền tảng bằng cách
gọi các endpoint `/api/admin/*` (GET) thay vì chỉ khớp template dashboard.

BẢO MẬT:
- CHỈ đọc (GET), không tạo/sửa/xóa.
- Quyền admin lấy TỪ token phiên (backend tự `requireRole(ADMIN)`), KHÔNG từ LLM.
  Không có token → mọi tool từ chối (tránh gọi API admin ẩn danh).
"""

from __future__ import annotations

import json
from typing import Any

import httpx

from app.config import Settings, get_settings
from app.tools import _unwrap  # cùng envelope {success, data} với tool người dùng

_DEFAULT_TIMEOUT = 30.0
_DEFAULT_LIMIT = 20


class AdminToolClient:
    """Client read-only gọi API admin của backend. Token admin tiêm từ phiên."""

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
    ) -> "AdminToolClient":
        s = settings or get_settings()
        return cls(base_url=s.backend_base_url, auth_token=auth_token)

    def _get(self, path: str, params: dict[str, Any] | None = None) -> Any:
        if not self._auth_token:
            return {"error": "Thiếu quyền admin (không có token phiên)."}
        return _unwrap(
            self._client.get(
                path,
                params=params or {},
                headers={"Authorization": f"Bearer {self._auth_token}"},
            )
        )

    # ---- Metrics + doanh thu ----
    def get_metrics(self) -> Any:
        return self._get("/api/admin/metrics")

    def get_revenue(self, months: int = 6) -> Any:
        return self._get("/api/admin/revenue", {"months": months})

    # ---- Bookings ----
    def list_bookings(
        self,
        status: str | None = None,
        date_from: str | None = None,
        date_to: str | None = None,
        limit: int = _DEFAULT_LIMIT,
    ) -> Any:
        params: dict[str, Any] = {"limit": limit}
        if status:
            params["status"] = status
        if date_from:
            params["from"] = date_from
        if date_to:
            params["to"] = date_to
        return self._get("/api/admin/bookings", params)

    # ---- Users + KYC ----
    def list_users(
        self,
        role: str | None = None,
        search: str | None = None,
        limit: int = _DEFAULT_LIMIT,
    ) -> Any:
        params: dict[str, Any] = {"limit": limit}
        if role:
            params["role"] = role
        if search:
            params["search"] = search
        return self._get("/api/admin/users", params)

    def list_kyc(self, status: str | None = None, limit: int = _DEFAULT_LIMIT) -> Any:
        params: dict[str, Any] = {"limit": limit}
        if status:
            params["status"] = status
        return self._get("/api/admin/kyc", params)

    # ---- Disputes + rủi ro ----
    def list_disputes(
        self, status: str | None = None, limit: int = _DEFAULT_LIMIT
    ) -> Any:
        params: dict[str, Any] = {"limit": limit}
        if status:
            params["status"] = status
        return self._get("/api/admin/disputes", params)

    def list_risk_flags(self) -> Any:
        return self._get("/api/admin/risk")


# Khai báo tool theo định dạng OpenAI function-calling (Qwen2.5 hỗ trợ).
ADMIN_TOOL_SPECS: list[dict] = [
    {
        "type": "function",
        "function": {
            "name": "get_metrics",
            "description": "Tổng quan số liệu nền tảng: KPI (người dùng/xe/đơn, tỉ lệ hoàn tất & huỷ, điểm đánh giá TB), doanh thu theo phương thức, đơn theo trạng thái, đội xe theo loại, top xe. Dùng cho câu hỏi tổng quan.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_revenue",
            "description": "Chuỗi doanh thu theo tháng gần nhất (để trả lời xu hướng doanh thu).",
            "parameters": {
                "type": "object",
                "properties": {
                    "months": {
                        "type": "integer",
                        "description": "Số tháng gần nhất (1-24). Mặc định 6.",
                        "default": 6,
                    }
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "list_bookings",
            "description": "Danh sách đơn thuê, lọc theo trạng thái và khoảng ngày tạo. Dùng để đếm/soi đơn theo điều kiện cụ thể.",
            "parameters": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "description": "Trạng thái đơn (VD: PENDING, CONFIRMED, ONGOING, COMPLETED, CANCELLED) — tuỳ chọn.",
                    },
                    "date_from": {
                        "type": "string",
                        "description": "Lọc từ ngày (ISO 8601) — tuỳ chọn.",
                    },
                    "date_to": {
                        "type": "string",
                        "description": "Lọc đến ngày (ISO 8601) — tuỳ chọn.",
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Số đơn tối đa (1-100). Mặc định 20.",
                        "default": 20,
                    },
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "list_users",
            "description": "Danh sách người dùng, lọc theo vai trò và từ khoá tìm kiếm. Dùng cho câu hỏi về dân số người dùng.",
            "parameters": {
                "type": "object",
                "properties": {
                    "role": {
                        "type": "string",
                        "description": "Vai trò (RENTER, OWNER, ADMIN) — tuỳ chọn.",
                    },
                    "search": {
                        "type": "string",
                        "description": "Từ khoá (email/SĐT) — tuỳ chọn.",
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Số user tối đa (1-100). Mặc định 20.",
                        "default": 20,
                    },
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "list_kyc",
            "description": "Hàng đợi KYC theo trạng thái (PENDING/APPROVED/REJECTED). Dùng cho câu hỏi về xác minh danh tính.",
            "parameters": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "description": "Trạng thái KYC — tuỳ chọn (mặc định backend: PENDING).",
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Số bản ghi tối đa (1-100). Mặc định 20.",
                        "default": 20,
                    },
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "list_disputes",
            "description": "Hàng đợi tranh chấp theo trạng thái (OPEN/RESOLVED/REJECTED). Dùng cho câu hỏi về tranh chấp đang mở.",
            "parameters": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "description": "Trạng thái tranh chấp — tuỳ chọn (mặc định backend: OPEN).",
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Số tranh chấp tối đa (1-100). Mặc định 20.",
                        "default": 20,
                    },
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "list_risk_flags",
            "description": "Các tài khoản/đơn bị cờ rủi ro bởi rule-engine (có điểm + lý do). Dùng cho câu hỏi về rủi ro/gian lận.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
]


def dispatch_admin_tool(client: AdminToolClient, name: str, arguments: dict) -> str:
    """Định tuyến lời gọi tool của LLM tới client admin; trả CHUỖI JSON để đưa lại LLM."""
    try:
        if name == "get_metrics":
            result = client.get_metrics()
        elif name == "get_revenue":
            result = client.get_revenue(months=int(arguments.get("months", 6)))
        elif name == "list_bookings":
            result = client.list_bookings(
                status=arguments.get("status"),
                date_from=arguments.get("date_from"),
                date_to=arguments.get("date_to"),
                limit=int(arguments.get("limit", _DEFAULT_LIMIT)),
            )
        elif name == "list_users":
            result = client.list_users(
                role=arguments.get("role"),
                search=arguments.get("search"),
                limit=int(arguments.get("limit", _DEFAULT_LIMIT)),
            )
        elif name == "list_kyc":
            result = client.list_kyc(
                status=arguments.get("status"),
                limit=int(arguments.get("limit", _DEFAULT_LIMIT)),
            )
        elif name == "list_disputes":
            result = client.list_disputes(
                status=arguments.get("status"),
                limit=int(arguments.get("limit", _DEFAULT_LIMIT)),
            )
        elif name == "list_risk_flags":
            result = client.list_risk_flags()
        else:
            result = {"error": f"Tool không tồn tại: {name}"}
    except httpx.HTTPError as err:
        result = {"error": f"Không gọi được backend: {err}"}
    return json.dumps(result, ensure_ascii=False, default=str)

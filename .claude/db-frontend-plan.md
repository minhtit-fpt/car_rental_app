# PLAN B — DB phía Máy (Flutter: Drift + Hive + SecureStorage)

> Hướng A: SQLite trên máy chỉ là **cache đọc nhanh + offline**, KHÔNG phải nguồn chân lý.
> Mọi bảng cache có `fetchedAt + TTL`; server luôn thắng khi xung đột.
> Token ở **secure storage**, KHÔNG để trong SQLite.
> Sơ đồ ER: `docs/db-structure.html` (phần 2–4).

**Status:** Chờ xác nhận 2 quyết định trước khi code (xem cuối file).

---

## Các phase

### F0 — Bootstrap storage · `feat/flutter-storage-bootstrap`
- Deps (cần duyệt `pubspec.yaml`): `drift`, `sqlite3_flutter_libs`, `flutter_secure_storage`, `hive`
- `core/db/app_database.dart` (Drift)
- `core/storage/secure_storage.dart` — token, refreshToken, role
- `core/storage/kv_storage.dart` — onboardingDone, themeMode, locale, lastSyncAt
- Đăng ký GetIt DI + build_runner

### F3 — Vehicles cache · `feat/flutter-vehicles-cache`
- Bảng `VehiclesCache` + DAO
- Bảng `SearchHistory` (local-only)
- Chiến lược: network-first → fallback cache (TTL 10′)

### F4 — Bookings cache + drafts · `feat/flutter-bookings-cache`
- `BookingsCache` (cache-first + SWR, TTL 30′)
- `BookingDrafts` (local-until-submit; syncState: draft|submitting)

### F5 — Notifications cache · `feat/flutter-notifications-cache`
- `NotificationsCache` (cache-first, push cập nhật live)

### F6 — Chat outbox · `feat/flutter-chat-outbox`
- `ChatConvLocal` + `ChatMessagesLocal` (outbox: pending|sent|failed)
- Worker retry khi có mạng lại + idempotency key

---

## Ánh xạ máy ↔ server (theo id, KHÔNG phải FK)
| Local | → Server |
|---|---|
| `VehiclesCache.id` | `Vehicle.id` |
| `BookingsCache.id` | `Booking.id` |
| `BookingDrafts.vehicleId` | `Vehicle.id` |
| `ChatMessagesLocal.serverId` | `ChatMessage.id` (sau khi gửi) |

## Chiến lược cache
| Dữ liệu | Cách |
|---|---|
| Xe / tìm kiếm | network-first, TTL 10′ |
| Booking history | cache-first + SWR, TTL 30′ |
| Chat | local-first + WebSocket sync |
| Notifications | cache-first, push live |
| Payment / Contract / KYC | **remote-only, KHÔNG cache** |

## KHÔNG bao giờ cache (remote-only)
Payment (status, amount) · Contract đã ký · Ảnh KYC (CCCD, bằng lái) · Booking status lúc giao dịch · Submit KYC.
**Quy tắc vàng:** dữ liệu tiền/pháp lý → luôn hỏi server thật.

---

## Rủi ro
| Mức | Vấn đề |
|---|---|
| HIGH | Phụ thuộc API backend: F3–F6 cần response contract của B3–B6 trước → chạy sau hoặc mock |
| MED | Outbox retry: chống trùng bằng idempotency key |
| MED | Drift code-gen (build_runner) dễ xung đột khi sửa schema nhiều |
| LOW | SQLCipher mã hoá file .db (mặc định off) |

---

## Quyết định cần chốt
1. **Bật SQLCipher** mã hoá file SQLite trên máy không? (mặc định: off)

## Phụ thuộc
Frontend cache theo sau backend từng feature.
Trình tự liên plan: **B0→B1→B2→B3 → (F0,F3) → B4→(F4) → B5→(F5) → B6→(F6)**.

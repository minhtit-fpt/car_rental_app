# PLAN A — DB phía Server (PostgreSQL + Prisma + Next.js)

> Hướng A: PostgreSQL là **nguồn chân lý** duy nhất. ACID, đa người dùng, PostGIS tìm xe gần, chống đặt trùng xe ở tầng DB.
> Kiến trúc: `Route Handler → Service → Repository → Prisma → PostgreSQL` (theo CLAUDE.md).
> Sơ đồ ER: `docs/db-structure.html` (phần 1).

**Status:** ✅ HOÀN TẤT B0→B7 — 5 migrations, 17 bảng, 4 constraint. Verify với Postgres thật, không drift.

**Quyết định đã chốt:** ChatConversation dùng **bảng nối `ConversationParticipant`** (B - nhiều-nhiều chuẩn).

**Verify:** CHECK roles (ADMIN độc quyền), GIST + ST_DWithin, EXCLUDE booking_no_overlap (chồng/liền kề/PENDING), review_rating_range.

**Migrations đã áp:**
- `20260603120000_init_auth` — User, RefreshToken, OTPCode + extensions
- `20260603120100_kyc_vehicle` — KYCVerification, Vehicle (GIST)
- `20260603120200_booking_payment` — Booking (EXCLUDE), Payment, Contract, Insurance
- `20260603120300_social` — Review (CHECK rating), LoyaltyPoint, TripStory, Notification
- `20260603120400_chat_audit` — ChatConversation, ConversationParticipant, ChatMessage, AuditLog

**Chưa làm (ngoài phạm vi "DB structure", để sau nếu cần):** repository layer (`repositories/*.ts`), Zod validators, seed script.

**Lưu ý kỹ thuật đã xử lý:**
- GIST index trên Unsupported geography → khai báo `@@index([location], type: Gist)` để tránh drift
- CHECK/EXCLUDE constraint: Prisma bỏ qua khi diff → không drift, an toàn để raw trong migration
- Tạo migration non-interactive: `migrate diff --from-migrations` (shadow db `ridevn_shadow`) → strip 2 dòng `CREATE EXTENSION` thừa → `migrate deploy`

**Quyết định đã chốt:**
- Multi-role: `roles UserRole[]` (1 user nhiều vai). **ADMIN độc quyền** — ép bằng CHECK constraint `user_admin_exclusive` + `user_roles_not_empty` (dùng `cardinality()`).

---

## Các phase

### B0 — Hạ tầng · `chore/docker-compose`
- `docker-compose.yml`: PostgreSQL+PostGIS 16, Redis 7, MinIO
- `backend/.env.example` (DB, JWT, Redis, MinIO, FCM, VNPay/MoMo/Stripe, SMS, Maps, eKYC)
- Khởi tạo Next.js + Prisma + Zod; Prisma client singleton tại `src/db/`

### B1 — Auth · `feat/db-auth`
- Models: `User`, `RefreshToken`, `OTPCode`
- Repo: `user.repository.ts`, `auth.repository.ts`
- Migration đầu: bật extension `postgis` + `btree_gist`

### B2 — KYC · `feat/db-kyc`
- Model `KYCVerification` (url ảnh → private bucket MinIO)
- Repo + service skeleton

### B3 — Vehicle · `feat/db-vehicle`
- Model `Vehicle` + cột `geography(Point)` + index GIST
- Repo có `findNearby` dùng `ST_DWithin`

### B4 — Booking & Tiền · `feat/db-booking`
- Models: `Booking`, `Payment`, `Contract`, `Insurance`
- **EXCLUDE constraint** chống trùng giờ (raw SQL trong migration):
  ```sql
  ALTER TABLE "Booking"
    ADD CONSTRAINT booking_no_overlap
    EXCLUDE USING gist (
      "vehicleId" WITH =,
      tstzrange("startTime", "endTime", '[)') WITH &&
    )
    WHERE ("status" IN ('CONFIRMED', 'IN_PROGRESS'));
  ```
- Repo cho từng model

### B5 — Social · `feat/db-social`
- Models: `Review` (2 FK: reviewerId, targetId), `LoyaltyPoint`, `TripStory`, `Notification`

### B6 — Chat · `feat/db-chat`
- Models: `ChatConversation`, `ChatMessage`

### B7 — Audit · `feat/db-audit`
- Model `AuditLog`

---

## Output mỗi phase
`schema.prisma` (models) + migration + `repositories/*.ts` + Zod validators. Mọi model có `createdAt/updatedAt`.

## Rủi ro
| Mức | Vấn đề |
|---|---|
| HIGH | EXCLUDE constraint cần `btree_gist` + Prisma không hỗ trợ native → raw migration |
| HIGH | PostGIS `geography`: Prisma chưa hỗ trợ type trực tiếp → `Unsupported("geography")` + raw query |
| MED | ChatConversation: mảng `participants[]` vs bảng nối `ConversationParticipant` |
| LOW | Thứ tự migration: bật PostGIS extension trước khi tạo Vehicle |

---

## Quyết định cần chốt
1. **ChatConversation**: mảng `participants[]` hay tách bảng nối `ConversationParticipant` (nhiều-nhiều chuẩn hoá)?

## Phụ thuộc
Server đi trước từng feature, frontend cache theo sau (cần response contract).
Trình tự liên plan: **B0→B1→B2→B3 → (F0,F3) → B4→(F4) → B5→(F5) → B6→(F6)**.

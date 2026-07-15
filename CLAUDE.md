# AGENTS.md — Car Rental Platform
> **Bước 0: Context Packing** — Front-load mọi thứ AI cần biết trước khi làm việc.  
> File này được Claude Code (VSCode Extension) và GitHub Copilot Agent tự động đọc mỗi khi start session.  
> Nguồn cảm hứng: Addy Osmani (Director, Google Cloud AI) · Workflow: @mr.q.hoc.ung.dung.ai

---

## Tech Stack

**Frontend:**
- Flutter (Dart) · Bloc/Cubit · GoRouter · Dio · GetIt

**Backend:**
- Next.js 14+ App Router · TypeScript · Prisma ORM · PostgreSQL
- Redis (cache) · MinIO/S3 (file storage) · WebSocket (chat) · Firebase FCM (push)

**Integrations:**
- Google Maps SDK · VNPay · MoMo · Stripe · eKYC provider

---

## Project Structure

```
car-rental-app/
├── frontend/          # Flutter mobile app
│   └── lib/
│       ├── core/      # config, di, router, theme, network, utils
│       ├── features/  # auth, kyc, vehicle, map, booking, owner,
│       │              # payment, pricing, ai_matching, loyalty,
│       │              # community, review, chat, notification, profile
│       └── shared/    # widgets, extensions dùng chung
├── backend/           # Next.js API
│   ├── src/
│   │   ├── app/api/   # Route handlers (HTTP layer only)
│   │   ├── lib/
│   │   │   ├── services/     # Business logic
│   │   │   ├── repositories/ # DB queries (Prisma only)
│   │   │   ├── middleware/   # auth, kyc, rate-limit
│   │   │   └── validators/   # Zod schemas
│   │   └── db/        # Prisma client singleton
│   └── prisma/        # schema.prisma + migrations
└── shared/            # API contracts, ERD docs, Postman
```

---

## Commands

### Flutter
```bash
flutter run                                                       # Chạy app
flutter test                                                      # Test — phải pass trước khi commit
flutter pub run build_runner build --delete-conflicting-outputs   # Sinh code
flutter clean && flutter pub get                                  # Clean
```

### Backend
```bash
npm run dev              # Dev server
npm test                 # Test — phải pass trước khi commit
npm run lint             # Lint
npx prisma migrate dev --name <tên>   # Migrate DB
npx prisma generate      # Sau khi sửa schema.prisma
npx prisma studio        # GUI xem DB
```

### Docker
```bash
docker-compose up -d            # Khởi động PostgreSQL + Redis + MinIO
docker-compose logs -f postgres
```

---

## Boundaries

### ✅ Always — Luôn làm
- Chạy `flutter test` / `npm test` trước khi commit
- Validate request body bằng **Zod** trước khi vào service layer
- Dùng middleware `auth.middleware.ts` cho mọi route cần xác thực
- Đặt business logic trong `services/`, không trong route handler
- Đặt Prisma queries trong `repositories/`, không nơi khác
- Trả về response theo chuẩn: `{ success, data }` hoặc `{ success, error, code }`
- Widget dùng chung đặt trong `shared/widgets/`, không duplicate trong feature
- Mỗi Flutter usecase chỉ làm đúng 1 việc

### ⚠️ Ask first — Hỏi trước khi làm
- Thay đổi `schema.prisma` (ảnh hưởng migration)
- Thêm package/dependency mới vào `pubspec.yaml` hoặc `package.json`
- Sửa logic `pricing.service.ts` (dynamic pricing engine)
- Thay đổi flow KYC hoặc contract signing
- Sửa `app_router.dart` (route structure)
- Thêm role mới ngoài `RENTER | OWNER | ADMIN`

### 🚫 Never — Không bao giờ
- Hardcode secrets, API keys, passwords vào source code
- Commit file `.env` (chỉ commit `.env.example`)
- Gọi PrismaClient trực tiếp từ route handler hoặc service — chỉ qua `repository`
- Gọi API trực tiếp từ Flutter `presentation/` layer — phải qua usecase → repository
- Public URL ảnh KYC (CCCD, bằng lái) — bucket MinIO phải private
- Bỏ qua rate limiting cho `/api/auth/*`, `/api/kyc/*`, `/api/payments/*`
- Dùng `any` type trong TypeScript

---

## Architecture Rules

### Flutter — Clean Architecture (3 lớp)
```
features/<n>/
├── data/         # datasource, model, repository impl
├── domain/       # entity, usecase, repository interface
└── presentation/ # screen, widget, bloc/cubit
```
Flow bắt buộc: `UI → Bloc → Usecase → Repository → Datasource → API`

### Next.js — Layered Architecture
```
Route Handler → Service → Repository → Prisma → PostgreSQL
```
Route handler chỉ parse request + gọi service, không chứa logic.

---

## Key Features Context

| Feature | Flutter | Backend |
|---|---|---|
| KYC | `features/kyc/` | `api/kyc/` + `kyc.service.ts` |
| Dynamic Pricing | `features/pricing/widgets/` | `pricing.service.ts` + `surge.util.ts` |
| AI Matching | `features/ai_matching/` | `ai.service.ts` |
| Hợp đồng điện tử | `booking/screens/contract_view.dart` | `contract.service.ts` |
| Bản đồ xe / EV | `features/map/` | `vehicles/nearby` route |
| Car Delivery | checkbox trong booking form | `delivery_available` field trên Vehicle |
| Loyalty / Gamification | `features/loyalty/` | `loyalty.service.ts` |
| Community feed | `features/community/` | `api/community/` |

---

## Database — Models chính (Prisma)

```
User              → id, phone, email, roles[] (RENTER|OWNER|ADMIN), kycStatus, createdAt
Vehicle           → id, ownerId, type, pricePerDay, isElectric, isAvailable, location
Booking           → id, vehicleId, renterId, status, startTime, endTime, totalPrice
Payment           → id, bookingId, method, status, amount, gatewayRef
Contract          → id, bookingId, pdfUrl, signedAt
Insurance         → id, bookingId, planType, premium, coverageAmount
KYCVerification   → id, userId, cccdUrl, licenseUrl, faceUrl, status
LoyaltyPoint      → id, userId, points, action
TripStory         → id, userId, bookingId, content, images[], likes
Review            → id, bookingId, reviewerId, targetId, rating, comment
```

---

## API Response Standard

```typescript
// Success
{ success: true, data: T, message?: string }

// Error
{ success: false, error: string, code?: string }
```

**HTTP Status:** `200` OK · `201` Created · `400` Validation · `401` Unauth · `403` Forbidden · `404` Not Found · `409` Conflict · `500` Server Error

---

## User Roles

| Role | Có thể làm |
|---|---|
| `RENTER` | Tìm xe, đặt xe, thanh toán, đánh giá, community |
| `OWNER` | Đăng xe, quản lý lịch, xem doanh thu, ký hợp đồng |
| `ADMIN` | Duyệt KYC, xử lý tranh chấp, quản lý người dùng |

> Một tài khoản có thể đồng thời là `RENTER` và `OWNER`.

### Tab "Tôi" (Tài khoản) — `core/shell/app_shell.dart`

- Bộ chuyển **👤 Người thuê / 🚗 Chủ xe** chỉ hiện khi `user.isOwner == true`.
  RENTER thuần tuý chỉ thấy `RenterDashboardScreen`, không thấy toggle Chủ xe.
  ADMIN có khu vực riêng ở `/admin`, không nằm trong toggle này.
- `RenterDashboardScreen` (tab "Tôi") **chỉ hiển thị hồ sơ + chỉ số nhanh**.
  Danh sách chuyến nằm hẳn ở tab **"Chuyến"** (`MyTripsScreen`) — không lặp lại
  danh sách booking trong màn hồ sơ.
- Nguồn dữ liệu màn hồ sơ (đã nối BE):
  - Hồ sơ (email, SĐT, KYC, vai trò) ← `AuthCubit` (`GET /api/auth/me`)
  - Stats Đang thuê / Sắp tới / Tổng chuyến ← `MyTripsCubit` (`GET /api/bookings`)
  - Điểm thưởng ← `LoyaltyCubit` (`GET /api/loyalty`)
- `PublicUser` của BE **không có** trường tên/rating/ngày tham gia
  (chỉ `id, phone, email, roles, kycStatus`). Display name fallback:
  email → số điện thoại. Không hardcode tên/rating giả.

---

## Flutter UI Consistency Rules

> Mọi màn hình mới phải tuân theo patterns này để đồng nhất với UI hiện có.

### Colors — chỉ dùng AppColors
> Tokens đã được cập nhật theo RideVN Design System (Claude Design handoff, 2026-05-25).

```dart
// ✅ Đúng
color: AppColors.primary        // #14336B — navy-600, màu trust chính
color: AppColors.accent         // #F26A1F — orange-500, CTA / trạng thái active
color: AppColors.teal           // #00A8A8 — verified badge only
color: AppColors.background     // #FAFBFD — ink-25, nền tổng
color: AppColors.surface        // #FFFFFF — nền card
color: AppColors.surfaceSunken  // #F4F6FA — ink-50, nền badge/chip
color: AppColors.border         // #DDE3EC — ink-200, viền card
color: AppColors.darkText       // #10131A — ink-900, text chính
color: AppColors.secondaryText  // #4A5263 — ink-600, text phụ
color: AppColors.mutedText      // #6B7384 — ink-500, text caption
color: AppColors.placeholderText// #99A2B2 — ink-400, placeholder
color: AppColors.cardShadowColor

// 🚫 Sai — không hardcode hex trong màn hình
color: Color(0xFF007BFF)
```
Ngoại lệ duy nhất: gradient header của từng role (dùng `AppColors.renterHeaderGradient` / `AppColors.ownerHeaderGradient`).

### Card / Container style chuẩn
```dart
BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(20),  // card lớn
  border: Border.all(color: AppColors.border),
  boxShadow: const [
    BoxShadow(
      color: AppColors.cardShadowColor,
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ],
)
```
- Stat card nhỏ: `borderRadius: 14`, shadow `blurRadius: 8`
- Chip / badge: `borderRadius: 8–10`
- Button: `borderRadius: 12`

### Status badge pattern
```dart
// background = statusColor.withAlpha(26), text = statusColor
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: color.withAlpha(26),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
)
```

### Screen structure bắt buộc
```dart
AnnotatedRegion<SystemUiOverlayStyle>(
  value: SystemUiOverlayStyle.light,  // hoặc .dark tuỳ header
  child: Scaffold(
    backgroundColor: AppColors.background,
    body: CustomScrollView(
      slivers: [
        _MyFeatureSliverAppBar(),  // gradient header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(...),
          ),
        ),
      ],
    ),
  ),
)
```
- **Không** dùng `Column` thẳng trong `body` nếu màn hình có scroll.
- Bottom padding cuối content: `SizedBox(height: 24)`.

### SliverAppBar / Header gradient theo role
```dart
// Renter screens
gradient: AppColors.renterHeaderGradient  // [0xFF003380 → 0xFF007BFF]

// Owner screens
gradient: AppColors.ownerHeaderGradient   // [0xFF001A3D → 0xFF003380]

// Admin screens — dark theme riêng (xem admin_dashboard_screen.dart)
// background: Color(0xFF0A1628), surface: Color(0xFF142035)
```
AppBar title luôn có logo box + "RideVN":
```dart
Row(children: [
  Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
      gradient: AppColors.logoGradient,
      borderRadius: BorderRadius.circular(7),
    ),
  ),
  const SizedBox(width: 8),
  const Text('RideVN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
])
```

### Typography scale
| Dùng cho | fontSize | fontWeight | color |
|---|---|---|---|
| Header expanded title | 22 | w800 | Colors.white |
| Section title | 16 | bold | AppColors.darkText |
| Card title / item name | 14 | w600 | AppColors.darkText |
| Body / description | 13–14 | normal | AppColors.secondaryText |
| Meta / caption | 11–12 | normal | AppColors.mutedText |
| Badge / chip label | 10–11 | w600 | status color |

Font family là **Be Vietnam Pro** (Google Fonts, đặt trong ThemeData qua `GoogleFonts.beVietnamProTextTheme()`). Không cần khai báo lại trong từng màn hình.

### Spacing
- Page padding: `EdgeInsets.all(16)`
- Giữa các section/card: `SizedBox(height: 16)`
- Cuối màn hình: `SizedBox(height: 24)`
- Padding nội bộ card lớn: `EdgeInsets.all(20)`
- Padding nội bộ card list row: `EdgeInsets.symmetric(horizontal: 16, vertical: 14)`

### Shared widgets — dùng lại, không viết lại
- `InfoRow` (`shared/widgets/info_row.dart`) — dòng icon + text trong profile card
- Các widget chung mới sẽ được thêm vào `shared/widgets/` trong Phase 0

### 🚫 Không làm trong màn hình mới
- Hardcode màu hex thay vì `AppColors.*`
- Tạo `MaterialApp` hoặc `ThemeData` bên trong feature screen
- Dùng `Scaffold` mà không có `backgroundColor: AppColors.background`
- Copy-paste widget đã có trong `shared/widgets/` — import lại
- Đặt admin dark-theme tokens mới trong feature screen — dùng constants từ `admin_dashboard_screen.dart` cho đến khi tách ra file riêng

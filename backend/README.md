# RideVN Backend (Next.js API)

API cho nền tảng thuê xe RideVN. Kiến trúc phân lớp:
`Route Handler → Service → Repository → Prisma → PostgreSQL`.

## Lệnh thường dùng

```bash
npm run dev     # Dev server
npm test        # Vitest — phải pass trước khi commit
npm run lint    # Lint
npx prisma migrate dev --name <tên>   # Migrate DB
```

## Scheduled jobs (cron)

### Tự huỷ đơn quá hạn thanh toán

Đơn để ở trạng thái `PENDING_PAYMENT` quá `PAYMENT_REMINDER_HOURS` giờ (mặc định
**1 giờ**) kể từ `createdAt` mà chưa thanh toán sẽ **tự động bị huỷ**
(`CANCELLED`) và renter nhận **thông báo in-app** (không gửi email).

Việc quét do một **scheduler ngoài** kích hoạt qua endpoint được bảo vệ:

```
POST /api/cron/payment-reminders
Header: x-cron-secret: <CRON_SECRET>
```

- Header `x-cron-secret` phải khớp biến môi trường `CRON_SECRET`.
- Thiếu `CRON_SECRET` (chưa cấu hình) → `503 CRON_NOT_CONFIGURED`.
- Sai/thiếu header → `401 UNAUTHORIZED`.
- Thành công → `200 { success: true, data: { expired: <số đơn đã huỷ> } }`.

Mỗi lần quét xử lý tối đa 100 đơn (cũ nhất trước). Không cần cờ "đã xử lý":
sau khi huỷ, đơn rời khỏi `PENDING_PAYMENT` nên lần quét sau không chọn lại.

#### Biến môi trường

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `CRON_SECRET` | — (bắt buộc để bật) | Secret xác thực header `x-cron-secret`. Sinh: `openssl rand -hex 32` |
| `PAYMENT_REMINDER_HOURS` | `1` | Số giờ chờ thanh toán trước khi tự huỷ |

#### Ví dụ kích hoạt

**curl (test cục bộ):**

```bash
curl -X POST https://api.ridevn.app/api/cron/payment-reminders \
  -H "x-cron-secret: $CRON_SECRET"
```

**crontab (mỗi 10 phút):**

```cron
*/10 * * * * curl -fsS -X POST https://api.ridevn.app/api/cron/payment-reminders -H "x-cron-secret: ${CRON_SECRET}" >/dev/null 2>&1
```

**Vercel Cron** (`vercel.json`) — gọi định kỳ, kèm header secret qua cấu hình
job hoặc một wrapper route đọc `Authorization`/`x-cron-secret`:

```json
{
  "crons": [
    { "path": "/api/cron/payment-reminders", "schedule": "*/10 * * * *" }
  ]
}
```

-- Trạng thái mới: đã thanh toán, chờ chủ xe xác nhận (trước CONFIRMED).
-- ADD VALUE phải nằm ở migration riêng (không dùng chung transaction với chỗ
-- tham chiếu giá trị mới — Postgres cấm dùng enum value mới trong cùng txn).
ALTER TYPE "BookingStatus" ADD VALUE IF NOT EXISTS 'AWAITING_OWNER' AFTER 'PENDING_PAYMENT';

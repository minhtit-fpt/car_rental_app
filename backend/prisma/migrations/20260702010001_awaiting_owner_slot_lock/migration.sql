-- Khoá slot ngay khi khách thanh toán (AWAITING_OWNER), không chỉ khi CONFIRMED.
-- Người trả thứ 2 cho cùng khoảng giờ sẽ dính EXCLUDE constraint (23P01).
ALTER TABLE "Booking" DROP CONSTRAINT booking_no_overlap;

ALTER TABLE "Booking"
    ADD CONSTRAINT booking_no_overlap
    EXCLUDE USING gist (
        "vehicleId" WITH =,
        tstzrange("startTime", "endTime", '[)') WITH &&
    )
    WHERE ("status" IN ('AWAITING_OWNER', 'CONFIRMED', 'IN_PROGRESS'));

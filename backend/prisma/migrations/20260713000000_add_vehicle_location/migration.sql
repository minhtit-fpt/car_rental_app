-- GPS tracking: lưu điểm toạ độ xe theo thời gian (simulator/thiết bị POST vào).
CREATE TABLE "VehicleLocation" (
    "id" UUID NOT NULL,
    "vehicleId" UUID NOT NULL,
    "bookingId" UUID,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "speedKmh" DOUBLE PRECISION,
    "recordedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VehicleLocation_pkey" PRIMARY KEY ("id")
);

-- Truy vấn "điểm mới nhất theo xe" và trail lộ trình.
CREATE INDEX "VehicleLocation_vehicleId_recordedAt_idx"
    ON "VehicleLocation"("vehicleId", "recordedAt");

ALTER TABLE "VehicleLocation"
    ADD CONSTRAINT "VehicleLocation_vehicleId_fkey"
    FOREIGN KEY ("vehicleId") REFERENCES "Vehicle"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;

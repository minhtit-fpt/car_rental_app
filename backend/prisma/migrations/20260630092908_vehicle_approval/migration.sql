-- CreateEnum
CREATE TYPE "VehicleApprovalStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- AlterTable
ALTER TABLE "Vehicle" ADD COLUMN     "approvalStatus" "VehicleApprovalStatus" NOT NULL DEFAULT 'PENDING',
ADD COLUMN     "rejectionReason" TEXT;

-- CreateIndex
CREATE INDEX "Vehicle_approvalStatus_idx" ON "Vehicle"("approvalStatus");

-- Grandfather: mọi xe đang có trước migration coi như đã duyệt (không ẩn xe
-- đang hoạt động). Xe đăng mới sau này mặc định PENDING (cột default).
UPDATE "Vehicle" SET "approvalStatus" = 'APPROVED';

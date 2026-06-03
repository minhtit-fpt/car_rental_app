-- CreateEnum
CREATE TYPE "VehicleType" AS ENUM ('CAR', 'MOTORBIKE', 'BICYCLE');

-- CreateTable
CREATE TABLE "KYCVerification" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "cccdUrl" TEXT NOT NULL,
    "licenseUrl" TEXT NOT NULL,
    "faceUrl" TEXT NOT NULL,
    "status" "KycStatus" NOT NULL DEFAULT 'PENDING',
    "reviewedBy" UUID,
    "reviewedAt" TIMESTAMP(3),
    "rejectReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "KYCVerification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Vehicle" (
    "id" UUID NOT NULL,
    "ownerId" UUID NOT NULL,
    "type" "VehicleType" NOT NULL,
    "title" TEXT NOT NULL,
    "pricePerHour" DECIMAL(12,2) NOT NULL,
    "isElectric" BOOLEAN NOT NULL DEFAULT false,
    "isAvailable" BOOLEAN NOT NULL DEFAULT true,
    "deliveryAvailable" BOOLEAN NOT NULL DEFAULT false,
    "location" geography(Point, 4326) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Vehicle_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "KYCVerification_userId_key" ON "KYCVerification"("userId");

-- CreateIndex
CREATE INDEX "KYCVerification_status_idx" ON "KYCVerification"("status");

-- CreateIndex
CREATE INDEX "Vehicle_ownerId_idx" ON "Vehicle"("ownerId");

-- CreateIndex
CREATE INDEX "Vehicle_type_idx" ON "Vehicle"("type");

-- CreateIndex
CREATE INDEX "Vehicle_isAvailable_idx" ON "Vehicle"("isAvailable");

-- CreateIndex (PostGIS): GIST trên cột geography để truy vấn xe gần (ST_DWithin)
-- Tên khớp convention Prisma (@@index([location], type: Gist)) để migrate diff không bị drift.
CREATE INDEX "Vehicle_location_idx" ON "Vehicle" USING GIST ("location");

-- AddForeignKey
ALTER TABLE "KYCVerification" ADD CONSTRAINT "KYCVerification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Vehicle" ADD CONSTRAINT "Vehicle_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

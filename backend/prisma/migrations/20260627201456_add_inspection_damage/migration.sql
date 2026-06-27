-- CreateEnum
CREATE TYPE "InspectionPhase" AS ENUM ('CHECKIN', 'CHECKOUT');

-- CreateTable
CREATE TABLE "Inspection" (
    "id" UUID NOT NULL,
    "bookingId" UUID NOT NULL,
    "phase" "InspectionPhase" NOT NULL,
    "photoKeys" TEXT[],
    "createdById" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Inspection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DamageReport" (
    "id" UUID NOT NULL,
    "bookingId" UUID NOT NULL,
    "summary" TEXT NOT NULL,
    "items" JSONB NOT NULL,
    "estimatedCost" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DamageReport_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Inspection_bookingId_idx" ON "Inspection"("bookingId");

-- CreateIndex
CREATE UNIQUE INDEX "Inspection_bookingId_phase_key" ON "Inspection"("bookingId", "phase");

-- CreateIndex
CREATE UNIQUE INDEX "DamageReport_bookingId_key" ON "DamageReport"("bookingId");

-- AddForeignKey
ALTER TABLE "Inspection" ADD CONSTRAINT "Inspection_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DamageReport" ADD CONSTRAINT "DamageReport_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

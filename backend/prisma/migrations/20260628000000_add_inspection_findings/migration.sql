-- AddColumn: per-phase VLM findings on Inspection
ALTER TABLE "Inspection"
  ADD COLUMN "findingsSummary" TEXT,
  ADD COLUMN "findings" JSONB,
  ADD COLUMN "analyzedAt" TIMESTAMP(3);

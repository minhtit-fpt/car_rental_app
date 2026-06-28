import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/repositories/booking.repository", () => ({
  bookingRepository: { findByIdForOwner: vi.fn() },
}));
vi.mock("@/lib/repositories/inspection.repository", () => ({
  inspectionRepository: {
    upsertInspection: vi.fn(),
    updateFindings: vi.fn(),
  },
}));
vi.mock("@/lib/storage", () => ({
  storage: { getBytes: vi.fn() },
}));
vi.mock("@/lib/ai/vlm.client", () => ({ vlmClient: { detectDamage: vi.fn() } }));
vi.mock("@/lib/services/notification.events", () => ({
  notificationEvents: { inspectionDamageFound: vi.fn() },
}));

import { inspectionService } from "@/lib/services/inspection.service";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { inspectionRepository } from "@/lib/repositories/inspection.repository";
import { storage } from "@/lib/storage";
import { vlmClient } from "@/lib/ai/vlm.client";
import { notificationEvents } from "@/lib/services/notification.events";

const booking = {
  id: "b-1",
  renterId: "renter-1",
  vehicle: { ownerId: "owner-1" },
} as never;

const input = {
  phase: "CHECKIN" as const,
  photoKeys: ["inspections/b-1/checkin/a.jpg"],
};

beforeEach(() => {
  vi.clearAllMocks();
  vi.mocked(bookingRepository.findByIdForOwner).mockResolvedValue(booking);
  vi.mocked(inspectionRepository.upsertInspection).mockResolvedValue({
    phase: "CHECKIN",
    photoKeys: input.photoKeys,
  } as never);
  vi.mocked(storage.getBytes).mockResolvedValue(Buffer.from(""));
});

describe("inspectionService.submit per-phase detection", () => {
  it("stores findings and notifies both parties when damage is found", async () => {
    vi.mocked(vlmClient.detectDamage).mockResolvedValue({
      summary: "Trầy cửa trái",
      items: [{ label: "trầy", severity: "minor", description: "cửa trái" }],
      estimatedCost: 0,
    });

    const result = await inspectionService.submit("renter-1", "b-1", input);

    expect(result.findings).toEqual({ summary: "Trầy cửa trái", damageCount: 1 });
    expect(inspectionRepository.updateFindings).toHaveBeenCalledOnce();
    expect(notificationEvents.inspectionDamageFound).toHaveBeenCalledWith(
      expect.objectContaining({ renterId: "renter-1", ownerId: "owner-1" }),
    );
  });

  it("does not notify when no damage is found", async () => {
    vi.mocked(vlmClient.detectDamage).mockResolvedValue({
      summary: "Xe sạch",
      items: [],
      estimatedCost: 0,
    });

    const result = await inspectionService.submit("renter-1", "b-1", input);

    expect(result.findings).toEqual({ summary: "Xe sạch", damageCount: 0 });
    expect(notificationEvents.inspectionDamageFound).not.toHaveBeenCalled();
  });

  it("still succeeds with null findings when VLM is unavailable", async () => {
    vi.mocked(vlmClient.detectDamage).mockRejectedValue(new Error("VLM down"));

    const result = await inspectionService.submit("renter-1", "b-1", input);

    expect(result.photoCount).toBe(1);
    expect(result.findings).toBeNull();
    expect(notificationEvents.inspectionDamageFound).not.toHaveBeenCalled();
  });
});

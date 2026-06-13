import { describe, expect, it } from "vitest";
import {
  reviewKycSchema,
  submitKycSchema,
  uploadUrlSchema,
} from "@/lib/validators/kyc.validator";

describe("uploadUrlSchema", () => {
  it("accepts a valid docType + image content-type", () => {
    const parsed = uploadUrlSchema.parse({
      docType: "cccd",
      contentType: "image/jpeg",
    });
    expect(parsed).toEqual({ docType: "cccd", contentType: "image/jpeg" });
  });

  it("rejects a non-image content-type", () => {
    expect(() =>
      uploadUrlSchema.parse({ docType: "cccd", contentType: "application/pdf" }),
    ).toThrow();
  });

  it("rejects an unknown docType", () => {
    expect(() =>
      uploadUrlSchema.parse({ docType: "passport", contentType: "image/png" }),
    ).toThrow();
  });
});

describe("submitKycSchema", () => {
  it("requires all three document keys", () => {
    const parsed = submitKycSchema.parse({
      cccdKey: "kyc/u1/cccd-1",
      licenseKey: "kyc/u1/license-1",
      faceKey: "kyc/u1/face-1",
    });
    expect(parsed.faceKey).toBe("kyc/u1/face-1");
  });

  it("rejects when a key is missing", () => {
    expect(() =>
      submitKycSchema.parse({
        cccdKey: "kyc/u1/cccd-1",
        licenseKey: "kyc/u1/license-1",
      }),
    ).toThrow();
  });
});

describe("reviewKycSchema", () => {
  it("accepts approve without a reason", () => {
    expect(reviewKycSchema.parse({ decision: "approve" })).toEqual({
      decision: "approve",
    });
  });

  it("requires rejectReason when rejecting", () => {
    expect(() => reviewKycSchema.parse({ decision: "reject" })).toThrow();
  });

  it("accepts reject with a reason", () => {
    const parsed = reviewKycSchema.parse({
      decision: "reject",
      rejectReason: "Ảnh CCCD bị mờ",
    });
    expect(parsed.rejectReason).toBe("Ảnh CCCD bị mờ");
  });
});

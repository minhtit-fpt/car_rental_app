import { describe, expect, it } from "vitest";
import { normalizeVietnamPhone } from "@/lib/utils/phone";

describe("normalizeVietnamPhone", () => {
  it("normalizes 0-prefixed numbers", () => {
    expect(normalizeVietnamPhone("0901234567")).toBe("+84901234567");
  });

  it("normalizes +84 numbers", () => {
    expect(normalizeVietnamPhone("+84901234567")).toBe("+84901234567");
  });

  it("normalizes 84 numbers", () => {
    expect(normalizeVietnamPhone("84901234567")).toBe("+84901234567");
  });

  it("strips spaces and dashes", () => {
    expect(normalizeVietnamPhone("090 123 45 67")).toBe("+84901234567");
  });

  it("rejects too-short numbers", () => {
    expect(normalizeVietnamPhone("0901")).toBeNull();
  });

  it("rejects invalid leading digit", () => {
    expect(normalizeVietnamPhone("0101234567")).toBeNull();
  });
});

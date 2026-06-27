import { describe, expect, it } from "vitest";
import { parseDamageAnalysis } from "@/lib/ai/vlm.client";
import { AppError } from "@/lib/errors/app-error";

describe("parseDamageAnalysis", () => {
  it("parses a clean JSON response", () => {
    const result = parseDamageAnalysis(
      '{"summary":"Có vết trầy mới","items":[{"label":"trầy xước","severity":"minor","description":"cửa trái"}],"estimatedCost":500000}',
    );
    expect(result.items).toHaveLength(1);
    expect(result.items[0].severity).toBe("minor");
    expect(result.estimatedCost).toBe(500000);
  });

  it("strips markdown code fences and surrounding prose", () => {
    const result = parseDamageAnalysis(
      'Đây là kết quả:\n```json\n{"summary":"ok","items":[],"estimatedCost":0}\n```',
    );
    expect(result.items).toHaveLength(0);
    expect(result.estimatedCost).toBe(0);
  });

  it("defaults missing optional fields", () => {
    const result = parseDamageAnalysis('{"items":[]}');
    expect(result.summary).toBe("");
    expect(result.estimatedCost).toBe(0);
  });

  it("throws VLM_BAD_RESPONSE when there is no JSON object", () => {
    expect(() => parseDamageAnalysis("xin lỗi tôi không biết")).toThrow(
      AppError,
    );
  });

  it("throws VLM_BAD_RESPONSE on an invalid severity enum", () => {
    expect(() =>
      parseDamageAnalysis(
        '{"summary":"x","items":[{"label":"a","severity":"catastrophic","description":""}],"estimatedCost":0}',
      ),
    ).toThrow("sai cấu trúc");
  });

  it("throws VLM_BAD_RESPONSE on malformed JSON", () => {
    expect(() => parseDamageAnalysis('{"items": [},')).toThrow(AppError);
  });
});

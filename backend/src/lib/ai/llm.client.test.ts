import { describe, expect, it } from "vitest";
import { parseJsonFromText } from "@/lib/ai/llm.client";
import { AppError } from "@/lib/errors/app-error";

describe("parseJsonFromText", () => {
  it("parses a clean JSON object", () => {
    expect(parseJsonFromText('{"key":"top_vehicles"}')).toEqual({
      key: "top_vehicles",
    });
  });

  it("strips code fences and surrounding prose", () => {
    expect(
      parseJsonFromText('Kết quả:\n```json\n{"key":"totals"}\n```'),
    ).toEqual({ key: "totals" });
  });

  it("throws when there is no JSON object", () => {
    expect(() => parseJsonFromText("không biết")).toThrow(AppError);
  });

  it("throws on malformed JSON", () => {
    expect(() => parseJsonFromText('{"key": ]')).toThrow(AppError);
  });
});

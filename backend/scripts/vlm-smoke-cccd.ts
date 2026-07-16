// Smoke test VLM qua đúng client của hệ thống (vlm.client.ts):
// đưa 1 ảnh bất kỳ vào detectDamage như luồng giám định giao/trả xe.
// Chạy: npx tsx --env-file=.env scripts/vlm-smoke-cccd.ts <đường-dẫn-ảnh>
import { readFileSync } from "node:fs";
import { vlmClient } from "@/lib/ai/vlm.client";

async function main(): Promise<void> {
  const path = process.argv[2];
  if (!path) throw new Error("Usage: tsx vlm-smoke-cccd.ts <image>");
  const bytes = readFileSync(path);
  const started = Date.now();
  const result = await vlmClient.detectDamage([
    { contentType: "image/jpeg", bytes },
  ]);
  const elapsed = ((Date.now() - started) / 1000).toFixed(1);
  console.log(`⏱  ${elapsed}s`);
  console.log(JSON.stringify(result, null, 2));
}

main().catch((e) => {
  console.error("FAILED:", e instanceof Error ? e.message : e);
  process.exit(1);
});

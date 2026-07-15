import { z } from "zod";

// Body ingest điểm GPS (simulator hoặc thiết bị thật POST vào).
export const ingestLocationSchema = z.object({
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  speedKmh: z.number().min(0).max(400).optional(),
});

export type IngestLocationInput = z.infer<typeof ingestLocationSchema>;

// Query cho GET latest: số điểm trail muốn kèm (vẽ đuôi lộ trình).
export const latestQuerySchema = z.object({
  trail: z.coerce.number().int().min(0).max(100).default(0),
});

export type LatestQueryInput = z.infer<typeof latestQuerySchema>;

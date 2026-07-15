import { z } from "zod";

// Validate biến môi trường tại biên hệ thống. getEnv() đọc & kiểm tra
// process.env mỗi lần gọi (fail-fast khi thiếu cấu hình), không cache để
// dễ test và an toàn với hot-reload của Next.

const envSchema = z.object({
  DATABASE_URL: z.string().min(1, "DATABASE_URL là bắt buộc"),
  REDIS_URL: z.string().min(1, "REDIS_URL là bắt buộc"),
  JWT_ACCESS_SECRET: z
    .string()
    .min(32, "JWT_ACCESS_SECRET phải tối thiểu 32 ký tự"),
  JWT_ACCESS_TTL: z.string().min(1).default("15m"),
  JWT_REFRESH_TTL_DAYS: z.coerce.number().int().positive().default(30),
  // Khoá thiết bị GPS (simulator/hộp đen) để POST toạ độ. Không đặt → ingest bị
  // từ chối (fail-closed), không mở endpoint.
  TRACKING_DEVICE_KEY: z.string().min(1).optional(),
  NODE_ENV: z
    .enum(["development", "test", "production"])
    .default("development"),
});

export type Env = z.infer<typeof envSchema>;

export function getEnv(): Env {
  const parsed = envSchema.safeParse(process.env);

  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((issue) => `  - ${issue.path.join(".")}: ${issue.message}`)
      .join("\n");
    throw new Error(`Biến môi trường không hợp lệ:\n${issues}`);
  }

  return parsed.data;
}

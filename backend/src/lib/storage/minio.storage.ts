import { Client } from "minio";
import { z } from "zod";
import type { StoragePort } from "./storage.port";

// Adapter MinIO cho StoragePort. Env được validate LAZY (chỉ khi thực sự gọi
// storage) để không ép các luồng khác — như auth — phải có cấu hình MinIO.

const storageEnvSchema = z.object({
  MINIO_ENDPOINT: z.string().min(1, "MINIO_ENDPOINT là bắt buộc"),
  MINIO_PORT: z.coerce.number().int().positive().default(9000),
  MINIO_USE_SSL: z
    .enum(["true", "false"])
    .default("false")
    .transform((v) => v === "true"),
  MINIO_ACCESS_KEY: z.string().min(1, "MINIO_ACCESS_KEY là bắt buộc"),
  MINIO_SECRET_KEY: z.string().min(1, "MINIO_SECRET_KEY là bắt buộc"),
  MINIO_KYC_BUCKET: z.string().min(1).default("kyc-private"),
});

// Presigned URL ngắn hạn — đủ để client upload/admin xem, không để rò rỉ lâu.
const UPLOAD_TTL_SECONDS = 5 * 60;
const DOWNLOAD_TTL_SECONDS = 5 * 60;

let cached: { client: Client; bucket: string } | undefined;

function getClient(): { client: Client; bucket: string } {
  if (cached) return cached;

  const parsed = storageEnvSchema.safeParse(process.env);
  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((issue) => `  - ${issue.path.join(".")}: ${issue.message}`)
      .join("\n");
    throw new Error(`Cấu hình MinIO không hợp lệ:\n${issues}`);
  }
  const env = parsed.data;

  cached = {
    client: new Client({
      endPoint: env.MINIO_ENDPOINT,
      port: env.MINIO_PORT,
      useSSL: env.MINIO_USE_SSL,
      accessKey: env.MINIO_ACCESS_KEY,
      secretKey: env.MINIO_SECRET_KEY,
    }),
    bucket: env.MINIO_KYC_BUCKET,
  };
  return cached;
}

export const minioStorage: StoragePort = {
  presignUpload(objectKey: string): Promise<string> {
    const { client, bucket } = getClient();
    return client.presignedPutObject(bucket, objectKey, UPLOAD_TTL_SECONDS);
  },

  presignDownload(objectKey: string): Promise<string> {
    const { client, bucket } = getClient();
    return client.presignedGetObject(bucket, objectKey, DOWNLOAD_TTL_SECONDS);
  },

  async getBytes(objectKey: string): Promise<Buffer> {
    const { client, bucket } = getClient();
    const stream = await client.getObject(bucket, objectKey);
    const chunks: Buffer[] = [];
    for await (const chunk of stream) {
      chunks.push(chunk as Buffer);
    }
    return Buffer.concat(chunks);
  },
};

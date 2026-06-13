import type { StoragePort } from "./storage.port";
import { minioStorage } from "./minio.storage";

// Điểm truy cập storage duy nhất cho tầng service. Đổi nhà cung cấp tại đây.
export const storage: StoragePort = minioStorage;

export type { StoragePort } from "./storage.port";

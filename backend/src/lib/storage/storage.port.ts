// Cổng lưu trữ đối tượng (bucket private MinIO/S3). Interface tách khỏi SDK
// cụ thể để service/test không phụ thuộc vào nhà cung cấp.
//
// LƯU Ý BẢO MẬT: ảnh KYC (CCCD, bằng lái, khuôn mặt) nằm trong bucket PRIVATE.
// Không bao giờ trả public URL — chỉ phát presigned URL ngắn hạn.

export type KycDocType = "cccd" | "license" | "face";

export interface PresignedUpload {
  // URL presigned (PUT) để client upload thẳng lên bucket private.
  uploadUrl: string;
  // Khóa đối tượng được lưu vào DB (KHÔNG phải public URL).
  objectKey: string;
}

export interface StoragePort {
  // Cấp presigned PUT để client upload thẳng object key lên bucket private.
  presignUpload(objectKey: string): Promise<string>;
  // Cấp presigned GET ngắn hạn để ADMIN xem ảnh khi duyệt KYC.
  presignDownload(objectKey: string): Promise<string>;
}

import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint `/api/kyc/*`.
class KycRemoteDataSource {
  const KycRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/kyc/status` → trạng thái KYC hiện tại.
  Future<Map<String, dynamic>> status() async {
    final data = await _client.get('/api/kyc/status');
    return data as Map<String, dynamic>;
  }

  /// `POST /api/kyc/upload-url` → `{uploadUrl, objectKey}` để upload presigned.
  /// [docType] ∈ {cccd, license, face}; [contentType] ∈ {image/jpeg, image/png}.
  Future<Map<String, dynamic>> createUploadUrl({
    required String docType,
    required String contentType,
  }) async {
    final data = await _client.post(
      '/api/kyc/upload-url',
      data: {'docType': docType, 'contentType': contentType},
    );
    return data as Map<String, dynamic>;
  }

  /// PUT ảnh lên [uploadUrl] (presigned). Trả về khi lưu trữ nhận xong.
  Future<void> uploadBinary({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) => _client.putBinary(uploadUrl, bytes, contentType: contentType);

  /// `POST /api/kyc/submit` → tạo hồ sơ KYC từ 3 object key đã upload.
  Future<Map<String, dynamic>> submit({
    required String cccdKey,
    required String licenseKey,
    required String faceKey,
  }) async {
    final data = await _client.post(
      '/api/kyc/submit',
      data: {'cccdKey': cccdKey, 'licenseKey': licenseKey, 'faceKey': faceKey},
    );
    return data as Map<String, dynamic>;
  }
}

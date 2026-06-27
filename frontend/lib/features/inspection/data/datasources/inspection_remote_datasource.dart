import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint kiểm tra xe + báo cáo hư hỏng trên backend Next.js.
class InspectionRemoteDataSource {
  const InspectionRemoteDataSource(this._client);

  final ApiClient _client;

  /// `POST /api/bookings/:id/inspections/upload-url` → `{uploadUrl, objectKey}`.
  Future<Map<String, dynamic>> createUploadUrl({
    required String bookingId,
    required String phase,
    required String contentType,
  }) async {
    final data = await _client.post(
      '/api/bookings/$bookingId/inspections/upload-url',
      data: {'phase': phase, 'contentType': contentType},
    );
    return data as Map<String, dynamic>;
  }

  /// PUT ảnh lên presigned URL (MinIO).
  Future<void> uploadBinary({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) => _client.putBinary(uploadUrl, bytes, contentType: contentType);

  /// `PUT /api/bookings/:id/inspections` → lưu bộ ảnh của một phase.
  Future<void> submit({
    required String bookingId,
    required String phase,
    required List<String> photoKeys,
  }) => _client.put(
    '/api/bookings/$bookingId/inspections',
    data: {'phase': phase, 'photoKeys': photoKeys},
  );

  /// `POST /api/bookings/:id/damage-report` → chạy VLM, trả báo cáo.
  Future<Map<String, dynamic>> analyze(String bookingId) async {
    final data = await _client.post('/api/bookings/$bookingId/damage-report');
    return data as Map<String, dynamic>;
  }

  /// `GET /api/bookings/:id/damage-report` → báo cáo đã lưu.
  Future<Map<String, dynamic>> getReport(String bookingId) async {
    final data = await _client.get('/api/bookings/$bookingId/damage-report');
    return data as Map<String, dynamic>;
  }
}

import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint `/api/admin/*` (đã chặn role ADMIN ở backend).
class AdminRemoteDataSource {
  const AdminRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> stats() async {
    final data = await _client.get('/api/admin/stats');
    return data as Map<String, dynamic>;
  }

  /// Tổng hợp số liệu dashboard (1 object gồm kpi + các nhóm aggregation).
  Future<Map<String, dynamic>> metrics() async {
    final data = await _client.get('/api/admin/metrics');
    return data as Map<String, dynamic>;
  }

  /// Trả về phần `items` của envelope phân trang.
  Future<List<dynamic>> users({required int limit}) async {
    final data = await _client.get('/api/admin/users', query: {'limit': limit});
    return (data as Map<String, dynamic>)['items'] as List<dynamic>;
  }

  Future<List<dynamic>> kyc({required int limit}) async {
    final data = await _client.get('/api/admin/kyc', query: {'limit': limit});
    return (data as Map<String, dynamic>)['items'] as List<dynamic>;
  }

  /// Presigned URL 3 giấy tờ KYC (ADMIN-only, dùng khi duyệt).
  Future<Map<String, dynamic>> kycDocuments(String id) async {
    final data = await _client.get('/api/kyc/$id/documents');
    return data as Map<String, dynamic>;
  }

  /// Duyệt/từ chối KYC. `decision` ∈ {approve, reject}; reject cần `rejectReason`.
  Future<void> reviewKyc(
    String id, {
    required String decision,
    String? rejectReason,
  }) async {
    final body = <String, dynamic>{'decision': decision};
    if (rejectReason != null) body['rejectReason'] = rejectReason;
    await _client.post('/api/kyc/$id/review', data: body);
  }

  /// Chuỗi doanh thu theo tháng (endpoint trả mảng phẳng).
  Future<List<dynamic>> revenue({required int months}) async {
    final data = await _client.get(
      '/api/admin/revenue',
      query: {'months': months},
    );
    return data as List<dynamic>;
  }

  /// Hàng đợi tranh chấp — phần `items` của envelope phân trang.
  Future<List<dynamic>> disputes({required int limit}) async {
    final data = await _client.get(
      '/api/admin/disputes',
      query: {'limit': limit},
    );
    return (data as Map<String, dynamic>)['items'] as List<dynamic>;
  }

  /// Giải quyết/bác bỏ tranh chấp. `decision` ∈ {resolve, reject}; `note` tuỳ chọn.
  Future<void> resolveDispute(
    String id, {
    required String decision,
    String? note,
  }) async {
    final body = <String, dynamic>{'decision': decision};
    if (note != null) body['note'] = note;
    await _client.patch('/api/admin/disputes/$id', data: body);
  }

  /// Hàng đợi duyệt xe — phần `items` của envelope phân trang.
  Future<List<dynamic>> vehicles({
    required String status,
    required int limit,
  }) async {
    final data = await _client.get(
      '/api/admin/vehicles',
      query: {'status': status, 'limit': limit},
    );
    return (data as Map<String, dynamic>)['items'] as List<dynamic>;
  }

  /// Duyệt/từ chối xe. `decision` ∈ {approve, reject}; reject cần `rejectionReason`.
  Future<void> reviewVehicle(
    String id, {
    required String decision,
    String? rejectionReason,
  }) async {
    final body = <String, dynamic>{'decision': decision};
    if (rejectionReason != null) body['rejectionReason'] = rejectionReason;
    await _client.patch('/api/admin/vehicles/$id', data: body);
  }

  /// Bật/tắt vai trò user. `role` = 'OWNER'; `action` ∈ {add, remove}.
  Future<Map<String, dynamic>> updateUserRole(
    String id, {
    required String role,
    required String action,
  }) async {
    final data = await _client.patch(
      '/api/admin/users/$id',
      data: {'role': role, 'action': action},
    );
    return data as Map<String, dynamic>;
  }
}

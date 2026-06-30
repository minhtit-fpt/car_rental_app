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

  /// Hàng đợi rủi ro (endpoint trả mảng phẳng đã xếp điểm giảm dần).
  Future<List<dynamic>> risk() async {
    final data = await _client.get('/api/admin/risk');
    return data as List<dynamic>;
  }

  /// Danh sách đơn — phần `items` của envelope phân trang. Lọc tuỳ chọn theo
  /// trạng thái + khoảng ngày (ISO).
  Future<List<dynamic>> bookings({
    required int limit,
    String? status,
    String? from,
    String? to,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    if (status != null) query['status'] = status;
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;
    final data = await _client.get('/api/admin/bookings', query: query);
    return (data as Map<String, dynamic>)['items'] as List<dynamic>;
  }

  /// Chi tiết một đơn (payment/contract/inspection/dispute).
  Future<Map<String, dynamic>> bookingDetail(String id) async {
    final data = await _client.get('/api/admin/bookings/$id');
    return data as Map<String, dynamic>;
  }

  /// Hoàn tiền một đơn (đánh dấu REFUNDED). `reason` bắt buộc.
  Future<Map<String, dynamic>> refundPayment(
    String id, {
    required double amount,
    required String reason,
  }) async {
    final data = await _client.post(
      '/api/admin/bookings/$id/refund',
      data: {'amount': amount, 'reason': reason},
    );
    return data as Map<String, dynamic>;
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

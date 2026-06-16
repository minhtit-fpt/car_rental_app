import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint `/api/admin/*` (đã chặn role ADMIN ở backend).
class AdminRemoteDataSource {
  const AdminRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> stats() async {
    final data = await _client.get('/api/admin/stats');
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
}

import 'package:dio/dio.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/features/vehicle/data/models/vehicle_mapper.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/vehicle_exception.dart';

class VehicleRemoteDataSource {
  const VehicleRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Vehicle>> getVehicles({
    VehicleType? type,
    bool? isElectric,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        VehicleEndpoints.list,
        queryParameters: {
          if (type != null) 'type': type.wireValue,
          if (isElectric != null) 'isElectric': isElectric.toString(),
          'page': page,
          'limit': limit,
        },
      );
      final data = _data(res) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items
          .map((e) => vehicleFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Vehicle> getById(String id) async {
    try {
      final res = await _dio.get<dynamic>(VehicleEndpoints.detail(id));
      return vehicleFromJson(_data(res) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  dynamic _data(Response<dynamic> res) {
    final body = res.data as Map<String, dynamic>;
    return body['data'];
  }

  VehicleException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return VehicleException(
        (data['error'] as String?) ?? 'Đã xảy ra lỗi',
        code: data['code'] as String?,
      );
    }
    return const VehicleException('Không thể kết nối tới máy chủ');
  }
}

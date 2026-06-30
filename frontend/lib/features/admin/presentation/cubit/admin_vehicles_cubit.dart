import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_vehicles_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/review_vehicle_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_vehicles_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_vehicles_state.dart';

/// Hàng đợi duyệt xe (PENDING) + thao tác duyệt/từ chối ngay trên danh sách.
class AdminVehiclesCubit extends Cubit<AdminVehiclesState> {
  AdminVehiclesCubit({
    required ListAdminVehiclesUseCase listVehicles,
    required ReviewVehicleUseCase reviewVehicle,
  }) : _listVehicles = listVehicles,
       _reviewVehicle = reviewVehicle,
       super(const AdminVehiclesLoading());

  final ListAdminVehiclesUseCase _listVehicles;
  final ReviewVehicleUseCase _reviewVehicle;

  Future<void> load() async {
    emit(const AdminVehiclesLoading());
    try {
      emit(AdminVehiclesLoaded(await _listVehicles()));
    } on ApiException catch (e) {
      emit(AdminVehiclesError(e.message));
    }
  }

  /// Duyệt/từ chối rồi tải lại hàng đợi. Trả về null nếu thành công, hoặc
  /// thông điệp lỗi để màn hình hiện SnackBar.
  Future<String?> review(
    String id, {
    required String decision,
    String? rejectionReason,
  }) async {
    try {
      await _reviewVehicle(
        id,
        decision: decision,
        rejectionReason: rejectionReason,
      );
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_bookings_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_bookings_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_bookings_state.dart';

/// Danh sách đơn cho ADMIN + lọc theo trạng thái.
class AdminBookingsCubit extends Cubit<AdminBookingsState> {
  AdminBookingsCubit({required ListAdminBookingsUseCase listBookings})
    : _listBookings = listBookings,
      super(const AdminBookingsLoading());

  final ListAdminBookingsUseCase _listBookings;

  String? _status;

  Future<void> load({String? status}) async {
    _status = status;
    emit(const AdminBookingsLoading());
    try {
      final items = await _listBookings(status: status);
      emit(AdminBookingsLoaded(items, status: status));
    } on ApiException catch (e) {
      emit(AdminBookingsError(e.message));
    }
  }

  /// Đổi bộ lọc trạng thái rồi tải lại.
  Future<void> filterByStatus(String? status) => load(status: status);

  Future<void> refresh() => load(status: _status);
}

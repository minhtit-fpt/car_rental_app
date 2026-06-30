import 'package:frontend/features/admin/domain/entities/admin_vehicle_item.dart';

sealed class AdminVehiclesState {
  const AdminVehiclesState();
}

final class AdminVehiclesLoading extends AdminVehiclesState {
  const AdminVehiclesLoading();
}

final class AdminVehiclesLoaded extends AdminVehiclesState {
  const AdminVehiclesLoaded(this.items);
  final List<AdminVehicleItem> items;
}

final class AdminVehiclesError extends AdminVehiclesState {
  const AdminVehiclesError(this.message);
  final String message;
}

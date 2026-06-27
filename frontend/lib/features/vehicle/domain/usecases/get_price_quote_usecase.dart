import 'package:frontend/features/vehicle/domain/entities/price_quote.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Lấy báo giá động (breakdown surge) cho 1 xe + khoảng thời gian thuê.
class GetPriceQuoteUseCase {
  const GetPriceQuoteUseCase(this._repository);

  final VehicleRepository _repository;

  Future<PriceQuote> call({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
  }) => _repository.getPriceQuote(
    vehicleId: vehicleId,
    startTime: startTime,
    endTime: endTime,
  );
}

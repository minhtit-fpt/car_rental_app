import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/loyalty/domain/usecases/get_loyalty_summary_usecase.dart';
import 'package:frontend/features/loyalty/presentation/cubit/loyalty_state.dart';

export 'package:frontend/features/loyalty/presentation/cubit/loyalty_state.dart';

/// Nạp tổng quan điểm thưởng của người dùng hiện tại.
class LoyaltyCubit extends Cubit<LoyaltyState> {
  LoyaltyCubit({required GetLoyaltySummaryUseCase getSummary})
    : _getSummary = getSummary,
      super(const LoyaltyLoading());

  final GetLoyaltySummaryUseCase _getSummary;

  Future<void> load() async {
    emit(const LoyaltyLoading());
    try {
      emit(LoyaltyLoaded(await _getSummary()));
    } on ApiException catch (e) {
      emit(LoyaltyError(e.message));
    }
  }
}

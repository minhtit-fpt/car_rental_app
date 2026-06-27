import 'package:frontend/features/loyalty/domain/entities/loyalty.dart';

sealed class LoyaltyState {
  const LoyaltyState();
}

final class LoyaltyLoading extends LoyaltyState {
  const LoyaltyLoading();
}

final class LoyaltyLoaded extends LoyaltyState {
  const LoyaltyLoaded(this.summary);
  final LoyaltySummary summary;
}

final class LoyaltyError extends LoyaltyState {
  const LoyaltyError(this.message);
  final String message;
}

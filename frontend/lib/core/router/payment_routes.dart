import 'package:go_router/go_router.dart';
import 'package:frontend/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:frontend/features/payment/presentation/screens/payment_screen.dart';
import 'package:frontend/features/review/presentation/screens/review_screen.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

final paymentRoutes = [
  GoRoute(
    path: '/payment',
    builder: (context, state) {
      final amount = state.extra as double? ?? 0.0;
      return PaymentScreen(amount: amount);
    },
  ),
  GoRoute(
    path: '/payment/result',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return PaymentResultScreen(
        success: args['success'] as bool,
        amount: args['amount'] as double,
      );
    },
  ),
  GoRoute(
    path: '/review',
    builder: (context, state) {
      final vehicle = state.extra as Vehicle;
      return ReviewScreen(vehicle: vehicle);
    },
  ),
];

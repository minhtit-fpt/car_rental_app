import 'package:go_router/go_router.dart';
import 'package:frontend/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:frontend/features/payment/presentation/screens/payment_screen.dart';
import 'package:frontend/features/review/presentation/screens/review_screen.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

final paymentRoutes = [
  GoRoute(
    path: '/payment',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return PaymentScreen(
        bookingId: args['bookingId'] as String,
        amount: args['amount'] as double,
        successLocation: args['successLocation'] as String?,
        successExtra: args['successExtra'],
      );
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
      final args = state.extra as Map<String, dynamic>;
      return ReviewScreen(
        bookingId: args['bookingId'] as String,
        vehicle: args['vehicle'] as Vehicle,
      );
    },
  ),
];

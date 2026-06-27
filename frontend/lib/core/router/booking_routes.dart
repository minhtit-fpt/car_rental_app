import 'package:go_router/go_router.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/booking/presentation/screens/active_trip_screen.dart';
import 'package:frontend/features/booking/presentation/screens/booking_confirm_screen.dart';
import 'package:frontend/features/booking/presentation/screens/booking_date_picker_screen.dart';
import 'package:frontend/features/booking/presentation/screens/contract_screen.dart';
import 'package:frontend/features/booking/presentation/screens/my_trips_screen.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

final bookingRoutes = [
  // Mở danh sách chuyến độc lập (dùng khi điều hướng từ thông báo).
  GoRoute(
    path: '/trips',
    builder: (context, state) => const MyTripsScreen(),
  ),
  GoRoute(
    path: '/booking/dates',
    builder: (context, state) {
      final vehicle = state.extra as Vehicle;
      return BookingDatePickerScreen(vehicle: vehicle);
    },
  ),
  GoRoute(
    path: '/booking/confirm',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return BookingConfirmScreen(
        vehicle: args['vehicle'] as Vehicle,
        cubit: args['cubit'] as BookingCubit,
      );
    },
  ),
  GoRoute(
    path: '/booking/contract',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return ContractScreen(
        vehicle: args['vehicle'] as Vehicle,
        cubit: args['cubit'] as BookingCubit,
      );
    },
  ),
  GoRoute(
    path: '/booking/active',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return ActiveTripScreen(
        vehicle: args['vehicle'] as Vehicle,
        cubit: args['cubit'] as BookingCubit,
      );
    },
  ),
];

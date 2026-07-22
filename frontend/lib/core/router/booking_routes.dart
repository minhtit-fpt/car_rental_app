import 'package:go_router/go_router.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/booking/presentation/screens/active_trip_screen.dart';
import 'package:frontend/features/booking/presentation/screens/booking_confirm_screen.dart';
import 'package:frontend/features/booking/presentation/screens/booking_date_picker_screen.dart';
import 'package:frontend/features/booking/presentation/screens/booking_detail_loader_screen.dart';
import 'package:frontend/features/booking/presentation/screens/booking_detail_screen.dart';
import 'package:frontend/features/booking/presentation/screens/contract_screen.dart';
import 'package:frontend/features/booking/presentation/screens/my_trips_screen.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/inspection/presentation/screens/vehicle_inspection_screen.dart';
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
  // Chi tiết một đơn (mở từ tab "Chuyến"). Booking truyền qua extra.
  GoRoute(
    path: '/trips/detail',
    builder: (context, state) =>
        BookingDetailScreen(booking: state.extra as Booking),
  ),
  // Mở thẳng chi tiết một đơn theo bookingId (dùng khi tap từ thông báo,
  // nơi chỉ có id chứ không có Booking đầy đủ qua `extra`).
  GoRoute(
    path: '/trips/detail/:bookingId',
    builder: (context, state) => BookingDetailLoaderScreen(
      bookingId: state.pathParameters['bookingId']!,
    ),
  ),
  // Kiểm tra xe + AI nhận diện hư hỏng (check-in/check-out).
  GoRoute(
    path: '/inspection/:bookingId',
    builder: (context, state) => VehicleInspectionScreen(
      bookingId: state.pathParameters['bookingId']!,
    ),
  ),
];

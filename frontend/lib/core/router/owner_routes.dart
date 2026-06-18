import 'package:go_router/go_router.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/presentation/screens/add_edit_vehicle_screen.dart';
import 'package:frontend/features/owner/presentation/screens/booking_request_detail_screen.dart';
import 'package:frontend/features/owner/presentation/screens/revenue_report_screen.dart';
import 'package:frontend/features/owner/presentation/screens/vehicle_calendar_screen.dart';

final ownerRoutes = [
  GoRoute(
    path: '/owner/vehicle/add',
    builder: (context, state) => const AddEditVehicleScreen(),
  ),
  GoRoute(
    path: '/owner/vehicle/edit',
    builder: (context, state) => const AddEditVehicleScreen(isEdit: true),
  ),
  GoRoute(
    path: '/owner/calendar',
    builder: (context, state) => const VehicleCalendarScreen(),
  ),
  GoRoute(
    path: '/owner/booking-request',
    builder: (context, state) => BookingRequestDetailScreen(
      booking: state.extra is OwnerBooking ? state.extra as OwnerBooking : null,
    ),
  ),
  GoRoute(
    path: '/owner/revenue',
    builder: (context, state) => const RevenueReportScreen(),
  ),
];

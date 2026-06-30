import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/entities/admin_booking_detail.dart';
import 'package:frontend/features/admin/domain/entities/admin_booking_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_booking_detail_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_bookings_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/refund_payment_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_booking_detail_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_bookings_cubit.dart';

/// Fake tối thiểu: chỉ hiện thực các method booking; phần còn lại của
/// AdminRepository rơi vào noSuchMethod (không dùng trong test này).
class _FakeAdminRepository implements AdminRepository {
  Object? listError;
  Object? detailError;
  Object? refundError;
  String? lastStatus;
  String? lastReason;
  double? lastAmount;
  List<AdminBookingItem> items = const [];
  AdminBookingDetail? detail;

  @override
  Future<List<AdminBookingItem>> listBookings({
    String? status,
    int limit = 50,
  }) async {
    if (listError != null) throw listError!;
    lastStatus = status;
    return items;
  }

  @override
  Future<AdminBookingDetail> getBookingDetail(String id) async {
    if (detailError != null) throw detailError!;
    return detail!;
  }

  @override
  Future<void> refundPayment(
    String id, {
    required double amount,
    required String reason,
  }) async {
    lastAmount = amount;
    lastReason = reason;
    if (refundError != null) throw refundError!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

AdminBookingDetail _detail({String paymentStatus = 'PAID'}) {
  return AdminBookingDetail(
    id: 'b1',
    status: 'COMPLETED',
    startTime: DateTime(2026, 6, 1),
    endTime: DateTime(2026, 6, 2),
    totalPrice: 500,
    deliveryRequested: false,
    createdAt: DateTime(2026, 5, 30),
    vehicle: const AdminBookingVehicle(id: 'v1', title: 'Xe', type: 'CAR'),
    renter: const AdminBookingRenter(id: 'u1', phone: '090'),
    payment: AdminBookingPayment(
      method: 'VNPAY',
      status: paymentStatus,
      amount: 500,
    ),
    inspections: const [],
    disputes: const [],
  );
}

void main() {
  group('AdminBookingsCubit', () {
    late _FakeAdminRepository repo;

    setUp(() => repo = _FakeAdminRepository());

    test('load → Loaded kèm status filter', () async {
      repo.items = [
        AdminBookingItem(
          id: 'b1',
          vehicleTitle: 'Xe',
          status: 'COMPLETED',
          totalPrice: 500,
          startTime: DateTime(2026, 6, 1),
          endTime: DateTime(2026, 6, 2),
          createdAt: DateTime(2026, 5, 30),
          paymentStatus: 'PAID',
        ),
      ];
      final cubit = AdminBookingsCubit(
        listBookings: ListAdminBookingsUseCase(repo),
      );

      await cubit.filterByStatus('COMPLETED');

      expect(repo.lastStatus, 'COMPLETED');
      final state = cubit.state;
      expect(state, isA<AdminBookingsLoaded>());
      expect((state as AdminBookingsLoaded).items, hasLength(1));
      expect(state.status, 'COMPLETED');
    });

    test('lỗi API → AdminBookingsError', () async {
      repo.listError = const ApiException('boom');
      final cubit = AdminBookingsCubit(
        listBookings: ListAdminBookingsUseCase(repo),
      );

      await cubit.load();

      expect(cubit.state, isA<AdminBookingsError>());
    });
  });

  group('AdminBookingDetailCubit.refund', () {
    late _FakeAdminRepository repo;

    AdminBookingDetailCubit build() => AdminBookingDetailCubit(
      bookingId: 'b1',
      getDetail: GetAdminBookingDetailUseCase(repo),
      refundPayment: RefundPaymentUseCase(repo),
    );

    setUp(() {
      repo = _FakeAdminRepository();
      repo.detail = _detail();
    });

    test('refund thành công → reload + refunded=true + truyền đúng tham số',
        () async {
      final cubit = build();
      await cubit.load();

      await cubit.refund(amount: 500, reason: 'Xe hỏng');

      expect(repo.lastAmount, 500);
      expect(repo.lastReason, 'Xe hỏng');
      final state = cubit.state;
      expect(state, isA<AdminBookingDetailLoaded>());
      expect((state as AdminBookingDetailLoaded).refunded, isTrue);
      expect(state.submitting, isFalse);
    });

    test('refund lỗi → giữ Loaded + refundError', () async {
      final cubit = build();
      await cubit.load();
      repo.refundError = const ApiException('không hoàn được');

      await cubit.refund(amount: 500, reason: 'x');

      final state = cubit.state;
      expect(state, isA<AdminBookingDetailLoaded>());
      expect((state as AdminBookingDetailLoaded).refundError, 'không hoàn được');
      expect(state.refunded, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/entities/admin_risk_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/usecases/list_risk_flags_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_risk_cubit.dart';

class _FakeAdminRepository implements AdminRepository {
  Object? error;
  List<AdminRiskItem> items = const [];

  @override
  Future<List<AdminRiskItem>> listRiskFlags() async {
    if (error != null) throw error!;
    return items;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('AdminRiskCubit', () {
    late _FakeAdminRepository repo;
    setUp(() => repo = _FakeAdminRepository());

    test('load success → AdminRiskLoaded với items', () async {
      repo.items = const [
        AdminRiskItem(
          userId: 'u1',
          phone: '090',
          roles: ['RENTER'],
          score: 5,
          tier: 'HIGH',
          reasons: [RiskReason(code: 'SELF_RENTAL', label: 'Tự thuê')],
        ),
      ];
      final cubit = AdminRiskCubit(listRiskFlags: ListRiskFlagsUseCase(repo));

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<AdminRiskLoaded>());
      expect((state as AdminRiskLoaded).items.single.tier, 'HIGH');
    });

    test('lỗi API → AdminRiskError', () async {
      repo.error = const ApiException('boom');
      final cubit = AdminRiskCubit(listRiskFlags: ListRiskFlagsUseCase(repo));

      await cubit.load();

      expect(cubit.state, isA<AdminRiskError>());
    });
  });
}

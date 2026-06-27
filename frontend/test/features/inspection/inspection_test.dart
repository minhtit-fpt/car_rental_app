import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/inspection/data/models/damage_report_model.dart';
import 'package:frontend/features/inspection/domain/entities/damage_report.dart';
import 'package:frontend/features/inspection/domain/repositories/inspection_repository.dart';
import 'package:frontend/features/inspection/presentation/cubit/inspection_cubit.dart';

/// Fake repo cấu hình được — không chạm mạng.
class _FakeInspectionRepository implements InspectionRepository {
  DamageReport? report;
  Object? getError;

  @override
  Future<DamageReport> getDamageReport(String bookingId) async {
    if (getError != null) throw getError!;
    return report!;
  }

  @override
  Future<DamageReport> analyzeDamage(String bookingId) async => report!;

  @override
  Future<String> uploadPhoto({
    required String bookingId,
    required String phase,
    required List<int> bytes,
    required String contentType,
  }) async => 'key';

  @override
  Future<void> submitInspection({
    required String bookingId,
    required String phase,
    required List<String> photoKeys,
  }) async {}
}

final _report = DamageReport(
  summary: 's',
  items: const [],
  estimatedCost: 0,
  createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  beforePhotos: const [],
  afterPhotos: const [],
);

void main() {
  group('DamageReportModel.fromJson', () {
    test('maps items, severity and estimatedCost', () {
      final report = DamageReportModel.fromJson({
        'summary': 'Có vết trầy',
        'estimatedCost': 500000,
        'createdAt': '2026-06-27T10:00:00.000Z',
        'beforePhotos': ['a'],
        'afterPhotos': ['b', 'c'],
        'items': [
          {'label': 'trầy', 'severity': 'severe', 'description': 'cửa trái'},
        ],
      });
      expect(report.items, hasLength(1));
      expect(report.items.first.severity, DamageSeverity.severe);
      expect(report.estimatedCost, 500000);
      expect(report.afterPhotos, hasLength(2));
      expect(report.hasDamage, isTrue);
    });

    test('defaults missing fields and unknown severity to minor', () {
      final report = DamageReportModel.fromJson({
        'items': [
          {'label': 'x', 'severity': 'weird'},
        ],
      });
      expect(report.summary, '');
      expect(report.estimatedCost, 0);
      expect(report.items.first.severity, DamageSeverity.minor);
    });

    test('empty items means no damage', () {
      final report = DamageReportModel.fromJson({'summary': 'sạch', 'items': []});
      expect(report.hasDamage, isFalse);
    });
  });

  group('InspectionCubit.loadExistingReport', () {
    late _FakeInspectionRepository repo;
    setUp(() => repo = _FakeInspectionRepository());

    InspectionCubit build() =>
        InspectionCubit(bookingId: 'b-1', repository: repo);

    test('sets the report when one exists', () async {
      repo.report = _report;
      final cubit = build();
      await cubit.loadExistingReport();
      expect(cubit.state.report, isNotNull);
      await cubit.close();
    });

    test('ignores a 404 (no report yet)', () async {
      repo.getError = const ApiException('not found', statusCode: 404);
      final cubit = build();
      await cubit.loadExistingReport();
      expect(cubit.state.report, isNull);
      await cubit.close();
    });
  });
}

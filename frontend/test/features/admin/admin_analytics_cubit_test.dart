import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/entities/admin_analytics_answer.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/usecases/ask_analytics_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_analytics_cubit.dart';

/// Fake gọn: chỉ hiện thực askAnalytics, còn lại noSuchMethod.
class _FakeAdminRepository implements AdminRepository {
  AnalyticsAnswer? answer;
  ApiException? error;

  @override
  Future<AnalyticsAnswer> askAnalytics(String question) async {
    if (error != null) throw error!;
    return answer!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('AdminAnalyticsCubit', () {
    late _FakeAdminRepository repo;

    AdminAnalyticsCubit build() =>
        AdminAnalyticsCubit(askAnalytics: AskAnalyticsUseCase(repo));

    setUp(() => repo = _FakeAdminRepository());

    test('ask → thêm turn câu hỏi + câu trả lời', () async {
      repo.answer = const AnalyticsAnswer(
        answer: 'Tổng doanh thu 3.000.000đ',
        templateKey: 'revenue_by_method',
      );
      final cubit = build();

      await cubit.ask('doanh thu?');

      expect(cubit.state.asking, false);
      expect(cubit.state.turns, hasLength(1));
      expect(cubit.state.turns.single.question, 'doanh thu?');
      expect(cubit.state.turns.single.answer?.templateKey, 'revenue_by_method');
    });

    test('câu hỏi rỗng → bỏ qua', () async {
      final cubit = build();
      await cubit.ask('   ');
      expect(cubit.state.turns, isEmpty);
    });

    test('lỗi API → answer chứa thông báo lỗi, không treo', () async {
      repo.error = const ApiException('boom');
      final cubit = build();

      await cubit.ask('doanh thu?');

      expect(cubit.state.asking, false);
      expect(cubit.state.turns.single.answer?.answer, 'boom');
    });
  });
}

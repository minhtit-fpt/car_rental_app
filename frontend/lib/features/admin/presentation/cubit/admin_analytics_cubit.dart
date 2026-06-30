import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/entities/admin_analytics_answer.dart';
import 'package:frontend/features/admin/domain/usecases/ask_analytics_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_analytics_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_analytics_state.dart';

/// NL-analytics (Phase 5a): hỏi đáp số liệu qua template whitelist ở BE.
class AdminAnalyticsCubit extends Cubit<AdminAnalyticsState> {
  AdminAnalyticsCubit({required AskAnalyticsUseCase askAnalytics})
    : _askAnalytics = askAnalytics,
      super(const AdminAnalyticsState());

  final AskAnalyticsUseCase _askAnalytics;

  Future<void> ask(String question) async {
    final q = question.trim();
    if (q.isEmpty || state.asking) return;
    final pending = [...state.turns, AnalyticsTurn(question: q)];
    emit(state.copyWith(turns: pending, asking: true));
    try {
      final answer = await _askAnalytics(q);
      _replaceLast(answer);
    } on ApiException catch (e) {
      _replaceLast(AnalyticsAnswer(answer: e.message));
    }
  }

  void _replaceLast(AnalyticsAnswer answer) {
    final turns = [...state.turns];
    final last = turns.removeLast();
    turns.add(AnalyticsTurn(question: last.question, answer: answer));
    emit(state.copyWith(turns: turns, asking: false));
  }
}

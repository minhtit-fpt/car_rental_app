import 'package:frontend/features/admin/domain/entities/admin_analytics_answer.dart';

/// Một lượt hỏi-đáp NL-analytics.
class AnalyticsTurn {
  const AnalyticsTurn({required this.question, this.answer});
  final String question;

  /// null = đang chờ trả lời.
  final AnalyticsAnswer? answer;
}

class AdminAnalyticsState {
  const AdminAnalyticsState({this.turns = const [], this.asking = false});

  final List<AnalyticsTurn> turns;
  final bool asking;

  AdminAnalyticsState copyWith({List<AnalyticsTurn>? turns, bool? asking}) {
    return AdminAnalyticsState(
      turns: turns ?? this.turns,
      asking: asking ?? this.asking,
    );
  }
}

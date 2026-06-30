import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_analytics_cubit.dart';

/// Phase 5a — NL-analytics: ô chat hỏi đáp số liệu. BE ánh xạ câu hỏi vào
/// template whitelist (không SQL tự do); câu không khớp → "không hỗ trợ".
class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final q = _controller.text;
    if (q.trim().isEmpty) return;
    context.read<AdminAnalyticsCubit>().ask(q);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.adminBg,
        appBar: AppBar(
          backgroundColor: AppColors.adminSurface,
          foregroundColor: AppColors.adminText,
          elevation: 0,
          title: const Text(
            'Hỏi đáp số liệu',
            style: TextStyle(
              color: AppColors.adminText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<AdminAnalyticsCubit, AdminAnalyticsState>(
                builder: (context, state) {
                  if (state.turns.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Hỏi về doanh thu, số đơn, đội xe, top xe, tỉ lệ '
                          'hoàn tất/huỷ, đánh giá hoặc đơn mới nhất.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.adminMuted),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.turns.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _TurnTile(turn: state.turns[i]),
                  );
                },
              ),
            ),
            _Composer(controller: _controller, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _TurnTile extends StatelessWidget {
  const _TurnTile({required this.turn});
  final AnalyticsTurn turn;

  @override
  Widget build(BuildContext context) {
    final answer = turn.answer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              turn.question,
              style: const TextStyle(color: AppColors.adminText, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.adminCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: answer == null
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.accent),
                )
              : Text(
                  answer.answer,
                  style: const TextStyle(
                      color: AppColors.adminText, fontSize: 13),
                ),
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.adminText),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi…',
                  hintStyle: const TextStyle(color: AppColors.adminMuted),
                  filled: true,
                  fillColor: AppColors.adminCard,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.adminBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.adminBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

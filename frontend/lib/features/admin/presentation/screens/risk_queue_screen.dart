import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/domain/entities/admin_risk_item.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_risk_cubit.dart';

/// Hàng đợi rủi ro: tài khoản bị rule-engine cờ, xếp điểm giảm dần. Mỗi thẻ
/// liệt kê lý do (rule kích hoạt) — minh bạch, không hộp đen.
class RiskQueueScreen extends StatelessWidget {
  const RiskQueueScreen({super.key});

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
            'Cảnh báo rủi ro',
            style: TextStyle(
              color: AppColors.adminText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<AdminRiskCubit, AdminRiskState>(
          builder: (context, state) => switch (state) {
            AdminRiskLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.adminBlue),
            ),
            AdminRiskError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.adminMuted),
                ),
              ),
            ),
            AdminRiskLoaded(:final items) when items.isEmpty => const Center(
              child: Text(
                'Không có tài khoản nào bị cờ',
                style: TextStyle(color: AppColors.adminMuted),
              ),
            ),
            AdminRiskLoaded(:final items) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _RiskCard(
                item: items[i],
                explanation: state.explanations[items[i].userId],
                explaining: state.explainingUserId == items[i].userId,
              ),
            ),
          },
        ),
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({
    required this.item,
    this.explanation,
    this.explaining = false,
  });

  final AdminRiskItem item;

  /// 5b-tail: lời giải thích AI (null = chưa yêu cầu).
  final String? explanation;
  final bool explaining;

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(item.tier);
    final name = item.email ?? item.phone;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.adminText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_tierLabel(item.tier)} · ${item.score}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          Text(
            item.roles.join(', '),
            style: const TextStyle(color: AppColors.adminMuted, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: item.reasons
                .map(
                  (r) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.adminCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                    child: Text(
                      r.label,
                      style: const TextStyle(
                        color: AppColors.adminText,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          if (explanation != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.accent, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      explanation!,
                      style: const TextStyle(
                          color: AppColors.adminText, fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: explaining
                    ? null
                    : () => context.read<AdminRiskCubit>().explain(item.userId),
                icon: explaining
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.accent),
                      )
                    : const Icon(Icons.auto_awesome_rounded,
                        size: 14, color: AppColors.accent),
                label: Text(
                  explaining ? 'Đang tạo…' : 'Giải thích bằng AI',
                  style: const TextStyle(
                      color: AppColors.accent, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Color _tierColor(String tier) => switch (tier) {
  'HIGH' => AppColors.danger,
  'MEDIUM' => AppColors.warning,
  _ => AppColors.adminMuted,
};

String _tierLabel(String tier) => switch (tier) {
  'HIGH' => 'Cao',
  'MEDIUM' => 'Trung bình',
  _ => 'Thấp',
};

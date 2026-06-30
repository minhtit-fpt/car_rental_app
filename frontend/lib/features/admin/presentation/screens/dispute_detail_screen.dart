import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/domain/entities/admin_dispute_analysis.dart';
import 'package:frontend/features/admin/domain/entities/admin_dispute_item.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_dispute_detail_cubit.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

/// Màn xử lý một tranh chấp. Baseline 0b: hiển thị thông tin thật từ hàng đợi +
/// nút giải quyết/bác bỏ (gọi PATCH /api/admin/disputes/:id). Hoàn tiền tách
/// riêng ở Phase 3; chi tiết các bên/bằng chứng/timeline ở Phase 3-4.
class DisputeDetailScreen extends StatelessWidget {
  const DisputeDetailScreen({super.key, this.item});

  final AdminDisputeItem? item;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.adminBg,
        body: BlocConsumer<AdminDisputeDetailCubit, AdminDisputeDetailState>(
          listenWhen: (prev, curr) =>
              prev.done != curr.done || prev.error != curr.error,
          listener: (context, state) {
            if (state.done) {
              context.pop(true);
            } else if (state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                const _AdminAppBar(
                  title: 'Chi tiết tranh chấp',
                  subtitle: 'Xem xét và xử lý khiếu nại',
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _DisputeHeaderCard(item: item),
                        const SizedBox(height: 16),
                        _DisputeInfoCard(item: item),
                        const SizedBox(height: 16),
                        _AiAssistantPanel(state: state, bookingId: item?.bookingId),
                        const SizedBox(height: 20),
                        _DisputeActionButtons(
                          submitting: state.submitting,
                          resolved: (item?.status ?? 'OPEN') != 'OPEN',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

(String, Color) _priorityChip(String priority) => switch (priority) {
  'HIGH' => ('🔴 Ưu tiên cao', AppColors.danger),
  'MEDIUM' => ('🟡 Ưu tiên vừa', AppColors.warning),
  'LOW' => ('🟢 Ưu tiên thấp', AppColors.success),
  _ => ('Ưu tiên', AppColors.adminMuted),
};

(String, Color) _statusChip(String status) => switch (status) {
  'RESOLVED' => ('Đã giải quyết', AppColors.success),
  'REJECTED' => ('Đã bác bỏ', AppColors.danger),
  'OPEN' => ('Đang mở', AppColors.warning),
  _ => (status, AppColors.adminMuted),
};

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)} · '
      '${two(local.day)}/${two(local.month)}/${local.year}';
}

class _AdminAppBar extends StatelessWidget {
  const _AdminAppBar({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: AppColors.adminBg,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.adminText,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 14, right: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.adminText,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.adminMuted),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B1F1F), AppColors.adminBg],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisputeHeaderCard extends StatelessWidget {
  const _DisputeHeaderCard({required this.item});
  final AdminDisputeItem? item;

  @override
  Widget build(BuildContext context) {
    final (priorityLabel, priorityColor) = _priorityChip(item?.priority ?? '');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.danger.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.report_problem_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item?.title ?? 'Tranh chấp',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.adminText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              StatusChip(label: priorityLabel, color: priorityColor),
              const SizedBox(width: 8),
              Text(
                item?.bookingRef ?? '—',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.adminMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DisputeInfoCard extends StatelessWidget {
  const _DisputeInfoCard({required this.item});
  final AdminDisputeItem? item;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _statusChip(item?.status ?? '');
    final createdAt = item?.createdAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trạng thái',
                style: TextStyle(fontSize: 13, color: AppColors.adminMuted),
              ),
              StatusChip(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Mã booking', value: item?.bookingRef ?? '—'),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Thời gian tạo',
            value: createdAt == null ? '—' : _formatDateTime(createdAt),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.adminMuted),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.adminText,
          ),
        ),
      ],
    );
  }
}

class _DisputeActionButtons extends StatelessWidget {
  const _DisputeActionButtons({
    required this.submitting,
    required this.resolved,
  });
  final bool submitting;

  /// Tranh chấp đã đóng (không OPEN) → ẩn nút hành động.
  final bool resolved;

  @override
  Widget build(BuildContext context) {
    if (resolved) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Tranh chấp đã được xử lý.',
          style: TextStyle(fontSize: 13, color: AppColors.adminMuted),
        ),
      );
    }
    return Column(
      children: [
        PrimaryButton(
          label: 'Chấp nhận khiếu nại',
          isLoading: submitting,
          onPressed: submitting
              ? null
              : () => _confirm(context, isResolve: true),
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Bác bỏ khiếu nại',
          onPressed: submitting
              ? null
              : () => _confirm(context, isResolve: false),
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context, {required bool isResolve}) async {
    final cubit = context.read<AdminDisputeDetailCubit>();
    final note = await _showNoteDialog(context, isResolve: isResolve);
    if (note == null) return; // huỷ dialog
    final trimmed = note.trim();
    final value = trimmed.isEmpty ? null : trimmed;
    if (isResolve) {
      await cubit.resolve(note: value);
    } else {
      await cubit.reject(note: value);
    }
  }
}

/// Dialog xác nhận + ghi chú tuỳ chọn. Trả null nếu huỷ, chuỗi (có thể rỗng) nếu OK.
Future<String?> _showNoteDialog(
  BuildContext context, {
  required bool isResolve,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.adminCard,
      title: Text(
        isResolve ? 'Chấp nhận khiếu nại' : 'Bác bỏ khiếu nại',
        style: const TextStyle(color: AppColors.adminText, fontSize: 16),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: 2,
        maxLines: 4,
        maxLength: 500,
        style: const TextStyle(color: AppColors.adminText),
        decoration: const InputDecoration(
          hintText: 'Ghi chú cho người dùng (tuỳ chọn)',
          hintStyle: TextStyle(color: AppColors.adminMuted),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Huỷ'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: Text(
            'Xác nhận',
            style: TextStyle(
              color: isResolve ? AppColors.success : AppColors.danger,
            ),
          ),
        ),
      ],
    ),
  );
}

String _money(num v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  buf.write('đ');
  return buf.toString();
}

/// Phase 4 — panel trợ lý AI (advisory). Hiện nút phân tích; sau khi có kết quả
/// hiển thị fact cứng + mức hoàn tiền NEO + suy luận AI (hoặc thông báo offline).
/// Nút "Áp dụng → Hoàn tiền" chỉ điều hướng sang luồng Phase 3 (admin vẫn confirm).
class _AiAssistantPanel extends StatelessWidget {
  const _AiAssistantPanel({required this.state, required this.bookingId});
  final AdminDisputeDetailState state;
  final String? bookingId;

  @override
  Widget build(BuildContext context) {
    final analysis = state.analysis;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome_rounded,
                  color: AppColors.accent, size: 18),
              SizedBox(width: 8),
              Text(
                'Trợ lý AI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.adminText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tổng hợp ngữ cảnh để tham khảo. Mọi quyết định do admin thực hiện.',
            style: TextStyle(fontSize: 11, color: AppColors.adminMuted),
          ),
          const SizedBox(height: 12),
          if (analysis == null) ...[
            SecondaryButton(
              label: state.analyzing ? 'Đang phân tích…' : 'Phân tích bằng AI',
              icon: Icons.psychology_alt_rounded,
              onPressed: state.analyzing
                  ? null
                  : () => context.read<AdminDisputeDetailCubit>().analyze(),
            ),
            if (state.analyzeError != null) ...[
              const SizedBox(height: 8),
              Text(
                state.analyzeError!,
                style: const TextStyle(fontSize: 12, color: AppColors.danger),
              ),
            ],
          ] else
            _AnalysisBody(analysis: analysis, bookingId: bookingId),
        ],
      ),
    );
  }
}

class _AnalysisBody extends StatelessWidget {
  const _AnalysisBody({required this.analysis, required this.bookingId});
  final DisputeAnalysis analysis;
  final String? bookingId;

  @override
  Widget build(BuildContext context) {
    final f = analysis.facts;
    final ai = analysis.ai;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fact('Bên khiếu nại', f.raisedByRole),
        _fact('Hợp đồng đã ký', f.contractSigned ? 'Có' : 'Chưa'),
        _fact('Thanh toán',
            f.paymentStatus == null ? 'Chưa có' : f.paymentStatus!),
        _fact('Ảnh nhận/trả',
            '${f.hasCheckin ? "✓" : "✗"} / ${f.hasCheckout ? "✓" : "✗"}'),
        _fact('Hư hỏng', f.damageSummary ?? 'Không có'),
        _fact('Chi phí ước tính', _money(f.estimatedCost)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mức hoàn tiền đề xuất (neo theo chi phí hư hỏng)',
                style: TextStyle(fontSize: 11, color: AppColors.adminMuted),
              ),
              const SizedBox(height: 2),
              Text(
                _money(analysis.anchoredRefund),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (ai == null)
          Text(
            analysis.aiError ?? 'Chưa phân tích được bằng AI.',
            style: const TextStyle(fontSize: 12, color: AppColors.warning),
          )
        else ...[
          Text(
            ai.summary,
            style: const TextStyle(fontSize: 13, color: AppColors.adminText),
          ),
          const SizedBox(height: 8),
          if (ai.timeline.isNotEmpty)
            ...ai.timeline.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $t',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.adminMuted),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              StatusChip(
                label: 'Lỗi: ${ai.faultParty}',
                color: AppColors.warning,
              ),
              StatusChip(
                label: 'Tin cậy: ${ai.confidence}',
                color: AppColors.adminMuted,
              ),
            ],
          ),
          if (ai.recommendation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Đề xuất: ${ai.recommendation}',
              style: const TextStyle(fontSize: 12, color: AppColors.adminText),
            ),
          ],
        ],
        if (bookingId != null) ...[
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Áp dụng → Hoàn tiền',
            icon: Icons.payments_outlined,
            onPressed: () => context.push('/admin/booking/$bookingId'),
          ),
        ],
      ],
    );
  }

  Widget _fact(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.adminMuted)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.adminText,
            ),
          ),
        ),
      ],
    ),
  );
}

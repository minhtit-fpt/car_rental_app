import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
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

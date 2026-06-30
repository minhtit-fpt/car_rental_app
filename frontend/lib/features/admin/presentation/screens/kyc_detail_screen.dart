import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/entities/kyc_documents.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_detail_cubit.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

/// Màn xét duyệt một hồ sơ KYC. Data thật qua [AdminKycDetailCubit]
/// (ảnh giấy tờ presigned + duyệt/từ chối gọi `/api/kyc/:id/review`).
class KycDetailScreen extends StatelessWidget {
  const KycDetailScreen({super.key, this.item});

  /// Thông tin hàng đợi đã có sẵn (truyền qua `extra`) — tránh fetch lại.
  final AdminKycItem? item;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.adminBg,
        body: BlocConsumer<AdminKycDetailCubit, AdminKycDetailState>(
          listenWhen: (prev, curr) =>
              prev.reviewDone != curr.reviewDone ||
              prev.reviewError != curr.reviewError,
          listener: (context, state) {
            if (state.reviewDone) {
              context.pop(true); // báo màn trước refresh hàng đợi
            } else if (state.reviewError != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.reviewError!)));
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                const _AdminAppBar(
                  title: 'Chi tiết KYC',
                  subtitle: 'Xét duyệt hồ sơ định danh',
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _UserInfoCard(item: item),
                        const SizedBox(height: 16),
                        _DocumentsCard(state: state),
                        const SizedBox(height: 16),
                        _SubmissionInfoCard(item: item),
                        const SizedBox(height: 20),
                        _AdminActionButtons(submitting: state.submitting),
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

(String, Color) _statusChip(String status) => switch (status) {
  'VERIFIED' => ('🟢 Đã duyệt', AppColors.success),
  'REJECTED' => ('🔴 Từ chối', AppColors.danger),
  'PENDING' => ('🟡 Đang chờ', AppColors.warning),
  _ => ('⚪ Chưa xác minh', AppColors.adminMuted),
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
              colors: [Color(0xFF1E3A5F), AppColors.adminBg],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.item});
  final AdminKycItem? item;

  @override
  Widget build(BuildContext context) {
    final name = item?.email ?? item?.phone ?? '—';
    final contact = [
      item?.phone,
      item?.email,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    final (label, color) = _statusChip(item?.status ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.adminBlue.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👨', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.adminText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  contact.isEmpty ? '—' : contact,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.adminMuted,
                  ),
                ),
                const SizedBox(height: 6),
                StatusChip(label: label, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({required this.state});
  final AdminKycDetailState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hồ sơ giấy tờ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.adminText,
            ),
          ),
          const SizedBox(height: 14),
          _body(context),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (state.loadingDocs) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.adminBlue),
        ),
      );
    }
    if (state.docsError != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              state.docsError!,
              style: const TextStyle(fontSize: 12, color: AppColors.adminMuted),
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<AdminKycDetailCubit>().loadDocuments(),
            child: const Text('Thử lại'),
          ),
        ],
      );
    }
    final docs = state.documents;
    if (docs == null) return const SizedBox.shrink();
    return _DocGrid(docs: docs);
  }
}

class _DocGrid extends StatelessWidget {
  const _DocGrid({required this.docs});
  final KycDocuments docs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DocTile(label: 'CCCD', url: docs.cccdUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DocTile(label: 'Bằng lái', url: docs.licenseUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DocTile(label: 'Ảnh selfie', url: docs.faceUrl),
        ),
      ],
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.label, required this.url});
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _openPreview(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const _DocPlaceholder(),
                errorBuilder: (context, _, _) =>
                    const _DocPlaceholder(failed: true),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppColors.adminMuted),
        ),
      ],
    );
  }

  void _openPreview(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _DocPlaceholder extends StatelessWidget {
  const _DocPlaceholder({this.failed = false});
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.adminBorder.withAlpha(80),
      alignment: Alignment.center,
      child: Icon(
        failed ? Icons.broken_image_outlined : Icons.hourglass_empty_rounded,
        color: AppColors.adminMuted,
        size: 22,
      ),
    );
  }
}

class _SubmissionInfoCard extends StatelessWidget {
  const _SubmissionInfoCard({required this.item});
  final AdminKycItem? item;

  @override
  Widget build(BuildContext context) {
    final submittedAt = item?.submittedAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        children: [
          const _InfoRow(label: 'Loại xác minh', value: 'CCCD + Bằng lái xe'),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Thời gian nộp',
            value: submittedAt == null ? '—' : _formatDateTime(submittedAt),
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

class _AdminActionButtons extends StatelessWidget {
  const _AdminActionButtons({required this.submitting});
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: 'Phê duyệt KYC',
          isLoading: submitting,
          onPressed: submitting
              ? null
              : () => context.read<AdminKycDetailCubit>().approve(),
          icon: Icons.verified_rounded,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Từ chối · Yêu cầu bổ sung',
          onPressed: submitting ? null : () => _promptReject(context),
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }

  Future<void> _promptReject(BuildContext context) async {
    final cubit = context.read<AdminKycDetailCubit>();
    final reason = await _showRejectDialog(context);
    if (reason != null && reason.trim().isNotEmpty) {
      await cubit.reject(reason.trim());
    }
  }
}

Future<String?> _showRejectDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.adminCard,
      title: const Text(
        'Lý do từ chối',
        style: TextStyle(color: AppColors.adminText, fontSize: 16),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: 2,
        maxLines: 4,
        maxLength: 500,
        style: const TextStyle(color: AppColors.adminText),
        decoration: const InputDecoration(
          hintText: 'Ví dụ: Ảnh CCCD bị mờ, vui lòng chụp lại.',
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
          child: const Text(
            'Xác nhận từ chối',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    ),
  );
}

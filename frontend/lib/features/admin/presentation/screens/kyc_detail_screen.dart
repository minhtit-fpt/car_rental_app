import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

class KycDetailScreen extends StatelessWidget {
  const KycDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.adminBg,
        body: CustomScrollView(
          slivers: [
            _AdminAppBar(
              title: 'Chi tiết KYC',
              subtitle: 'Xét duyệt hồ sơ định danh',
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _UserInfoCard(),
                    const SizedBox(height: 16),
                    _DocumentsCard(),
                    const SizedBox(height: 16),
                    _SubmissionInfoCard(),
                    const SizedBox(height: 20),
                    _AdminActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppColors.adminText, size: 20),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 14, right: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.adminText)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.adminMuted)),
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
  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Nguyen Van An',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.adminText,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '0912 345 678 · an.nguyen@email.com',
                  style: TextStyle(fontSize: 12, color: AppColors.adminMuted),
                ),
                const SizedBox(height: 6),
                StatusChip(label: '🟡 Đang chờ', color: AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
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
          Row(
            children: [
              Expanded(child: _DocTile(label: 'CCCD mặt trước', emoji: '🪪')),
              const SizedBox(width: 10),
              Expanded(child: _DocTile(label: 'CCCD mặt sau', emoji: '🪪')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _DocTile(label: 'Bằng lái xe', emoji: '📋')),
              const SizedBox(width: 10),
              Expanded(child: _DocTile(label: 'Ảnh selfie', emoji: '🤳')),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.label, required this.emoji});
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.adminBorder.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.adminMuted),
          ),
        ],
      ),
    );
  }
}

class _SubmissionInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: const Column(
        children: [
          _InfoRow(label: 'Loại xác minh', value: 'CCCD + Bằng lái xe'),
          SizedBox(height: 10),
          _InfoRow(label: 'Thời gian nộp', value: '10:32 · 05/06/2025'),
          SizedBox(height: 10),
          _InfoRow(label: 'Lần thứ', value: '1 (lần đầu)'),
          SizedBox(height: 10),
          _InfoRow(label: 'IP nộp', value: '192.168.1.xxx'),
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
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.adminMuted)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.adminText)),
      ],
    );
  }
}

class _AdminActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: 'Phê duyệt KYC',
          onPressed: () => context.pop(),
          icon: Icons.verified_rounded,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Từ chối · Yêu cầu bổ sung',
          onPressed: () => context.pop(),
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }
}

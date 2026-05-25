import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

const _kAdminBg = Color(0xFF0A1628);
const _kAdminCard = Color(0xFF1A2A40);
const _kAdminBorder = Color(0xFF253A54);
const _kAdminText = Color(0xFFE8F0FC);
const _kAdminMuted = Color(0xFF6B8AAD);
const _kAdminPrimary = Color(0xFF3B82F6);

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kAdminBg,
        body: CustomScrollView(
          slivers: [
            _AdminAppBar(
              title: 'Chi tiết người dùng',
              subtitle: 'Xem và quản lý tài khoản',
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _UserProfileCard(),
                    const SizedBox(height: 16),
                    _AccountStatsCard(),
                    const SizedBox(height: 16),
                    _ActivityCard(),
                    const SizedBox(height: 20),
                    _UserActionButtons(),
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
      backgroundColor: _kAdminBg,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: _kAdminText, size: 20),
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
                    color: _kAdminText)),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: _kAdminMuted)),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A5F), _kAdminBg],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kAdminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAdminBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _kAdminPrimary.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👩', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trần Thị Lan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kAdminText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'lan.tran@email.com · 0912 xxx 678',
                      style: TextStyle(fontSize: 12, color: _kAdminMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusChip(
                            label: '✅ KYC Đã xác minh',
                            color: const Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        StatusChip(
                            label: 'Renter',
                            color: _kAdminPrimary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: _kAdminBorder, height: 1),
          const SizedBox(height: 12),
          _InfoRow(label: 'Ngày đăng ký', value: '12/01/2025'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Lần đăng nhập cuối', value: '05/06/2025 09:14'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Địa chỉ IP', value: '118.70.xxx.xxx · TP.HCM'),
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
            style: const TextStyle(fontSize: 13, color: _kAdminMuted)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kAdminText)),
      ],
    );
  }
}

class _AccountStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kAdminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAdminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê tài khoản',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _kAdminText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatTile(
                  icon: Icons.directions_car_rounded,
                  label: 'Chuyến',
                  value: '14',
                  color: _kAdminPrimary),
              _StatTile(
                  icon: Icons.star_rounded,
                  label: 'Đánh giá',
                  value: '4.8',
                  color: const Color(0xFFF59E0B)),
              _StatTile(
                  icon: Icons.payments_outlined,
                  label: 'Chi tiêu',
                  value: '12M',
                  color: const Color(0xFF10B981)),
              _StatTile(
                  icon: Icons.report_outlined,
                  label: 'Tranh chấp',
                  value: '0',
                  color: const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icon, size: 16, color: color)),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: _kAdminMuted)),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kAdminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAdminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoạt động gần đây',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _kAdminText,
            ),
          ),
          const SizedBox(height: 12),
          _ActivityRow(
              icon: Icons.directions_car_rounded,
              text: 'Hoàn thành chuyến Tesla Model 3',
              time: '05/06/2025',
              color: const Color(0xFF10B981)),
          const Divider(color: _kAdminBorder, height: 16),
          _ActivityRow(
              icon: Icons.payments_outlined,
              text: 'Thanh toán 2,403K VNĐ qua MoMo',
              time: '05/06/2025',
              color: _kAdminPrimary),
          const Divider(color: _kAdminBorder, height: 16),
          _ActivityRow(
              icon: Icons.star_rounded,
              text: 'Đánh giá 5⭐ cho chủ xe',
              time: '08/06/2025',
              color: const Color(0xFFF59E0B)),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.text,
    required this.time,
    required this.color,
  });
  final IconData icon;
  final String text;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Center(child: Icon(icon, size: 14, color: color)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(fontSize: 13, color: _kAdminText)),
        ),
        Text(time,
            style:
                const TextStyle(fontSize: 11, color: _kAdminMuted)),
      ],
    );
  }
}

class _UserActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: 'Gửi thông báo cho người dùng',
          onPressed: () => context.pop(),
          icon: Icons.notifications_outlined,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Khóa tài khoản tạm thời',
          onPressed: () => context.pop(),
          icon: Icons.lock_outline_rounded,
        ),
      ],
    );
  }
}

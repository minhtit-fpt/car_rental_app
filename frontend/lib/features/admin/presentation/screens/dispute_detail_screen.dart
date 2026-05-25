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

class DisputeDetailScreen extends StatelessWidget {
  const DisputeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kAdminBg,
        body: CustomScrollView(
          slivers: [
            _AdminAppBar(
              title: 'Chi tiết tranh chấp',
              subtitle: 'Xem xét và xử lý khiếu nại',
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _DisputeHeaderCard(),
                    const SizedBox(height: 16),
                    _PartiesCard(),
                    const SizedBox(height: 16),
                    _EvidenceCard(),
                    const SizedBox(height: 16),
                    _TimelineCard(),
                    const SizedBox(height: 20),
                    _DisputeActionButtons(),
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
              colors: [Color(0xFF3B1F1F), _kAdminBg],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisputeHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEF4444).withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.report_problem_rounded,
                  color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Xe bị trầy xước sau khi thuê',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _kAdminText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              StatusChip(
                  label: '🔴 Ưu tiên cao',
                  color: const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              const Text(
                'Ref: DS-2025-1042',
                style: TextStyle(fontSize: 12, color: _kAdminMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Chủ xe báo cáo rằng xe bị trầy xước nghiêm trọng tại cửa sau bên trái sau khi khách thuê trả xe. Khách thuê phủ nhận trách nhiệm.',
            style: TextStyle(fontSize: 13, color: _kAdminMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _PartiesCard extends StatelessWidget {
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
            'Các bên liên quan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _kAdminText,
            ),
          ),
          const SizedBox(height: 12),
          _PartyRow(
            emoji: '👨‍💼',
            role: 'Chủ xe (Người báo cáo)',
            name: 'Nguyen Minh Tuan',
            phone: '0901 234 567',
            roleColor: _kAdminPrimary,
          ),
          const Divider(color: _kAdminBorder, height: 16),
          _PartyRow(
            emoji: '👤',
            role: 'Người thuê (Bị cáo buộc)',
            name: 'Tran Van Hung',
            phone: '0912 345 678',
            roleColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

class _PartyRow extends StatelessWidget {
  const _PartyRow({
    required this.emoji,
    required this.role,
    required this.name,
    required this.phone,
    required this.roleColor,
  });

  final String emoji;
  final String role;
  final String name;
  final String phone;
  final Color roleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: roleColor.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role,
                  style: TextStyle(
                      fontSize: 11,
                      color: roleColor,
                      fontWeight: FontWeight.w600)),
              Text(name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kAdminText)),
              Text(phone,
                  style: const TextStyle(
                      fontSize: 12, color: _kAdminMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EvidenceCard extends StatelessWidget {
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
            'Bằng chứng đính kèm',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _kAdminText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                4,
                (i) => Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
                  decoration: BoxDecoration(
                    color: _kAdminBorder.withAlpha(80),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      i < 3 ? '📸' : '📹',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
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
            'Tiến trình xử lý',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _kAdminText,
            ),
          ),
          const SizedBox(height: 14),
          _TimelineItem(
            date: '05/06 09:00',
            text: 'Khách thuê trả xe tại 123 Lê Lợi',
            color: const Color(0xFF10B981),
            done: true,
          ),
          _TimelineItem(
            date: '05/06 09:45',
            text: 'Chủ xe báo cáo trầy xước',
            color: const Color(0xFFEF4444),
            done: true,
          ),
          _TimelineItem(
            date: '05/06 10:30',
            text: 'Hệ thống gửi thông báo cho admin',
            color: _kAdminPrimary,
            done: true,
          ),
          _TimelineItem(
            date: 'Đang chờ',
            text: 'Admin xem xét và quyết định',
            color: const Color(0xFFF59E0B),
            done: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.date,
    required this.text,
    required this.color,
    required this.done,
    this.isLast = false,
  });

  final String date;
  final String text;
  final Color color;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: done ? color : _kAdminBorder,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: _kAdminBorder,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(
                        fontSize: 11, color: _kAdminMuted)),
                const SizedBox(height: 2),
                Text(text,
                    style: const TextStyle(
                        fontSize: 13, color: _kAdminText)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DisputeActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: 'Chấp nhận khiếu nại · Hoàn tiền',
          onPressed: () => context.pop(),
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Bác bỏ khiếu nại',
          onPressed: () => context.pop(),
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }
}

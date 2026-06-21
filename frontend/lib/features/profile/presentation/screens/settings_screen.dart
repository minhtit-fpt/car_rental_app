import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/shared/utils/coming_soon.dart';

/// Phiên bản hiển thị ở mục "Về ứng dụng". Đồng bộ thủ công với `pubspec.yaml`
/// (chưa thêm package_info_plus để tránh dependency mới ở plan này).
const String _appVersion = '0.1.0';

/// Màn Cài đặt tập trung cho tab "Tôi". Các mục đã có hành vi thật (đăng xuất)
/// chạy ngay; các mục chờ backend/feature khác hiển thị rõ "Sắp có" thay vì im
/// lặng.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Trạng thái cục bộ (chưa lưu BE) — placeholder cho preference thông báo.
  bool _notificationsEnabled = true;

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất khỏi tài khoản này?',
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Huỷ',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Đồng bộ với logout ở app_shell: router tự redirect về /login khi
      // AuthCubit phát trạng thái chưa đăng nhập (refreshListenable).
      context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const _SettingsSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingsSection(
                      label: 'Hoạt động',
                      rows: [
                        _SettingsRow(
                          icon: Icons.favorite_border_rounded,
                          title: 'Xe đã lưu',
                          subtitle: 'Danh sách xe yêu thích',
                          onTap: () => context.push('/favorites'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      label: 'Tuỳ chỉnh',
                      rows: [
                        _SettingsRow(
                          icon: Icons.language_outlined,
                          title: 'Ngôn ngữ',
                          subtitle: 'Tiếng Việt',
                          trailing: const _ComingSoonChip(),
                          onTap: () =>
                              showComingSoonSnack(context, 'Đổi ngôn ngữ'),
                        ),
                        _SettingsRow(
                          icon: Icons.notifications_outlined,
                          title: 'Thông báo',
                          subtitle: 'Nhận thông báo đẩy',
                          trailing: Switch.adaptive(
                            value: _notificationsEnabled,
                            activeThumbColor: AppColors.primary,
                            onChanged: (v) =>
                                setState(() => _notificationsEnabled = v),
                          ),
                        ),
                        _SettingsRow(
                          icon: Icons.dark_mode_outlined,
                          title: 'Giao diện tối',
                          subtitle: 'Chế độ nền tối',
                          trailing: const _ComingSoonChip(),
                          // Disabled: chưa có hạ tầng đổi theme.
                          onTap: null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      label: 'Tài khoản',
                      rows: [
                        _SettingsRow(
                          icon: Icons.lock_outline_rounded,
                          title: 'Đổi mật khẩu',
                          trailing: const _ComingSoonChip(),
                          onTap: null,
                        ),
                        _SettingsRow(
                          icon: Icons.logout_rounded,
                          title: 'Đăng xuất',
                          danger: true,
                          onTap: _confirmLogout,
                        ),
                        _SettingsRow(
                          icon: Icons.delete_outline_rounded,
                          title: 'Xoá tài khoản',
                          danger: true,
                          trailing: const _ComingSoonChip(),
                          onTap: null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      label: 'Khác',
                      rows: [
                        _SettingsRow(
                          icon: Icons.info_outline_rounded,
                          title: 'Về ứng dụng',
                          subtitle: 'RideVN · Phiên bản $_appVersion',
                          onTap: () => showAboutDialog(
                            context: context,
                            applicationName: 'RideVN',
                            applicationVersion: 'Phiên bản $_appVersion',
                            applicationLegalese: '© 2026 RideVN',
                          ),
                        ),
                        _SettingsRow(
                          icon: Icons.description_outlined,
                          title: 'Điều khoản & chính sách',
                          trailing: const _ComingSoonChip(),
                          onTap: null,
                        ),
                      ],
                    ),
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

// ─────────────────────────────────────────────
// Sliver App Bar — gradient renter
// ─────────────────────────────────────────────

class _SettingsSliverAppBar extends StatelessWidget {
  const _SettingsSliverAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        background: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.renterHeaderGradient),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section card
// ─────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.label, required this.rows});

  final String label;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadowColor,
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: AppColors.border, indent: 56),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Row
// ─────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null && trailing is! Switch;
    final iconColor = danger ? AppColors.danger : AppColors.primary;
    final titleColor = danger ? AppColors.danger : AppColors.darkText;

    // Trailing mặc định: chevron khi có hành vi và không có trailing tuỳ biến.
    final effectiveTrailing =
        trailing ??
        (onTap != null
            ? const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.placeholderText,
              )
            : null);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Opacity(
        opacity: isDisabled ? 0.7 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (effectiveTrailing != null) ...[
                const SizedBox(width: 8),
                effectiveTrailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Nhãn "Sắp có" cho các mục chưa nối backend/feature khác.
class _ComingSoonChip extends StatelessWidget {
  const _ComingSoonChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Sắp có',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}

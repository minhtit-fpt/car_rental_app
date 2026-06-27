import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/locale/locale_cubit.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/core/theme/theme_mode_cubit.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.settingsLogout,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: dialogContext.palette.darkText,
          ),
        ),
        content: Text(
          l10n.settingsLogoutConfirm,
          style: TextStyle(
            fontSize: 14,
            color: dialogContext.palette.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: dialogContext.palette.mutedText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.settingsLogout,
              style: const TextStyle(
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

  /// Xác nhận xoá tài khoản — yêu cầu tick checkbox "tôi hiểu" trước khi cho xoá.
  /// Thành công → AuthCubit phát unauthenticated → router về /login.
  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final authCubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var acknowledged = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: context.palette.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.settingsDeleteAccount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.danger,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deleteAccountWarning,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.palette.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () =>
                      setDialogState(() => acknowledged = !acknowledged),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: acknowledged,
                        activeColor: AppColors.danger,
                        onChanged: (v) =>
                            setDialogState(() => acknowledged = v ?? false),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            l10n.deleteAccountConfirmCheckbox,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.palette.darkText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  l10n.commonCancel,
                  style: TextStyle(color: context.palette.mutedText),
                ),
              ),
              TextButton(
                onPressed: acknowledged
                    ? () => Navigator.of(dialogContext).pop(true)
                    : null,
                child: Text(
                  l10n.deleteAccountConfirmButton,
                  style: TextStyle(
                    color: acknowledged
                        ? AppColors.danger
                        : context.palette.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;
    final success = await authCubit.deleteAccount();
    if (!success) {
      final message = authCubit.state.errorMessage;
      if (message != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  /// Bottom sheet chọn ngôn ngữ. Đổi qua [LocaleCubit] (persist + rebuild app).
  Future<void> _showLanguagePicker() async {
    final l10n = AppLocalizations.of(context);
    final localeCubit = context.read<LocaleCubit>();
    final current = localeCubit.state.languageCode;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                l10n.languagePickerTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: sheetContext.palette.darkText,
                ),
              ),
            ),
            _PickerOption(
              label: l10n.languageVietnamese,
              selected: current == 'vi',
              onTap: () {
                Navigator.of(sheetContext).pop();
                localeCubit.setLocale(const Locale('vi'));
              },
            ),
            _PickerOption(
              label: l10n.languageEnglish,
              selected: current == 'en',
              onTap: () {
                Navigator.of(sheetContext).pop();
                localeCubit.setLocale(const Locale('en'));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet chọn chế độ giao diện. Đổi qua [ThemeModeCubit]
  /// (persist + rebuild app).
  Future<void> _showThemePicker() async {
    final l10n = AppLocalizations.of(context);
    final themeCubit = context.read<ThemeModeCubit>();
    final current = themeCubit.state;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                l10n.themePickerTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: sheetContext.palette.darkText,
                ),
              ),
            ),
            for (final mode in ThemeMode.values)
              _PickerOption(
                label: _themeModeLabel(l10n, mode),
                selected: current == mode,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  themeCubit.setMode(mode);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Nhãn hiển thị cho từng [ThemeMode] (theo hệ thống / sáng / tối).
  String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) =>
      switch (mode) {
        ThemeMode.system => l10n.settingsThemeSystem,
        ThemeMode.light => l10n.settingsThemeLight,
        ThemeMode.dark => l10n.settingsThemeDark,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Hiển thị autonym của ngôn ngữ đang chọn; rebuild khi LocaleCubit đổi.
    final currentLanguageLabel =
        context.watch<LocaleCubit>().state.languageCode == 'en'
        ? l10n.languageEnglish
        : l10n.languageVietnamese;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
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
                      label: l10n.settingsSectionPreferences,
                      rows: [
                        _SettingsRow(
                          icon: Icons.language_outlined,
                          title: l10n.settingsLanguage,
                          subtitle: currentLanguageLabel,
                          onTap: _showLanguagePicker,
                        ),
                        _SettingsRow(
                          icon: Icons.notifications_outlined,
                          title: l10n.settingsNotifications,
                          subtitle: l10n.settingsNotificationsSubtitle,
                          trailing: Switch.adaptive(
                            value: _notificationsEnabled,
                            activeThumbColor: AppColors.primary,
                            onChanged: (v) =>
                                setState(() => _notificationsEnabled = v),
                          ),
                        ),
                        _SettingsRow(
                          icon: Icons.dark_mode_outlined,
                          title: l10n.settingsDarkMode,
                          subtitle: _themeModeLabel(
                            l10n,
                            context.watch<ThemeModeCubit>().state,
                          ),
                          onTap: _showThemePicker,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      label: l10n.settingsSectionAccount,
                      rows: [
                        _SettingsRow(
                          icon: Icons.lock_outline_rounded,
                          title: l10n.settingsChangePassword,
                          onTap: () => context.push('/change-password'),
                        ),
                        _SettingsRow(
                          icon: Icons.logout_rounded,
                          title: l10n.settingsLogout,
                          danger: true,
                          onTap: _confirmLogout,
                        ),
                        _SettingsRow(
                          icon: Icons.delete_outline_rounded,
                          title: l10n.settingsDeleteAccount,
                          danger: true,
                          onTap: _confirmDeleteAccount,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      label: l10n.settingsSectionOther,
                      rows: [
                        _SettingsRow(
                          icon: Icons.info_outline_rounded,
                          title: l10n.settingsAbout,
                          subtitle: l10n.settingsAboutSubtitle(_appVersion),
                          onTap: () => showAboutDialog(
                            context: context,
                            applicationName: 'RideVN',
                            applicationVersion: l10n.settingsVersionLabel(
                              _appVersion,
                            ),
                            applicationLegalese: '© 2026 RideVN',
                          ),
                        ),
                        _SettingsRow(
                          icon: Icons.description_outlined,
                          title: l10n.settingsTermsPolicies,
                          onTap: () => context.push('/terms'),
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
        title: Text(
          AppLocalizations.of(context).settingsTitle,
          style: const TextStyle(
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.palette.mutedText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.palette.border),
            boxShadow: [
              BoxShadow(
                color: context.palette.cardShadowColor,
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: context.palette.border,
                    indent: 56,
                  ),
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
    final titleColor = danger ? AppColors.danger : context.palette.darkText;

    // Trailing mặc định: chevron khi có hành vi và không có trailing tuỳ biến.
    final effectiveTrailing =
        trailing ??
        (onTap != null
            ? Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.palette.placeholderText,
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
                        style: TextStyle(
                          fontSize: 12,
                          color: context.palette.mutedText,
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

/// Một lựa chọn trong bottom sheet picker (có dấu check khi đang chọn).
/// Dùng chung cho cả picker ngôn ngữ và picker giao diện.
class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.primary : context.palette.darkText,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

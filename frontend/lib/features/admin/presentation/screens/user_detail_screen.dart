import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_user_detail_cubit.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.adminBg,
        body: BlocConsumer<AdminUserDetailCubit, AdminUserDetailState>(
          listenWhen: (prev, curr) => prev.error != curr.error,
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _AdminAppBar(onBack: () => context.pop(state.changed)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _UserProfileCard(state: state),
                        const SizedBox(height: 16),
                        _RoleManagementCard(state: state),
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

/// Fallback khi mở route trực tiếp không kèm dữ liệu user (vd: deep link).
class UserDetailMissing extends StatelessWidget {
  const UserDetailMissing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBg,
      appBar: AppBar(
        backgroundColor: AppColors.adminBg,
        foregroundColor: AppColors.adminText,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text(
          'Không có dữ liệu người dùng',
          style: TextStyle(color: AppColors.adminMuted),
        ),
      ),
    );
  }
}

class _AdminAppBar extends StatelessWidget {
  const _AdminAppBar({required this.onBack});
  final VoidCallback onBack;

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
        onPressed: onBack,
      ),
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 56, bottom: 14, right: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi tiết người dùng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.adminText,
              ),
            ),
            Text(
              'Xem và quản lý vai trò',
              style: TextStyle(fontSize: 11, color: AppColors.adminMuted),
            ),
          ],
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
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

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard({required this.state});
  final AdminUserDetailState state;

  @override
  Widget build(BuildContext context) {
    final user = state.user;
    final title = user.email ?? user.phone;
    final (kycLabel, kycColor) = _kycChip(user.kycStatus);

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
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.adminBlue, AppColors.adminTeal],
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(user.email, user.phone),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
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
                    const SizedBox(height: 3),
                    Text(
                      user.phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.adminMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusChip(label: kycLabel, color: kycColor),
                        for (final role in user.roles)
                          StatusChip(
                            label: _roleLabel(role),
                            color: _roleColor(role),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.adminBorder, height: 1),
          const SizedBox(height: 12),
          _InfoRow(label: 'Mã người dùng', value: user.id),
          const SizedBox(height: 8),
          _InfoRow(label: 'Ngày đăng ký', value: _formatDate(user.createdAt)),
        ],
      ),
    );
  }
}

class _RoleManagementCard extends StatelessWidget {
  const _RoleManagementCard({required this.state});
  final AdminUserDetailState state;

  @override
  Widget build(BuildContext context) {
    final isAdmin = state.user.roles.contains('ADMIN');
    final hasOwner = state.user.hasOwner;

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
            'Quản lý vai trò',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.adminText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAdmin
                ? 'Tài khoản ADMIN không thể đổi vai trò.'
                : hasOwner
                ? 'Người dùng đang có vai Chủ xe — có thể đăng và quản lý xe.'
                : 'Cấp vai Chủ xe để người dùng có thể đăng xe cho thuê.',
            style: const TextStyle(fontSize: 13, color: AppColors.adminMuted),
          ),
          const SizedBox(height: 16),
          if (!isAdmin)
            PrimaryButton(
              label: hasOwner ? 'Thu hồi vai Chủ xe' : 'Cấp vai Chủ xe',
              icon: hasOwner
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              isLoading: state.submitting,
              onPressed: () =>
                  context.read<AdminUserDetailCubit>().toggleOwner(),
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
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.adminText,
            ),
          ),
        ),
      ],
    );
  }
}

String _initials(String? email, String phone) {
  final source = (email != null && email.isNotEmpty) ? email : phone;
  return source.characters.take(2).toString().toUpperCase();
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';

(String, Color) _kycChip(String status) => switch (status) {
  'VERIFIED' => ('✅ KYC đã xác minh', AppColors.success),
  'PENDING' => ('⏳ KYC chờ duyệt', AppColors.warning),
  'REJECTED' => ('❌ KYC bị từ chối', AppColors.danger),
  _ => ('KYC chưa xác minh', AppColors.adminMuted),
};

String _roleLabel(String role) => switch (role) {
  'OWNER' => 'Chủ xe',
  'RENTER' => 'Người thuê',
  'ADMIN' => 'Admin',
  _ => role,
};

Color _roleColor(String role) => switch (role) {
  'OWNER' => AppColors.success,
  'ADMIN' => const Color(0xFFA855F7),
  _ => AppColors.adminTeal,
};

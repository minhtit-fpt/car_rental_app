import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/presentation/cubit/change_password_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';

/// Mật khẩu tối thiểu (đồng bộ với backend passwordField).
const _minPasswordLength = 8;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _clientError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Kiểm tra phía client trước khi gọi server. Trả thông báo lỗi hoặc null.
  String? _validate(AppLocalizations l10n) {
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      return l10n.changePasswordFillAll;
    }
    if (next.length < _minPasswordLength) return l10n.changePasswordTooShort;
    if (next != confirm) return l10n.changePasswordMismatch;
    if (next == current) return l10n.changePasswordSameAsCurrent;
    return null;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final error = _validate(l10n);
    if (error != null) {
      setState(() => _clientError = error);
      return;
    }
    setState(() => _clientError = null);
    context.read<ChangePasswordCubit>().submit(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            if (state is ChangePasswordSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.changePasswordSuccess),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              context.pop();
            }
          },
          builder: (context, state) {
            final submitting = state is ChangePasswordSubmitting;
            final serverError = state is ChangePasswordFailure
                ? state.message
                : null;
            final error = _clientError ?? serverError;
            return CustomScrollView(
              slivers: [
                const _ChangePasswordAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PasswordField(
                          label: l10n.changePasswordCurrent,
                          controller: _currentController,
                        ),
                        const SizedBox(height: 12),
                        _PasswordField(
                          label: l10n.changePasswordNew,
                          controller: _newController,
                        ),
                        const SizedBox(height: 12),
                        _PasswordField(
                          label: l10n.changePasswordConfirm,
                          controller: _confirmController,
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            error,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: l10n.changePasswordSubmit,
                          icon: Icons.lock_reset_rounded,
                          isLoading: submitting,
                          onPressed: _submit,
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

class _ChangePasswordAppBar extends StatelessWidget {
  const _ChangePasswordAppBar();

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
          AppLocalizations.of(context).settingsChangePassword,
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

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscured,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.mutedText,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 13, color: AppColors.darkText),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/shared/widgets/primary_button.dart';

/// Đăng nhập bằng SĐT + mật khẩu (khớp backend `/api/auth/login`).
/// [AuthCubit] được cung cấp ở gốc app nên màn này chỉ đọc, không tự tạo.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go((state.user?.isAdmin ?? false) ? '/admin' : '/');
        }
        if (state.status == AuthStatus.unauthenticated &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.danger,
              ),
            );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _Logo(),
                    const SizedBox(height: 40),
                    const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Nhập số điện thoại và mật khẩu để tiếp tục',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _PhoneField(controller: _phoneController),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      onToggle: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) => PrimaryButton(
                        label: 'Đăng nhập',
                        onPressed: _submit,
                        isLoading: state.isBusy,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.logoGradient,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'RideVN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số điện thoại',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.darkText,
          ),
          decoration: InputDecoration(
            hintText: '0912 345 678',
            hintStyle: const TextStyle(color: AppColors.mutedText),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppColors.border),
                ),
              ),
              child: const Text(
                '🇻🇳 +84',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary, width: 2),
            errorBorder: _border(AppColors.danger),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Vui lòng nhập số điện thoại';
            if (v.length < 9) return 'Số điện thoại không hợp lệ';
            return null;
          },
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mật khẩu',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(fontSize: 15, color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: AppColors.mutedText),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.mutedText,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary, width: 2),
            errorBorder: _border(AppColors.danger),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
            return null;
          },
        ),
      ],
    );
  }
}

OutlineInputBorder _border(Color color, {double width = 1}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

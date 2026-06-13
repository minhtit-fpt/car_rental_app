import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:frontend/features/auth/presentation/validators.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_switch_link.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      final email = _email.text.trim();
      context.read<AuthCubit>().register(
            phone: _phone.text.trim(),
            password: _password.text,
            email: email.isEmpty ? null : email,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Tạo tài khoản',
      subtitle: 'Đăng ký để bắt đầu hành trình cùng RideVN',
      child: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (_, current) =>
            current is AuthUnauthenticated && current.message != null,
        listener: (context, state) {
          if (state is AuthUnauthenticated && state.message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: AppColors.orange,
                ),
              );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _phone,
                  label: 'Số điện thoại',
                  hint: '09xxxxxxxx',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: validatePhone,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _email,
                  label: 'Email (tùy chọn)',
                  hint: 'ban@email.com',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validateOptionalEmail,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _password,
                  label: 'Mật khẩu',
                  hint: 'Tối thiểu 8 ký tự',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: validatePassword,
                  onFieldSubmitted: (_) {
                    if (!isLoading) _submit();
                  },
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  label: 'Đăng ký',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                AuthSwitchLink(
                  question: 'Đã có tài khoản?',
                  action: 'Đăng nhập',
                  onTap: () => context.go('/login'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

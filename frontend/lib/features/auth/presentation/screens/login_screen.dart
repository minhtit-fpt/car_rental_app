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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthCubit>().login(
            phone: _phone.text.trim(),
            password: _password.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Chào mừng trở lại',
      subtitle: 'Đăng nhập để tiếp tục thuê xe',
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
                  controller: _password,
                  label: 'Mật khẩu',
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
                  label: 'Đăng nhập',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                AuthSwitchLink(
                  question: 'Chưa có tài khoản?',
                  action: 'Đăng ký',
                  onTap: () => context.go('/register'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

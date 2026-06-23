import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';

/// Đăng ký bằng SĐT + mật khẩu (+ email tuỳ chọn), khớp backend
/// `/api/auth/register`. Backend chưa lưu họ tên nên màn này không thu trường đó.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authAgreeTermsRequired),
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    context.read<AuthCubit>().register(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      email: email.isEmpty ? null : email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          backgroundColor: context.palette.background,
          appBar: AppBar(
            backgroundColor: context.palette.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: context.palette.darkText,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              l10n.authRegisterTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.palette.darkText,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.authRegisterSectionAccount,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.palette.mutedText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: l10n.phoneLabel,
                      controller: _phoneController,
                      hint: '0912 345 678',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.phoneRequired;
                        }
                        if (v.length < 9) return l10n.phoneInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: l10n.authEmailOptionalLabel,
                      controller: _emailController,
                      hint: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (!v.contains('@')) return l10n.authEmailInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: l10n.passwordLabel,
                      controller: _passwordController,
                      hint: l10n.authPasswordHintMin,
                      obscure: _obscurePassword,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (v.length < 8) {
                          return l10n.authPasswordMinLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: l10n.authConfirmPasswordLabel,
                      controller: _confirmController,
                      hint: l10n.authConfirmPasswordHint,
                      obscure: _obscureConfirm,
                      onToggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return l10n.authPasswordMismatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _TermsCheckbox(
                      value: _agreedToTerms,
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) => PrimaryButton(
                        label: l10n.authRegisterTitle,
                        onPressed: _submit,
                        isLoading: state.isBusy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.authAlreadyHaveAccount,
                          style: TextStyle(color: context.palette.mutedText),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            l10n.authLoginTitle,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.obscure = false,
    this.onToggleObscure,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.palette.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscure,
          style: TextStyle(fontSize: 15, color: context.palette.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.palette.mutedText),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: context.palette.mutedText,
                      size: 20,
                    ),
                  ),
            filled: true,
            fillColor: context.palette.surface,
            border: _border(context.palette.border),
            enabledBorder: _border(context.palette.border),
            focusedBorder: _border(AppColors.primary, width: 2),
            errorBorder: _border(AppColors.danger),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const linkStyle = TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: context.palette.secondaryText,
              ),
              children: [
                TextSpan(text: l10n.authTermsPrefix),
                TextSpan(text: l10n.authTermsOfUse, style: linkStyle),
                TextSpan(text: l10n.authTermsAnd),
                TextSpan(text: l10n.authPrivacyPolicy, style: linkStyle),
                TextSpan(text: l10n.authTermsSuffix),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

OutlineInputBorder _border(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

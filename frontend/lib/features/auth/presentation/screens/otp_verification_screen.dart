import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/otp_input_field.dart';
import 'package:frontend/shared/widgets/primary_button.dart';

/// Màn OTP — hiện chạy mock ([OtpCubit]) vì backend OTP chưa có.
/// Để dành cho giai đoạn "OTP sau" (vd xác thực SĐT / quên mật khẩu).
class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(),
      child: _OtpView(phone: phone),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView({required this.phone});

  final String phone;

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  static const _resendSeconds = 60;

  String _otp = '';
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft == 0) {
        _timer?.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _resend() {
    context.read<OtpCubit>().sendOtp(widget.phone);
    _startCountdown();
  }

  void _verify() {
    if (_otp.length != 6) return;
    context.read<OtpCubit>().verifyOtp(_otp);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          context.go('/');
        }
        if (state is OtpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.authOtpInvalid),
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
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n.authOtpTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.palette.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: context.palette.mutedText,
                      ),
                      children: [
                        TextSpan(text: l10n.authOtpSentToPrefix),
                        TextSpan(
                          text: '+84 ${widget.phone}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.palette.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  OtpInputField(
                    length: 6,
                    onCompleted: (otp) => setState(() => _otp = otp),
                    onChanged: (otp) => setState(() => _otp = otp),
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<OtpCubit, OtpState>(
                    builder: (context, state) => PrimaryButton(
                      label: l10n.authOtpConfirm,
                      onPressed: _otp.length == 6 ? _verify : null,
                      isLoading: state is OtpVerifying,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _secondsLeft > 0
                        ? RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: context.palette.mutedText,
                              ),
                              children: [
                                TextSpan(text: l10n.authOtpResendInPrefix),
                                TextSpan(
                                  text: l10n.authOtpSeconds(_secondsLeft),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: _resend,
                            child: Text(
                              l10n.authOtpResend,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(40),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.authOtpDemoHint,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

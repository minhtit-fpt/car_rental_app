import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/presentation/cubit/otp_cubit.dart';
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
    return BlocListener<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          context.go('/');
        }
        if (state is OtpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.darkText),
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
                  const Text(
                    'Xác thực OTP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                      children: [
                        const TextSpan(text: 'Nhập mã 6 số đã gửi tới '),
                        TextSpan(
                          text: '+84 ${widget.phone}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
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
                      label: 'Xác nhận',
                      onPressed: _otp.length == 6 ? _verify : null,
                      isLoading: state is OtpVerifying,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _secondsLeft > 0
                        ? RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedText,
                              ),
                              children: [
                                const TextSpan(text: 'Gửi lại sau '),
                                TextSpan(
                                  text: '$_secondsLeft giây',
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
                            child: const Text(
                              'Gửi lại mã OTP',
                              style: TextStyle(
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
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dùng mã 123456 để test trong môi trường demo.',
                            style: TextStyle(
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

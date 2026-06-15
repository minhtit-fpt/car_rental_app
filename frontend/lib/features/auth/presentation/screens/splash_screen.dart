import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Hiển thị trong lúc [AuthCubit.checkSession] khôi phục phiên (trạng thái
/// `unknown`). Router sẽ chuyển sang `/` hoặc `/login` ngay khi biết kết quả.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.logoGradient,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'RideVN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

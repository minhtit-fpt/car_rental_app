import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_upload_cubit.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

class KycUploadScreen extends StatelessWidget {
  const KycUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KycUploadCubit(),
      child: const _KycUploadView(),
    );
  }
}

class _KycUploadView extends StatelessWidget {
  const _KycUploadView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<KycUploadCubit, KycUploadState>(
      listenWhen: (p, c) => c.submitted && !p.submitted,
      listener: (context, _) => context.pushReplacement('/kyc/status'),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              const RvSliverAppBar(
                title: 'Xác minh danh tính',
                subtitle: 'Hoàn thành KYC để thuê và đăng xe',
                role: RvRole.neutral,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoBanner(),
                      const SizedBox(height: 20),
                      const _StepLabel(step: '1', title: 'CCCD / Căn cước công dân'),
                      const SizedBox(height: 10),
                      _DocTile(docType: 'cccd', icon: Icons.credit_card_rounded),
                      const SizedBox(height: 20),
                      const _StepLabel(step: '2', title: 'Bằng lái xe'),
                      const SizedBox(height: 10),
                      _DocTile(
                        docType: 'license',
                        icon: Icons.drive_eta_rounded,
                      ),
                      const SizedBox(height: 20),
                      const _StepLabel(step: '3', title: 'Ảnh chân dung (selfie)'),
                      const SizedBox(height: 10),
                      _DocTile(
                        docType: 'selfie',
                        icon: Icons.face_rounded,
                        hint: 'Chụp thẳng mặt, ánh sáng đầy đủ',
                      ),
                      const SizedBox(height: 28),
                      BlocBuilder<KycUploadCubit, KycUploadState>(
                        builder: (context, state) => PrimaryButton(
                          label: 'Gửi xác minh',
                          onPressed: state.allUploaded
                              ? () => context.read<KycUploadCubit>().submit()
                              : null,
                          isLoading: state.isSubmitting,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 20, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Thông tin của bạn được mã hoá và bảo mật. Chỉ dùng để xác minh danh tính.',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.step, required this.title});
  final String step;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.docType,
    required this.icon,
    this.hint,
  });

  final String docType;
  final IconData icon;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KycUploadCubit, KycUploadState>(
      builder: (context, state) {
        final doc = switch (docType) {
          'cccd' => state.cccd,
          'license' => state.license,
          _ => state.selfie,
        };

        final isUploaded = doc.status == DocStatus.uploaded;
        final isUploading = doc.status == DocStatus.uploading;

        return GestureDetector(
          onTap: isUploading
              ? null
              : () => context.read<KycUploadCubit>().uploadDoc(docType),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUploaded
                  ? AppColors.success.withAlpha(13)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUploaded
                    ? AppColors.success.withAlpha(80)
                    : isUploading
                        ? AppColors.primary.withAlpha(80)
                        : AppColors.border,
                width: isUploaded || isUploading ? 1.5 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadowColor,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isUploaded
                        ? AppColors.successSoft
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isUploading
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Icon(
                          isUploaded ? Icons.check_circle_rounded : icon,
                          color: isUploaded
                              ? AppColors.success
                              : AppColors.mutedText,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUploaded
                            ? 'Đã tải lên'
                            : isUploading
                                ? 'Đang tải...'
                                : 'Chạm để tải ảnh',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isUploaded
                              ? AppColors.success
                              : AppColors.darkText,
                        ),
                      ),
                      if (hint != null && !isUploaded)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            hint!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ),
                      if (isUploaded && doc.fileName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            doc.fileName!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  isUploaded
                      ? Icons.edit_outlined
                      : Icons.upload_rounded,
                  size: 18,
                  color: isUploaded
                      ? AppColors.mutedText
                      : AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

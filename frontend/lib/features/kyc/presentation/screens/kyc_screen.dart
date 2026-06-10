import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_doc_type.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_cubit.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_state.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<KycCubit>(
      create: (_) => getIt<KycCubit>()..load(),
      child: const _KycView(),
    );
  }
}

class _KycView extends StatelessWidget {
  const _KycView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const _KycSliverAppBar(),
            SliverToBoxAdapter(
              child: BlocConsumer<KycCubit, KycState>(
                listenWhen: (prev, next) =>
                    next is KycReady && next.error != null,
                listener: (context, state) {
                  if (state is KycReady && state.error != null) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.error!),
                          backgroundColor: AppColors.orange,
                        ),
                      );
                  }
                },
                builder: (context, state) => switch (state) {
                  KycLoading() => const _CenteredBox(
                      child: CircularProgressIndicator(),
                    ),
                  KycLoadFailure(:final message) => _LoadFailure(message: message),
                  KycReady(:final info, :final submitting) => _KycContent(
                      info: info,
                      submitting: submitting,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KycSliverAppBar extends StatelessWidget {
  const _KycSliverAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: const Color(0xFF003380),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Xác minh danh tính',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          alignment: Alignment.bottomLeft,
          child: const Text(
            'Cần xác minh để được đặt xe',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class _KycContent extends StatelessWidget {
  const _KycContent({required this.info, required this.submitting});

  final KycStatusInfo info;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusCard(info: info),
          if (info.canSubmit) ...[
            const SizedBox(height: 16),
            _KycForm(submitting: submitting),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Status card + badge
// ─────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.info});

  final KycStatusInfo info;

  @override
  Widget build(BuildContext context) {
    final (color, icon, title, subtitle) = _present(info);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 12,
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
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String, String) _present(KycStatusInfo info) {
    return switch (info.status) {
      KycStatus.verified => (
          AppColors.teal,
          Icons.verified_rounded,
          'Đã xác minh',
          'Tài khoản của bạn đã được xác minh danh tính.',
        ),
      KycStatus.pending => (
          AppColors.primary,
          Icons.hourglass_top_rounded,
          'Đang chờ duyệt',
          'Hồ sơ đang được xét duyệt, vui lòng chờ trong giây lát.',
        ),
      KycStatus.rejected => (
          AppColors.orange,
          Icons.error_outline_rounded,
          'Bị từ chối',
          info.rejectReason ?? 'Hồ sơ chưa đạt yêu cầu, vui lòng nộp lại.',
        ),
      KycStatus.unverified => (
          AppColors.mutedText,
          Icons.badge_outlined,
          'Chưa xác minh',
          'Tải lên giấy tờ để xác minh danh tính và bắt đầu đặt xe.',
        ),
    };
  }
}

// ─────────────────────────────────────────────
// Upload form (3 documents)
// ─────────────────────────────────────────────

class _KycForm extends StatefulWidget {
  const _KycForm({required this.submitting});

  final bool submitting;

  @override
  State<_KycForm> createState() => _KycFormState();
}

class _KycFormState extends State<_KycForm> {
  final _picker = ImagePicker();
  final _files = <KycDocType, File>{};

  bool get _allPicked => KycDocType.values.every(_files.containsKey);

  Future<void> _pick(KycDocType docType) async {
    final source = await _chooseSource();
    if (source == null) return;
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (picked == null || !mounted) return;
    setState(() => _files[docType] = File(picked.path));
  }

  Future<ImageSource?> _chooseSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final cccd = _files[KycDocType.cccd];
    final license = _files[KycDocType.license];
    final face = _files[KycDocType.face];
    if (cccd == null || license == null || face == null) return;
    context.read<KycCubit>().submitDocuments(
          cccd: cccd,
          license: license,
          face: face,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12, top: 4),
          child: Text(
            'Tải lên giấy tờ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ),
        for (final docType in KycDocType.values) ...[
          _DocPickerTile(
            docType: docType,
            file: _files[docType],
            onTap: widget.submitting ? null : () => _pick(docType),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        FilledButton(
          onPressed: (_allPicked && !widget.submitting) ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: widget.submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Gửi xác minh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }
}

class _DocPickerTile extends StatelessWidget {
  const _DocPickerTile({
    required this.docType,
    required this.file,
    required this.onTap,
  });

  final KycDocType docType;
  final File? file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final picked = file != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: picked ? AppColors.teal : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: picked
                    ? Image.file(file!, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.mutedText,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docType.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    docType.hint,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              picked ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: picked ? AppColors.teal : AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Loading / failure helpers
// ─────────────────────────────────────────────

class _CenteredBox extends StatelessWidget {
  const _CenteredBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(child: child),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 48, color: AppColors.mutedText),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.read<KycCubit>().load(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

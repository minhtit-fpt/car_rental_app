import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

class ContractScreen extends StatelessWidget {
  const ContractScreen({super.key, required this.vehicle, required this.cubit});

  final Vehicle vehicle;
  final BookingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: _ContractView(vehicle: vehicle),
    );
  }
}

class _ContractView extends StatelessWidget {
  const _ContractView({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingFormState>(
      listenWhen: (p, c) => c.contractSigned && !p.contractSigned,
      listener: (context, _) => context.pushReplacement(
        '/booking/active',
        extra: {'vehicle': vehicle, 'cubit': context.read<BookingCubit>()},
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              const RvSliverAppBar(
                title: 'Hợp đồng điện tử',
                subtitle: 'Đọc kỹ và ký hợp đồng',
                role: RvRole.renter,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _ContractHeader(vehicle: vehicle),
                      const SizedBox(height: 16),
                      const _ContractBody(),
                      const SizedBox(height: 16),
                      const _TermsSection(),
                      const SizedBox(height: 20),
                      _SignatureSection(),
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

class _ContractHeader extends StatelessWidget {
  const _ContractHeader({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('📋', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          const Text(
            'Hợp đồng thuê xe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vehicle.name,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Mã hợp đồng: HĐ-2025-08472',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractBody extends StatelessWidget {
  const _ContractBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ContractSection(
            title: 'I. CÁC BÊN THAM GIA',
            content:
                '• Bên A (Chủ xe): Được xác minh qua hệ thống KYC RideVN\n'
                '• Bên B (Người thuê): Đã hoàn tất xác minh danh tính',
          ),
          const Divider(color: AppColors.border, height: 24),
          const _ContractSection(
            title: 'II. THÔNG TIN XE',
            content:
                'Xe được giao đúng tình trạng đã mô tả. Người thuê có '
                'trách nhiệm kiểm tra xe trước khi nhận và xác nhận trong ứng dụng.',
          ),
          const Divider(color: AppColors.border, height: 24),
          const _ContractSection(
            title: 'III. ĐIỀU KHOẢN SỬ DỤNG',
            content:
                '• Không sử dụng xe vào mục đích trái pháp luật\n'
                '• Không cho người khác lái xe khi chưa được chủ xe đồng ý\n'
                '• Trả xe đúng thời hạn, đúng địa điểm thỏa thuận\n'
                '• Bảo quản xe cẩn thận, không tự ý sửa chữa',
          ),
          const Divider(color: AppColors.border, height: 24),
          const _ContractSection(
            title: 'IV. BỒI THƯỜNG THIỆT HẠI',
            content:
                'Mọi thiệt hại nằm ngoài phạm vi bảo hiểm sẽ do Bên B '
                'chịu trách nhiệm bồi thường theo định giá của bên thứ ba được chỉ định.',
          ),
        ],
      ),
    );
  }
}

class _ContractSection extends StatelessWidget {
  const _ContractSection({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _TermsSection extends StatefulWidget {
  const _TermsSection();

  @override
  State<_TermsSection> createState() => _TermsSectionState();
}

class _TermsSectionState extends State<_TermsSection> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _agreed,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Tôi đã đọc kỹ và đồng ý với tất cả điều khoản trong hợp đồng thuê xe này.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignatureSection extends StatefulWidget {
  @override
  State<_SignatureSection> createState() => _SignatureSectionState();
}

class _SignatureSectionState extends State<_SignatureSection> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreed,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Tôi đã đọc kỹ và đồng ý với tất cả điều khoản trong hợp đồng thuê xe này.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Ký hợp đồng',
          onPressed: _agreed
              ? () => context.read<BookingCubit>().signContract()
              : null,
          icon: Icons.draw_rounded,
        ),
      ],
    );
  }
}

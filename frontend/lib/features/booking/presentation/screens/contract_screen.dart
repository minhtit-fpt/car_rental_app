import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return BlocListener<BookingCubit, BookingFormState>(
      listenWhen: (p, c) => c.contractSigned && !p.contractSigned,
      listener: (context, state) {
        // Đã ký hợp đồng → thanh toán thật. Xong xuôi đơn ở trạng thái
        // AWAITING_OWNER (chờ chủ xe xác nhận) — CHƯA phải chuyến đang chạy, nên
        // về danh sách "Chuyến" chứ không nhảy vào màn active trip.
        context.pushReplacement(
          '/payment',
          extra: {
            'bookingId': state.booking?.id,
            'amount': state.booking?.totalPrice ?? 0.0,
            'successLocation': '/trips',
          },
        );
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: context.palette.background,
          body: CustomScrollView(
            slivers: [
              RvSliverAppBar(
                title: l10n.contractTitle,
                subtitle: l10n.contractSubtitle,
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
    final l10n = AppLocalizations.of(context);
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
          Text(
            l10n.contractHeading,
            style: const TextStyle(
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
            child: Text(
              l10n.contractCode('HĐ-2025-08472'),
              style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContractSection(
            title: l10n.contractPartiesTitle,
            content: l10n.contractPartiesBody,
          ),
          Divider(color: context.palette.border, height: 24),
          _ContractSection(
            title: l10n.contractVehicleTitle,
            content: l10n.contractVehicleBody,
          ),
          Divider(color: context.palette.border, height: 24),
          _ContractSection(
            title: l10n.contractTermsTitle,
            content: l10n.contractTermsBody,
          ),
          Divider(color: context.palette.border, height: 24),
          _ContractSection(
            title: l10n.contractCompensationTitle,
            content: l10n.contractCompensationBody,
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.palette.darkText,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: TextStyle(
            fontSize: 12,
            color: context.palette.secondaryText,
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
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                l10n.contractAgree,
                style: TextStyle(
                  fontSize: 13,
                  color: context.palette.secondaryText,
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
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.palette.border),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    l10n.contractAgree,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.palette.secondaryText,
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
          label: l10n.contractSign,
          onPressed: _agreed
              ? () => context.read<BookingCubit>().signContract()
              : null,
          icon: Icons.draw_rounded,
        ),
      ],
    );
  }
}

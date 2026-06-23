import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Trang tĩnh Điều khoản & Chính sách (terms + privacy). Nội dung lấy từ ARB
/// nên tự localize; không gọi backend.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = <_TermsSectionData>[
      _TermsSectionData(l10n.termsIntroHeading, l10n.termsIntroBody),
      _TermsSectionData(l10n.termsAccountHeading, l10n.termsAccountBody),
      _TermsSectionData(l10n.termsBookingHeading, l10n.termsBookingBody),
      _TermsSectionData(l10n.termsConductHeading, l10n.termsConductBody),
      _TermsSectionData(l10n.termsPrivacyHeading, l10n.termsPrivacyBody),
      _TermsSectionData(l10n.termsContactHeading, l10n.termsContactBody),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const _TermsSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        l10n.termsUpdatedLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                    for (final section in sections) ...[
                      _TermsSection(section),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSectionData {
  const _TermsSectionData(this.heading, this.body);
  final String heading;
  final String body;
}

class _TermsSection extends StatelessWidget {
  const _TermsSection(this.data);

  final _TermsSectionData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.heading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSliverAppBar extends StatelessWidget {
  const _TermsSliverAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16),
        title: Text(
          AppLocalizations.of(context).termsScreenTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        background: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.renterHeaderGradient),
        ),
      ),
    );
  }
}

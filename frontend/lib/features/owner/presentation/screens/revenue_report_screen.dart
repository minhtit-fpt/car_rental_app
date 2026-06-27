import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/owner/domain/entities/owner_revenue.dart';
import 'package:frontend/features/owner/presentation/cubit/owner_revenue_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/section_header.dart';

/// Định dạng VND đầy đủ với dấu phân cách nghìn (vd: 8409000 → "8.409.000").
String _fmtVnd(num v) {
  final s = v.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}$buf';
}

/// Nhãn tháng `YYYY-MM` → `T<m>`.
String _monthLabel(String ym) {
  final parts = ym.split('-');
  return parts.length == 2 ? 'T${int.parse(parts[1])}' : ym;
}

class RevenueReportScreen extends StatelessWidget {
  const RevenueReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OwnerRevenueCubit>()..load(),
      child: const _RevenueReportView(),
    );
  }
}

class _RevenueReportView extends StatelessWidget {
  const _RevenueReportView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: CustomScrollView(
          slivers: [
            RvSliverAppBar(
              title: l10n.ownerRevenueTitle,
              subtitle: l10n.ownerRevenueSubtitle,
              role: RvRole.owner,
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<OwnerRevenueCubit, OwnerRevenueState>(
                builder: (context, state) => switch (state) {
                  OwnerRevenueLoading() => const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  OwnerRevenueError(:final message) => _ErrorView(
                    message: message,
                    onRetry: () => context.read<OwnerRevenueCubit>().load(),
                  ),
                  OwnerRevenueLoaded(:final revenue) => _Content(
                    revenue: revenue,
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 48),
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.palette.secondaryText),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).commonRetry),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.revenue});
  final OwnerRevenue revenue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _SummaryCard(revenue: revenue),
          const SizedBox(height: 16),
          _ChartCard(monthly: revenue.monthly),
          const SizedBox(height: 16),
          _TransactionList(transactions: revenue.transactions),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.revenue});
  final OwnerRevenue revenue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ownerIncomeThisMonth,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '${_fmtVnd(revenue.monthRevenue)} VNĐ',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _StatChip(
            label: l10n.ownerPaidTrips(revenue.totalTrips),
            icon: Icons.directions_car_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.monthly});
  final List<RevenuePoint> monthly;

  @override
  Widget build(BuildContext context) {
    final maxTotal = monthly.fold<double>(
      0,
      (m, p) => p.total > m ? p.total : m,
    );
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
          SectionHeader(title: AppLocalizations.of(context).ownerRevenueChart),
          const SizedBox(height: 16),
          if (maxTotal == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).ownerNoRevenue,
                  style: TextStyle(
                    color: context.palette.mutedText,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthly.map((p) {
                  final fraction = maxTotal == 0 ? 0.0 : p.total / maxTotal;
                  final isPeak = p.total == maxTotal && p.total > 0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: fraction.clamp(0.02, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: isPeak
                                        ? AppColors.heroGradient
                                        : LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.primary.withAlpha(100),
                                              AppColors.primary.withAlpha(60),
                                            ],
                                          ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _monthLabel(p.month),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.palette.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});
  final List<OwnerTransaction> transactions;

  @override
  Widget build(BuildContext context) {
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
          SectionHeader(
            title: AppLocalizations.of(context).ownerRecentTransactions,
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).ownerNoTransactions,
                  style: TextStyle(
                    color: context.palette.mutedText,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...transactions.asMap().entries.map((entry) {
              final i = entry.key;
              return Column(
                children: [
                  _TransactionRow(transaction: entry.value),
                  if (i < transactions.length - 1)
                    Divider(color: context.palette.border, height: 16),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});
  final OwnerTransaction transaction;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.success;
    final d = transaction.startTime;
    final dateLabel =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.arrow_downward_rounded, size: 18, color: color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.vehicleTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.palette.darkText,
                ),
              ),
              Text(
                '${transaction.renterDisplayName} · $dateLabel',
                style: TextStyle(
                  fontSize: 12,
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
        ),
        Text(
          '+${_fmtVnd(transaction.amount)} VNĐ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

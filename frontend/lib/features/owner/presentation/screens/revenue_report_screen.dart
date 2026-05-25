import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/section_header.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  int _selectedPeriod = 1; // 0=week, 1=month, 2=year

  static const _periods = ['Tuần', 'Tháng', 'Năm'];

  static const _monthlyRevenue = [
    _RevenueBar('T1', 0.4),
    _RevenueBar('T2', 0.6),
    _RevenueBar('T3', 0.5),
    _RevenueBar('T4', 0.8),
    _RevenueBar('T5', 0.7),
    _RevenueBar('T6', 1.0),
  ];

  static const _transactions = [
    _Transaction('Thanh N.', '05/06 – 08/06', 2403, true),
    _Transaction('Hùng T.', '28/05 – 30/05', 1602, true),
    _Transaction('Lan P.', '20/05 – 22/05', 1602, true),
    _Transaction('Phí nền tảng', '01/06', -534, false),
    _Transaction('Minh D.', '15/05 – 18/05', 2403, true),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const RvSliverAppBar(
              title: 'Báo cáo doanh thu',
              subtitle: 'Theo dõi thu nhập của bạn',
              role: RvRole.owner,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _SummaryCard(period: _periods[_selectedPeriod]),
                    const SizedBox(height: 16),
                    _PeriodSelector(
                      selected: _selectedPeriod,
                      periods: _periods,
                      onChanged: (i) => setState(() => _selectedPeriod = i),
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(bars: _monthlyRevenue),
                    const SizedBox(height: 16),
                    _StatsRow(),
                    const SizedBox(height: 16),
                    _TransactionList(transactions: _transactions),
                    const SizedBox(height: 24),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.period});
  final String period;

  @override
  Widget build(BuildContext context) {
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
            'Thu nhập $period này',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '8,409,000 VNĐ',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                label: '12 chuyến',
                icon: Icons.directions_car_rounded,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: '+18% vs tháng trước',
                icon: Icons.trending_up_rounded,
              ),
            ],
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

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selected,
    required this.periods,
    required this.onChanged,
  });
  final int selected;
  final List<String> periods;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(periods.length, (i) {
          final isSelected = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    periods[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RevenueBar {
  const _RevenueBar(this.label, this.fraction);
  final String label;
  final double fraction;
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.bars});
  final List<_RevenueBar> bars;

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
          const SectionHeader(title: 'Biểu đồ doanh thu'),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars
                  .map((bar) => Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: bar.fraction,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: bar.fraction == 1.0
                                            ? AppColors.heroGradient
                                            : LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  AppColors.primary
                                                      .withAlpha(100),
                                                  AppColors.primary
                                                      .withAlpha(60),
                                                ],
                                              ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                bar.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            label: 'Đánh giá TB',
            value: '4.9',
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.directions_car_rounded,
            label: 'Tỉ lệ chấp nhận',
            value: '94%',
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_month_rounded,
            label: 'Ngày cho thuê',
            value: '38',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 18, color: color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _Transaction {
  const _Transaction(this.name, this.date, this.amount, this.isIncome);
  final String name;
  final String date;
  final int amount;
  final bool isIncome;
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});
  final List<_Transaction> transactions;

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
          const SectionHeader(title: 'Giao dịch gần đây'),
          const SizedBox(height: 12),
          ...transactions.asMap().entries.map((entry) {
            final i = entry.key;
            final tx = entry.value;
            return Column(
              children: [
                _TransactionRow(transaction: tx),
                if (i < transactions.length - 1)
                  const Divider(color: AppColors.border, height: 16),
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
  final _Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final sign = transaction.isIncome ? '+' : '';

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              transaction.isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 18,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                transaction.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$sign${transaction.amount}K VNĐ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

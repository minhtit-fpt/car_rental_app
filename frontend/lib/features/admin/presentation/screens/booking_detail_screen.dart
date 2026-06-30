import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/domain/entities/admin_booking_detail.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_booking_detail_cubit.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_booking_format.dart';

/// Chi tiết một đơn + hoàn tiền. Hoàn tiền là thao tác TIỀN → confirm dialog
/// bắt buộc nhập lý do; backend ghi audit + báo người thuê.
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.adminBg,
        appBar: AppBar(
          backgroundColor: AppColors.adminSurface,
          foregroundColor: AppColors.adminText,
          elevation: 0,
          title: const Text(
            'Chi tiết đơn',
            style: TextStyle(
              color: AppColors.adminText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocConsumer<AdminBookingDetailCubit, AdminBookingDetailState>(
          listener: (context, state) {
            if (state is AdminBookingDetailLoaded) {
              if (state.refunded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hoàn tiền thành công')),
                );
              } else if (state.refundError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.refundError!)),
                );
              }
            }
          },
          builder: (context, state) {
            return switch (state) {
              AdminBookingDetailLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.adminBlue),
              ),
              AdminBookingDetailError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.adminMuted),
                  ),
                ),
              ),
              AdminBookingDetailLoaded(:final detail, :final submitting) =>
                _Content(detail: detail, submitting: submitting),
            };
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.detail, required this.submitting});

  final AdminBookingDetail detail;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    final payment = detail.payment;
    final canRefund = payment != null && payment.status == 'PAID';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Card(
            title: detail.vehicle.title,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _badge(bookingStatusLabel(detail.status),
                    bookingStatusColor(detail.status)),
                const SizedBox(height: 10),
                _kv('Tổng tiền', formatVnd(detail.totalPrice)),
                _kv(
                  'Thời gian',
                  '${_fmt(detail.startTime)} → ${_fmt(detail.endTime)}',
                ),
                _kv('Giao xe tận nơi', detail.deliveryRequested ? 'Có' : 'Không'),
                _kv('Tạo lúc', _fmt(detail.createdAt)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            title: 'Người thuê',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('SĐT', detail.renter.phone),
                if (detail.renter.email != null)
                  _kv('Email', detail.renter.email!),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            title: 'Thanh toán',
            child: payment == null
                ? const Text(
                    'Chưa có thanh toán',
                    style: TextStyle(color: AppColors.adminMuted, fontSize: 13),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _badge(paymentStatusLabel(payment.status),
                          paymentStatusColor(payment.status)),
                      const SizedBox(height: 10),
                      _kv('Phương thức', payment.method),
                      _kv('Số tiền', formatVnd(payment.amount)),
                      if (payment.paidAt != null)
                        _kv('Thanh toán lúc', _fmt(payment.paidAt!)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canRefund && !submitting
                              ? () => _openRefundDialog(context, payment.amount)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            disabledBackgroundColor: AppColors.adminCard,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: AppColors.adminMuted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: submitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  canRefund
                                      ? 'Hoàn tiền'
                                      : 'Không thể hoàn tiền',
                                ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (detail.damageReport != null) ...[
            const SizedBox(height: 16),
            _Card(
              title: 'Báo cáo hư hỏng (AI)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.damageReport!.summary,
                    style: const TextStyle(
                      color: AppColors.adminText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _kv(
                    'Chi phí ước tính',
                    formatVnd(detail.damageReport!.estimatedCost),
                  ),
                ],
              ),
            ),
          ],
          if (detail.inspections.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Card(
              title: 'Kiểm tra xe',
              child: Column(
                children: detail.inspections
                    .map(
                      (i) => _kv(
                        i.phase == 'CHECKIN' ? 'Nhận xe' : 'Trả xe',
                        '${i.photoCount} ảnh · ${_fmt(i.createdAt)}',
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (detail.disputes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Card(
              title: 'Tranh chấp',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: detail.disputes
                    .map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                d.title,
                                style: const TextStyle(
                                  color: AppColors.adminText,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            _badge(d.status, AppColors.adminMuted),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _openRefundDialog(BuildContext context, double maxAmount) async {
    final cubit = context.read<AdminBookingDetailCubit>();
    final amountController = TextEditingController(
      text: maxAmount.round().toString(),
    );
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.adminSurface,
        title: const Text(
          'Xác nhận hoàn tiền',
          style: TextStyle(color: AppColors.adminText, fontSize: 16),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.adminText),
                decoration: _inputDecoration('Số tiền hoàn (đ)'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Nhập số tiền hợp lệ';
                  if (n > maxAmount) return 'Vượt quá số đã thanh toán';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.adminText),
                decoration: _inputDecoration('Lý do (bắt buộc)'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Nhập lý do hoàn tiền' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Hoàn tiền', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.refund(
        amount: double.parse(amountController.text.trim()),
        reason: reasonController.text.trim(),
      );
    }
  }
}

InputDecoration _inputDecoration(String label) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: AppColors.adminMuted),
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.adminBorder),
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.adminBlue),
  ),
);

String _fmt(DateTime d) {
  final local = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}

Widget _kv(String key, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 3),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 120,
        child: Text(
          key,
          style: const TextStyle(color: AppColors.adminMuted, fontSize: 13),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(color: AppColors.adminText, fontSize: 13),
        ),
      ),
    ],
  ),
);

Widget _badge(String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: color.withAlpha(38),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    label,
    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
  ),
);

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.adminText,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

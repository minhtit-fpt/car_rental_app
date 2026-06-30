import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/domain/entities/admin_vehicle_item.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_vehicles_cubit.dart';

/// Hàng đợi "Duyệt xe" trên dashboard — duyệt/từ chối ngay tại chỗ.
class AdminVehicleReviewCard extends StatelessWidget {
  const AdminVehicleReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text(
              'Duyệt xe chờ duyệt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.adminText,
              ),
            ),
          ),
          const Divider(color: AppColors.adminBorder, height: 1),
          BlocBuilder<AdminVehiclesCubit, AdminVehiclesState>(
            builder: (context, state) {
              return switch (state) {
                AdminVehiclesLoading() => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.adminBlue,
                    ),
                  ),
                ),
                AdminVehiclesError(:final message) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: AppColors.adminMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.read<AdminVehiclesCubit>().load(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
                AdminVehiclesLoaded(:final items) =>
                  items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Không có xe nào chờ duyệt',
                            style: TextStyle(
                              color: AppColors.adminMuted,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (final v in items) _VehicleRow(vehicle: v),
                          ],
                        ),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const _VehicleRow({required this.vehicle});
  final AdminVehicleItem vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.adminBorder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.adminText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_typeLabel(vehicle.type)}'
                      '${vehicle.isElectric ? ' · ⚡EV' : ''} · '
                      '${vehicle.ownerEmail ?? vehicle.ownerPhone}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.adminMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_formatPrice(vehicle.pricePerHour)}/h',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.adminText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _reject(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approve(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Duyệt'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext context) async {
    final cubit = context.read<AdminVehiclesCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final error = await cubit.review(vehicle.id, decision: 'approve');
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _reject(BuildContext context) async {
    final cubit = context.read<AdminVehiclesCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final reason = await _askReason(context);
    if (reason == null) return; // huỷ dialog
    final error = await cubit.review(
      vehicle.id,
      decision: 'reject',
      rejectionReason: reason,
    );
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<String?> _askReason(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.adminCard,
        title: const Text(
          'Lý do từ chối',
          style: TextStyle(color: AppColors.adminText),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: AppColors.adminText),
          decoration: const InputDecoration(
            hintText: 'Nhập lý do từ chối xe…',
            hintStyle: TextStyle(color: AppColors.adminMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(dialogContext).pop(text);
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }
}

String _typeLabel(String type) => switch (type) {
  'CAR' => 'Ô tô',
  'MOTORBIKE' => 'Xe máy',
  'BICYCLE' => 'Xe đạp',
  _ => type,
};

String _formatPrice(double v) {
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
  if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
  return v.toStringAsFixed(0);
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_cubit.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_state.dart';
import 'package:frontend/features/vehicle/presentation/screens/car_detail_screen.dart';
import 'package:frontend/features/vehicle/presentation/widgets/car_card.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VehicleListCubit>(
      create: (_) => getIt<VehicleListCubit>()..load(),
      child: const _CarListView(),
    );
  }
}

class _CarListView extends StatefulWidget {
  const _CarListView();

  @override
  State<_CarListView> createState() => _CarListViewState();
}

class _CarListViewState extends State<_CarListView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Vehicle> _applySearch(List<Vehicle> items) {
    if (_query.isEmpty) return items;
    final q = _query.toLowerCase();
    return items.where((v) => v.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const _CarListAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 12),
                    const _FilterChips(),
                  ],
                ),
              ),
            ),
            BlocBuilder<VehicleListCubit, VehicleListState>(
              builder: (context, state) => switch (state) {
                VehicleListLoading() => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                VehicleListError(:final message) => SliverToBoxAdapter(
                    child: _ErrorBox(message: message),
                  ),
                VehicleListLoaded(:final items) =>
                  _VehicleSliverList(items: _applySearch(items)),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CarListAppBar extends StatelessWidget {
  const _CarListAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF003380),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppColors.logoGradient,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Tìm xe',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Tìm theo tên xe...',
        prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleListCubit, VehicleListState>(
      builder: (context, state) {
        final cubit = context.read<VehicleListCubit>();
        final (VehicleType? type, bool electric) = switch (state) {
          VehicleListLoaded(:final type, :final electricOnly) =>
            (type, electricOnly),
          VehicleListError(:final type, :final electricOnly) =>
            (type, electricOnly),
          VehicleListLoading() => (null, false),
        };
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _Chip(
                label: 'Tất cả',
                selected: type == null && !electric,
                onTap: () {
                  cubit.toggleElectric(false);
                  cubit.setType(null);
                },
              ),
              const SizedBox(width: 8),
              for (final t in VehicleType.values) ...[
                _Chip(
                  label: t.label,
                  selected: type == t && !electric,
                  onTap: () => cubit.setType(t),
                ),
                const SizedBox(width: 8),
              ],
              _Chip(
                label: '⚡ EV',
                selected: electric,
                onTap: () => cubit.toggleElectric(!electric),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

class _VehicleSliverList extends StatelessWidget {
  const _VehicleSliverList({required this.items});

  final List<Vehicle> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(
            child: Text(
              'Không tìm thấy xe phù hợp',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final vehicle = items[index];
          return CarListTile(
            vehicle: vehicle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CarDetailScreen(vehicle: vehicle),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

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
            onPressed: () => context.read<VehicleListCubit>().load(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

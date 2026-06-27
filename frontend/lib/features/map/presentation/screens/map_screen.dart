import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/location/app_geo.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/map/presentation/cubit/map_cubit.dart';
import 'package:frontend/features/map/presentation/vehicle_marker.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/utils/price_format.dart';

/// Bản đồ trực tiếp (Phase C): quét xe quanh vị trí người dùng, marker tap →
/// chi tiết xe. Tự cấp [MapCubit] để dùng được cả ở tab lẫn khi push route.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapCubit>(
      create: (_) => sl<MapCubit>()..load(),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _moveCamera(GeoPoint center) {
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(center.latitude, center.longitude),
        AppGeo.cityZoom,
      ),
    );
  }

  Set<Marker> _buildMarkers(List<VehicleMarker> markers) {
    return {
      for (final m in markers)
        Marker(
          markerId: MarkerId(m.vehicleId),
          position: LatLng(m.position.latitude, m.position.longitude),
          infoWindow: InfoWindow(
            title: m.title,
            snippet: formatPricePerDayK(
              m.pricePerHour * 24 / 1000,
              withCurrency: true,
            ),
            onTap: () => context.push('/vehicles/${m.vehicleId}'),
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: BlocConsumer<MapCubit, MapState>(
          listenWhen: (prev, curr) => curr is MapLoaded,
          listener: (context, state) {
            if (state is MapLoaded) _moveCamera(state.center);
          },
          builder: (context, state) {
            return Stack(
              children: [
                _MapCanvas(
                  state: state,
                  markers: _buildMarkers(
                    state is MapLoaded ? state.markers : const [],
                  ),
                  onMapCreated: (c) => _controller = c,
                ),
                _TopBar(
                  label: switch (state) {
                    MapLoaded(:final markers) => l10n.mapNearbyCount(
                      markers.length,
                    ),
                    _ => l10n.mapScreenTitle,
                  },
                ),
                if (state is MapLoaded && state.availableTypes.length > 1)
                  _FilterBar(
                    types: state.availableTypes,
                    selected: state.filter.types,
                    onToggle: (t) => context.read<MapCubit>().toggleType(t),
                  ),
                Positioned(
                  right: 16,
                  bottom: 24,
                  child: _MapControls(
                    onRefresh: () => context.read<MapCubit>().load(),
                  ),
                ),
                if (state is MapLoading)
                  const Positioned.fill(child: _LoadingVeil()),
                if (state is MapError)
                  Positioned.fill(
                    child: _ErrorVeil(
                      message: state.message,
                      onRetry: () => context.read<MapCubit>().load(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Bản đồ nền. Tách riêng để overlay (top bar, controls) ngồi trên Stack.
class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.state,
    required this.markers,
    required this.onMapCreated,
  });

  final MapState state;
  final Set<Marker> markers;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    final center = switch (state) {
      MapLoaded(:final center) => center,
      _ => AppGeo.defaultCenter,
    };
    return GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(center.latitude, center.longitude),
        zoom: AppGeo.cityZoom,
      ),
      markers: markers,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            if (canPop) ...[
              _CircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.palette.border),
                  boxShadow: [
                    BoxShadow(
                      color: context.palette.cardShadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.palette.darkText,
                        ),
                      ),
                    ),
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

/// Hàng chip lọc theo loại xe, đặt ngay dưới thanh tiêu đề.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.types,
    required this.selected,
    required this.onToggle,
  });

  final List<String> types;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 64, left: 16, right: 16),
        child: SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: types.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final type = types[i];
              return _TypeChip(
                label: _typeLabelL10n(l10n, type),
                active: selected.contains(type),
                onTap: () => onToggle(type),
              );
            },
          ),
        ),
      ),
    );
  }
}

String _typeLabelL10n(AppLocalizations l10n, String type) => switch (type) {
  'MOTORBIKE' => l10n.vehicleTypeMotorbike,
  'BICYCLE' => l10n.vehicleTypeBicycle,
  _ => l10n.vehicleTypeCar,
};

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.accent : context.palette.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: context.palette.cardShadowColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : context.palette.darkText,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  const _MapControls({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CircleButton(
      icon: Icons.my_location_rounded,
      tooltip: l10n.mapMyLocationTooltip,
      onTap: onRefresh,
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: context.palette.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: context.palette.cardShadowColor,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 22, color: context.palette.darkText),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class _LoadingVeil extends StatelessWidget {
  const _LoadingVeil();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.background.withAlpha(150),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorVeil extends StatelessWidget {
  const _ErrorVeil({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: context.palette.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: context.palette.mutedText,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.palette.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
            ],
          ),
        ),
      ),
    );
  }
}

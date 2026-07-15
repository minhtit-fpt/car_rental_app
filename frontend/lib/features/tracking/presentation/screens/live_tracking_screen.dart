import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/tracking/domain/entities/tracking_snapshot.dart';
import 'package:frontend/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:frontend/features/tracking/presentation/cubit/tracking_state.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Bản đồ theo dõi vị trí realtime một xe. Poll `/latest` mỗi 3s (TrackingCubit),
/// marker chạy theo điểm mới nhất, polyline vẽ trail. Dùng chung owner + renter.
class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrackingCubit>(
      create: (_) => sl<TrackingCubit>()..start(vehicleId),
      child: const _TrackingView(),
    );
  }
}

class _TrackingView extends StatefulWidget {
  const _TrackingView();

  @override
  State<_TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<_TrackingView> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _follow(TrackingPoint p) {
    // ponytail: camera animate theo điểm mới nhất; không tween marker từng frame
    // giữa 2 poll. Đủ mượt cho poll 3s; nâng lên AnimationController nếu cần.
    _controller?.animateCamera(
      CameraUpdate.newLatLng(LatLng(p.lat, p.lng)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: BlocConsumer<TrackingCubit, TrackingState>(
          listenWhen: (_, curr) => curr is TrackingLoaded,
          listener: (context, state) {
            if (state is TrackingLoaded) _follow(state.snapshot.latest);
          },
          builder: (context, state) {
            final loaded = state is TrackingLoaded ? state : null;
            return Stack(
              children: [
                _MapCanvas(
                  snapshot: loaded?.snapshot,
                  onMapCreated: (c) => _controller = c,
                ),
                _TopBar(
                  title: l10n.trackingTitle,
                  speedKmh: loaded?.snapshot.latest.speedKmh,
                ),
                if (state is TrackingLoading)
                  Positioned.fill(child: _LoadingVeil(label: l10n.trackingWaiting)),
                if (state is TrackingError)
                  Positioned.fill(
                    child: _ErrorVeil(
                      message: state.message,
                      onRetry: () => context.read<TrackingCubit>().retry(),
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

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({required this.snapshot, required this.onMapCreated});

  final TrackingSnapshot? snapshot;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    // Tâm mặc định Hà Nội khi chưa có điểm nào.
    final latest = snapshot?.latest;
    final target = latest != null
        ? LatLng(latest.lat, latest.lng)
        : const LatLng(21.0278, 105.8342);
    final trail = snapshot?.trail ?? const <TrackingPoint>[];
    return GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(target: target, zoom: 15),
      markers: {
        if (latest != null)
          Marker(
            markerId: const MarkerId('vehicle'),
            position: LatLng(latest.lat, latest.lng),
            rotation: 0,
          ),
      },
      polylines: {
        if (trail.length > 1)
          Polyline(
            polylineId: const PolylineId('trail'),
            points: [for (final p in trail) LatLng(p.lat, p.lng)],
            color: AppColors.accent,
            width: 4,
          ),
      },
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.speedKmh});

  final String title;
  final double? speedKmh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            _CircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 10),
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
                      Icons.navigation_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        speedKmh != null
                            ? l10n.trackingSpeed(speedKmh!.round())
                            : title,
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
  }
}

class _LoadingVeil extends StatelessWidget {
  const _LoadingVeil({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.background.withAlpha(150),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: context.palette.secondaryText,
              ),
            ),
          ],
        ),
      ),
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
                Icons.location_off_outlined,
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

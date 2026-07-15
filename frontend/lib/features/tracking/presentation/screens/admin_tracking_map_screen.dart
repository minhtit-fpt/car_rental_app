import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/tracking/domain/entities/tracking_snapshot.dart';
import 'package:frontend/features/tracking/presentation/cubit/admin_tracking_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Map admin: mọi xe đang trong chuyến. Poll `/active` mỗi 8s. Dark-theme admin.
class AdminTrackingMapScreen extends StatelessWidget {
  const AdminTrackingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminTrackingCubit>(
      create: (_) => sl<AdminTrackingCubit>()..start(),
      child: const _AdminTrackingView(),
    );
  }
}

class _AdminTrackingView extends StatefulWidget {
  const _AdminTrackingView();

  @override
  State<_AdminTrackingView> createState() => _AdminTrackingViewState();
}

class _AdminTrackingViewState extends State<_AdminTrackingView> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Set<Marker> _markers(List<ActiveVehicleLocation> vehicles) {
    return {
      for (final v in vehicles)
        Marker(
          markerId: MarkerId(v.vehicleId),
          position: LatLng(v.lat, v.lng),
          infoWindow: InfoWindow(
            title: v.title,
            snippet: v.speedKmh != null
                ? '${v.speedKmh!.round()} km/h'
                : null,
            onTap: v.bookingId != null
                ? () => context.push('/vehicles/${v.vehicleId}')
                : null,
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.adminBg,
        appBar: AppBar(
          backgroundColor: AppColors.adminSurface,
          foregroundColor: AppColors.adminText,
          title: Text(l10n.adminActiveTripsTitle),
        ),
        body: BlocBuilder<AdminTrackingCubit, AdminTrackingState>(
          builder: (context, state) {
            final vehicles = state is AdminTrackingLoaded
                ? state.vehicles
                : const <ActiveVehicleLocation>[];
            return Stack(
              children: [
                GoogleMap(
                  onMapCreated: (c) => _controller = c,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(21.0278, 105.8342),
                    zoom: 12,
                  ),
                  markers: _markers(vehicles),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                if (state is AdminTrackingLoading)
                  const Center(child: CircularProgressIndicator()),
                if (state is AdminTrackingLoaded && vehicles.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.adminSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.adminBorder),
                      ),
                      child: Text(
                        l10n.adminActiveTripsEmpty,
                        style: const TextStyle(color: AppColors.adminMuted),
                      ),
                    ),
                  ),
                if (state is AdminTrackingError)
                  Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.adminMuted),
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

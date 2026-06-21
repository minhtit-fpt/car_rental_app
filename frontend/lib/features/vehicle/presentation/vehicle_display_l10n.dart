import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Localized display labels for [Vehicle]. Kept in the presentation layer so the
/// domain entity stays pure Dart (no `AppLocalizations`/`BuildContext`).
extension VehicleDisplayL10n on Vehicle {
  /// Localized vehicle type, e.g. "Ô tô" / "Car".
  String typeLabelL10n(AppLocalizations l10n) => switch (type) {
    'MOTORBIKE' => l10n.vehicleTypeMotorbike,
    'BICYCLE' => l10n.vehicleTypeBicycle,
    _ => l10n.vehicleTypeCar,
  };

  /// Localized gearbox label, or null when the backend hasn't provided it.
  String? transmissionLabelL10n(AppLocalizations l10n) =>
      switch (transmission) {
        'AUTOMATIC' => l10n.vehicleTransmissionAutomatic,
        'MANUAL' => l10n.vehicleTransmissionManual,
        _ => null,
      };

  /// Subtitle line: "Điện · Ô tô" when electric, otherwise just the type label.
  String typeSummaryL10n(AppLocalizations l10n) => isElectric
      ? '${l10n.vehicleElectric} · ${typeLabelL10n(l10n)}'
      : typeLabelL10n(l10n);
}

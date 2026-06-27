import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Theme-variant neutral tokens — surfaces, text, borders, card shadow.
///
/// Brand + semantic colours (primary, accent, teal, danger, gradients…) stay in
/// [AppColors] as `const`: they read the same in light and dark. Only the
/// neutral scaffolding flips per theme, so those tokens live here and are read
/// through `context.palette` instead of the `const` [AppColors] members.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceSunken,
    required this.inkLight,
    required this.darkText,
    required this.secondaryText,
    required this.mutedText,
    required this.placeholderText,
    required this.border,
    required this.border2,
    required this.cardShadowColor,
  });

  final Color background;
  final Color surface;
  final Color surfaceSunken;
  final Color inkLight;
  final Color darkText;
  final Color secondaryText;
  final Color mutedText;
  final Color placeholderText;
  final Color border;
  final Color border2;
  final Color cardShadowColor;

  /// Light — current RideVN tokens ([AppColors] stays the source of truth).
  static const AppPalette light = AppPalette(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceSunken: AppColors.surfaceSunken,
    inkLight: AppColors.inkLight,
    darkText: AppColors.darkText,
    secondaryText: AppColors.secondaryText,
    mutedText: AppColors.mutedText,
    placeholderText: AppColors.placeholderText,
    border: AppColors.border,
    border2: AppColors.border2,
    cardShadowColor: AppColors.cardShadowColor,
  );

  /// Dark — deep navy surface system, aligned with the admin dark palette so
  /// the product reads as one family across renter/owner/admin surfaces.
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0A1628), // page background (ink-25 → navy-950)
    surface: Color(0xFF142035), // card surface (ink-0 → navy-900)
    surfaceSunken: Color(0xFF0E1A2E), // sunken chip/badge bg (ink-50)
    inkLight: Color(0xFF1F2D45), // raised hairline fill (ink-100)
    darkText: Color(0xFFE8F0FC), // primary text (ink-900 inverted)
    secondaryText: Color(0xFFB4C2D8), // ink-600
    mutedText: Color(0xFF8395AD), // ink-500
    placeholderText: Color(0xFF5E718C), // ink-400
    border: Color(0xFF253A54), // ink-200
    border2: Color(0xFF31496A), // ink-300
    cardShadowColor: Color(0x66000000), // shadows read darker on dark surfaces
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSunken,
    Color? inkLight,
    Color? darkText,
    Color? secondaryText,
    Color? mutedText,
    Color? placeholderText,
    Color? border,
    Color? border2,
    Color? cardShadowColor,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      inkLight: inkLight ?? this.inkLight,
      darkText: darkText ?? this.darkText,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      placeholderText: placeholderText ?? this.placeholderText,
      border: border ?? this.border,
      border2: border2 ?? this.border2,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      inkLight: Color.lerp(inkLight, other.inkLight, t)!,
      darkText: Color.lerp(darkText, other.darkText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      placeholderText: Color.lerp(placeholderText, other.placeholderText, t)!,
      border: Color.lerp(border, other.border, t)!,
      border2: Color.lerp(border2, other.border2, t)!,
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t)!,
    );
  }
}

/// Read the active [AppPalette] from the nearest theme. Falls back to light if
/// the extension is somehow absent (e.g. a bare `MaterialApp` in a test).
extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

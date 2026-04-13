import 'package:flutter/material.dart';

/// Design tokens extracted from Figma: RideVN Car Rental Application
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF007BFF);
  static const Color teal = Color(0xFF00D4AA);
  static const Color orange = Color(0xFFFF6B35);
  static const Color background = Color(0xFFF8FBFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF0A1628);
  static const Color secondaryText = Color(0xFF4A5568);
  static const Color mutedText = Color(0xFF889AAA);
  static const Color border = Color(0xFFE2EAF4);
  static const Color starYellow = Color(0xFFF9A825);

  // rgba(0, 70, 180, 0.06)
  static const Color cardShadowColor = Color(0x0F0046B4);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF001A3D),
      Color(0xFF003380),
      Color(0xFF007BFF),
      Color(0xFF4DABFF),
    ],
    stops: [0.0, 0.259, 0.481, 0.741],
  );

  static const LinearGradient promoGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF007BFF), Color(0xFF00D4AA)],
  );

  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF007BFF), Color(0xFF00D4AA)],
    stops: [0.0, 0.714],
  );

  static const LinearGradient cardImageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x14007BFF), Color(0x0A00D4AA)],
    stops: [0.0, 0.714],
  );
}

import 'package:flutter/material.dart';

/// RideVN Design System — Design tokens aligned with the Claude Design handoff.
/// Navy-600 is primary trust color; Orange-500 is the accent/CTA.
class AppColors {
  AppColors._();

  // ── Primary — Trust Navy ──────────────────────────────────────────
  static const Color primary = Color(0xFF14336B); // navy-600
  static const Color navyMid = Color(0xFF1E4789); // navy-500
  static const Color navyDark = Color(0xFF0E2552); // navy-700
  static const Color navyDeep = Color(0xFF091A3D); // navy-800
  static const Color navySoft = Color(0xFFEEF3FA); // navy-50

  // ── Accent — Lacquer Orange ───────────────────────────────────────
  static const Color accent = Color(0xFFF26A1F); // orange-500 — CTA / active state
  static const Color orange = Color(0xFFF26A1F); // alias for accent
  static const Color orangeDark = Color(0xFFD2540E); // orange-600
  static const Color orangeSoft = Color(0xFFFFF3EC); // orange-50

  // ── Verified teal — "đã xác minh" ────────────────────────────────
  static const Color teal = Color(0xFF00A8A8); // verified-500
  static const Color tealDark = Color(0xFF007878);
  static const Color tealSoft = Color(0x1A00A8A8); // 10% teal

  // ── Neutrals (warm-cool grey, slight blue tint) ───────────────────
  static const Color background = Color(0xFFFAFBFD); // ink-25
  static const Color surface = Color(0xFFFFFFFF); // ink-0
  static const Color surfaceSunken = Color(0xFFF4F6FA); // ink-50
  static const Color inkLight = Color(0xFFECEFF5); // ink-100

  // ── Text ─────────────────────────────────────────────────────────
  static const Color darkText = Color(0xFF10131A); // ink-900 — primary text
  static const Color secondaryText = Color(0xFF4A5263); // ink-600
  static const Color mutedText = Color(0xFF6B7384); // ink-500
  static const Color placeholderText = Color(0xFF99A2B2); // ink-400

  // ── Borders / Dividers ────────────────────────────────────────────
  static const Color border = Color(0xFFDDE3EC); // ink-200
  static const Color border2 = Color(0xFFC2CAD7); // ink-300

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF1BA85A);
  static const Color successSoft = Color(0xFFE8F7EE);
  static const Color warning = Color(0xFFE5A300);
  static const Color warningSoft = Color(0xFFFFF6E0);
  static const Color danger = Color(0xFFDC2B2B);
  static const Color dangerSoft = Color(0xFFFDECEC);

  // ── Stars — orange per design system ─────────────────────────────
  static const Color starYellow = Color(0xFFF26A1F);

  // ── Card shadow ───────────────────────────────────────────────────
  // 0 2px 6px rgba(15, 23, 42, 0.06) + 0 1px 2px rgba(15, 23, 42, 0.04)
  static const Color cardShadowColor = Color(0x0F0F172A); // --shadow-sm layer 1

  // ── Gradients ─────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF091A3D), Color(0xFF14336B)],
  );

  // Renter screen headers
  static const LinearGradient renterHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF003380), Color(0xFF007BFF)],
  );

  // Owner screen headers
  static const LinearGradient ownerHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF001A3D), Color(0xFF003380)],
  );

  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E4789), Color(0xFF14336B)],
  );

  static const LinearGradient cardImageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1414336B), Color(0x0A14336B)],
  );

  // Celebration / success dialogs (e.g. booking confirmed)
  static const LinearGradient promoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, orangeDark],
  );

  // ── Admin dark theme ─────────────────────────────────────────────
  // Deep-navy dark surface system used exclusively on admin screens.
  static const Color adminBg = Color(0xFF0A1628); // page background
  static const Color adminSurface = Color(0xFF142035); // primary card surface
  static const Color adminCard = Color(0xFF1A2A40); // elevated card
  static const Color adminBorder = Color(0xFF253A54); // dividers / borders
  static const Color adminText = Color(0xFFE8F0FC); // primary text on dark
  static const Color adminMuted = Color(0xFF6B8AAD); // secondary text on dark
  static const Color adminBlue = Color(0xFF3B82F6); // interactive blue
  static const Color adminTeal = Color(0xFF14B8A6); // teal accent on dark
  static const LinearGradient adminHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF142035)],
  );

  // Orange CTA shadow — used for primary CTA only (keeps orange scarce)
  static const List<BoxShadow> accentShadow = [
    BoxShadow(
      color: Color(0x47F26A1F), // rgba(242, 106, 31, 0.28)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> brandShadow = [
    BoxShadow(
      color: Color(0x33143368), // rgba(20, 51, 107, 0.20)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

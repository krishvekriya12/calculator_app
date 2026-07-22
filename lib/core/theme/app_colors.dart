import 'package:flutter/material.dart';

/// Centralized color palette for Daily Hisaab.
class AppColors {
  AppColors._();

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF1A1A1F);
  static const Color surfaceVariant = Color(0xFF242429);
  static const Color surfaceHighlight = Color(0xFF2D2D35);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF2D2D35);
  static const Color borderLight = Color(0xFF3D3D47);

  // ── Accent — Gold ─────────────────────────────────────────────────────────
  static const Color gold = Color(0xFFF0B429);
  static const Color goldLight = Color(0xFFF5C842);
  static const Color goldDark = Color(0xFFD4980F);
  static const Color goldBg = Color(0xFF2A210A);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color profit = Color(0xFF22C55E);
  static const Color profitBg = Color(0xFF0D2018);
  static const Color loss = Color(0xFFEF4444);
  static const Color lossBg = Color(0xFF280F0F);
  static const Color neutral = Color(0xFF9CA3AF);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF8F8F2);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // ── Platform brand colors ──────────────────────────────────────────────────
  static const Color zomato = Color(0xFFE23744);
  static const Color swiggy = Color(0xFFFC8019);
  static const Color ola = Color(0xFF2DB928);
  static const Color uber = Color(0xFFCBD5E1);
  static const Color rapido = Color(0xFFFFD500);
  static const Color dunzo = Color(0xFF00B140);
  static const Color other = Color(0xFF818CF8);

  /// Returns brand color for a platform name.
  static Color platformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'zomato':
        return zomato;
      case 'swiggy':
        return swiggy;
      case 'ola':
        return ola;
      case 'uber':
        return uber;
      case 'rapido':
        return rapido;
      case 'dunzo':
        return dunzo;
      default:
        return other;
    }
  }

  /// Returns a lightly tinted background for a platform card.
  static Color platformBg(String platform) =>
      platformColor(platform).withValues(alpha: 0.12);
}

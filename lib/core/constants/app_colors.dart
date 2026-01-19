import 'package:flutter/material.dart';

class AppColors {
  // ---------------- BRAND ----------------
  static const Color primaryBlue = Color(0xFF1D4ED8);
  static const Color accentOrange = Color(0xFFF97316);

  static const MaterialColor primaryBlueSwatch =
      MaterialColor(0xFF0D47A1, <int, Color>{
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: Color(0xFF2196F3),
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2),
        800: Color(0xFF1565C0),
        900: Color(0xFF0D47A1),
      });

  // ---------------- LIGHT MODE ----------------
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF3F4F6);
  static const Color lightTextPrimary = Color(0xFF1E3A8A);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // ---------------- DARK MODE ----------------
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkSurface = Color(0xFF020617);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  // ---------------- STATUS ----------------
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF97316);
  static const Color infoBlue = Color(0xFF3B82F6);

  // ---------------- SHADOW ----------------
  static const Color shadowGray = Color(0xFF9CA3AF);
}

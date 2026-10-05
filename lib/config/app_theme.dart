import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Luxury Palette
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgSurface = Color(0xFF121829);
  static const Color bgCard = Color(0xFF182238);
  static const Color bgCardHover = Color(0xFF1E2B47);
  static const Color border = Color(0xFF23324F);
  static const Color borderLight = Color(0xFF2E4166);

  // Brand Accents
  static const Color primary = Color(0xFFE50914); // TicOne Red
  static const Color primaryLight = Color(0xFFFF3844);
  static const Color primaryGradientStart = Color(0xFFE50914);
  static const Color primaryGradientEnd = Color(0xFFB81D24);

  static const Color secondary = Color(0xFF00E5FF); // Electric Cyan
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentOrange = Color(0xFFF97316);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,
      cardColor: bgCard,
      dividerColor: border,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: bgSurface,
        error: error,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        hintStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 13),
        labelStyle: GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
          elevation: 2,
        ),
      ),
    );
  }
}

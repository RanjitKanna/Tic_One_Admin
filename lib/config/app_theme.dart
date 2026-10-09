import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Admin theme aligned with the TicOne app's "Nocturne Cinema" dark theme
/// (Tic_One/lib/theme/cinex_tokens.dart → CineXColors).
class AppTheme {
  // Nocturne Cinema surfaces
  static const Color bgDark = Color(0xFF0B1326); // background
  static const Color bgSurface = Color(0xFF131B2E); // surfaceContainerLow
  static const Color bgCard = Color(0xFF171F33); // surfaceContainer
  static const Color bgCardHover = Color(0xFF222A3D); // surfaceContainerHigh
  static const Color border = Color(0xFF2D3449); // surfaceContainerHighest
  static const Color borderLight = Color(0xFF464554); // outlineVariant

  // Brand Accents — Electric Indigo
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8); // indigo400
  static const Color primaryGradientStart = Color(0xFF6366F1);
  static const Color primaryGradientEnd = Color(0xFF4F46E5); // primaryHover

  static const Color secondary = Color(0xFF0EA5E9); // Vivid Sky
  static const Color accentIndigo = Color(0xFFF43F5E); // Warm Coral (TicOne secondary)
  static const Color accentGold = Color(0xFFFBBF24); // amber400
  static const Color accentPurple = Color(0xFFA78BFA); // violet400
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentOrange = Color(0xFFF97316);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
    return base.copyWith(
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,
      cardColor: bgCard,
      dividerColor: border,
      canvasColor: bgSurface,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF8083FF),
        secondary: Color(0xFFF43F5E),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFB50036),
        surface: bgSurface,
        onSurface: textPrimary,
        surfaceContainerLowest: Color(0xFF060E20),
        surfaceContainerLow: bgSurface,
        surfaceContainer: bgCard,
        surfaceContainerHigh: bgCardHover,
        surfaceContainerHighest: border,
        outline: Color(0xFF908FA0),
        outlineVariant: borderLight,
        error: error,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        base.textTheme.apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
      ),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(base.primaryTextTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        hintStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 13),
        labelStyle: GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryLight),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    );
  }
}

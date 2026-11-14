import 'package:flutter/material.dart';

/// Doctor Crop Design System & Theme Tokens
///
/// Designed to convey:
/// - Agriculture & Crop Health
/// - Professional Agricultural Assistance
/// - Trust, Cleanliness, and Modern Usability
class DoctorCropColors {
  // Brand Greens
  static const Color primary = Color(0xFF15803D); // Emerald field green
  static const Color primaryDark = Color(0xFF14532D); // Deep forest green
  static const Color primaryLight = Color(0xFFDCFCE7); // Mint container tint
  static const Color primaryUltraLight = Color(0xFFF0FDF4); // Subtle green tint

  // Accent Harvest Colors
  static const Color accent = Color(0xFFF97316); // Harvest amber/orange
  static const Color accentDark = Color(0xFFC2410C); // Deep rust
  static const Color accentLight = Color(0xFFFFEDD5); // Soft orange tint

  // Neutral Palette
  static const Color background = Color(0xFFF8FAF7); // Organic off-white
  static const Color surface = Colors.white; // Pure white cards & sheets
  static const Color surfaceSecondary = Color(0xFFF1F5F0); // Subtle contrast surface
  static const Color surfaceMuted = Color(0xFFF4F6F4);

  static const Color border = Color(0xFFE2E8E0); // Crisp light border
  static const Color borderLight = Color(0xFFEEF2EC);

  // Typography Colors
  static const Color textPrimary = Color(0xFF111827); // Deep slate / ink
  static const Color textSecondary = Color(0xFF4B5563); // Readable body text
  static const Color textMuted = Color(0xFF9CA3AF); // Subtitle / hint text
  static const Color textLight = Colors.white;

  // Status & Utility Colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
}

class DoctorCropTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: DoctorCropColors.primary,
      scaffoldBackgroundColor: DoctorCropColors.background,
      colorScheme: const ColorScheme.light(
        primary: DoctorCropColors.primary,
        onPrimary: Colors.white,
        primaryContainer: DoctorCropColors.primaryLight,
        onPrimaryContainer: DoctorCropColors.primaryDark,
        secondary: DoctorCropColors.accent,
        onSecondary: Colors.white,
        secondaryContainer: DoctorCropColors.accentLight,
        onSecondaryContainer: DoctorCropColors.accentDark,
        surface: DoctorCropColors.surface,
        onSurface: DoctorCropColors.textPrimary,
        error: DoctorCropColors.error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: DoctorCropColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: DoctorCropColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DoctorCropColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DoctorCropColors.primary,
          side: const BorderSide(color: DoctorCropColors.primary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DoctorCropColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: DoctorCropColors.textMuted,
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: DoctorCropColors.textSecondary,
          fontSize: 13.5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DoctorCropColors.border, width: 0.9),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DoctorCropColors.border, width: 0.9),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DoctorCropColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DoctorCropColors.error, width: 1.2),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DoctorCropColors.border, width: 0.9),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: DoctorCropColors.borderLight,
        thickness: 0.8,
        space: 1,
      ),
    );
  }

  // Modern Card Decoration Helper
  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double radius = 16,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? DoctorCropColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? DoctorCropColors.border,
        width: 0.9,
      ),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ]
          : null,
    );
  }

  // Modern Bottom Navigation Container Decoration
  static BoxDecoration bottomNavDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: const Border(
        top: BorderSide(color: DoctorCropColors.border, width: 0.9),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, -3),
        ),
      ],
    );
  }
}

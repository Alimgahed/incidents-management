import 'package:flutter/material.dart';

/// =======================
/// BRAND / PRIMARY
/// =======================
const Color appColor = Color(0xFF1E3A5F);
const Color buttonColor = Color(0xFF007BFF);
// Additional helper colors used in this file:
const Color darkBorder = Color(0xFF334155); // Subtle borders
const Color darkText = Color(0xFFE2E8F0); // Primary text
const Color darkTextSecondary = Color(0xFF94A3B8); // Secondary text
const Color darkDivider = Color(0xFF475569); // Dividers/separastors

/// =======================ww
/// TEXT COLORS
/// =======================
const Color primaryTextColor = Color(0xFF1A202C);
const Color secondaryTextColor = Color(0xFF4A5565);
const Color disabledTextColor = Color(0xFF9CA3AF);

/// =======================
/// LIGHT MODE BACKGROUNDS
/// =======================
const Color scaffoldColor = Color(0xFFF9FAFB);
const Color containerColor = Color(0xFFF9FAFB);
const Color fieldColor = Color(0xFFF5F6F7);
const Color inputFieldColor = Color(0xFFF5F6F7);
const Color divColor = Color(0xFFF5F5F5);
const Color radioColor = Color(0xFFE2E8F0);

/// =======================
/// DARK MODE BACKGROUNDS
/// =======================
const Color darkColor = Color(0xFF0B1020);
const Color darkColor2 = Color(0xFF0F172A);
const Color darkCardColor = Color(0xFF141B2D);
const Color darkFieldColor = Color(0xFF1E293B);

/// =======================
/// STATUS / FEEDBACK
/// =======================
const Color successColor = Color(0xFF22C55E);
const Color warningColor = Color(0xFFCB3843);
const Color infoColor = Color(0xFF38BDF8);
const Color accentColor = Color(0xFF2C5F8D);
const Color backgroundColor = Color(0xFFF5F7FA);
const Color borderColor = Color(0xFFE0E6ED);

const Color errorColor = Color(0xFFEF4444);

/// =======================
/// BORDERS & DIVIDERS
/// =======================
const Color darkBorderColor = Color(0xFF334155);


class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2A4D7C);
  static const Color primaryDark = Color(0xFF152B47);
  
  // Accent Colors
  static const Color accentColor = Color(0xFF00D9FF);
  static const Color accentLight = Color(0xFF5CE1FF);
  static const Color accentDark = Color(0xFF00A8CC);
  
  // Status Colors
  static const Color successColor = Color(0xFF00E5A0);
  static const Color errorColor = Color(0xFFFF6B93);
  static const Color warningColor = Color(0xFFFFB547);
  static const Color infoColor = Color(0xFF7B8CDE);
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textTertiary = Color(0xFFA0AEC0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border & Divider
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFEDF2F7);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        fontFamily: 'Poppins',
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: 'Poppins',
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: 'Poppins',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        fontFamily: 'Inter',
        height: 1.4,
      ),
    ),
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 24,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
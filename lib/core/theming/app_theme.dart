import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';

class AppTheme {
  // =======================
  // Color Constants
  // =======================
  static const Color primaryColor = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2A4D7C);
  static const Color primaryDark = Color(0xFF152B47);

  static const Color accentColor = Color(0xFF00D9FF);
  static const Color accentLight = Color(0xFF5CE1FF);
  static const Color accentDark = Color(0xFF00A8CC);

  static const Color successColor = Color(0xFF00E5A0);
  static const Color errorColor = Color(0xFFFF6B93);
  static const Color warningColor = Color(0xFFFFB547);
  static const Color infoColor = Color(0xFF7B8CDE);

  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textTertiary = Color(0xFFA0AEC0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFEDF2F7);

  // =======================
  // Light Theme
  // =======================
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.white,
      fontFamily: 'Alexandria',

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: Colors.white,
        surface: Colors.white,
        onPrimary: Colors.black,
      ),

      // Icons
      iconTheme: IconThemeData(color: appColor),
      primaryIconTheme: IconThemeData(color: appColor),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(
          color: appColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: appColor),
        elevation: 0,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: appColor),

      // Text
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
        bodySmall: TextStyle(color: Colors.black45),
      ),

      brightness: Brightness.light,
      primarySwatch: Colors.blue,
    );
  }
}

// =======================
// Dark Theme
// =======================

class AppDecorations {
  static const BoxDecoration lightContainer = BoxDecoration(
    color: containerColor,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: Color(0x1A000000), // black with 0.1 opacity
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
}

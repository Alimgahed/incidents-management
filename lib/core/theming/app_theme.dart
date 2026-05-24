import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';

class AppTheme {
  // =======================
  // Color Constants — Logo-derived palette
  // =======================
  static const Color primaryColor = Color(0xFF1B4F8A);   // Royal blue
  static const Color primaryLight = Color(0xFF2B6CB0);
  static const Color primaryDark = Color(0xFF0F3460);     // Deep navy

  static const Color accentColor = Color(0xFFCDA349);     // Gold
  static const Color accentLight = Color(0xFFE0C068);
  static const Color accentDark = Color(0xFFAA8030);

  static const Color successColor = Color(0xFF22C55E);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFCDA349);    // Gold as warning
  static const Color infoColor = Color(0xFF5BA3D9);       // Water blue

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
      primaryColor: primaryColor,
      fontFamily: 'Alexandria',

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
      ),

      // Icons
      iconTheme: const IconThemeData(color: primaryColor),
      primaryIconTheme: const IconThemeData(color: primaryColor),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: primaryColor),
        elevation: 0,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryColor),

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
// Decorations
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

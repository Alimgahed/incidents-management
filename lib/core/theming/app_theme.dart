import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';

class AppTheme {
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

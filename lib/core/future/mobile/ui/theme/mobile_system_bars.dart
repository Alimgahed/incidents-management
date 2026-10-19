import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized manager for Android & iOS system bar styling (Status Bar & System Navigation Bar).
///
/// Designed strictly for Mobile screens to provide a seamless edge-to-edge experience:
/// 1. Top Status Bar: Transparent so the app header's official gradient flows continuously
///    behind system icons (time, battery, WiFi), with light icons for optimal contrast.
/// 2. Bottom Navigation Bar: Styled to blend with the app's bottom bar (#164780 navy on dark
///    surfaces or clean white matching the bottom nav bar), ensuring system icons (Back, Home,
///    Recent Apps) remain crisp and visible across all Android versions.
abstract final class MobileSystemBars {
  /// The app's signature deep navy blue, matching the base of the header gradient and bottom accents.
  static const Color appBottomBarBlue = Color(0xFF164780);

  /// Default mobile system UI overlay style used when the screen has the standard gradient header
  /// and white bottom navigation bar or white bottom sheet/actions.
  static SystemUiOverlayStyle get standard {
    if (kIsWeb) return SystemUiOverlayStyle.light;

    return const SystemUiOverlayStyle(
      // Top status bar: completely transparent so gradient header extends seamlessly behind it
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark, // iOS equivalent

      // Bottom system navigation bar: blends with app's bottom bar/scaffold
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }

  /// Overlay style for screens with the blue bottom background or when viewing a dark bottom sheet/bar.
  static SystemUiOverlayStyle get withBlueNavigationBar {
    if (kIsWeb) return SystemUiOverlayStyle.light;

    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,

      systemNavigationBarColor: appBottomBarBlue,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    );
  }

  /// Overlay style for screens with a white or light AppBar (e.g. More Services screen).
  static SystemUiOverlayStyle get lightAppBar {
    if (kIsWeb) return SystemUiOverlayStyle.dark;

    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,

      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }

  /// Central initialization for mobile platforms called during startup.
  static void configureEdgeToEdge() {
    if (kIsWeb) return;

    // Enable edge-to-edge rendering on Android & iOS
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    // Apply the initial standard overlay style
    SystemChrome.setSystemUIOverlayStyle(standard);
  }
}

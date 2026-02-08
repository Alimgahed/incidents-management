import 'package:flutter/material.dart';

/// Responsive helper class to handle different screen sizes
class ResponsiveHelper {
  /// Get screen width
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Determine if the device is mobile (width < 600)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Determine if the device is tablet (width >= 600 && width < 1024)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  /// Determine if the device is desktop (width >= 1024)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  /// Determine if the device is in landscape mode
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Determine if the device is in portrait mode
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Get responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobileSize,
    required double desktopSize,
  }) {
    if (isMobile(context)) {
      return mobileSize;
    } else if (isTablet(context)) {
      return (mobileSize + desktopSize) / 2;
    } else {
      return desktopSize;
    }
  }

  /// Get responsive spacing
  static double responsiveSpacing(
    BuildContext context, {
    required double mobileSpacing,
    required double desktopSpacing,
  }) {
    if (isMobile(context)) {
      return mobileSpacing;
    } else if (isTablet(context)) {
      return (mobileSpacing + desktopSpacing) / 2;
    } else {
      return desktopSpacing;
    }
  }

  /// Get responsive crossAxisCount for GridView
  static int responsiveGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Get responsive column count for flexible layouts
  static int responsiveColumnCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return isLandscape(context) ? 3 : 2;
    }
  }

  /// Get responsive max width for content
  static double responsiveMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return screenWidth(context);
    } else if (isTablet(context)) {
      return 800;
    } else {
      return 1400;
    }
  }

  /// Get device padding (SafeArea equivalent for specific directions)
  static EdgeInsets getDevicePadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }
}

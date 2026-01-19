import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';

class TextStyles {
  TextStyles._();

  // Use these helpers if you need a parameter for fontWeight (and optional color)
  static TextStyle size20({
    FontWeight fontWeight = FontWeight.normal,
    Color color = appColor,
  }) {
    return TextStyle(fontSize: 20.0, fontWeight: fontWeight, color: color);
  }

  static TextStyle size16({
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black87,
  }) {
    return TextStyle(fontSize: 16.0, fontWeight: fontWeight, color: color);
  }

  static TextStyle size14({
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black87,
  }) {
    return TextStyle(fontSize: 14.0, fontWeight: fontWeight, color: color);
  }

  static TextStyle size12({
    FontWeight fontWeight = FontWeight.normal,
    Color color = secondaryTextColor,
  }) {
    return TextStyle(fontSize: 12.0, fontWeight: fontWeight, color: color);
  }

  static TextStyle size8({
    FontWeight fontWeight = FontWeight.normal,
    Color color = secondaryTextColor,
  }) {
    return TextStyle(fontSize: 8.0, fontWeight: fontWeight, color: color);
  }
}

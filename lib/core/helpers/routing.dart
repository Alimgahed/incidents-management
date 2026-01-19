import 'package:flutter/material.dart';

extension Navigation on BuildContext {
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);

  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
  }) => Navigator.of(
    this,
  ).pushReplacementNamed<T, TO>(routeName, arguments: arguments);

  // ⭐ Add this for logout (clears all previous routes)
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) => Navigator.of(this).pushNamedAndRemoveUntil<T>(
    routeName,
    predicate ?? (route) => false,
    arguments: arguments,
  );

  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result); // Handles back navigation
  }

  void popAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }
}

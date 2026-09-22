import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _themeKey = 'app_theme_mode';
  
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey);
      if (isDark == true) {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.light);
      }
    } catch (_) {
      // Fallback to light theme if SharedPreferences fails
      emit(ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newTheme);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, newTheme == ThemeMode.dark);
    } catch (_) {}
  }
}

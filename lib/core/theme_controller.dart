import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.system);

  static const String _key = "theme_mode";

  // Carregar tema salvo ao iniciar app
  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString(_key);

    if (savedTheme == "dark") {
      themeMode.value = ThemeMode.dark;
    } else if (savedTheme == "light") {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.system;
    }
  }

  // Salvar tema
  static Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    if (mode == ThemeMode.dark) {
      await prefs.setString(_key, "dark");
    } else if (mode == ThemeMode.light) {
      await prefs.setString(_key, "light");
    } else {
      await prefs.setString(_key, "system");
    }

    themeMode.value = mode;
  }

  /// 🔥 Toggle
  static void toggleTheme(bool isDark) {
    setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
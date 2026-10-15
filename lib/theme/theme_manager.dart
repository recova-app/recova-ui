import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.system;
  String _colorScheme = 'default';

  ThemeMode get themeMode => _themeMode;
  String get colorScheme => _colorScheme;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    // Here you would save to persistent storage
  }

  void setColorScheme(String scheme) {
    _colorScheme = scheme;
    notifyListeners();
    // Here you would save to persistent storage
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

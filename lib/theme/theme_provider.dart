import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_constance.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  ThemeProvider() {
    _loadTheme(); // Load the theme when the provider is created
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
    _saveTheme(); // Save the theme whenever it is changed
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }

  // Load the saved theme from Shared Preferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode =
        prefs.getString('theme') ?? 'light'; // Default to light if not set
    _themeData = (themeMode == 'dark') ? darkMode : lightMode;
    notifyListeners(); // Notify listeners to rebuild with the loaded theme
  }

  // Save the current theme to Shared Preferences
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = (_themeData == darkMode) ? 'dark' : 'light';
    await prefs.setString('theme', themeMode);
  }
}

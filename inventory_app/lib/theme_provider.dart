// lib/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Quản lý trạng thái Light/Dark mode với lưu trữ cục bộ qua SharedPreferences
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isDarkMode;

  ThemeProvider(this._prefs)
      : _isDarkMode = _prefs.getBool('isDarkMode') ?? false;

  /// True nếu đang ở Dark mode
  bool get isDarkMode => _isDarkMode;

  /// Lấy ThemeMode để truyền vào MaterialApp
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Đổi chế độ và lưu vào SharedPreferences
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _themeKey = 'isDarkTheme';
  
  late Box _box;
  bool _isDark = true;

  bool get isDark => _isDark;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _isDark = _box.get(_themeKey, defaultValue: true);
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    _box.put(_themeKey, _isDark);
    notifyListeners();
  }
}

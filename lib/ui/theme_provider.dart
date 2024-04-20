import 'package:flutter/material.dart';

class ThemeProvier extends ChangeNotifier {
  // dark/light theme
  ThemeMode themeMode = ThemeMode.system;
  ThemeMode get currentTheme => themeMode;
  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  // material you
  bool useMaterialYou = true;
  bool get usingMaterialYou => useMaterialYou;
  void setUsingMaterialYou(bool value) {
    useMaterialYou = value;
    notifyListeners();
  }
}

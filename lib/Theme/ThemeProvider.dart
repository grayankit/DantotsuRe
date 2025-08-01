import 'package:flutter/material.dart';

import '../Preferences/PrefManager.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isOled = false;
  String _theme = 'purple';
  bool _useMaterialYou = false;
  bool _useCustomColor = false;
  int _customColor = 4280391411;
  bool _useGlassMode = false;

  bool get isDarkMode => _isDarkMode;

  bool get isOled => _isOled;

  String get theme => _theme;

  bool get useMaterialYou => _useMaterialYou;

  bool get useCustomColor => _useCustomColor;

  int get customColor => _customColor;

  bool get useGlassMode => _useGlassMode;

  ThemeNotifier() {
    _initialize();
  }

  void _initialize() {
    var darkMode = loadData(PrefName.isDarkMode);
    bool isDark;

    if (darkMode == 0) {
      isDark =
          WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
      saveData(PrefName.isDarkMode, isDark ? 1 : 2);
    } else if (darkMode == 1) {
      isDark = true;
    } else {
      isDark = false;
    }

    _isDarkMode = isDark;
    _isOled = loadData(PrefName.isOled);
    _theme = loadData(PrefName.theme);
    _useMaterialYou = loadData(PrefName.useMaterialYou);
    _useCustomColor = loadData(PrefName.useCustomColor);
    _customColor = loadData(PrefName.customColor);
    _useGlassMode = loadData(PrefName.useGlassMode);
    notifyListeners();
  }

  Future<void> setGlassEffect(bool useGlassEffect) async {
    _useGlassMode = useGlassEffect;
    saveData(PrefName.useGlassMode, useGlassEffect);
    if (useGlassEffect) {
      //setOled(false);
      setMaterialYou(false);
      useCustomTheme(false);
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    saveData(PrefName.isDarkMode, _isDarkMode ? 1 : 2);
    if (!isDarkMode) {
      setOled(false);
    }
    notifyListeners();
  }

  Future<void> setOled(bool isOled) async {
    _isOled = isOled;
    saveData(PrefName.isOled, isOled);
    if (isOled) {
      setDarkMode(true);
    }
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _theme = theme;
    useCustomTheme(false);
    setMaterialYou(false);
    saveData(PrefName.theme, theme);
    notifyListeners();
  }

  Future<void> setMaterialYou(bool useMaterialYou) async {
    _useMaterialYou = useMaterialYou;
    saveData(PrefName.useMaterialYou, useMaterialYou);
    if (useMaterialYou) {
      useCustomTheme(false);
      setGlassEffect(false);
    }
    notifyListeners();
  }

  Future<void> useCustomTheme(bool useCustomTheme) async {
    _useCustomColor = useCustomTheme;
    saveData(PrefName.useCustomColor, useCustomTheme);
    if (useCustomTheme) {
      setMaterialYou(false);
      setGlassEffect(false);
    }
    notifyListeners();
  }

  Future<void> setCustomColor(Color color) async {
    _customColor = color.value;
    saveData(PrefName.customColor, color.value);
    notifyListeners();
  }
}

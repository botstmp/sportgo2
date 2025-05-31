// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import '../../shared/themes/app_themes.dart';
import '../services/storage_service.dart';

/// Провайдер для управления темами и языком приложения SportOn
class ThemeProvider with ChangeNotifier {
  // === ПРИВАТНЫЕ ПОЛЯ ===
  AppThemeType _currentThemeType = AppThemeType.classic;
  Locale _currentLocale = const Locale('en');
  final StorageService _storageService = StorageService();

  // === ГЕТТЕРЫ ===

  /// Текущий тип темы
  AppThemeType get currentThemeType => _currentThemeType;

  /// Текущая тема
  ThemeData get currentTheme => AppThemes.getTheme(_currentThemeType);

  /// Текущая локаль
  Locale get currentLocale => _currentLocale;

  /// Список всех доступных тем
  List<ThemeData> get availableThemes =>
      AppThemes.availableThemes.map((type) => AppThemes.getTheme(type)).toList();

  /// Список типов тем
  List<AppThemeType> get availableThemeTypes => AppThemes.availableThemes;

  /// Текущее название темы
  String get currentThemeName => _getCurrentThemeExtension().name;

  /// Получить расширение текущей темы
  CustomThemeExtension _getCurrentThemeExtension() {
    return currentTheme.extension<CustomThemeExtension>()!;
  }

  // === ИНИЦИАЛИЗАЦИЯ ===

  /// Инициализация провайдера с загрузкой сохраненных настроек
  Future<void> initialize() async {
    await _loadSavedSettings();
  }

  /// Загрузка сохраненных настроек
  Future<void> _loadSavedSettings() async {
    try {
      // Загрузка темы
      final savedThemeIndex = await _storageService.getInt('theme_index');
      if (savedThemeIndex != null &&
          savedThemeIndex >= 0 &&
          savedThemeIndex < AppThemes.availableThemes.length) {
        _currentThemeType = AppThemes.availableThemes[savedThemeIndex];
      }

      // Загрузка языка
      final savedLanguage = await _storageService.getString('language_code');
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки настроек темы: $e');
    }
  }

  // === УПРАВЛЕНИЕ ТЕМАМИ ===

  /// Переключение на следующую тему
  Future<void> nextTheme() async {
    _currentThemeType = AppThemes.getNextTheme(_currentThemeType);
    await _saveThemeSettings();
    notifyListeners();
  }

  /// Переключение на предыдущую тему
  Future<void> previousTheme() async {
    _currentThemeType = AppThemes.getPreviousTheme(_currentThemeType);
    await _saveThemeSettings();
    notifyListeners();
  }

  /// Установка конкретной темы по типу
  Future<void> setTheme(AppThemeType themeType) async {
    if (_currentThemeType != themeType) {
      _currentThemeType = themeType;
      await _saveThemeSettings();
      notifyListeners();
    }
  }

  /// Установка темы по индексу
  Future<void> setThemeByIndex(int index) async {
    if (index >= 0 && index < AppThemes.availableThemes.length) {
      _currentThemeType = AppThemes.availableThemes[index];
      await _saveThemeSettings();
      notifyListeners();
    }
  }

  /// Сохранение настроек темы
  Future<void> _saveThemeSettings() async {
    try {
      final themeIndex = AppThemes.availableThemes.indexOf(_currentThemeType);
      await _storageService.setInt('theme_index', themeIndex);
    } catch (e) {
      debugPrint('Ошибка сохранения настроек темы: $e');
    }
  }

  // === УПРАВЛЕНИЕ ЯЗЫКОМ ===

  /// Переключение языка между английским и русским
  Future<void> toggleLanguage() async {
    _currentLocale = _currentLocale.languageCode == 'en'
        ? const Locale('ru')
        : const Locale('en');

    await _saveLanguageSettings();
    notifyListeners();
  }

  /// Установка конкретного языка
  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode != languageCode) {
      _currentLocale = Locale(languageCode);
      await _saveLanguageSettings();
      notifyListeners();
    }
  }

  /// Сохранение настроек языка
  Future<void> _saveLanguageSettings() async {
    try {
      await _storageService.setString('language_code', _currentLocale.languageCode);
    } catch (e) {
      debugPrint('Ошибка сохранения настроек языка: $e');
    }
  }

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  /// Проверка, является ли текущая тема темной
  bool get isDarkTheme => _currentThemeType == AppThemeType.dark;

  /// Получить индекс текущей темы
  int get currentThemeIndex => AppThemes.availableThemes.indexOf(_currentThemeType);

  /// Получить все названия тем
  List<String> get themeNames => AppThemes.availableThemes
      .map((type) => AppThemes.getTheme(type).extension<CustomThemeExtension>()!.name)
      .toList();

  /// Сброс настроек к значениям по умолчанию
  Future<void> resetToDefaults() async {
    _currentThemeType = AppThemeType.classic;
    _currentLocale = const Locale('en');

    await _saveThemeSettings();
    await _saveLanguageSettings();
    notifyListeners();
  }

  /// Получить информацию о текущих настройках
  Map<String, dynamic> getCurrentSettings() {
    return {
      'themeType': _currentThemeType.toString(),
      'themeName': currentThemeName,
      'themeIndex': currentThemeIndex,
      'locale': _currentLocale.toString(),
      'languageCode': _currentLocale.languageCode,
      'isDarkTheme': isDarkTheme,
    };
  }

  // === ОТЛАДКА ===

  /// Логирование текущего состояния (для отладки)
  void debugPrintState() {
    debugPrint('=== ThemeProvider State ===');
    debugPrint('Current Theme: ${_currentThemeType.toString()}');
    debugPrint('Theme Name: $currentThemeName');
    debugPrint('Current Locale: ${_currentLocale.toString()}');
    debugPrint('Is Dark Theme: $isDarkTheme');
    debugPrint('Available Themes: ${AppThemes.availableThemes.length}');
    debugPrint('===========================');
  }
}
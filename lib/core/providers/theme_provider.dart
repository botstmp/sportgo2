// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../../shared/themes/app_themes.dart';
import '../services/storage_service.dart';


/// Провайдер для управления темами и локализацией приложения
class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = AppThemes.classicTheme;
  Locale _currentLocale = const Locale('en', '');
  ThemeMode _themeMode = ThemeMode.system;

  // Getters
  ThemeData get currentTheme => _currentTheme;
  Locale get currentLocale => _currentLocale;
  ThemeMode get themeMode => _themeMode;
  List<ThemeData> get availableThemes => AppThemes.availableThemes;

  /// Получение текущего имени темы
  String get currentThemeName {
    final extension = _currentTheme.extension<CustomThemeExtension>();
    return extension?.name ?? 'Unknown';
  }

  /// Получение текущего ID темы
  String get currentThemeId {
    final extension = _currentTheme.extension<CustomThemeExtension>();
    return extension?.id ?? 'classic';
  }

  /// Инициализация провайдера
  ThemeProvider() {
    _loadSettings();
  }

  /// Загрузка сохраненных настроек
  Future<void> _loadSettings() async {
    try {
      // Загружаем тему
      final themeIndex = await StorageService.getThemeIndex();
      if (themeIndex >= 0 && themeIndex < availableThemes.length) {
        _currentTheme = availableThemes[themeIndex];
      }

      // Загружаем язык
      final localeCode = await StorageService.getLocaleCode();
      _currentLocale = Locale(localeCode, '');

      // Загружаем режим темы
      final themeModeString = await StorageService.getSetting<String>('theme_mode', 'system');
      _themeMode = _parseThemeMode(themeModeString ?? 'system');

      developer.log('Theme settings loaded: theme=$currentThemeName, locale=${_currentLocale.languageCode}, mode=$_themeMode');
      notifyListeners();
    } catch (e) {
      developer.log('Failed to load theme settings: $e', level: 900);
    }
  }

  /// Установка новой темы
  Future<void> setTheme(ThemeData theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;

    try {
      final themeIndex = AppThemes.getThemeIndex(theme);
      await StorageService.saveThemeIndex(themeIndex);

      developer.log('Theme changed to: $currentThemeName');
      notifyListeners();
    } catch (e) {
      developer.log('Failed to save theme: $e', level: 900);
    }
  }

  /// Установка темы по ID
  Future<void> setThemeById(String themeId) async {
    final theme = AppThemes.getThemeById(themeId);
    if (theme != null) {
      await setTheme(theme);
    }
  }

  /// Переключение на следующую тему
  Future<void> nextTheme() async {
    final currentIndex = availableThemes.indexOf(_currentTheme);
    final nextIndex = (currentIndex + 1) % availableThemes.length;
    await setTheme(availableThemes[nextIndex]);
  }

  /// Переключение на предыдущую тему
  Future<void> previousTheme() async {
    final currentIndex = availableThemes.indexOf(_currentTheme);
    final previousIndex = currentIndex == 0
        ? availableThemes.length - 1
        : currentIndex - 1;
    await setTheme(availableThemes[previousIndex]);
  }

  /// Установка новой локали
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;

    try {
      await StorageService.saveLocaleCode(locale.languageCode);

      developer.log('Locale changed to: ${locale.languageCode}');
      notifyListeners();
    } catch (e) {
      developer.log('Failed to save locale: $e', level: 900);
    }
  }

  /// Переключение языка
  Future<void> toggleLanguage() async {
    final newLocale = _currentLocale.languageCode == 'en'
        ? const Locale('ru', '')
        : const Locale('en', '');
    await setLocale(newLocale);
  }

  /// Установка режима темы (светлая/темная/система)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;

    try {
      await StorageService.setSetting('theme_mode', mode.name);

      developer.log('Theme mode changed to: $mode');
      notifyListeners();
    } catch (e) {
      developer.log('Failed to save theme mode: $e', level: 900);
    }
  }

  /// Переключение режима темы
  Future<void> toggleThemeMode() async {
    final nextMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(nextMode);
  }

  /// Проверка, является ли текущая тема темной
  bool get isDarkTheme {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark || _currentTheme.brightness == Brightness.dark;
  }

  /// Получение адаптивной темы с учетом системных настроек
  ThemeData getAdaptiveTheme(Brightness systemBrightness) {
    if (_themeMode == ThemeMode.system) {
      // Если системный режим, выбираем тему в зависимости от системной яркости
      if (systemBrightness == Brightness.dark) {
        return AppThemes.darkTheme;
      } else {
        return _currentTheme.brightness == Brightness.dark
            ? AppThemes.classicTheme
            : _currentTheme;
      }
    }

    if (_themeMode == ThemeMode.dark && _currentTheme.brightness != Brightness.dark) {
      return AppThemes.darkTheme;
    }

    if (_themeMode == ThemeMode.light && _currentTheme.brightness == Brightness.dark) {
      return AppThemes.classicTheme;
    }

    return _currentTheme;
  }

  /// Получение списка доступных локалей
  List<LocaleInfo> get supportedLocales => [
    const LocaleInfo(
      locale: Locale('en', ''),
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    const LocaleInfo(
      locale: Locale('ru', ''),
      name: 'Russian',
      nativeName: 'Русский',
      flag: '🇷🇺',
    ),
  ];

  /// Получение информации о текущей локали
  LocaleInfo get currentLocaleInfo {
    return supportedLocales.firstWhere(
          (info) => info.locale.languageCode == _currentLocale.languageCode,
      orElse: () => supportedLocales.first,
    );
  }

  /// Получение списка доступных тем с информацией
  List<ThemeInfo> get availableThemeInfos {
    return availableThemes.map((theme) {
      final extension = theme.extension<CustomThemeExtension>()!;
      return ThemeInfo(
        id: extension.id,
        name: extension.name,
        theme: theme,
        isDark: theme.brightness == Brightness.dark,
        primaryColor: extension.buttonPrimaryColor,
        accentColor: extension.buttonSecondaryColor,
      );
    }).toList();
  }

  /// Сброс настроек к значениям по умолчанию
  Future<void> resetToDefaults() async {
    try {
      _currentTheme = AppThemes.classicTheme;
      _currentLocale = const Locale('en', '');
      _themeMode = ThemeMode.system;

      await StorageService.saveThemeIndex(0);
      await StorageService.saveLocaleCode('en');
      await StorageService.setSetting('theme_mode', 'system');

      developer.log('Theme settings reset to defaults');
      notifyListeners();
    } catch (e) {
      developer.log('Failed to reset theme settings: $e', level: 900);
    }
  }

  /// Экспорт настроек
  Map<String, dynamic> exportSettings() {
    return {
      'themeId': currentThemeId,
      'localeCode': _currentLocale.languageCode,
      'themeMode': _themeMode.name,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Импорт настроек
  Future<bool> importSettings(Map<String, dynamic> settings) async {
    try {
      final themeId = settings['themeId'] as String?;
      final localeCode = settings['localeCode'] as String?;
      final themeModeString = settings['themeMode'] as String?;

      if (themeId != null) {
        await setThemeById(themeId);
      }

      if (localeCode != null) {
        await setLocale(Locale(localeCode, ''));
      }

      if (themeModeString != null) {
        await setThemeMode(_parseThemeMode(themeModeString));
      }

      developer.log('Theme settings imported successfully');
      return true;
    } catch (e) {
      developer.log('Failed to import theme settings: $e', level: 900);
      return false;
    }
  }

  /// Парсинг режима темы из строки
  ThemeMode _parseThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

/// Информация о локали
class LocaleInfo {
  final Locale locale;
  final String name;
  final String nativeName;
  final String flag;

  const LocaleInfo({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  @override
  String toString() => '$flag $nativeName';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LocaleInfo &&
              runtimeType == other.runtimeType &&
              locale == other.locale;

  @override
  int get hashCode => locale.hashCode;
}

/// Информация о теме
class ThemeInfo {
  final String id;
  final String name;
  final ThemeData theme;
  final bool isDark;
  final Color primaryColor;
  final Color accentColor;

  const ThemeInfo({
    required this.id,
    required this.name,
    required this.theme,
    required this.isDark,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  String toString() => '$name${isDark ? ' (Dark)' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ThemeInfo &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
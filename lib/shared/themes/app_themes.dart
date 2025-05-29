// lib/shared/themes/app_themes.dart
import 'package:flutter/material.dart';

/// Централизованная система тем приложения
class AppThemes {
  AppThemes._(); // Приватный конструктор

  // === КОНСТАНТЫ ШРИФТОВ ===
  static const String headingFontFamily = 'Poppins';
  static const String bodyFontFamily = 'OpenSans';
  static const String timerFontFamily = 'BebasNeue';

  // === БАЗОВЫЕ СТИЛИ ТЕКСТА ===
  static const TextStyle baseDisplayTimer = TextStyle(
    fontFamily: timerFontFamily,
    fontSize: 64,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.0,
  );

  static const TextTheme baseTextTheme = TextTheme(
    // Основные заголовки
    headlineLarge: TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    headlineMedium: TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),

    // Заголовки разделов
    titleLarge: TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),

    // Основной текст
    bodyLarge: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 18,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),

    // Мелкий текст
    labelLarge: TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white, // Фиксированный цвет для кнопок
    ),
    labelMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );

  // === ДОСТУПНЫЕ ТЕМЫ ===
  static final List<ThemeData> availableThemes = [
    classicTheme,
    darkTheme,
    forestTheme,
    oceanTheme,
    desertTheme,
    mochaMousseTheme,
  ];

  // === CLASSIC THEME (Светлая классическая) ===
  static final ThemeData classicTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: [
      CustomThemeExtension(
        id: 'classic',
        name: 'Classic',
        headerImagePath: 'assets/images/header_classic.png',
        scaffoldBackgroundColor: const Color(0xFFE1E4ED),
        cardColor: const Color(0xFFF7F7F9),
        buttonPrimaryColor: const Color(0xFFF45756),
        buttonSecondaryColor: const Color(0xFF395775),
        buttonPressedColor: const Color(0xFF2C4A66),
        restButtonColor: const Color(0xFFB6C9DB),
        restBackgroundColor: const Color(0xFFE4ECF6),
        restProgressColor: const Color(0xFFB6C9DB),
        evenMinuteColor: const Color(0xFFE4ECF6),
        oddMinuteColor: const Color(0xFFB6C9DB),
        evenMinuteProgressColor: const Color(0xFFB6C9DB),
        oddMinuteProgressColor: const Color(0xFFE4ECF6),
        scrollbarColor: const Color(0xFF395775),
        displayTimer: baseDisplayTimer.copyWith(color: const Color(0xFF395775)),
        successColor: const Color(0xFF4CAF50),
        warningColor: const Color(0xFFFF9800),
        errorColor: const Color(0xFFF44336),
      ),
    ],
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF395775),
      secondary: Color(0xFFF45756),
      surface: Color(0xFFF7F7F9),
      error: Color(0xFFF44336),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF395775),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFE1E4ED),
    textTheme: _buildTextTheme(baseTextTheme, const Color(0xFF395775)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF7F7F9),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Color(0xFF395775),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFF7F7F9),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF45756),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFE4ECF6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),
  );

  // === DARK THEME (Темная тема) ===
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    extensions: [
      CustomThemeExtension(
        id: 'dark',
        name: 'Dark',
        headerImagePath: 'assets/images/header_dark.png',
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        buttonPrimaryColor: const Color(0xFFD32F2F),
        buttonSecondaryColor: const Color(0xFF546E7A),
        buttonPressedColor: const Color(0xFF37474F),
        restButtonColor: const Color(0xFF455A64),
        restBackgroundColor: const Color(0xFF263238),
        restProgressColor: const Color(0xFF455A64),
        evenMinuteColor: const Color(0xFF263238),
        oddMinuteColor: const Color(0xFF455A64),
        evenMinuteProgressColor: const Color(0xFF455A64),
        oddMinuteProgressColor: const Color(0xFF263238),
        scrollbarColor: const Color(0xFF546E7A),
        displayTimer: baseDisplayTimer.copyWith(color: Colors.white),
        successColor: const Color(0xFF4CAF50),
        warningColor: const Color(0xFFFF9800),
        errorColor: const Color(0xFFF44336),
      ),
    ],
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF546E7A),
      secondary: Color(0xFFD32F2F),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFF44336),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: _buildTextTheme(baseTextTheme, Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF1E1E1E),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),
  );

  // === FOREST THEME (Лесная тема) ===
  static final ThemeData forestTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: [
      CustomThemeExtension(
        id: 'forest',
        name: 'Forest',
        headerImagePath: 'assets/images/header_forest.png',
        scaffoldBackgroundColor: const Color(0xFFE8F5E9),
        cardColor: const Color(0xFFC8E6C9),
        buttonPrimaryColor: const Color(0xFF388E3C),
        buttonSecondaryColor: const Color(0xFF2E7D32),
        buttonPressedColor: const Color(0xFF1B5E20),
        restButtonColor: const Color(0xFFA5D6A7),
        restBackgroundColor: const Color(0xFFDCE775),
        restProgressColor: const Color(0xFFA5D6A7),
        evenMinuteColor: const Color(0xFFDCE775),
        oddMinuteColor: const Color(0xFFA5D6A7),
        evenMinuteProgressColor: const Color(0xFFA5D6A7),
        oddMinuteProgressColor: const Color(0xFFDCE775),
        scrollbarColor: const Color(0xFF4CAF50),
        displayTimer: baseDisplayTimer.copyWith(color: const Color(0xFF2E7D32)),
        successColor: const Color(0xFF4CAF50),
        warningColor: const Color(0xFFFF9800),
        errorColor: const Color(0xFFF44336),
      ),
    ],
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2E7D32),
      secondary: Color(0xFF388E3C),
      surface: Color(0xFFC8E6C9),
      error: Color(0xFFF44336),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF2E7D32),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFE8F5E9),
    textTheme: _buildTextTheme(baseTextTheme, const Color(0xFF2E7D32)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFC8E6C9),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Color(0xFF2E7D32),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFC8E6C9),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF3FAC7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),
  );

  // === OCEAN THEME (Океанская тема) ===
  static final ThemeData oceanTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: [
      CustomThemeExtension(
        id: 'ocean',
        name: 'Ocean',
        headerImagePath: 'assets/images/header_ocean.png',
        scaffoldBackgroundColor: const Color(0xFFE0F7FA),
        cardColor: const Color(0xFFB3E5FC),
        buttonPrimaryColor: const Color(0xFF0288D1),
        buttonSecondaryColor: const Color(0xFF0277BD),
        buttonPressedColor: const Color(0xFF01579B),
        restButtonColor: const Color(0xFF81D4FA),
        restBackgroundColor: const Color(0xFF81D4FA),
        restProgressColor: const Color(0xFFB3E5FC),
        evenMinuteColor: const Color(0xFF81D4FA),
        oddMinuteColor: const Color(0xFFB3E5FC),
        evenMinuteProgressColor: const Color(0xFFB3E5FC),
        oddMinuteProgressColor: const Color(0xFF81D4FA),
        scrollbarColor: const Color(0xFF0277BD),
        displayTimer: baseDisplayTimer.copyWith(color: const Color(0xFF01579B)),
        successColor: const Color(0xFF4CAF50),
        warningColor: const Color(0xFFFF9800),
        errorColor: const Color(0xFFF44336),
      ),
    ],
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0277BD),
      secondary: Color(0xFF0288D1),
      surface: Color(0xFFB3E5FC),
      error: Color(0xFFF44336),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF01579B),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFE0F7FA),
    textTheme: _buildTextTheme(baseTextTheme, const Color(0xFF01579B)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFB3E5FC),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Color(0xFF01579B),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFB3E5FC),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0288D1),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF81D4FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),
  );

  // === DESERT THEME (Пустынная тема) ===
  static final ThemeData desertTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: [
      CustomThemeExtension(
        id: 'desert',
        name: 'Desert',
        headerImagePath: 'assets/images/header_desert.png',
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),
        cardColor: const Color(0xFFFFE8CC),
        buttonPrimaryColor: const Color(0xFF8D5524),
        buttonSecondaryColor: const Color(0xFFA1887F),
        buttonPressedColor: const Color(0xFF5D4037),
        restButtonColor: const Color(0xFFD7CCC8),
        restBackgroundColor: const Color(0xFFFFF1E6),
        restProgressColor: const Color(0xFFD7CCC8),
        evenMinuteColor: const Color(0xFFFFF1E6),
        oddMinuteColor: const Color(0xFFD7CCC8),
        evenMinuteProgressColor: const Color(0xFFD7CCC8),
        oddMinuteProgressColor: const Color(0xFFFFF1E6),
        scrollbarColor: const Color(0xFFA1887F),
        displayTimer: baseDisplayTimer.copyWith(color: const Color(0xFF5D4037)),
        successColor: const Color(0xFF4CAF50),
        warningColor: const Color(0xFFFF9800),
        errorColor: const Color(0xFFF44336),
      ),
    ],
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFA1887F),
      secondary: Color(0xFF8D5524),
      surface: Color(0xFFFFE8CC),
      error: Color(0xFFF44336),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF5D4037),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF3E0),
    textTheme: _buildTextTheme(baseTextTheme, const Color(0xFF5D4037)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFE8CC),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Color(0xFF5D4037),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFFFE8CC),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8D5524),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFFF1E6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),
  );

  // === MOCHA MOUSSE THEME (Тема цвета года 2024) ===
  static final ThemeData mochaMousseTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: [
      CustomThemeExtension(
        id: 'mocha_mousse',
        name: 'Mocha Mousse',
        headerImagePath: 'assets/images/header_mocha_mousse.png',
        scaffoldBackgroundColor: const Color(0xFFF5E8D9),
        cardColor: const Color(0xFFEADBC8),
        buttonPrimaryColor: const Color(0xFFA67B5B),
        buttonSecondaryColor: const Color(0xFF8D5524),
        buttonPressedColor: const Color(0xFF6B3C1A),
        restButtonColor: const Color(0xFFD7C0A1),
        restBackgroundColor: const Color(0xFFEADBC8),
        restProgressColor: const Color(0xFFD7C0A1),
        evenMinuteColor: const Color(0xFFEADBC8),
        oddMinuteColor: const Color(0xFFD7C0A1),
        evenMinuteProgressColor: const Color(0xFFD7C0A1),
        oddMinuteProgressColor: const Color(0xFFEADBC8),
        scrollbarColor: const Color(0xFF8D5524),
        displayTimer: baseDisplayTimer.copyWith(color: const Color(0xFF6B3C1A)),
        successColor: const Color(0xFF4CAF50),
        warningColor: const Color(0xFFFF9800),
        errorColor: const Color(0xFFF44336),
      ),
    ],
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8D5524),
      secondary: Color(0xFFA67B5B),
      surface: Color(0xFFEADBC8),
      error: Color(0xFFF44336),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF6B3C1A),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5E8D9),
    textTheme: _buildTextTheme(baseTextTheme, const Color(0xFF6B3C1A)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFEADBC8),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Color(0xFF6B3C1A),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFEADBC8),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA67B5B),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFD7C0A1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),
  );

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  /// Создание TextTheme с определенным цветом текста
  static TextTheme _buildTextTheme(TextTheme baseTheme, Color textColor) {
    return baseTheme.copyWith(
      headlineLarge: baseTheme.headlineLarge?.copyWith(color: textColor),
      headlineMedium: baseTheme.headlineMedium?.copyWith(color: textColor),
      headlineSmall: baseTheme.headlineSmall?.copyWith(color: textColor),
      titleLarge: baseTheme.titleLarge?.copyWith(color: textColor),
      titleMedium: baseTheme.titleMedium?.copyWith(color: textColor),
      titleSmall: baseTheme.titleSmall?.copyWith(color: textColor),
      bodyLarge: baseTheme.bodyLarge?.copyWith(color: textColor),
      bodyMedium: baseTheme.bodyMedium?.copyWith(color: textColor),
      bodySmall: baseTheme.bodySmall?.copyWith(color: textColor),
      labelMedium: baseTheme.labelMedium?.copyWith(color: textColor),
      labelSmall: baseTheme.labelSmall?.copyWith(color: textColor),
      // labelLarge остается белым для кнопок
    );
  }

  /// Получение темы по ID
  static ThemeData? getThemeById(String id) {
    try {
      return availableThemes.firstWhere((theme) {
        final extension = theme.extension<CustomThemeExtension>();
        return extension?.id == id;
      });
    } catch (e) {
      return null;
    }
  }

  /// Получение индекса темы
  static int getThemeIndex(ThemeData theme) {
    return availableThemes.indexOf(theme);
  }
}

/// Кастомное расширение темы для специфичных цветов приложения
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final String id;
  final String name;
  final String headerImagePath;

  // Основные цвета
  final Color scaffoldBackgroundColor;
  final Color cardColor;

  // Цвета кнопок
  final Color buttonPrimaryColor;
  final Color buttonSecondaryColor;
  final Color buttonPressedColor;

  // Цвета отдыха
  final Color restButtonColor;
  final Color restBackgroundColor;
  final Color restProgressColor;

  // Цвета минут (четные/нечетные)
  final Color evenMinuteColor;
  final Color oddMinuteColor;
  final Color evenMinuteProgressColor;
  final Color oddMinuteProgressColor;

  // Другие цвета
  final Color scrollbarColor;

  // Стили текста
  final TextStyle displayTimer;

  // Семантические цвета
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  const CustomThemeExtension({
    required this.id,
    required this.name,
    required this.headerImagePath,
    required this.scaffoldBackgroundColor,
    required this.cardColor,
    required this.buttonPrimaryColor,
    required this.buttonSecondaryColor,
    required this.buttonPressedColor,
    required this.restButtonColor,
    required this.restBackgroundColor,
    required this.restProgressColor,
    required this.evenMinuteColor,
    required this.oddMinuteColor,
    required this.evenMinuteProgressColor,
    required this.oddMinuteProgressColor,
    required this.scrollbarColor,
    required this.displayTimer,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
  });

  @override
  CustomThemeExtension copyWith({
    String? id,
    String? name,
    String? headerImagePath,
    Color? scaffoldBackgroundColor,
    Color? cardColor,
    Color? buttonPrimaryColor,
    Color? buttonSecondaryColor,
    Color? buttonPressedColor,
    Color? restButtonColor,
    Color? restBackgroundColor,
    Color? restProgressColor,
    Color? evenMinuteColor,
    Color? oddMinuteColor,
    Color? evenMinuteProgressColor,
    Color? oddMinuteProgressColor,
    Color? scrollbarColor,
    TextStyle? displayTimer,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
  }) {
    return CustomThemeExtension(
      id: id ?? this.id,
      name: name ?? this.name,
      headerImagePath: headerImagePath ?? this.headerImagePath,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      cardColor: cardColor ?? this.cardColor,
      buttonPrimaryColor: buttonPrimaryColor ?? this.buttonPrimaryColor,
      buttonSecondaryColor: buttonSecondaryColor ?? this.buttonSecondaryColor,
      buttonPressedColor: buttonPressedColor ?? this.buttonPressedColor,
      restButtonColor: restButtonColor ?? this.restButtonColor,
      restBackgroundColor: restBackgroundColor ?? this.restBackgroundColor,
      restProgressColor: restProgressColor ?? this.restProgressColor,
      evenMinuteColor: evenMinuteColor ?? this.evenMinuteColor,
      oddMinuteColor: oddMinuteColor ?? this.oddMinuteColor,
      evenMinuteProgressColor: evenMinuteProgressColor ?? this.evenMinuteProgressColor,
      oddMinuteProgressColor: oddMinuteProgressColor ?? this.oddMinuteProgressColor,
      scrollbarColor: scrollbarColor ?? this.scrollbarColor,
      displayTimer: displayTimer ?? this.displayTimer,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  CustomThemeExtension lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) return this;
    return CustomThemeExtension(
      id: t < 0.5 ? id : other.id,
      name: t < 0.5 ? name : other.name,
      headerImagePath: t < 0.5 ? headerImagePath : other.headerImagePath,
      scaffoldBackgroundColor: Color.lerp(scaffoldBackgroundColor, other.scaffoldBackgroundColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      buttonPrimaryColor: Color.lerp(buttonPrimaryColor, other.buttonPrimaryColor, t)!,
      buttonSecondaryColor: Color.lerp(buttonSecondaryColor, other.buttonSecondaryColor, t)!,
      buttonPressedColor: Color.lerp(buttonPressedColor, other.buttonPressedColor, t)!,
      restButtonColor: Color.lerp(restButtonColor, other.restButtonColor, t)!,
      restBackgroundColor: Color.lerp(restBackgroundColor, other.restBackgroundColor, t)!,
      restProgressColor: Color.lerp(restProgressColor, other.restProgressColor, t)!,
      evenMinuteColor: Color.lerp(evenMinuteColor, other.evenMinuteColor, t)!,
      oddMinuteColor: Color.lerp(oddMinuteColor, other.oddMinuteColor, t)!,
      evenMinuteProgressColor: Color.lerp(evenMinuteProgressColor, other.evenMinuteProgressColor, t)!,
      oddMinuteProgressColor: Color.lerp(oddMinuteProgressColor, other.oddMinuteProgressColor, t)!,
      scrollbarColor: Color.lerp(scrollbarColor, other.scrollbarColor, t)!,
      displayTimer: TextStyle.lerp(displayTimer, other.displayTimer, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
    );
  }
}
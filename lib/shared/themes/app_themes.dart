// lib/shared/themes/app_themes.dart
import 'package:flutter/material.dart';

/// Система тем SportOn с поддержкой 6 цветовых схем
class AppThemes {
  AppThemes._(); // Приватный конструктор

  // === КОНСТАНТЫ ШРИФТОВ ===
  // Используем системные шрифты до загрузки кастомных
  static const String headingFontFamily = 'Roboto'; // Системный шрифт Android
  static const String bodyFontFamily = 'Roboto';    // Системный шрифт
  static const String timerFontFamily = 'RobotoMono'; // Моноширинный для таймера

  // === СПИСОК ДОСТУПНЫХ ТЕМ ===
  static const List<AppThemeType> availableThemes = [
    AppThemeType.classic,
    AppThemeType.dark,
    AppThemeType.forest,
    AppThemeType.ocean,
    AppThemeType.desert,
    AppThemeType.mochaMousse,
  ];

  // === МЕТОДЫ ПОЛУЧЕНИЯ ТЕМ ===

  /// Получить тему по типу
  static ThemeData getTheme(AppThemeType themeType) {
    final customTheme = _getCustomThemeExtension(themeType);
    final brightness = themeType == AppThemeType.dark ? Brightness.dark : Brightness.light;

    return ThemeData(
      brightness: brightness,
      fontFamily: bodyFontFamily,

      // === ЦВЕТОВАЯ СХЕМА ===
      colorScheme: ColorScheme.fromSeed(
        seedColor: customTheme.buttonPrimaryColor,
        brightness: brightness,
      ).copyWith(
        surface: customTheme.cardColor,
        primary: customTheme.buttonPrimaryColor,
        secondary: customTheme.buttonSecondaryColor,
        error: customTheme.errorColor,
      ),

      // === ОСНОВНЫЕ ЦВЕТА ===
      scaffoldBackgroundColor: customTheme.scaffoldBackgroundColor,
      cardColor: customTheme.cardColor,
      dividerColor: customTheme.dividerColor,

      // === APP BAR ТЕМА ===
      appBarTheme: AppBarTheme(
        backgroundColor: customTheme.scaffoldBackgroundColor,
        foregroundColor: customTheme.textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: headingFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: customTheme.textPrimaryColor,
        ),
        iconTheme: IconThemeData(
          color: customTheme.textPrimaryColor,
        ),
      ),

      // === КАРТОЧКИ ===
      cardTheme: CardTheme(
        color: customTheme.cardColor,
        elevation: 4,
        shadowColor: customTheme.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // === КНОПКИ ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customTheme.buttonPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: customTheme.buttonPrimaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // === ТЕКСТОВЫЕ СТИЛИ ===
      textTheme: TextTheme(
        // Большие заголовки
        headlineLarge: TextStyle(
          fontFamily: headingFontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: customTheme.textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: headingFontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: customTheme.textPrimaryColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: headingFontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: customTheme.textPrimaryColor,
        ),

        // Заголовки
        titleLarge: TextStyle(
          fontFamily: headingFontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: customTheme.textPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontFamily: headingFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: customTheme.textPrimaryColor,
        ),
        titleSmall: TextStyle(
          fontFamily: headingFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: customTheme.textPrimaryColor,
        ),

        // Основной текст
        bodyLarge: TextStyle(
          fontFamily: bodyFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: customTheme.textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: bodyFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: customTheme.textSecondaryColor,
        ),
        bodySmall: TextStyle(
          fontFamily: bodyFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: customTheme.textSecondaryColor,
        ),

        // Лейблы
        labelLarge: TextStyle(
          fontFamily: bodyFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: customTheme.textPrimaryColor,
        ),
        labelMedium: TextStyle(
          fontFamily: bodyFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: customTheme.textSecondaryColor,
        ),
        labelSmall: TextStyle(
          fontFamily: bodyFontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: customTheme.textSecondaryColor,
        ),
      ),

      // === ИКОНКИ ===
      iconTheme: IconThemeData(
        color: customTheme.textPrimaryColor,
        size: 24,
      ),

      // === DIVIDER ===
      dividerTheme: DividerThemeData(
        color: customTheme.dividerColor,
        thickness: 1,
      ),

      // === РАСШИРЕНИЯ ===
      extensions: [customTheme],
    );
  }

  /// Получить кастомное расширение темы
  static CustomThemeExtension _getCustomThemeExtension(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return CustomThemeExtension(
          name: 'Классическая',
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          cardColor: Colors.white,
          dividerColor: const Color(0xFFE2E8F0),
          shadowColor: Colors.black.withOpacity(0.1),
          textPrimaryColor: const Color(0xFF1E293B),
          textSecondaryColor: const Color(0xFF64748B),
          textDisabledColor: const Color(0xFFCBD5E1),
          buttonPrimaryColor: const Color(0xFF3B82F6),
          buttonSecondaryColor: const Color(0xFF6B7280),
          buttonDisabledColor: const Color(0xFFD1D5DB),
          successColor: const Color(0xFF10B981),
          warningColor: const Color(0xFFF59E0B),
          errorColor: const Color(0xFFEF4444),
        );

      case AppThemeType.dark:
        return CustomThemeExtension(
          name: 'Темная',
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          cardColor: const Color(0xFF1E293B),
          dividerColor: const Color(0xFF334155),
          shadowColor: Colors.black.withOpacity(0.3),
          textPrimaryColor: const Color(0xFFF1F5F9),
          textSecondaryColor: const Color(0xFF94A3B8),
          textDisabledColor: const Color(0xFF475569),
          buttonPrimaryColor: const Color(0xFF3B82F6),
          buttonSecondaryColor: const Color(0xFF64748B),
          buttonDisabledColor: const Color(0xFF374151),
          successColor: const Color(0xFF10B981),
          warningColor: const Color(0xFFF59E0B),
          errorColor: const Color(0xFFEF4444),
        );

      case AppThemeType.forest:
        return CustomThemeExtension(
          name: 'Лес',
          scaffoldBackgroundColor: const Color(0xFFF0F4F0),
          cardColor: const Color(0xFFFFFFFF),
          dividerColor: const Color(0xFFD4E6D4),
          shadowColor: const Color(0xFF059669).withOpacity(0.2),
          textPrimaryColor: const Color(0xFF064E3B),
          textSecondaryColor: const Color(0xFF047857),
          textDisabledColor: const Color(0xFFA7C3A7),
          buttonPrimaryColor: const Color(0xFF059669),
          buttonSecondaryColor: const Color(0xFF10B981),
          buttonDisabledColor: const Color(0xFFBBE5D1),
          successColor: const Color(0xFF22C55E),
          warningColor: const Color(0xFFF59E0B),
          errorColor: const Color(0xFFEF4444),
        );

      case AppThemeType.ocean:
        return CustomThemeExtension(
          name: 'Океан',
          scaffoldBackgroundColor: const Color(0xFFF0F9FF),
          cardColor: const Color(0xFFFFFFFF),
          dividerColor: const Color(0xFFBAE6FD),
          shadowColor: const Color(0xFF0EA5E9).withOpacity(0.2),
          textPrimaryColor: const Color(0xFF0C4A6E),
          textSecondaryColor: const Color(0xFF0284C7),
          textDisabledColor: const Color(0xFF7DD3FC),
          buttonPrimaryColor: const Color(0xFF0EA5E9),
          buttonSecondaryColor: const Color(0xFF38BDF8),
          buttonDisabledColor: const Color(0xFFBFDBFE),
          successColor: const Color(0xFF10B981),
          warningColor: const Color(0xFFF59E0B),
          errorColor: const Color(0xFFEF4444),
        );

      case AppThemeType.desert:
        return CustomThemeExtension(
          name: 'Пустыня',
          scaffoldBackgroundColor: const Color(0xFFFEF3E2),
          cardColor: const Color(0xFFFFFFFF),
          dividerColor: const Color(0xFFFED7AA),
          shadowColor: const Color(0xFFEA580C).withOpacity(0.2),
          textPrimaryColor: const Color(0xFF9A3412),
          textSecondaryColor: const Color(0xFFEA580C),
          textDisabledColor: const Color(0xFFFEDBB6),
          buttonPrimaryColor: const Color(0xFFEA580C),
          buttonSecondaryColor: const Color(0xFFF97316),
          buttonDisabledColor: const Color(0xFFFED7AA),
          successColor: const Color(0xFF10B981),
          warningColor: const Color(0xFFF59E0B),
          errorColor: const Color(0xFFEF4444),
        );

      case AppThemeType.mochaMousse:
        return CustomThemeExtension(
          name: 'Мокко Мусс',
          scaffoldBackgroundColor: const Color(0xFFF7F3F0),
          cardColor: const Color(0xFFFFFFFF),
          dividerColor: const Color(0xFFE7D7CC),
          shadowColor: const Color(0xFF8B4513).withOpacity(0.2),
          textPrimaryColor: const Color(0xFF5D4037),
          textSecondaryColor: const Color(0xFF8D6E63),
          textDisabledColor: const Color(0xFFD7CCC8),
          buttonPrimaryColor: const Color(0xFF8B4513),
          buttonSecondaryColor: const Color(0xFFA0522D),
          buttonDisabledColor: const Color(0xFFE6C2B3),
          successColor: const Color(0xFF10B981),
          warningColor: const Color(0xFFF59E0B),
          errorColor: const Color(0xFFEF4444),
        );
    }
  }

  /// Получить следующую тему по порядку
  static AppThemeType getNextTheme(AppThemeType currentTheme) {
    final currentIndex = availableThemes.indexOf(currentTheme);
    final nextIndex = (currentIndex + 1) % availableThemes.length;
    return availableThemes[nextIndex];
  }

  /// Получить предыдущую тему
  static AppThemeType getPreviousTheme(AppThemeType currentTheme) {
    final currentIndex = availableThemes.indexOf(currentTheme);
    final previousIndex = (currentIndex - 1 + availableThemes.length) % availableThemes.length;
    return availableThemes[previousIndex];
  }
}

// === ТИПЫ ТЕМ ===
enum AppThemeType {
  classic,
  dark,
  forest,
  ocean,
  desert,
  mochaMousse,
}

// === РАСШИРЕНИЕ ТЕМЫ ===
/// Кастомное расширение темы для дополнительных цветов SportOn
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  // === МЕТА-ИНФОРМАЦИЯ ===
  final String name;

  // === ОСНОВНЫЕ ЦВЕТА ===
  final Color scaffoldBackgroundColor;
  final Color cardColor;
  final Color dividerColor;
  final Color shadowColor;

  // === ЦВЕТА ТЕКСТА ===
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color textDisabledColor;

  // === ЦВЕТА КНОПОК ===
  final Color buttonPrimaryColor;
  final Color buttonSecondaryColor;
  final Color buttonDisabledColor;

  // === ЦВЕТА СОСТОЯНИЙ ===
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  const CustomThemeExtension({
    required this.name,
    required this.scaffoldBackgroundColor,
    required this.cardColor,
    required this.dividerColor,
    required this.shadowColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.textDisabledColor,
    required this.buttonPrimaryColor,
    required this.buttonSecondaryColor,
    required this.buttonDisabledColor,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
  });

  @override
  CustomThemeExtension copyWith({
    String? name,
    Color? scaffoldBackgroundColor,
    Color? cardColor,
    Color? dividerColor,
    Color? shadowColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
    Color? textDisabledColor,
    Color? buttonPrimaryColor,
    Color? buttonSecondaryColor,
    Color? buttonDisabledColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
  }) {
    return CustomThemeExtension(
      name: name ?? this.name,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      cardColor: cardColor ?? this.cardColor,
      dividerColor: dividerColor ?? this.dividerColor,
      shadowColor: shadowColor ?? this.shadowColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      textDisabledColor: textDisabledColor ?? this.textDisabledColor,
      buttonPrimaryColor: buttonPrimaryColor ?? this.buttonPrimaryColor,
      buttonSecondaryColor: buttonSecondaryColor ?? this.buttonSecondaryColor,
      buttonDisabledColor: buttonDisabledColor ?? this.buttonDisabledColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  CustomThemeExtension lerp(
      covariant CustomThemeExtension? other,
      double t,
      ) {
    if (other is! CustomThemeExtension) return this;

    return CustomThemeExtension(
      name: other.name,
      scaffoldBackgroundColor: Color.lerp(scaffoldBackgroundColor, other.scaffoldBackgroundColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      textPrimaryColor: Color.lerp(textPrimaryColor, other.textPrimaryColor, t)!,
      textSecondaryColor: Color.lerp(textSecondaryColor, other.textSecondaryColor, t)!,
      textDisabledColor: Color.lerp(textDisabledColor, other.textDisabledColor, t)!,
      buttonPrimaryColor: Color.lerp(buttonPrimaryColor, other.buttonPrimaryColor, t)!,
      buttonSecondaryColor: Color.lerp(buttonSecondaryColor, other.buttonSecondaryColor, t)!,
      buttonDisabledColor: Color.lerp(buttonDisabledColor, other.buttonDisabledColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
    );
  }
}
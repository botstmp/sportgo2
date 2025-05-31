// lib/core/constants/ui_config.dart
import 'package:flutter/material.dart';

/// Конфигурация пользовательского интерфейса SportOn
/// Содержит константы для адаптивной верстки и размеров элементов
class UIConfig {
  UIConfig._(); // Приватный конструктор для предотвращения создания экземпляров

  // === РАЗМЕРЫ КОНТЕЙНЕРОВ ===
  static const double containerOuterPaddingFactor = 0.04;
  static const double containerInnerPaddingFactor = 0.04;
  static const double containerBorderRadiusFactor = 0.04;

  // === РАЗМЕРЫ КНОПОК ===
  static const double primaryButtonHeightFactor = 0.065;
  static const double buttonBorderRadiusFactor = 0.025;
  static const double buttonHorizontalPaddingFactor = 0.06;
  static const double buttonIconTextSpacingFactor = 0.02;

  // === РАЗМЕРЫ ШРИФТОВ ===
  static const double titleFontSizeFactor = 0.032;
  static const double subtitleFontSizeFactor = 0.022;
  static const double bodyFontSizeFactor = 0.018;
  static const double buttonTextSizeFactor = 0.02;

  // === РАЗМЕРЫ ЭЛЕМЕНТОВ ИНТЕРФЕЙСА ===
  static const double toolbarHeightFactor = 0.08;
  static const double iconSizeFactor = 0.06;
  static const double smallIconSizeFactor = 0.04;

  // === ОТСТУПЫ И ИНТЕРВАЛЫ ===
  static const double verticalSpacingFactor = 0.02;
  static const double horizontalSpacingFactor = 0.04;

  // === АНИМАЦИИ ===
  static const int fastAnimationDuration = 200;
  static const int normalAnimationDuration = 300;
  static const int slowAnimationDuration = 500;

  // === РАЗМЕРЫ КАРТОЧЕК ===
  static const double cardHeightFactor = 0.16;
  static const double cardElevation = 4.0;

  // === РАЗМЕРЫ ТАЙМЕРА ===
  static const double timerCardHeightFactor = 0.25;
  static const double timerProgressStrokeWidth = 8.0;

  /// Размер кругового таймера относительно ширины экрана
  /// Пример: при ширине 393px = ~314px
  static const double circularTimerSizeFactor = 0.8;

  /// Размер шрифта времени в круговом таймере
  /// Пример: при высоте 873px = ~44px
  static const double timerDisplayFontSizeFactor = 0.05;

  /// Размер подсказки под временем в таймере
  /// Пример: при высоте 873px = ~13px
  static const double timerHintFontSizeFactor = 0.015;

  // === РАЗМЕРЫ МОДАЛЬНЫХ ОКОН ===
  static const double modalBottomSheetHeightFactor = 0.6;
  static const double dialogWidthFactor = 0.85;

  // === ЦВЕТА (константы для темной/светлой темы) ===
  /// Прозрачность для оверлеев и теней
  static const double shadowOpacity = 0.2;
  static const double overlayOpacity = 0.1;

  // === КОНСТАНТЫ ТРЕНИРОВКИ ===
  /// Длительность подготовительного отсчета в секундах
  static const int preparationDuration = 7;

  /// Звуковое предупреждение за N секунд до начала
  static const int audioWarningBeforeStart = 5;

  /// Максимальное количество записей в истории
  static const int maxHistoryRecords = 100;

  // === RESPONSIVE BREAKPOINTS ===
  /// Минимальная ширина для планшетного лэйаута
  static const double tabletBreakpoint = 600;

  /// Минимальная ширина для десктопного лэйаута
  static const double desktopBreakpoint = 1200;

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  /// Проверка, является ли устройство планшетом
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Проверка, является ли устройство десктопом
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Получение адаптивного размера шрифта
  static double getAdaptiveFontSize(
      BuildContext context,
      double baseFactor, {
        double maxSize = double.infinity,
        double minSize = 10.0,
      }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenHeight * baseFactor;
    return fontSize.clamp(minSize, maxSize);
  }

  /// Получение адаптивного размера
  static double getAdaptiveSize(
      BuildContext context,
      double widthFactor,
      double heightFactor,
      ) {
    final size = MediaQuery.of(context).size;
    return size.width * widthFactor + size.height * heightFactor;
  }
}
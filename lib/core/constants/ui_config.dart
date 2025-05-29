// lib/core/constants/ui_config.dart
import 'package:flutter/material.dart';

/// Централизованная конфигурация UI компонентов
/// Все размеры рассчитываются относительно размера экрана для адаптивности
class UIConfig {
  UIConfig._(); // Приватный конструктор для статического класса

  // === TOOLBAR (Шапка приложения) ===
  /// Высота тулбара относительно высоты экрана
  /// Пример: при высоте 873px = ~130px
  static const double toolbarHeightFactor = 0.15;

  /// Высота логотипа в тулбаре относительно высоты экрана
  /// Пример: при высоте 873px = ~110px
  static const double toolbarImageHeightFactor = 0.125;

  // === КОНТЕЙНЕРЫ И ОТСТУПЫ ===
  /// Внешний отступ основного контейнера от краев экрана
  /// Пример: при ширине 393px = ~16px
  static const double containerOuterPaddingFactor = 0.04;

  /// Внутренний отступ внутри контейнеров
  /// Пример: при ширине 393px = ~16px
  static const double containerInnerPaddingFactor = 0.04;

  /// Радиус закругления углов контейнеров
  /// Пример: при ширине 393px = ~16px
  static const double containerBorderRadiusFactor = 0.04;

  // === ТИПОГРАФИКА ===
  /// Отступ сверху от заголовков
  /// Пример: при высоте 873px = ~20px
  static const double titleTopSpacingFactor = 0.01;

  /// Размер основного заголовка
  /// Пример: при высоте 873px = ~26px
  static const double titleFontSizeFactor = 0.03;

  /// Размер описания и обычного текста
  /// Пример: при высоте 873px = ~16px
  static const double descriptionFontSizeFactor = 0.018;

  /// Отступ между элементами списка
  /// Пример: при высоте 873px = ~22px
  static const double listDescriptionSpacingFactor = 0.025;

  // === КНОПКИ ===
  /// Высота основных кнопок (START, STOP и т.д.)
  /// Пример: при высоте 873px = ~100px
  static const double primaryButtonHeightFactor = 0.115;

  /// Размер иконок в кнопках
  /// Пример: при высоте 873px = ~29px
  static const double buttonIconSizeFactor = 0.033;

  /// Отступ между иконкой и текстом в кнопке
  /// Пример: при ширине 393px = ~10px
  static const double buttonIconTextSpacingFactor = 0.025;

  /// Размер текста в кнопках
  /// Пример: при высоте 873px = ~24px
  static const double buttonTextSizeFactor = 0.028;

  // === ВТОРИЧНЫЕ КНОПКИ ===
  /// Размер квадратных кнопок (пауза, история и т.д.)
  /// Пример: при высоте 873px = ~35px
  static const double secondaryButtonSizeFactor = 0.04;

  /// Размер иконок во вторичных кнопках
  /// Пример: при высоте 873px = ~29px
  static const double secondaryButtonIconSizeFactor = 0.033;

  /// Радиус закругления вторичных кнопок (фиксированный)
  static const double secondaryButtonBorderRadius = 9.0;

  /// Отступ между вторичными кнопками
  /// Пример: при ширине 393px = ~12px
  static const double buttonSpacingFactor = 0.03;

  // === ВЫПАДАЮЩИЕ СПИСКИ ===
  /// Высота элементов в выпадающих списках
  /// Пример: при высоте 873px = ~70px
  static const double dropdownItemHeightFactor = 0.08;

  /// Отступ сверху от выпадающего списка
  /// Пример: при высоте 873px = ~30px
  static const double dropdownTopSpacingFactor = 0.035;

  /// Размер заголовка в выпадающем списке
  /// Пример: при высоте 873px = ~18px
  static const double dropdownTitleFontSizeFactor = 0.021;

  /// Размер подзаголовка в выпадающем списке
  /// Пример: при высоте 873px = ~12px
  static const double dropdownSubtitleFontSizeFactor = 0.014;

  // === АНИМАЦИИ ===
  /// Стандартная длительность анимаций кнопок
  static const Duration buttonAnimationDuration = Duration(milliseconds: 200);

  /// Стандартная длительность переходов между экранами
  static const Duration screenTransitionDuration = Duration(milliseconds: 300);

  /// Длительность анимации подготовки к тренировке
  static const Duration preparationAnimationDuration = Duration(milliseconds: 300);

  // === СПЕЦИФИЧНЫЕ РАЗМЕРЫ ===
  /// Толщина прогресс-бара в круговом таймере относительно ширины экрана
  /// Пример: при ширине 393px = ~287px (весь фон круга)
  static const double circularTimerStrokeWidthFactor = 0.73;

  /// Размер кругового таймера относительно ширины экрана
  /// Пример: при ширине 393px = ~314px
  static const double circularTimerSizeFactor = 0.8;

  /// Размер шрифта времени в круговом таймере
  /// Пример: при высоте 873px = ~44px
  static const double timerDisplayFontSizeFactor = 0.05;

  /// Размер подсказки под временем в таймере
  /// Пример: при высоте 873px = ~13px
  static const double timerHintFontSizeFactor = 0.015;

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
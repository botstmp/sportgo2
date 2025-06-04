// lib/shared/themes/timer_colors.dart
import 'package:flutter/material.dart';
import '../../../core/providers/timer_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../../core/providers/settings_provider.dart';
import '../../../core/enums/timer_enums.dart';
import '../../../shared/themes/app_themes.dart';

/// Цветовая схема для различных состояний таймера
class TimerColors {
  // Подготовка - оранжевый градиент
  static const Color preparationPrimary = Color(0xFFFF8A50);
  static const Color preparationSecondary = Color(0xFFFF6B35);

  // Работа - синий градиент
  static const Color workPrimary = Color(0xFF4A90E2);
  static const Color workSecondary = Color(0xFF357ABD);

  // Отдых - зеленый градиент
  static const Color restPrimary = Color(0xFF7ED321);
  static const Color restSecondary = Color(0xFF5CB85C);

  // Пауза - серый градиент
  static const Color pausePrimary = Color(0xFF9B9B9B);
  static const Color pauseSecondary = Color(0xFF757575);

  // Завершено - золотой градиент
  static const Color finishedPrimary = Color(0xFFFFD700);
  static const Color finishedSecondary = Color(0xFFFFB347);

  /// Получить градиент для состояния таймера
  static LinearGradient getGradientForState(TimerState state) {
    switch (state) {
      case TimerState.preparation:
        return const LinearGradient(
          colors: [preparationPrimary, preparationSecondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case TimerState.working:
        return const LinearGradient(
          colors: [workPrimary, workSecondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case TimerState.resting:
        return const LinearGradient(
          colors: [restPrimary, restSecondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case TimerState.paused:
        return const LinearGradient(
          colors: [pausePrimary, pauseSecondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case TimerState.finished:
        return const LinearGradient(
          colors: [finishedPrimary, finishedSecondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return const LinearGradient(
          colors: [Colors.grey, Colors.grey],
        );
    }
  }

  /// Получить основной цвет для состояния
  static Color getPrimaryColorForState(TimerState state) {
    switch (state) {
      case TimerState.preparation:
        return preparationPrimary;
      case TimerState.working:
        return workPrimary;
      case TimerState.resting:
        return restPrimary;
      case TimerState.paused:
        return pausePrimary;
      case TimerState.finished:
        return finishedPrimary;
      default:
        return Colors.grey;
    }
  }
}
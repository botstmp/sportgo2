// lib/core/models/workout_enums_extensions.dart
import 'package:flutter/material.dart';
import 'workout_enums.dart';

/// Дополнительные расширения для enum'ов тренировок (UI-методы)
/// Примечание: displayName уже определен в workout_enums.dart
extension WorkoutStatusUIExtension on WorkoutStatus {
  /// Иконка для статуса тренировки
  IconData get icon {
    switch (this) {
      case WorkoutStatus.completed:
        return Icons.check_circle;
      case WorkoutStatus.stopped:
        return Icons.stop_circle;
      case WorkoutStatus.interrupted:
        return Icons.warning_amber;
    }
  }

  /// Цвет для статуса тренировки
  Color get color {
    switch (this) {
      case WorkoutStatus.completed:
        return const Color(0xFF10B981); // Зеленый
      case WorkoutStatus.stopped:
        return const Color(0xFFEF4444); // Красный
      case WorkoutStatus.interrupted:
        return const Color(0xFFF59E0B); // Оранжевый
    }
  }
}

/// Дополнительные расширения для RecordType (UI-методы)
/// Примечание: displayName и emoji уже определены в workout_enums.dart
extension RecordTypeUIExtension on RecordType {
  /// Иконка для типа рекорда
  IconData get icon {
    switch (this) {
      case RecordType.fastestTime:
        return Icons.speed;
      case RecordType.mostRounds: // ИСПРАВЛЕНО: было mostLaps
        return Icons.repeat;
      case RecordType.longestSession:
        return Icons.timer;
      case RecordType.bestConsistency:
        return Icons.trending_up;
      case RecordType.perfectRounds:
        return Icons.diamond;
      case RecordType.personalBest: // ДОБАВЛЕНО: отсутствующий case
        return Icons.emoji_events;
    }
  }

  /// Цвет для типа рекорда
  Color get color {
    switch (this) {
      case RecordType.fastestTime:
        return const Color(0xFFFFD700); // Золотой
      case RecordType.mostRounds: // ИСПРАВЛЕНО: было mostLaps
        return const Color(0xFFC0C0C0); // Серебряный
      case RecordType.longestSession:
        return const Color(0xFF9C27B0); // Фиолетовый
      case RecordType.bestConsistency:
        return const Color(0xFFCD7F32); // Бронзовый
      case RecordType.perfectRounds:
        return const Color(0xFF00BCD4); // Циан
      case RecordType.personalBest: // ДОБАВЛЕНО: отсутствующий case
        return const Color(0xFFFFD700); // Золотой
    }
  }
}

/// Дополнительные расширения для WorkoutLinkType (UI-методы)
extension WorkoutLinkTypeUIExtension on WorkoutLinkType {
  /// Иконка для типа привязки
  IconData get icon {
    switch (this) {
      case WorkoutLinkType.none:
        return Icons.remove_circle_outline;
      case WorkoutLinkType.byCode:
        return Icons.qr_code;
      case WorkoutLinkType.byTitle:
        return Icons.title;
      case WorkoutLinkType.byBoth:
        return Icons.link;
    }
  }

  /// Отображаемое название типа привязки
  String get displayName {
    switch (this) {
      case WorkoutLinkType.none:
        return 'Без привязки';
      case WorkoutLinkType.byCode:
        return 'По коду';
      case WorkoutLinkType.byTitle:
        return 'По названию';
      case WorkoutLinkType.byBoth:
        return 'Код + название';
    }
  }

  /// Цвет для типа привязки
  Color get color {
    switch (this) {
      case WorkoutLinkType.none:
        return const Color(0xFF9CA3AF); // Серый
      case WorkoutLinkType.byCode:
        return const Color(0xFF3B82F6); // Синий
      case WorkoutLinkType.byTitle:
        return const Color(0xFF10B981); // Зеленый
      case WorkoutLinkType.byBoth:
        return const Color(0xFF8B5CF6); // Пурпурный
    }
  }
}
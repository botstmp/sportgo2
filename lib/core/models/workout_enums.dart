// lib/core/models/workout_enums.dart
import 'package:flutter/material.dart';

/// Типы записей/рекордов в тренировках
enum RecordType {
  personalBest('personal_best', 'Личный рекорд'),
  fastestTime('fastest_time', 'Лучшее время'),
  mostRounds('most_rounds', 'Больше всего раундов'),
  longestSession('longest_session', 'Самая длинная сессия'),
  bestConsistency('best_consistency', 'Лучшая стабильность'),
  perfectRounds('perfect_rounds', 'Идеальные раунды');

  const RecordType(this.id, this.displayName);
  final String id;
  final String displayName;

  /// Получение типа рекорда по ID
  static RecordType fromId(String id) {
    return RecordType.values.firstWhere(
          (type) => type.id == id,
      orElse: () => RecordType.personalBest,
    );
  }
}

/// Статус завершения тренировки
enum WorkoutStatus {
  completed('completed', 'Завершена'),
  stopped('stopped', 'Остановлена'),
  interrupted('interrupted', 'Прервана');

  const WorkoutStatus(this.id, this.displayName);
  final String id;
  final String displayName;

  /// Получение статуса по ID
  static WorkoutStatus fromId(String id) {
    return WorkoutStatus.values.firstWhere(
          (status) => status.id == id,
      orElse: () => WorkoutStatus.completed,
    );
  }
}

/// Тип привязки к тренировке
enum WorkoutLinkType {
  none('none', 'Без привязки'),
  byCode('by_code', 'По коду'),
  byTitle('by_title', 'По названию'),
  byBoth('by_both', 'И код и название');

  const WorkoutLinkType(this.id, this.displayName);
  final String id;
  final String displayName;

  /// Получение типа привязки по ID
  static WorkoutLinkType fromId(String id) {
    return WorkoutLinkType.values.firstWhere(
          (type) => type.id == id,
      orElse: () => WorkoutLinkType.none,
    );
  }
}

// Добавляем расширения для удобства
extension RecordTypeExtension on RecordType {
  String get emoji {
    switch (this) {
      case RecordType.personalBest:
        return '🏆';
      case RecordType.fastestTime:
        return '⚡';
      case RecordType.mostRounds:
        return '🔄';
      case RecordType.longestSession:
        return '⏰';
      case RecordType.bestConsistency:
        return '🎯';
      case RecordType.perfectRounds:
        return '💎';
    }
  }
}

extension WorkoutStatusExtension on WorkoutStatus {
  bool get isSuccessful => this == WorkoutStatus.completed;

  IconData get icon {
    switch (this) {
      case WorkoutStatus.completed:
        return Icons.check_circle;
      case WorkoutStatus.stopped:
        return Icons.stop_circle;
      case WorkoutStatus.interrupted:
        return Icons.block;
    }
  }

  Color get color {
    switch (this) {
      case WorkoutStatus.completed:
        return Colors.green;
      case WorkoutStatus.stopped:
        return Colors.orange;
      case WorkoutStatus.interrupted:
        return Colors.red;
    }
  }
}
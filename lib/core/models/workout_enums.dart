// lib/core/models/workout_enums.dart

/// Типы записей/рекордов в тренировках
enum RecordType {
  fastestTime,      // Самое быстрое время выполнения
  mostLaps,         // Больше всего отсечек/кругов
  longestSession,   // Самая длинная сессия
  bestConsistency,  // Лучшая стабильность между раундами
  perfectRounds,    // Идеальные раунды (одинаковое время)
}

/// Статус завершения тренировки
enum WorkoutStatus {
  completed,        // Завершена успешно
  stopped,          // Остановлена пользователем
  interrupted,      // Прервана (например, звонок)
}

/// Тип привязки к тренировке
enum WorkoutLinkType {
  none,            // Без привязки
  byCode,          // По коду (например TB-001)
  byTitle,         // По названию
  byBoth,          // И код и название
}

/// Расширения для удобства работы с енумами
extension RecordTypeExtension on RecordType {
  String get displayName {
    switch (this) {
      case RecordType.fastestTime:
        return 'Лучшее время';
      case RecordType.mostLaps:
        return 'Больше всего кругов';
      case RecordType.longestSession:
        return 'Самая длинная сессия';
      case RecordType.bestConsistency:
        return 'Лучшая стабильность';
      case RecordType.perfectRounds:
        return 'Идеальные раунды';
    }
  }

  String get emoji {
    switch (this) {
      case RecordType.fastestTime:
        return '⚡';
      case RecordType.mostLaps:
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
  String get displayName {
    switch (this) {
      case WorkoutStatus.completed:
        return 'Завершена';
      case WorkoutStatus.stopped:
        return 'Остановлена';
      case WorkoutStatus.interrupted:
        return 'Прервана';
    }
  }

  bool get isSuccessful => this == WorkoutStatus.completed;
}
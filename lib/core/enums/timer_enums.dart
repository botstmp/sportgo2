// lib/core/enums/timer_enums.dart

/// Типы таймеров в приложении SportOn
enum TimerType {
  classic,    // Классический секундомер
  interval1,  // Интервальный таймер 1 (45 сек работа, 15 сек отдых)
  interval2,  // Интервальный таймер 2 (30 сек работа, 30 сек отдых)
  intensive,  // Интенсивный (20 сек работа, 10 сек отдых)
  norest,     // Без отдыха (длительная работа без перерывов)
  countdown,  // Обратный отсчет
}

/// Состояния таймера
enum TimerState {
  stopped,      // Остановлен
  preparation,  // Подготовка
  working,      // Рабочий период
  resting,      // Период отдыха
  paused,       // На паузе
  finished,     // Завершен
}

/// Класс для хранения данных об отсечке времени
class LapTime {
  final int lapNumber;
  final int time; // Время с начала тренировки в секундах
  final String formattedTime;
  final DateTime timestamp;
  final int lapDuration; // Продолжительность конкретного раунда

  LapTime({
    required this.lapNumber,
    required this.time,
    required this.formattedTime,
    required this.timestamp,
    required this.lapDuration,
  });

  // Форматированная продолжительность раунда
  String get formattedLapDuration {
    final minutes = lapDuration ~/ 60;
    final seconds = lapDuration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// ДОБАВЛЕНО: Метод для совместимости с существующим кодом
  String getFormattedDeltaTime() {
    return formattedLapDuration;
  }

  /// ДОБАВЛЕНО: Дополнительные методы для удобства
  String get formattedTotalTime {
    final minutes = time ~/ 60;
    final seconds = time % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Получить отформатированное время раунда (альтернативное название)
  String get formattedRoundTime => formattedLapDuration;

  Map<String, dynamic> toMap() {
    return {
      'lapNumber': lapNumber,
      'time': time,
      'formattedTime': formattedTime,
      'timestamp': timestamp.toIso8601String(),
      'lapDuration': lapDuration,
    };
  }

  factory LapTime.fromMap(Map<String, dynamic> map) {
    return LapTime(
      lapNumber: map['lapNumber'],
      time: map['time'],
      formattedTime: map['formattedTime'],
      timestamp: DateTime.parse(map['timestamp']),
      lapDuration: map['lapDuration'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'LapTime(lapNumber: $lapNumber, time: $time, lapDuration: $lapDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LapTime &&
        other.lapNumber == lapNumber &&
        other.time == time &&
        other.lapDuration == lapDuration;
  }

  @override
  int get hashCode {
    return lapNumber.hashCode ^ time.hashCode ^ lapDuration.hashCode;
  }
}
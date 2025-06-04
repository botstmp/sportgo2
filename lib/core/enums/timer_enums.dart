// lib/core/enums/timer_enums.dart

/// Состояния таймера
enum TimerState {
  stopped,     // Остановлен
  preparation, // Подготовка (обратный отсчет)
  working,     // Рабочий период
  resting,     // Период отдыха
  paused,      // Пауза
  finished,    // Завершен
}

/// Типы таймеров
enum TimerType {
  classic,     // Классический таймер
  interval1,   // Интервальный 1
  interval2,   // Интервальный 2
  intensive,   // Интенсивный
  norest,      // Без отдыха
  countdown,   // Обратный отсчет
}

/// Класс для хранения отсечек времени
class LapTime {
  final int lapNumber;        // Номер отсечки
  final int time;            // Время в секундах
  final String formattedTime; // Отформатированное время
  final DateTime timestamp;   // Временная метка

  const LapTime({
    required this.lapNumber,
    required this.time,
    required this.formattedTime,
    required this.timestamp,
  });

  /// Время с предыдущей отсечки
  int getDeltaTime(LapTime? previousLap) {
    if (previousLap == null) return time;
    return time - previousLap.time;
  }

  /// Отформатированное время дельты
  String getFormattedDeltaTime(LapTime? previousLap) {
    final delta = getDeltaTime(previousLap);
    final minutes = delta ~/ 60;
    final seconds = delta % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Преобразование в Map для сохранения
  Map<String, dynamic> toMap() {
    return {
      'lapNumber': lapNumber,
      'time': time,
      'formattedTime': formattedTime,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Создание из Map
  factory LapTime.fromMap(Map<String, dynamic> map) {
    return LapTime(
      lapNumber: map['lapNumber'],
      time: map['time'],
      formattedTime: map['formattedTime'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
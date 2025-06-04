// lib/core/models/classic_timer_stats.dart
import 'dart:math';

/// Статистика для классического таймера (секундомер с отсечками)
class ClassicTimerStats {
  final List<Duration> lapTimes;           // Абсолютные времена отсечек
  final List<Duration> roundTimes;         // Время каждого раунда (интервалы)
  final int totalLaps;                     // Общее количество отсечек
  final Duration averageRoundTime;         // Среднее время раунда
  final Duration fastestRound;             // Самый быстрый раунд
  final Duration slowestRound;             // Самый медленный раунд
  final double consistencyPercent;         // Процент стабильности раундов
  final Duration totalActiveTime;          // Общее активное время (без пауз)

  const ClassicTimerStats({
    required this.lapTimes,
    required this.roundTimes,
    required this.totalLaps,
    required this.averageRoundTime,
    required this.fastestRound,
    required this.slowestRound,
    required this.consistencyPercent,
    required this.totalActiveTime,
  });

  /// Создание статистики из списка отсечек
  factory ClassicTimerStats.fromLapTimes(List<Duration> lapTimes) {
    if (lapTimes.isEmpty) {
      return ClassicTimerStats.empty();
    }

    // Вычисляем время каждого раунда (интервалы между отсечками)
    final roundTimes = <Duration>[];
    Duration previousLap = Duration.zero;

    for (final lapTime in lapTimes) {
      final roundTime = lapTime - previousLap;
      roundTimes.add(roundTime);
      previousLap = lapTime;
    }

    // Статистические вычисления
    final totalLaps = lapTimes.length;
    final totalActiveTime = lapTimes.last;

    final averageRoundTime = Duration(
      milliseconds: roundTimes
          .map((r) => r.inMilliseconds)
          .reduce((a, b) => a + b) ~/ roundTimes.length,
    );

    final fastestRound = roundTimes.reduce((a, b) => a < b ? a : b);
    final slowestRound = roundTimes.reduce((a, b) => a > b ? a : b);

    // Вычисляем стабильность (чем меньше разброс, тем выше процент)
    final consistency = _calculateConsistency(roundTimes);

    return ClassicTimerStats(
      lapTimes: List.unmodifiable(lapTimes),
      roundTimes: List.unmodifiable(roundTimes),
      totalLaps: totalLaps,
      averageRoundTime: averageRoundTime,
      fastestRound: fastestRound,
      slowestRound: slowestRound,
      consistencyPercent: consistency,
      totalActiveTime: totalActiveTime,
    );
  }

  /// Пустая статистика (когда нет отсечек)
  factory ClassicTimerStats.empty() {
    return const ClassicTimerStats(
      lapTimes: [],
      roundTimes: [],
      totalLaps: 0,
      averageRoundTime: Duration.zero,
      fastestRound: Duration.zero,
      slowestRound: Duration.zero,
      consistencyPercent: 0.0,
      totalActiveTime: Duration.zero,
    );
  }

  /// Вычисление процента стабильности раундов
  static double _calculateConsistency(List<Duration> roundTimes) {
    if (roundTimes.length < 2) return 100.0;

    final times = roundTimes.map((r) => r.inMilliseconds).toList();
    final average = times.reduce((a, b) => a + b) / times.length;

    // Вычисляем стандартное отклонение
    final variance = times
        .map((time) => pow(time - average, 2))
        .reduce((a, b) => a + b) / times.length;
    final standardDeviation = sqrt(variance);

    // Коэффициент вариации (чем меньше, тем стабильнее)
    final coefficientOfVariation = standardDeviation / average;

    // Преобразуем в процент стабильности (100% = идеально стабильно)
    final consistencyPercent = max(0.0, 100.0 - (coefficientOfVariation * 100));

    return double.parse(consistencyPercent.toStringAsFixed(1));
  }

  /// Получить время конкретного раунда
  Duration getRoundTime(int roundIndex) {
    if (roundIndex < 0 || roundIndex >= roundTimes.length) {
      return Duration.zero;
    }
    return roundTimes[roundIndex];
  }

  /// Проверка на новый рекорд по количеству отсечек
  bool isLapCountRecord(int previousBest) {
    return totalLaps > previousBest;
  }

  /// Проверка на рекорд стабильности
  bool isConsistencyRecord(double previousBest) {
    return consistencyPercent > previousBest;
  }

  /// Форматированное отображение среднего времени раунда
  String get formattedAverageRound {
    return _formatDuration(averageRoundTime);
  }

  /// Форматированное отображение самого быстрого раунда
  String get formattedFastestRound {
    return _formatDuration(fastestRound);
  }

  /// Форматированное отображение общего времени
  String get formattedTotalTime {
    return _formatDuration(totalActiveTime);
  }

  /// Вспомогательный метод форматирования времени
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = duration.inMilliseconds.remainder(1000);

    if (minutes > 0) {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    } else {
      return '${seconds}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() {
    return 'ClassicTimerStats(laps: $totalLaps, avgRound: $formattedAverageRound, consistency: ${consistencyPercent.toStringAsFixed(1)}%)';
  }
}
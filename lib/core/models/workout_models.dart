// lib/core/models/workout_models.dart
import 'package:flutter/material.dart';

/// Типы таймеров в приложении
enum TimerType {
  classic('classic', 'Classic Stopwatch'),
  intervalWithRest('interval_rest', 'Interval with Rest'),
  fixedRounds('fixed_rounds', 'Fixed Round Timer'),
  intensive('intensive', 'Intensive Timer'),
  noRest('no_rest', 'Rounds without Rest'),
  countdown('countdown', 'Countdown Timer');

  const TimerType(this.id, this.displayName);
  final String id;
  final String displayName;

  /// Получение типа по ID
  static TimerType fromId(String id) {
    return TimerType.values.firstWhere(
          (type) => type.id == id,
      orElse: () => TimerType.classic,
    );
  }
}

/// Состояния таймера
enum TimerState {
  idle('idle', 'Готов к запуску'),
  preparing('preparing', 'Подготовка'),
  running('running', 'Выполнение'),
  paused('paused', 'Пауза'),
  resting('resting', 'Отдых'),
  finished('finished', 'Завершен');

  const TimerState(this.id, this.displayName);
  final String id;
  final String displayName;
}

/// Базовая модель конфигурации тренировки
abstract class WorkoutConfig {
  final String id;
  final TimerType timerType;
  final String titleKey;
  final String subtitleKey;
  final String descriptionKey;
  final IconData icon;
  final Color? accentColor;
  final bool isEnabled;

  const WorkoutConfig({
    required this.id,
    required this.timerType,
    required this.titleKey,
    required this.subtitleKey,
    required this.descriptionKey,
    this.icon = Icons.timer,
    this.accentColor,
    this.isEnabled = true,
  });

  /// Валидация конфигурации
  bool validate();

  /// Получение общей продолжительности тренировки
  Duration get estimatedDuration;

  /// Преобразование в JSON
  Map<String, dynamic> toJson();

  /// Создание из JSON
  static WorkoutConfig fromJson(Map<String, dynamic> json) {
    final timerType = TimerType.fromId(json['timerType'] ?? 'classic');

    switch (timerType) {
      case TimerType.classic:
        return ClassicWorkoutConfig.fromJson(json);
      case TimerType.intervalWithRest:
        return IntervalWorkoutConfig.fromJson(json);
      case TimerType.fixedRounds:
        return FixedRoundsWorkoutConfig.fromJson(json);
      case TimerType.intensive:
        return IntensiveWorkoutConfig.fromJson(json);
      case TimerType.noRest:
        return NoRestWorkoutConfig.fromJson(json);
      case TimerType.countdown:
        return CountdownWorkoutConfig.fromJson(json);
    }
  }
}

/// Конфигурация классического таймера (секундомер)
class ClassicWorkoutConfig extends WorkoutConfig {
  const ClassicWorkoutConfig({
    super.id = 'classic',
    super.timerType = TimerType.classic,
    super.titleKey = 'classicTitle',
    super.subtitleKey = 'classicSubtitle',
    super.descriptionKey = 'classicDescription',
    super.icon = Icons.timer_outlined,
    super.accentColor = Colors.green,
  });

  @override
  bool validate() => true; // Всегда валиден

  @override
  Duration get estimatedDuration => const Duration(hours: 1); // Неограниченно

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'timerType': timerType.id,
  };

  factory ClassicWorkoutConfig.fromJson(Map<String, dynamic> json) {
    return const ClassicWorkoutConfig();
  }
}

/// Конфигурация интервального таймера с отдыхом
class IntervalWorkoutConfig extends WorkoutConfig {
  final int rounds;
  final int restMinutes;
  final int restSeconds;

  const IntervalWorkoutConfig({
    super.id = 'interval_rest',
    super.timerType = TimerType.intervalWithRest,
    super.titleKey = 'interval1Title',
    super.subtitleKey = 'interval1Subtitle',
    super.descriptionKey = 'interval1Description',
    super.icon = Icons.loop,
    super.accentColor = Colors.blue,
    required this.rounds,
    required this.restMinutes,
    required this.restSeconds,
  });

  @override
  bool validate() => rounds > 0 && (restMinutes > 0 || restSeconds > 0);

  @override
  Duration get estimatedDuration {
    final restDuration = Duration(minutes: restMinutes, seconds: restSeconds);
    return Duration(
      seconds: rounds * restDuration.inSeconds,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'timerType': timerType.id,
    'rounds': rounds,
    'restMinutes': restMinutes,
    'restSeconds': restSeconds,
  };

  factory IntervalWorkoutConfig.fromJson(Map<String, dynamic> json) {
    return IntervalWorkoutConfig(
      rounds: json['rounds'] ?? 1,
      restMinutes: json['restMinutes'] ?? 0,
      restSeconds: json['restSeconds'] ?? 30,
    );
  }
}

/// Конфигурация таймера с фиксированными раундами
class FixedRoundsWorkoutConfig extends WorkoutConfig {
  final int rounds;
  final int roundMinutes;
  final int roundSeconds;
  final int restMinutes;
  final int restSeconds;

  const FixedRoundsWorkoutConfig({
    super.id = 'fixed_rounds',
    super.timerType = TimerType.fixedRounds,
    super.titleKey = 'interval2Title',
    super.subtitleKey = 'interval2Subtitle',
    super.descriptionKey = 'interval2Description',
    super.icon = Icons.access_time,
    super.accentColor = Colors.orange,
    required this.rounds,
    required this.roundMinutes,
    required this.roundSeconds,
    required this.restMinutes,
    required this.restSeconds,
  });

  @override
  bool validate() =>
      rounds > 0 &&
          (roundMinutes > 0 || roundSeconds > 0) &&
          (restMinutes > 0 || restSeconds > 0);

  @override
  Duration get estimatedDuration {
    final roundDuration = Duration(minutes: roundMinutes, seconds: roundSeconds);
    final restDuration = Duration(minutes: restMinutes, seconds: restSeconds);
    return Duration(
      seconds: rounds * (roundDuration.inSeconds + restDuration.inSeconds),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'timerType': timerType.id,
    'rounds': rounds,
    'roundMinutes': roundMinutes,
    'roundSeconds': roundSeconds,
    'restMinutes': restMinutes,
    'restSeconds': restSeconds,
  };

  factory FixedRoundsWorkoutConfig.fromJson(Map<String, dynamic> json) {
    return FixedRoundsWorkoutConfig(
      rounds: json['rounds'] ?? 1,
      roundMinutes: json['roundMinutes'] ?? 3,
      roundSeconds: json['roundSeconds'] ?? 0,
      restMinutes: json['restMinutes'] ?? 1,
      restSeconds: json['restSeconds'] ?? 0,
    );
  }
}

/// Конфигурация интенсивного таймера
class IntensiveWorkoutConfig extends WorkoutConfig {
  final int minutes;
  final int seconds;

  const IntensiveWorkoutConfig({
    super.id = 'intensive',
    super.timerType = TimerType.intensive,
    super.titleKey = 'intensiveTitle',
    super.subtitleKey = 'intensiveSubtitle',
    super.descriptionKey = 'intensiveDescription',
    super.icon = Icons.flash_on,
    super.accentColor = Colors.red,
    required this.minutes,
    required this.seconds,
  });

  @override
  bool validate() => minutes > 0 || seconds > 0;

  @override
  Duration get estimatedDuration => Duration(minutes: minutes, seconds: seconds);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'timerType': timerType.id,
    'minutes': minutes,
    'seconds': seconds,
  };

  factory IntensiveWorkoutConfig.fromJson(Map<String, dynamic> json) {
    return IntensiveWorkoutConfig(
      minutes: json['minutes'] ?? 5,
      seconds: json['seconds'] ?? 0,
    );
  }
}

/// Конфигурация таймера без отдыха
class NoRestWorkoutConfig extends WorkoutConfig {
  final int rounds;

  const NoRestWorkoutConfig({
    super.id = 'no_rest',
    super.timerType = TimerType.noRest,
    super.titleKey = 'noRestTitle',
    super.subtitleKey = 'noRestSubtitle',
    super.descriptionKey = 'noRestDescription',
    super.icon = Icons.directions_run,
    super.accentColor = Colors.purple,
    required this.rounds,
  });

  @override
  bool validate() => rounds > 0;

  @override
  Duration get estimatedDuration => const Duration(hours: 1); // Неопределенно

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'timerType': timerType.id,
    'rounds': rounds,
  };

  factory NoRestWorkoutConfig.fromJson(Map<String, dynamic> json) {
    return NoRestWorkoutConfig(
      rounds: json['rounds'] ?? 5,
    );
  }
}

/// Конфигурация обратного отсчета
class CountdownWorkoutConfig extends WorkoutConfig {
  final int hours;
  final int minutes;
  final int seconds;

  const CountdownWorkoutConfig({
    super.id = 'countdown',
    super.timerType = TimerType.countdown,
    super.titleKey = 'countdownTitle',
    super.subtitleKey = 'countdownSubtitle',
    super.descriptionKey = 'countdownDescription',
    super.icon = Icons.keyboard_arrow_down,
    super.accentColor = Colors.teal,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  bool validate() => hours > 0 || minutes > 0 || seconds > 0;

  @override
  Duration get estimatedDuration => Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'timerType': timerType.id,
    'hours': hours,
    'minutes': minutes,
    'seconds': seconds,
  };

  factory CountdownWorkoutConfig.fromJson(Map<String, dynamic> json) {
    return CountdownWorkoutConfig(
      hours: json['hours'] ?? 0,
      minutes: json['minutes'] ?? 10,
      seconds: json['seconds'] ?? 0,
    );
  }
}

/// Результат тренировки
class WorkoutResult {
  final String id;
  final DateTime date;
  final TimerType timerType;
  final WorkoutConfig config;
  final Duration totalDuration;
  final List<Duration> lapTimes;
  final Duration? avgLapTime;
  final bool isCompleted;
  final Map<String, dynamic>? metadata;

  const WorkoutResult({
    required this.id,
    required this.date,
    required this.timerType,
    required this.config,
    required this.totalDuration,
    this.lapTimes = const [],
    this.avgLapTime,
    this.isCompleted = true,
    this.metadata,
  });

  /// Преобразование в JSON для сохранения
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'timerType': timerType.id,
    'config': config.toJson(),
    'totalDuration': totalDuration.inSeconds,
    'lapTimes': lapTimes.map((lap) => lap.inSeconds).toList(),
    'avgLapTime': avgLapTime?.inSeconds,
    'isCompleted': isCompleted,
    'metadata': metadata,
  };

  /// Создание из JSON
  factory WorkoutResult.fromJson(Map<String, dynamic> json) {
    final timerType = TimerType.fromId(json['timerType'] ?? 'classic');
    final config = WorkoutConfig.fromJson(json['config'] ?? {});

    return WorkoutResult(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.parse(json['date']),
      timerType: timerType,
      config: config,
      totalDuration: Duration(seconds: json['totalDuration'] ?? 0),
      lapTimes: (json['lapTimes'] as List<dynamic>?)
          ?.map((seconds) => Duration(seconds: seconds))
          .toList() ?? [],
      avgLapTime: json['avgLapTime'] != null
          ? Duration(seconds: json['avgLapTime'])
          : null,
      isCompleted: json['isCompleted'] ?? true,
      metadata: json['metadata'],
    );
  }

  /// Форматирование времени для отображения
  String get formattedTotalTime => _formatDuration(totalDuration);
  String get formattedAvgLapTime => avgLapTime != null
      ? _formatDuration(avgLapTime!)
      : '--';

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() => 'WorkoutResult($timerType, $formattedTotalTime, ${lapTimes.length} laps)';
}
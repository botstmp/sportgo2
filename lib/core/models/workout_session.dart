// lib/core/models/workout_session.dart
import 'package:uuid/uuid.dart';
import '../enums/timer_enums.dart';
import 'workout_enums.dart';

/// Модель сессии тренировки SportOn
class WorkoutSession {
  final String? id;
  final String? workoutCode;
  final String? workoutTitle;
  final String? userNotes;
  final TimerType timerType;
  final WorkoutStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final Duration workTime;
  final Duration restTime;
  final int roundsCompleted;
  final Map<String, dynamic> configuration;
  final ClassicTimerStats? classicStats;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutSession({
    this.id,
    this.workoutCode,
    this.workoutTitle,
    this.userNotes,
    required this.timerType,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.workTime,
    required this.restTime,
    required this.roundsCompleted,
    required this.configuration,
    this.classicStats,
    this.version = 2,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Является ли тренировка привязанной к конкретной программе
  bool get isLinkedWorkout => workoutCode != null || workoutTitle != null;

  /// Ключ для группировки тренировок одного типа
  String get workoutKey {
    if (workoutCode != null) {
      return workoutCode!;
    } else if (workoutTitle != null) {
      return workoutTitle!;
    } else {
      return 'free_workout_${timerType.name}';
    }
  }

  /// Отображаемое название тренировки
  String get displayName {
    if (workoutCode != null && workoutTitle != null) {
      return '$workoutCode "$workoutTitle"';
    } else if (workoutCode != null) {
      return workoutCode!;
    } else if (workoutTitle != null) {
      return workoutTitle!;
    } else {
      // Для свободных тренировок
      return 'Свободная тренировка ${_formatShortDate(startTime)}';
    }
  }

  /// Общая продолжительность тренировки
  Duration get totalDuration => endTime.difference(startTime);

  /// Форматированная продолжительность
  String get formattedDuration {
    final duration = totalDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}ч ${minutes}м ${seconds}с';
    } else if (minutes > 0) {
      return '${minutes}м ${seconds}с';
    } else {
      return '${seconds}с';
    }
  }

  /// Эффективность тренировки (процент завершенных раундов)
  double get efficiency {
    final plannedRounds = configuration['rounds'] as int? ?? 1;
    if (plannedRounds == 0) return 0.0;
    return (roundsCompleted / plannedRounds).clamp(0.0, 1.0);
  }

  /// Интенсивность тренировки (отношение времени работы к общему времени)
  double get intensity {
    final totalTime = workTime + restTime;
    if (totalTime.inSeconds == 0) return 0.0;
    return workTime.inSeconds / totalTime.inSeconds;
  }

  /// Создать сессию из провайдера таймера
  factory WorkoutSession.fromTimerProvider(
      dynamic timerProvider, {
        String? workoutCode,
        String? workoutTitle,
        String? userNotes,
      }) {
    final id = const Uuid().v4();
    final now = DateTime.now();

    print('🏷 WorkoutSession.fromTimerProvider:');
    print('  workoutCode: $workoutCode');
    print('  workoutTitle: $workoutTitle');
    print('  userNotes: $userNotes');

    // Получаем результаты из провайдера
    final results = timerProvider.getWorkoutResults();
    final timerType = timerProvider.type as TimerType;

    // ИСПРАВЛЕНО: Определяем статус используя правильные константы
    WorkoutStatus status;
    if (results['isCompleted'] == true) {
      status = WorkoutStatus.completed;
    } else if (results['totalWorkTime'] > 0) {
      // ИСПРАВЛЕНО: Используем существующую константу - если есть время работы, значит была активность
      status = WorkoutStatus.completed; // Считаем что тренировка была выполнена, даже если не до конца
    } else {
      // ИСПРАВЛЕНО: Если вообще нет времени работы - тренировка не началась
      status = WorkoutStatus.completed; // По умолчанию completed
    }

    // Создаем конфигурацию
    final configuration = <String, dynamic>{
      'workDuration': results['workDuration'],
      'restDuration': results['restDuration'],
      'rounds': results['rounds'],
      'timerType': timerType.toString(),
    };

    // Включаем статистику раундов для классического таймера
    if (timerType == TimerType.classic && results.containsKey('lapStats')) {
      configuration['lapStats'] = results['lapStats'];
      configuration['lapTimes'] = results['lapTimes'];
    }

    return WorkoutSession(
      id: id,
      workoutCode: workoutCode,
      workoutTitle: workoutTitle,
      userNotes: userNotes,
      timerType: timerType,
      status: status,
      startTime: DateTime.parse(results['startTime']),
      endTime: results['endTime'] != null ? DateTime.parse(results['endTime']) : now,
      workTime: Duration(seconds: results['totalWorkTime'] ?? 0),
      restTime: Duration(seconds: results['totalRestTime'] ?? 0),
      roundsCompleted: results['completedRounds'] ?? 0,
      configuration: configuration,
      classicStats: timerType == TimerType.classic ?
      _createClassicStatsFromResults(results) : null,
      version: 2,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Создать классическую статистику из результатов
  static ClassicTimerStats? _createClassicStatsFromResults(Map<String, dynamic> results) {
    final lapStats = results['lapStats'] as Map<String, dynamic>?;
    if (lapStats == null) {
      return null;
    }

    final totalLaps = lapStats['totalLaps'] as int? ?? 0;
    if (totalLaps == 0) {
      return null;
    }

    final averageLapTime = (lapStats['averageLapTime'] as double? ?? 0.0).round();
    final fastestLap = lapStats['fastestLap'] as int? ?? 0;
    final consistency = lapStats['consistency'] as double? ?? 0.0;

    return ClassicTimerStats(
      totalLaps: totalLaps,
      averageRoundDuration: Duration(seconds: averageLapTime),
      fastestRoundDuration: Duration(seconds: fastestLap),
      consistencyPercent: consistency,
      lapTimes: (lapStats['lapDetails'] as List<dynamic>?)
          ?.map((lap) => Duration(seconds: lap['lapDuration'] as int? ?? 0))
          .toList() ?? [],
    );
  }

  /// Вспомогательный метод форматирования короткой даты
  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }

  /// Копировать с изменениями
  WorkoutSession copyWith({
    String? id,
    String? workoutCode,
    String? workoutTitle,
    String? userNotes,
    TimerType? timerType,
    WorkoutStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Duration? workTime,
    Duration? restTime,
    int? roundsCompleted,
    Map<String, dynamic>? configuration,
    ClassicTimerStats? classicStats,
    int? version,
    DateTime? updatedAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutCode: workoutCode ?? this.workoutCode,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      userNotes: userNotes ?? this.userNotes,
      timerType: timerType ?? this.timerType,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      workTime: workTime ?? this.workTime,
      restTime: restTime ?? this.restTime,
      roundsCompleted: roundsCompleted ?? this.roundsCompleted,
      configuration: configuration ?? this.configuration,
      classicStats: classicStats ?? this.classicStats,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Конвертировать в Map для БД
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_code': workoutCode,
      'workout_title': workoutTitle,
      'user_notes': userNotes,
      'timer_type': timerType.name,
      'status': status.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'work_time_ms': workTime.inMilliseconds,
      'rest_time_ms': restTime.inMilliseconds,
      'rounds_completed': roundsCompleted,
      'configuration': configuration,
      'classic_stats': classicStats?.toMap(),
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// ДОБАВЛЕНО: Метод toJson для совместимости с database_helper
  Map<String, dynamic> toJson() => toMap();

  /// Создать из Map БД
  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      workoutCode: map['workout_code'],
      workoutTitle: map['workout_title'],
      userNotes: map['user_notes'],
      timerType: TimerType.values.firstWhere(
            (type) => type.name == map['timer_type'],
        orElse: () => TimerType.classic,
      ),
      status: WorkoutStatus.values.firstWhere(
            (status) => status.name == map['status'],
        orElse: () => WorkoutStatus.completed,
      ),
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      workTime: Duration(milliseconds: map['work_time_ms'] ?? 0),
      restTime: Duration(milliseconds: map['rest_time_ms'] ?? 0),
      roundsCompleted: map['rounds_completed'] ?? 0,
      configuration: Map<String, dynamic>.from(map['configuration'] ?? {}),
      classicStats: map['classic_stats'] != null
          ? ClassicTimerStats.fromMap(Map<String, dynamic>.from(map['classic_stats']))
          : null,
      version: map['version'] ?? 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// ДОБАВЛЕНО: Метод fromJson для совместимости с database_helper
  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession.fromMap(json);

  @override
  String toString() {
    return 'WorkoutSession(id: $id, displayName: $displayName, status: $status, duration: $formattedDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Статистика для классического таймера
class ClassicTimerStats {
  final int totalLaps;
  final Duration averageRoundDuration;
  final Duration fastestRoundDuration;
  final double consistencyPercent;
  final List<Duration> lapTimes;

  const ClassicTimerStats({
    required this.totalLaps,
    required this.averageRoundDuration,
    required this.fastestRoundDuration,
    required this.consistencyPercent,
    required this.lapTimes,
  });

  /// Форматированное среднее время раунда
  String get formattedAverageRound {
    final seconds = averageRoundDuration.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Форматированное лучшее время раунда
  String get formattedFastestRound {
    final seconds = fastestRoundDuration.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Конвертировать в Map
  Map<String, dynamic> toMap() {
    return {
      'total_laps': totalLaps,
      'average_round_duration_ms': averageRoundDuration.inMilliseconds,
      'fastest_round_duration_ms': fastestRoundDuration.inMilliseconds,
      'consistency_percent': consistencyPercent,
      'lap_times_ms': lapTimes.map((duration) => duration.inMilliseconds).toList(),
    };
  }

  /// Создать из Map
  factory ClassicTimerStats.fromMap(Map<String, dynamic> map) {
    return ClassicTimerStats(
      totalLaps: map['total_laps'] ?? 0,
      averageRoundDuration: Duration(milliseconds: map['average_round_duration_ms'] ?? 0),
      fastestRoundDuration: Duration(milliseconds: map['fastest_round_duration_ms'] ?? 0),
      consistencyPercent: (map['consistency_percent'] ?? 0.0).toDouble(),
      lapTimes: (map['lap_times_ms'] as List<dynamic>?)
          ?.map((ms) => Duration(milliseconds: ms as int))
          .toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'ClassicTimerStats(totalLaps: $totalLaps, averageRound: $formattedAverageRound, fastestRound: $formattedFastestRound, consistency: ${consistencyPercent.toStringAsFixed(1)}%)';
  }
}
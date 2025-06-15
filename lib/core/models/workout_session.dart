// lib/core/models/workout_session.dart
import 'package:uuid/uuid.dart';
import '../enums/timer_enums.dart';
import 'workout_enums.dart';
import 'dart:convert'; // Добавляем для работы с JSON
import 'dart:math' as math; // Добавляем для sqrt

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

  /// Тип связи с тренировкой
  String get linkType {
    if (workoutCode != null) return 'code';
    if (workoutTitle != null) return 'title';
    return 'free';
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

    // Определяем статус
    WorkoutStatus status = WorkoutStatus.completed;
    if (results['isCompleted'] == true) {
      status = WorkoutStatus.completed;
    } else if (results['totalWorkTime'] > 0) {
      status = WorkoutStatus.completed;
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

  /// ИСПРАВЛЕНО: Конвертировать в Map для БД согласно схеме
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timer_type': timerType.name,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'total_duration': totalDuration.inMilliseconds,
      'status': status.name,
      'workout_code': workoutCode,
      'workout_title': workoutTitle,
      'link_type': linkType,
      'user_notes': userNotes,
      'configuration': json.encode(configuration), // Сериализуем в JSON строку
      'work_time': workTime.inMilliseconds,
      'rest_time': restTime.inMilliseconds,
      'pause_time': 0, // Пока не используется, но требуется схемой
      'rounds_completed': roundsCompleted,
      'classic_stats': classicStats?.toMap() != null ? json.encode(classicStats!.toMap()) : null, // Безопасная сериализация
      'created_at': createdAt.millisecondsSinceEpoch,
      'version': version,
    };
  }

  /// Метод toJson для совместимости с database_helper
  Map<String, dynamic> toJson() => toMap();

  /// 🛠️ ИСПРАВЛЕНО: Создать из Map БД с поддержкой старых форматов
  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    print('🔍 Создаем WorkoutSession: ${map['id']}');

    try {
      // Безопасное извлечение базовых данных
      final id = map['id'] as String?;
      final workoutCode = map['workout_code'] as String?;
      final workoutTitle = map['workout_title'] as String?;
      final userNotes = map['user_notes'] as String?;

      // Парсинг типа таймера
      final timerType = TimerType.values.firstWhere(
            (type) => type.name == map['timer_type'],
        orElse: () => TimerType.classic,
      );

      // Парсинг статуса
      final status = WorkoutStatus.values.firstWhere(
            (status) => status.name == map['status'],
        orElse: () => WorkoutStatus.completed,
      );

      // Времена
      final startTime = DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int);
      final endTime = DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int);
      final workTime = Duration(milliseconds: map['work_time'] ?? 0);
      final restTime = Duration(milliseconds: map['rest_time'] ?? 0);
      final roundsCompleted = map['rounds_completed'] ?? 0;

      // 🛠️ БЕЗОПАСНЫЙ ПАРСИНГ КОНФИГУРАЦИИ
      Map<String, dynamic> configuration = {};
      final configData = map['configuration'];
      if (configData != null) {
        if (configData is String) {
          try {
            configuration = json.decode(configData) as Map<String, dynamic>;
          } catch (e) {
            print('⚠️ Ошибка декодирования configuration: $e');
            configuration = {};
          }
        } else if (configData is Map) {
          configuration = Map<String, dynamic>.from(configData);
        }
      }

      // 🛠️ БЕЗОПАСНЫЙ ПАРСИНГ CLASSIC_STATS С ПОДДЕРЖКОЙ СТАРОГО ФОРМАТА
      ClassicTimerStats? classicStats;
      final statsData = map['classic_stats'];

      if (statsData != null) {
        if (statsData is String) {
          // JSON строка - декодируем
          try {
            final decoded = json.decode(statsData);
            if (decoded is Map) {
              classicStats = ClassicTimerStats.fromMap(Map<String, dynamic>.from(decoded));
            } else if (decoded is List) {
              // 🔧 СТАРЫЙ ФОРМАТ - конвертируем List в ClassicTimerStats
              print('🔄 Конвертируем старый формат List в ClassicTimerStats: $decoded');
              classicStats = _convertLegacyListToClassicStats(decoded);
            }
          } catch (e) {
            print('⚠️ Ошибка декодирования classic_stats JSON: $e');
            classicStats = null;
          }
        } else if (statsData is Map) {
          // Уже корректный Map
          try {
            classicStats = ClassicTimerStats.fromMap(Map<String, dynamic>.from(statsData));
          } catch (e) {
            print('⚠️ Ошибка создания ClassicTimerStats из Map: $e');
            classicStats = null;
          }
        } else if (statsData is List) {
          // 🔧 ПРЯМОЙ СТАРЫЙ ФОРМАТ - конвертируем
          print('🔄 Конвертируем прямой старый формат List: $statsData');
          classicStats = _convertLegacyListToClassicStats(statsData);
        }
      }

      // Метки времени
      final version = (map['version'] as int?) ?? 1;
      final createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int);
      final updatedAt = DateTime.now(); // При загрузке из БД обновляем время

      final session = WorkoutSession(
        id: id,
        workoutCode: workoutCode,
        workoutTitle: workoutTitle,
        userNotes: userNotes,
        timerType: timerType,
        status: status,
        startTime: startTime,
        endTime: endTime,
        workTime: workTime,
        restTime: restTime,
        roundsCompleted: roundsCompleted,
        configuration: configuration,
        classicStats: classicStats,
        version: version,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      print('✅ WorkoutSession создан: ${session.displayName}');
      return session;

    } catch (e, stackTrace) {
      print('❌ Error mapping to WorkoutSession: $e');
      print('❌ Map data: $map');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 🔄 Конвертация старого формата List в ClassicTimerStats
  static ClassicTimerStats? _convertLegacyListToClassicStats(List<dynamic> legacyStats) {
    print('🔄 Конвертируем legacy stats в ClassicTimerStats: $legacyStats');

    try {
      final List<int> lapTimes = legacyStats.cast<int>();

      if (lapTimes.isEmpty) {
        return null;
      }

      // Вычисляем статистики
      final totalLaps = lapTimes.length;
      final averageMs = lapTimes.reduce((a, b) => a + b) ~/ totalLaps;
      final fastestMs = lapTimes.reduce((a, b) => a < b ? a : b);

      // Вычисляем консистентность
      double consistency = 0.0;
      if (totalLaps > 1) {
        final variance = lapTimes
            .map((time) => (time - averageMs) * (time - averageMs))
            .reduce((a, b) => a + b) / totalLaps;
        final standardDeviation = variance > 0 ? math.sqrt(variance) : 0.0;
        consistency = averageMs > 0
            ? (100 - (standardDeviation / averageMs * 100)).clamp(0, 100)
            : 0.0;
      }

      final convertedStats = ClassicTimerStats(
        totalLaps: totalLaps,
        averageRoundDuration: Duration(milliseconds: averageMs),
        fastestRoundDuration: Duration(milliseconds: fastestMs),
        consistencyPercent: consistency,
        lapTimes: lapTimes.map((ms) => Duration(milliseconds: ms)).toList(),
      );

      print('✅ Legacy stats converted to ClassicTimerStats: $convertedStats');
      return convertedStats;

    } catch (e) {
      print('❌ Ошибка конвертации legacy stats: $e');
      return null;
    }
  }

  /// Метод fromJson для совместимости с database_helper
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
// lib/core/models/workout_session.dart
import '../providers/timer_provider.dart'; // TimerType здесь
import '../enums/timer_enums.dart';        // TimerType и TimerState здесь
import 'workout_enums.dart';
import 'classic_timer_stats.dart';

/// Основная модель сессии тренировки
class WorkoutSession {
  final String id;                         // Уникальный ID сессии
  final TimerType timerType;               // Тип таймера
  final DateTime startTime;                // Время начала
  final DateTime endTime;                  // Время окончания
  final Duration totalDuration;            // Общая продолжительность
  final WorkoutStatus status;              // Статус завершения

  // Привязка к тренировке
  final String? workoutCode;               // Код тренировки (например TB-001)
  final String? workoutTitle;              // Название тренировки
  final WorkoutLinkType linkType;          // Тип привязки
  final String? userNotes;                 // Заметки пользователя

  // Конфигурация таймера (настройки)
  final Map<String, dynamic> configuration;

  // Базовая статистика
  final Duration workTime;                 // Время работы
  final Duration restTime;                 // Время отдыха
  final Duration pauseTime;                // Время пауз
  final int roundsCompleted;               // Завершенные раунды

  // Специфичная статистика для классического таймера
  final ClassicTimerStats? classicStats;

  // Метаданные
  final DateTime createdAt;                // Время создания записи
  final int version;                       // Версия модели данных

  const WorkoutSession({
    required this.id,
    required this.timerType,
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
    required this.status,
    this.workoutCode,
    this.workoutTitle,
    required this.linkType,
    this.userNotes,
    required this.configuration,
    required this.workTime,
    required this.restTime,
    required this.pauseTime,
    required this.roundsCompleted,
    this.classicStats,
    required this.createdAt,
    this.version = 1,
  });

  /// Создание сессии из TimerProvider при завершении тренировки
  factory WorkoutSession.fromTimerProvider(
      TimerProvider timerProvider, {
        String? workoutCode,
        String? workoutTitle,
        String? userNotes,
      }) {
    final now = DateTime.now();
    final sessionId = '${now.millisecondsSinceEpoch}_${timerProvider.type.name}';

    // Определяем тип привязки к тренировке
    WorkoutLinkType linkType = WorkoutLinkType.none;
    if (workoutCode != null && workoutTitle != null) {
      linkType = WorkoutLinkType.byBoth;
    } else if (workoutCode != null) {
      linkType = WorkoutLinkType.byCode;
    } else if (workoutTitle != null) {
      linkType = WorkoutLinkType.byTitle;
    }

    // Создаем статистику для классического таймера
    ClassicTimerStats? classicStats;
    if (timerProvider.type == TimerType.classic) {
      // Здесь должен быть доступ к отсечкам из TimerProvider
      // Пока создаем пустую статистику
      classicStats = ClassicTimerStats.empty();
    }

    return WorkoutSession(
      id: sessionId,
      timerType: timerProvider.type,
      startTime: timerProvider.startTime ?? now,
      endTime: timerProvider.endTime ?? now,
      totalDuration: timerProvider.totalDuration ?? Duration.zero,
      status: timerProvider.isFinished ? WorkoutStatus.completed : WorkoutStatus.stopped,
      workoutCode: workoutCode,
      workoutTitle: workoutTitle,
      linkType: linkType,
      userNotes: userNotes,
      configuration: timerProvider.getTimerSettings(),
      workTime: Duration(seconds: timerProvider.totalWorkTime),
      restTime: Duration(seconds: timerProvider.totalRestTime),
      pauseTime: Duration.zero, // TODO: добавить отслеживание пауз в TimerProvider
      roundsCompleted: timerProvider.currentRound,
      classicStats: classicStats,
      createdAt: now,
    );
  }

  /// Копирование с изменениями
  WorkoutSession copyWith({
    String? id,
    TimerType? timerType,
    DateTime? startTime,
    DateTime? endTime,
    Duration? totalDuration,
    WorkoutStatus? status,
    String? workoutCode,
    String? workoutTitle,
    WorkoutLinkType? linkType,
    String? userNotes,
    Map<String, dynamic>? configuration,
    Duration? workTime,
    Duration? restTime,
    Duration? pauseTime,
    int? roundsCompleted,
    ClassicTimerStats? classicStats,
    DateTime? createdAt,
    int? version,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      timerType: timerType ?? this.timerType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDuration: totalDuration ?? this.totalDuration,
      status: status ?? this.status,
      workoutCode: workoutCode ?? this.workoutCode,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      linkType: linkType ?? this.linkType,
      userNotes: userNotes ?? this.userNotes,
      configuration: configuration ?? this.configuration,
      workTime: workTime ?? this.workTime,
      restTime: restTime ?? this.restTime,
      pauseTime: pauseTime ?? this.pauseTime,
      roundsCompleted: roundsCompleted ?? this.roundsCompleted,
      classicStats: classicStats ?? this.classicStats,
      createdAt: createdAt ?? this.createdAt,
      version: version ?? this.version,
    );
  }

  /// Преобразование в JSON для сохранения в БД
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timer_type': timerType.name,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'total_duration': totalDuration.inMilliseconds,
      'status': status.name,
      'workout_code': workoutCode,
      'workout_title': workoutTitle,
      'link_type': linkType.name,
      'user_notes': userNotes,
      'configuration': configuration,
      'work_time': workTime.inMilliseconds,
      'rest_time': restTime.inMilliseconds,
      'pause_time': pauseTime.inMilliseconds,
      'rounds_completed': roundsCompleted,
      'classic_stats': classicStats?.lapTimes.map((lap) => lap.inMilliseconds).toList(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'version': version,
    };
  }

  /// Создание из JSON (из БД)
  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    // Восстанавливаем статистику классического таймера
    ClassicTimerStats? classicStats;
    if (json['classic_stats'] != null) {
      final lapMilliseconds = List<int>.from(json['classic_stats']);
      final lapTimes = lapMilliseconds
          .map((ms) => Duration(milliseconds: ms))
          .toList();
      classicStats = ClassicTimerStats.fromLapTimes(lapTimes);
    }

    return WorkoutSession(
      id: json['id'],
      timerType: TimerType.values.firstWhere(
            (type) => type.name == json['timer_type'],
        orElse: () => TimerType.classic,
      ),
      startTime: DateTime.fromMillisecondsSinceEpoch(json['start_time']),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['end_time']),
      totalDuration: Duration(milliseconds: json['total_duration']),
      status: WorkoutStatus.values.firstWhere(
            (status) => status.name == json['status'],
        orElse: () => WorkoutStatus.completed,
      ),
      workoutCode: json['workout_code'],
      workoutTitle: json['workout_title'],
      linkType: WorkoutLinkType.values.firstWhere(
            (type) => type.name == json['link_type'],
        orElse: () => WorkoutLinkType.none,
      ),
      userNotes: json['user_notes'],
      configuration: Map<String, dynamic>.from(json['configuration'] ?? {}),
      workTime: Duration(milliseconds: json['work_time']),
      restTime: Duration(milliseconds: json['rest_time']),
      pauseTime: Duration(milliseconds: json['pause_time']),
      roundsCompleted: json['rounds_completed'],
      classicStats: classicStats,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      version: json['version'] ?? 1,
    );
  }

  /// Получить уникальный ключ тренировки для группировки
  String get workoutKey {
    if (workoutCode != null) {
      return workoutCode!.toUpperCase();
    } else if (workoutTitle != null) {
      return workoutTitle!;
    } else {
      return 'FREE_${timerType.name}';
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
      return 'Свободная тренировка';
    }
  }

  /// Проверка успешного завершения
  bool get isSuccessfullyCompleted => status.isSuccessful;

  /// Проверка привязки к тренировке
  bool get isLinkedWorkout => linkType != WorkoutLinkType.none;

  /// Форматированная продолжительность
  String get formattedDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    final seconds = totalDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() {
    return 'WorkoutSession(${displayName}, ${timerType.name}, $formattedDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
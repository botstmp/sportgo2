// lib/core/services/workout_history_service.dart
import 'dart:async';
import '../models/workout_session.dart';
import '../models/workout_enums.dart';
import '../enums/timer_enums.dart';
import 'database_helper.dart';

/// Сервис для управления историей тренировок SportOn
class WorkoutHistoryService {
  static WorkoutHistoryService? _instance;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Singleton pattern
  WorkoutHistoryService._internal();

  factory WorkoutHistoryService() {
    _instance ??= WorkoutHistoryService._internal();
    return _instance!;
  }

  // === ОСНОВНЫЕ CRUD ОПЕРАЦИИ ===

  /// Сохранить новую тренировку
  Future<bool> saveWorkoutSession(WorkoutSession session) async {
    try {
      print('📝 WorkoutHistoryService: Attempting to save session - ${session.displayName}');
      print('📝 Session ID: ${session.id}');
      print('📝 Timer type: ${session.timerType}');
      print('📝 Duration: ${session.formattedDuration}');

      final result = await _databaseHelper.insertWorkoutSession(session);

      if (result > 0) {
        print('✅ WorkoutHistoryService: Session saved successfully - ${session.displayName}');

        // Дополнительная проверка - загружаем сессию обратно
        final savedSession = await _databaseHelper.getWorkoutSessionById(session.id!);
        if (savedSession != null) {
          print('✅ WorkoutHistoryService: Session verification successful');
        } else {
          print('⚠️ WorkoutHistoryService: Session saved but verification failed');
        }

        return true;
      } else {
        print('⚠️ WorkoutHistoryService: Insert returned 0 rows');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ WorkoutHistoryService: Failed to save session - $e');
      print('❌ StackTrace: $stackTrace');
      return false;
    }
  }

  /// Получить все тренировки
  Future<List<WorkoutSession>> getAllSessions() async {
    try {
      print('🔍 WorkoutHistoryService: Loading all sessions...');
      final sessions = await _databaseHelper.getAllWorkoutSessions();
      print('✅ WorkoutHistoryService: Loaded ${sessions.length} sessions');

      if (sessions.isNotEmpty) {
        print('🔍 First session: ${sessions.first.displayName}');
        print('🔍 Last session: ${sessions.last.displayName}');
      }

      return sessions;
    } catch (e, stackTrace) {
      print('❌ WorkoutHistoryService: Failed to load sessions - $e');
      print('❌ StackTrace: $stackTrace');
      return [];
    }
  }

  /// Получить тренировку по ID
  Future<WorkoutSession?> getSessionById(String id) async {
    try {
      final session = await _databaseHelper.getWorkoutSessionById(id);
      if (session != null) {
        print('✅ WorkoutHistoryService: Session found - ${session.displayName}');
      } else {
        print('⚠️ WorkoutHistoryService: Session not found - $id');
      }
      return session;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get session by ID - $e');
      return null;
    }
  }

  /// Обновить существующую тренировку
  Future<bool> updateWorkoutSession(WorkoutSession session) async {
    try {
      final result = await _databaseHelper.updateWorkoutSession(session);
      if (result > 0) {
        print('✅ WorkoutHistoryService: Session updated - ${session.displayName}');
        return true;
      } else {
        print('⚠️ WorkoutHistoryService: No session updated - ${session.id}');
        return false;
      }
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to update session - $e');
      return false;
    }
  }

  /// ЧИСТОЕ удаление без логов
  Future<bool> deleteWorkoutSession(String id) async {
    try {
      final result = await _databaseHelper.deleteWorkoutSession(id);
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // === ФИЛЬТРАЦИЯ И ПОИСК ===

  /// Получить тренировки по типу таймера
  Future<List<WorkoutSession>> getSessionsByTimerType(TimerType timerType) async {
    try {
      final sessions = await _databaseHelper.getWorkoutSessionsByType(timerType.name);
      print('✅ WorkoutHistoryService: Found ${sessions.length} sessions for ${timerType.name}');
      return sessions;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get sessions by timer type - $e');
      return [];
    }
  }

  /// Получить тренировки конкретной тренировки (по коду или названию)
  Future<List<WorkoutSession>> getSessionsByWorkoutKey(String workoutKey) async {
    try {
      final sessions = await _databaseHelper.getWorkoutSessionsByKey(workoutKey);
      print('✅ WorkoutHistoryService: Found ${sessions.length} sessions for workout "$workoutKey"');
      return sessions;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get sessions by workout key - $e');
      return [];
    }
  }

  /// Получить тренировки за период
  Future<List<WorkoutSession>> getSessionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allSessions = await getAllSessions();

      final filteredSessions = allSessions.where((session) {
        final sessionDate = session.startTime;
        return sessionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            sessionDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      print('✅ WorkoutHistoryService: Found ${filteredSessions.length} sessions in date range');
      return filteredSessions;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get sessions by date range - $e');
      return [];
    }
  }

  /// Получить только успешно завершенные тренировки
  Future<List<WorkoutSession>> getCompletedSessions() async {
    try {
      final allSessions = await getAllSessions();
      final completedSessions = allSessions
          .where((session) => session.status == WorkoutStatus.completed)
          .toList();

      print('✅ WorkoutHistoryService: Found ${completedSessions.length} completed sessions');
      return completedSessions;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get completed sessions - $e');
      return [];
    }
  }

  /// Получить привязанные к тренировкам сессии
  Future<List<WorkoutSession>> getLinkedSessions() async {
    try {
      final allSessions = await getAllSessions();
      final linkedSessions = allSessions
          .where((session) => session.isLinkedWorkout)
          .toList();

      print('✅ WorkoutHistoryService: Found ${linkedSessions.length} linked sessions');
      return linkedSessions;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get linked sessions - $e');
      return [];
    }
  }

  /// Получить независимые тренировки
  Future<List<WorkoutSession>> getIndependentSessions() async {
    try {
      final allSessions = await getAllSessions();
      final independentSessions = allSessions
          .where((session) => !session.isLinkedWorkout)
          .toList();

      print('✅ WorkoutHistoryService: Found ${independentSessions.length} independent sessions');
      return independentSessions;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get independent sessions - $e');
      return [];
    }
  }

  // === СТАТИСТИКА И АНАЛИТИКА ===

  /// Получить общую статистику
  Future<WorkoutOverallStats> getOverallStats() async {
    try {
      final dbStats = await _databaseHelper.getOverallStats();
      final sessions = await getAllSessions();

      final stats = WorkoutOverallStats.fromData(
        totalSessions: dbStats['totalSessions'] as int,
        totalTimeMs: dbStats['totalTimeMs'] as int,
        sessionsByType: Map<String, int>.from(dbStats['sessionsByType']),
        sessions: sessions,
      );

      print('✅ WorkoutHistoryService: Overall stats calculated');
      return stats;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get overall stats - $e');
      return WorkoutOverallStats.empty();
    }
  }

  /// Получить статистику конкретной тренировки
  Future<WorkoutSpecificStats> getWorkoutStats(String workoutKey) async {
    try {
      final sessions = await getSessionsByWorkoutKey(workoutKey);

      if (sessions.isEmpty) {
        print('⚠️ WorkoutHistoryService: No sessions found for workout "$workoutKey"');
        return WorkoutSpecificStats.empty();
      }

      final stats = WorkoutSpecificStats.fromSessions(workoutKey, sessions);
      print('✅ WorkoutHistoryService: Stats calculated for workout "$workoutKey"');
      return stats;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get workout stats - $e');
      return WorkoutSpecificStats.empty();
    }
  }

  /// Получить карту кодов тренировок для автодополнения
  Future<Map<String, String>> getWorkoutCodesMap() async {
    try {
      final codesMap = await _databaseHelper.getWorkoutCodesMap();
      print('✅ WorkoutHistoryService: Loaded ${codesMap.length} workout codes');
      return codesMap;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get workout codes - $e');
      return {};
    }
  }

  /// Проверить является ли результат рекордом для тренировки
  Future<RecordCheckResult> checkForRecord(WorkoutSession newSession) async {
    try {
      if (!newSession.isLinkedWorkout) {
        return RecordCheckResult.noRecord();
      }

      final previousSessions = await getSessionsByWorkoutKey(newSession.workoutKey);

      // Исключаем текущую сессию из сравнения
      final otherSessions = previousSessions
          .where((session) => session.id != newSession.id)
          .toList();

      if (otherSessions.isEmpty) {
        return RecordCheckResult.firstAttempt();
      }

      // Проверяем рекорд по времени (основной критерий)
      final bestPreviousTime = otherSessions
          .map((session) => session.totalDuration)
          .reduce((a, b) => a < b ? a : b);

      if (newSession.totalDuration < bestPreviousTime) {
        final improvement = bestPreviousTime - newSession.totalDuration;
        print('🏆 WorkoutHistoryService: NEW RECORD for "${newSession.workoutKey}"! Improved by ${improvement.inSeconds}s');
        return RecordCheckResult.newRecord(RecordType.fastestTime, improvement);
      }

      // Проверяем другие типы рекордов для классического таймера
      if (newSession.timerType == TimerType.classic && newSession.classicStats != null) {
        final newStats = newSession.classicStats!;

        // Рекорд по количеству раундов
        final maxPreviousRounds = otherSessions
            .where((session) => session.classicStats != null)
            .map((session) => session.classicStats!.totalLaps)
            .fold(0, (max, laps) => laps > max ? laps : max);

        if (newStats.totalLaps > maxPreviousRounds) {
          print('🏆 WorkoutHistoryService: NEW ROUND RECORD for "${newSession.workoutKey}"! ${newStats.totalLaps} rounds');
          return RecordCheckResult.newRecord(RecordType.mostRounds, newStats.totalLaps - maxPreviousRounds);
        }

        // Рекорд по стабильности
        final bestPreviousConsistency = otherSessions
            .where((session) => session.classicStats != null)
            .map((session) => session.classicStats!.consistencyPercent)
            .fold(0.0, (max, consistency) => consistency > max ? consistency : max);

        if (newStats.consistencyPercent > bestPreviousConsistency + 5.0) { // Улучшение на 5%+
          print('🎯 WorkoutHistoryService: NEW CONSISTENCY RECORD for "${newSession.workoutKey}"! ${newStats.consistencyPercent.toStringAsFixed(1)}%');
          return RecordCheckResult.newRecord(RecordType.bestConsistency, newStats.consistencyPercent - bestPreviousConsistency);
        }
      }

      return RecordCheckResult.noRecord();
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to check for record - $e');
      return RecordCheckResult.noRecord();
    }
  }

  // === УТИЛИТЫ ===

  /// Получить количество тренировок
  Future<int> getTotalSessionsCount() async {
    try {
      final count = await _databaseHelper.getWorkoutSessionsCount();
      return count;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get sessions count - $e');
      return 0;
    }
  }

  /// Очистить всю историю (для тестирования)
  Future<bool> clearAllHistory() async {
    try {
      await _databaseHelper.clearAllData();
      print('✅ WorkoutHistoryService: All history cleared');
      return true;
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to clear history - $e');
      return false;
    }
  }

  /// Получить информацию о сервисе (для отладки)
  Future<Map<String, dynamic>> getServiceInfo() async {
    try {
      final dbInfo = await _databaseHelper.getDatabaseInfo();
      final totalSessions = await getTotalSessionsCount();

      return {
        'database': dbInfo,
        'totalSessions': totalSessions,
        'serviceReady': true,
      };
    } catch (e) {
      print('❌ WorkoutHistoryService: Failed to get service info - $e');
      return {'serviceReady': false, 'error': e.toString()};
    }
  }

  /// НОВЫЙ МЕТОД: Проверить целостность базы данных
  Future<Map<String, dynamic>> checkDatabaseIntegrity() async {
    try {
      final info = await getServiceInfo();
      final sessions = await getAllSessions();

      final issues = <String>[];

      for (final session in sessions) {
        if (session.id == null || session.id!.isEmpty) {
          issues.add('Session with empty ID found');
        }
        if (session.totalDuration.inSeconds <= 0) {
          issues.add('Session with zero duration: ${session.id}');
        }
      }

      return {
        'isHealthy': issues.isEmpty,
        'issues': issues,
        'totalSessions': sessions.length,
        'databaseInfo': info,
      };
    } catch (e) {
      return {
        'isHealthy': false,
        'issues': ['Database check failed: $e'],
        'totalSessions': 0,
        'databaseInfo': {},
      };
    }
  }
}

// === ВСПОМОГАТЕЛЬНЫЕ КЛАССЫ ===

/// Общая статистика тренировок
class WorkoutOverallStats {
  final int totalSessions;
  final Duration totalTime;
  final Map<TimerType, int> sessionsByType;
  final Duration averageSessionTime;
  final DateTime? firstWorkout;
  final DateTime? lastWorkout;

  const WorkoutOverallStats({
    required this.totalSessions,
    required this.totalTime,
    required this.sessionsByType,
    required this.averageSessionTime,
    this.firstWorkout,
    this.lastWorkout,
  });

  factory WorkoutOverallStats.fromData({
    required int totalSessions,
    required int totalTimeMs,
    required Map<String, int> sessionsByType,
    required List<WorkoutSession> sessions,
  }) {
    final typeStats = <TimerType, int>{};
    for (final entry in sessionsByType.entries) {
      try {
        final timerType = TimerType.values.firstWhere((type) => type.name == entry.key);
        typeStats[timerType] = entry.value;
      } catch (e) {
        // Игнорируем неизвестные типы
      }
    }

    DateTime? firstWorkout;
    DateTime? lastWorkout;
    if (sessions.isNotEmpty) {
      sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
      firstWorkout = sessions.first.startTime;
      lastWorkout = sessions.last.startTime;
    }

    final averageMs = totalSessions > 0 ? totalTimeMs ~/ totalSessions : 0;

    return WorkoutOverallStats(
      totalSessions: totalSessions,
      totalTime: Duration(milliseconds: totalTimeMs),
      sessionsByType: typeStats,
      averageSessionTime: Duration(milliseconds: averageMs),
      firstWorkout: firstWorkout,
      lastWorkout: lastWorkout,
    );
  }

  factory WorkoutOverallStats.empty() {
    return const WorkoutOverallStats(
      totalSessions: 0,
      totalTime: Duration.zero,
      sessionsByType: {},
      averageSessionTime: Duration.zero,
    );
  }
}

/// Статистика конкретной тренировки
class WorkoutSpecificStats {
  final String workoutKey;
  final int totalAttempts;
  final int completedSessions;
  final Duration bestTime;
  final Duration averageTime;
  final Duration worstTime;
  final DateTime firstAttempt;
  final DateTime lastAttempt;
  final List<Duration> recentTimes;

  const WorkoutSpecificStats({
    required this.workoutKey,
    required this.totalAttempts,
    required this.completedSessions,
    required this.bestTime,
    required this.averageTime,
    required this.worstTime,
    required this.firstAttempt,
    required this.lastAttempt,
    required this.recentTimes,
  });

  factory WorkoutSpecificStats.fromSessions(String workoutKey, List<WorkoutSession> sessions) {
    final completedSessions = sessions.where((s) => s.status == WorkoutStatus.completed).toList();

    if (completedSessions.isEmpty) {
      return WorkoutSpecificStats.empty();
    }

    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    final times = completedSessions.map((s) => s.totalDuration).toList();
    final bestTime = times.reduce((a, b) => a < b ? a : b);
    final worstTime = times.reduce((a, b) => a > b ? a : b);

    final totalMs = times.map((t) => t.inMilliseconds).reduce((a, b) => a + b);
    final averageTime = Duration(milliseconds: totalMs ~/ times.length);

    final recentTimes = sessions.length > 10
        ? sessions.sublist(sessions.length - 10).map((s) => s.totalDuration).toList()
        : times;

    return WorkoutSpecificStats(
      workoutKey: workoutKey,
      totalAttempts: sessions.length,
      completedSessions: completedSessions.length,
      bestTime: bestTime,
      averageTime: averageTime,
      worstTime: worstTime,
      firstAttempt: sessions.first.startTime,
      lastAttempt: sessions.last.startTime,
      recentTimes: recentTimes,
    );
  }

  factory WorkoutSpecificStats.empty() {
    final now = DateTime.now();

    return WorkoutSpecificStats(
      workoutKey: '',
      totalAttempts: 0,
      completedSessions: 0,
      bestTime: Duration.zero,
      averageTime: Duration.zero,
      worstTime: Duration.zero,
      firstAttempt: now,
      lastAttempt: now,
      recentTimes: const [],
    );
  }

  bool get isEmpty => totalAttempts == 0;
}

/// Результат проверки рекорда
class RecordCheckResult {
  final bool isRecord;
  final bool isFirstAttempt;
  final RecordType? recordType;
  final dynamic improvement;

  const RecordCheckResult({
    required this.isRecord,
    required this.isFirstAttempt,
    this.recordType,
    this.improvement,
  });

  factory RecordCheckResult.newRecord(RecordType type, dynamic improvement) {
    return RecordCheckResult(
      isRecord: true,
      isFirstAttempt: false,
      recordType: type,
      improvement: improvement,
    );
  }

  factory RecordCheckResult.firstAttempt() {
    return const RecordCheckResult(
      isRecord: false,
      isFirstAttempt: true,
    );
  }

  factory RecordCheckResult.noRecord() {
    return const RecordCheckResult(
      isRecord: false,
      isFirstAttempt: false,
    );
  }

  String get message {
    if (isFirstAttempt) return 'Первая попытка!';
    if (isRecord && recordType != null) {
      return '🏆 РЕКОРД: ${recordType!.displayName}';
    }
    return '';
  }
}

/// Типы рекордов
enum RecordType {
  fastestTime('Лучшее время'),
  mostRounds('Больше всего раундов'),
  bestConsistency('Лучшая стабильность');

  const RecordType(this.displayName);
  final String displayName;
}
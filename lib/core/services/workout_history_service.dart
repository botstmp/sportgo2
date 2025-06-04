// lib/core/services/workout_history_service.dart
import '../models/workout_session.dart';
import '../models/workout_enums.dart';
import 'database_helper.dart';

/// Простой сервис управления историей тренировок
class WorkoutHistoryService {
  static WorkoutHistoryService? _instance;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  WorkoutHistoryService._internal();

  factory WorkoutHistoryService() {
    _instance ??= WorkoutHistoryService._internal();
    return _instance!;
  }

  /// Получить все сессии тренировок
  Future<List<WorkoutSession>> getAllSessions() async {
    try {
      return await _databaseHelper.getAllWorkoutSessions();
    } catch (e) {
      print('Error getting all sessions: $e');
      return [];
    }
  }

  /// Сохранить новую тренировку
  Future<bool> saveWorkoutSession(WorkoutSession session) async {
    try {
      await _databaseHelper.insertWorkoutSession(session);
      return true;
    } catch (e) {
      print('Error saving workout session: $e');
      return false;
    }
  }

  /// Удалить тренировку
  Future<bool> deleteWorkoutSession(String id) async {
    try {
      await _databaseHelper.deleteWorkoutSession(id);
      return true;
    } catch (e) {
      print('Error deleting workout session: $e');
      return false;
    }
  }

  /// Получить тренировки по типу
  Future<List<WorkoutSession>> getSessionsByType(String timerType) async {
    try {
      return await _databaseHelper.getWorkoutSessionsByType(timerType);
    } catch (e) {
      print('Error getting sessions by type: $e');
      return [];
    }
  }

  /// Получить тренировку по ID
  Future<WorkoutSession?> getSessionById(String id) async {
    try {
      return await _databaseHelper.getWorkoutSessionById(id);
    } catch (e) {
      print('Error getting session by ID: $e');
      return null;
    }
  }

  /// Обновить тренировку
  Future<bool> updateWorkoutSession(WorkoutSession session) async {
    try {
      await _databaseHelper.updateWorkoutSession(session);
      return true;
    } catch (e) {
      print('Error updating workout session: $e');
      return false;
    }
  }

  /// Создать сессию из результатов таймера
  Future<WorkoutSession> createSessionFromTimerResult(
      Map<String, dynamic> timerResult, {
        String? linkedWorkoutCode,
        String? linkedWorkoutTitle,
        String? userNotes,
      }) async {
    return WorkoutSession.fromTimerResults(
      timerResult,
      workoutCode: linkedWorkoutCode,
      workoutTitle: linkedWorkoutTitle,
      userNotes: userNotes,
    );
  }

  /// Получить общую статистику
  Future<Map<String, dynamic>> getOverallStats() async {
    try {
      return await _databaseHelper.getOverallStats();
    } catch (e) {
      print('Error getting overall stats: $e');
      return {
        'totalSessions': 0,
        'totalTimeMs': 0,
        'sessionsByType': <String, int>{},
      };
    }
  }

  /// Получить количество тренировок
  Future<int> getTotalSessionsCount() async {
    try {
      return await _databaseHelper.getWorkoutSessionsCount();
    } catch (e) {
      print('Error getting sessions count: $e');
      return 0;
    }
  }

  /// Получить уникальные коды тренировок
  Future<Map<String, String>> getWorkoutCodes() async {
    try {
      return await _databaseHelper.getWorkoutCodesMap();
    } catch (e) {
      print('Error getting workout codes: $e');
      return {};
    }
  }

  /// Очистить всю историю (для тестирования)
  Future<bool> clearAllHistory() async {
    try {
      await _databaseHelper.clearAllData();
      return true;
    } catch (e) {
      print('Error clearing history: $e');
      return false;
    }
  }

  /// Получить информацию о базе данных
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      return await _databaseHelper.getDatabaseInfo();
    } catch (e) {
      print('Error getting database info: $e');
      return {};
    }
  }
}
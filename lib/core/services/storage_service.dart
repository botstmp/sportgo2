// lib/core/services/storage_service.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

/// Модель тренировки для истории
class WorkoutHistoryModel {
  final String id;
  final String timerType;
  final DateTime date;
  final List<int> roundTimes;
  final int? restTime;
  final int overallTime;
  final Map<String, dynamic>? metadata;

  const WorkoutHistoryModel({
    required this.id,
    required this.timerType,
    required this.date,
    required this.roundTimes,
    this.restTime,
    required this.overallTime,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timerType': timerType,
    'date': date.toIso8601String(),
    'roundTimes': roundTimes,
    'restTime': restTime,
    'overallTime': overallTime,
    'metadata': metadata,
  };

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timerType: json['timerType'] ?? 'Unknown',
      date: DateTime.parse(json['date']),
      roundTimes: List<int>.from(json['roundTimes'] ?? []),
      restTime: json['restTime'],
      overallTime: json['overallTime'] ?? 0,
      metadata: json['metadata'],
    );
  }

  @override
  String toString() => 'WorkoutHistory($timerType, $date, ${roundTimes.length} rounds)';
}

/// Централизованный сервис для работы с хранилищем
class StorageService {
  static const String _historyKey = 'training_history';
  static const String _settingsKey = 'app_settings';
  static const String _themeKey = 'theme_index';
  static const String _localeKey = 'locale';

  static SharedPreferences? _prefs;

  /// Инициализация сервиса
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      developer.log('StorageService initialized successfully');
    } catch (e) {
      developer.log('Failed to initialize StorageService: $e', level: 900);
      rethrow;
    }
  }

  /// Получение экземпляра SharedPreferences
  static Future<SharedPreferences> get _instance async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  // === ИСТОРИЯ ТРЕНИРОВОК ===

  /// Сохранить тренировку в историю
  static Future<bool> saveWorkout(WorkoutHistoryModel workout) async {
    try {
      final prefs = await _instance;
      final history = await getWorkoutHistory();

      // Добавляем уникальный ID если его нет
      final workoutWithId = WorkoutHistoryModel(
        id: workout.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : workout.id,
        timerType: workout.timerType,
        date: workout.date,
        roundTimes: workout.roundTimes,
        restTime: workout.restTime,
        overallTime: workout.overallTime,
        metadata: workout.metadata,
      );

      history.add(workoutWithId);

      // Ограничиваем историю 100 записями
      if (history.length > 100) {
        history.removeRange(0, history.length - 100);
      }

      final historyJson = history.map((w) => jsonEncode(w.toJson())).toList();
      final success = await prefs.setStringList(_historyKey, historyJson);

      developer.log('Workout saved: ${workoutWithId.timerType} - $success');
      return success;
    } catch (e) {
      developer.log('Failed to save workout: $e', level: 900);
      return false;
    }
  }

  /// Получить историю тренировок
  static Future<List<WorkoutHistoryModel>> getWorkoutHistory() async {
    try {
      final prefs = await _instance;
      final historyStrings = prefs.getStringList(_historyKey) ?? [];

      final history = historyStrings
          .map((historyString) {
        try {
          final json = jsonDecode(historyString) as Map<String, dynamic>;
          return WorkoutHistoryModel.fromJson(json);
        } catch (e) {
          developer.log('Failed to parse workout history item: $e');
          return null;
        }
      })
          .where((workout) => workout != null)
          .cast<WorkoutHistoryModel>()
          .toList();

      // Сортируем по дате (новые сверху)
      history.sort((a, b) => b.date.compareTo(a.date));

      developer.log('Loaded ${history.length} workout records');
      return history;
    } catch (e) {
      developer.log('Failed to load workout history: $e', level: 900);
      return [];
    }
  }

  /// Удалить тренировку из истории
  static Future<bool> deleteWorkout(String workoutId) async {
    try {
      final history = await getWorkoutHistory();
      history.removeWhere((workout) => workout.id == workoutId);

      final prefs = await _instance;
      final historyJson = history.map((w) => jsonEncode(w.toJson())).toList();
      final success = await prefs.setStringList(_historyKey, historyJson);

      developer.log('Workout deleted: $workoutId - $success');
      return success;
    } catch (e) {
      developer.log('Failed to delete workout: $e', level: 900);
      return false;
    }
  }

  /// Очистить всю историю тренировок
  static Future<bool> clearWorkoutHistory() async {
    try {
      final prefs = await _instance;
      final success = await prefs.remove(_historyKey);
      developer.log('Workout history cleared: $success');
      return success;
    } catch (e) {
      developer.log('Failed to clear workout history: $e', level: 900);
      return false;
    }
  }

  /// Получить статистику тренировок
  static Future<WorkoutStatsModel> getWorkoutStats() async {
    try {
      final history = await getWorkoutHistory();

      if (history.isEmpty) {
        return const WorkoutStatsModel();
      }

      final totalWorkouts = history.length;
      final totalTime = history.fold<int>(0, (sum, workout) => sum + workout.overallTime);
      final avgTime = totalTime ~/ totalWorkouts;

      // Группировка по типам таймеров
      final timerTypes = <String, int>{};
      for (final workout in history) {
        timerTypes[workout.timerType] = (timerTypes[workout.timerType] ?? 0) + 1;
      }

      // Статистика за последнюю неделю
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentWorkouts = history.where((w) => w.date.isAfter(weekAgo)).length;

      return WorkoutStatsModel(
        totalWorkouts: totalWorkouts,
        totalTimeSeconds: totalTime,
        averageTimeSeconds: avgTime,
        timerTypeStats: timerTypes,
        recentWorkoutsCount: recentWorkouts,
        lastWorkoutDate: history.first.date,
      );
    } catch (e) {
      developer.log('Failed to calculate workout stats: $e', level: 900);
      return const WorkoutStatsModel();
    }
  }

  // === НАСТРОЙКИ ТЕМЫ И ЯЗЫКА ===

  /// Сохранить индекс темы
  static Future<bool> saveThemeIndex(int themeIndex) async {
    try {
      final prefs = await _instance;
      return await prefs.setInt(_themeKey, themeIndex);
    } catch (e) {
      developer.log('Failed to save theme index: $e', level: 900);
      return false;
    }
  }

  /// Получить индекс темы
  static Future<int> getThemeIndex() async {
    try {
      final prefs = await _instance;
      return prefs.getInt(_themeKey) ?? 0;
    } catch (e) {
      developer.log('Failed to load theme index: $e', level: 900);
      return 0;
    }
  }

  /// Сохранить код языка
  static Future<bool> saveLocaleCode(String localeCode) async {
    try {
      final prefs = await _instance;
      return await prefs.setString(_localeKey, localeCode);
    } catch (e) {
      developer.log('Failed to save locale code: $e', level: 900);
      return false;
    }
  }

  /// Получить код языка
  static Future<String> getLocaleCode() async {
    try {
      final prefs = await _instance;
      return prefs.getString(_localeKey) ?? 'en';
    } catch (e) {
      developer.log('Failed to load locale code: $e', level: 900);
      return 'en';
    }
  }

  // === ОБЩИЕ НАСТРОЙКИ ===

  /// Сохранить произвольную настройку
  static Future<bool> setSetting(String key, dynamic value) async {
    try {
      final prefs = await _instance;

      if (value is String) {
        return await prefs.setString(key, value);
      } else if (value is int) {
        return await prefs.setInt(key, value);
      } else if (value is double) {
        return await prefs.setDouble(key, value);
      } else if (value is bool) {
        return await prefs.setBool(key, value);
      } else if (value is List<String>) {
        return await prefs.setStringList(key, value);
      } else {
        return await prefs.setString(key, jsonEncode(value));
      }
    } catch (e) {
      developer.log('Failed to save setting $key: $e', level: 900);
      return false;
    }
  }

  /// Получить произвольную настройку
  static Future<T?> getSetting<T>(String key, [T? defaultValue]) async {
    try {
      final prefs = await _instance;

      if (T == String) {
        return prefs.getString(key) as T? ?? defaultValue;
      } else if (T == int) {
        return prefs.getInt(key) as T? ?? defaultValue;
      } else if (T == double) {
        return prefs.getDouble(key) as T? ?? defaultValue;
      } else if (T == bool) {
        return prefs.getBool(key) as T? ?? defaultValue;
      } else {
        final stringValue = prefs.getString(key);
        if (stringValue == null) return defaultValue;
        return jsonDecode(stringValue) as T;
      }
    } catch (e) {
      developer.log('Failed to load setting $key: $e', level: 900);
      return defaultValue;
    }
  }

  /// Удалить настройку
  static Future<bool> removeSetting(String key) async {
    try {
      final prefs = await _instance;
      return await prefs.remove(key);
    } catch (e) {
      developer.log('Failed to remove setting $key: $e', level: 900);
      return false;
    }
  }

  /// Очистить все данные
  static Future<bool> clearAll() async {
    try {
      final prefs = await _instance;
      return await prefs.clear();
    } catch (e) {
      developer.log('Failed to clear all data: $e', level: 900);
      return false;
    }
  }

  // === УТИЛИТЫ ===

  /// Экспорт всех данных
  static Future<Map<String, dynamic>> exportAllData() async {
    try {
      final history = await getWorkoutHistory();
      final stats = await getWorkoutStats();
      final themeIndex = await getThemeIndex();
      final localeCode = await getLocaleCode();

      return {
        'version': '2.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'workoutHistory': history.map((w) => w.toJson()).toList(),
        'stats': {
          'totalWorkouts': stats.totalWorkouts,
          'totalTimeSeconds': stats.totalTimeSeconds,
          'averageTimeSeconds': stats.averageTimeSeconds,
          'timerTypeStats': stats.timerTypeStats,
          'recentWorkoutsCount': stats.recentWorkoutsCount,
          'lastWorkoutDate': stats.lastWorkoutDate?.toIso8601String(),
        },
        'settings': {
          'themeIndex': themeIndex,
          'localeCode': localeCode,
        },
      };
    } catch (e) {
      developer.log('Failed to export data: $e', level: 900);
      return {};
    }
  }

  /// Импорт данных
  static Future<bool> importAllData(Map<String, dynamic> data) async {
    try {
      // Импорт истории тренировок
      if (data.containsKey('workoutHistory')) {
        final historyData = data['workoutHistory'] as List<dynamic>;
        final history = historyData
            .map((item) => WorkoutHistoryModel.fromJson(item as Map<String, dynamic>))
            .toList();

        final prefs = await _instance;
        final historyJson = history.map((w) => jsonEncode(w.toJson())).toList();
        await prefs.setStringList(_historyKey, historyJson);
      }

      // Импорт настроек
      if (data.containsKey('settings')) {
        final settings = data['settings'] as Map<String, dynamic>;

        if (settings.containsKey('themeIndex')) {
          await saveThemeIndex(settings['themeIndex'] as int);
        }

        if (settings.containsKey('localeCode')) {
          await saveLocaleCode(settings['localeCode'] as String);
        }
      }

      developer.log('Data imported successfully');
      return true;
    } catch (e) {
      developer.log('Failed to import data: $e', level: 900);
      return false;
    }
  }
}

/// Модель статистики тренировок
class WorkoutStatsModel {
  final int totalWorkouts;
  final int totalTimeSeconds;
  final int averageTimeSeconds;
  final Map<String, int> timerTypeStats;
  final int recentWorkoutsCount;
  final DateTime? lastWorkoutDate;

  const WorkoutStatsModel({
    this.totalWorkouts = 0,
    this.totalTimeSeconds = 0,
    this.averageTimeSeconds = 0,
    this.timerTypeStats = const {},
    this.recentWorkoutsCount = 0,
    this.lastWorkoutDate,
  });

  String get formattedTotalTime {
    final hours = totalTimeSeconds ~/ 3600;
    final minutes = (totalTimeSeconds % 3600) ~/ 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  String get formattedAverageTime {
    final minutes = averageTimeSeconds ~/ 60;
    final seconds = averageTimeSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  /// Получение самого популярного типа таймера
  String get mostUsedTimerType {
    if (timerTypeStats.isEmpty) return 'None';

    var maxCount = 0;
    var mostUsed = 'None';

    timerTypeStats.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsed = type;
      }
    });

    return mostUsed;
  }

  /// Процент использования определенного типа таймера
  double getTimerTypeUsagePercent(String timerType) {
    if (totalWorkouts == 0) return 0.0;
    final count = timerTypeStats[timerType] ?? 0;
    return (count / totalWorkouts) * 100;
  }
}
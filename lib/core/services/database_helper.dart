// lib/core/services/database_helper.dart
import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout_session.dart';

/// Помощник для работы с SQLite базой данных SportOn
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  // Singleton pattern
  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  /// Получить экземпляр базы данных
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Инициализация базы данных
  Future<Database> _initDatabase() async {
    // Получаем путь к папке с базами данных
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'sporton.db');

    // Открываем/создаем базу данных
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Создание таблиц при первом запуске
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        timer_type TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        total_duration INTEGER NOT NULL,
        status TEXT NOT NULL,
        workout_code TEXT,
        workout_title TEXT,
        link_type TEXT NOT NULL,
        user_notes TEXT,
        configuration TEXT NOT NULL,
        work_time INTEGER NOT NULL,
        rest_time INTEGER NOT NULL,
        pause_time INTEGER NOT NULL,
        rounds_completed INTEGER NOT NULL,
        classic_stats TEXT,
        created_at INTEGER NOT NULL,
        version INTEGER DEFAULT 1
      )
    ''');

    // Создаем индексы для быстрого поиска
    await db.execute('''
      CREATE INDEX idx_workout_sessions_timer_type ON workout_sessions(timer_type)
    ''');

    await db.execute('''
      CREATE INDEX idx_workout_sessions_workout_code ON workout_sessions(workout_code)
    ''');

    await db.execute('''
      CREATE INDEX idx_workout_sessions_created_at ON workout_sessions(created_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_workout_sessions_workout_key ON workout_sessions(workout_code, workout_title)
    ''');

    print('✅ SportOn database created successfully');
  }

  /// Обновление схемы базы данных при изменении версии
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from version $oldVersion to $newVersion');

    // Здесь будут миграции при обновлении схемы
    if (oldVersion < 2) {
      // Пример миграции для версии 2
      // await db.execute('ALTER TABLE workout_sessions ADD COLUMN new_field TEXT');
    }
  }

  /// Сохранить сессию тренировки
  Future<int> insertWorkoutSession(WorkoutSession session) async {
    final db = await database;

    try {
      print('🔍 Сохраняем сессию: ${session.id}');

      // Конвертируем в JSON для сохранения
      final sessionMap = session.toJson();
      print('🔍 JSON данные: $sessionMap');

      // Преобразуем сложные объекты в JSON строки
      sessionMap['configuration'] = jsonEncode(sessionMap['configuration']);
      if (sessionMap['classic_stats'] != null) {
        sessionMap['classic_stats'] = jsonEncode(sessionMap['classic_stats']);
      }

      final result = await db.insert(
        'workout_sessions',
        sessionMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Workout session saved with result: $result, ID: ${session.id}');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error saving workout session: $e');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Получить все сессии тренировок
  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    final db = await database;

    try {
      print('🔍 Загружаем все сессии из БД...');

      final List<Map<String, dynamic>> maps = await db.query(
        'workout_sessions',
        orderBy: 'created_at DESC',
      );

      print('🔍 Найдено записей в БД: ${maps.length}');

      if (maps.isNotEmpty) {
        print('🔍 Первая запись: ${maps.first}');
      }

      final sessions = maps.map((map) => _mapToWorkoutSession(map)).toList();
      print('🔍 Преобразовано в объекты: ${sessions.length}');

      return sessions;
    } catch (e, stackTrace) {
      print('❌ Error loading workout sessions: $e');
      print('❌ StackTrace: $stackTrace');
      return [];
    }
  }

  /// Получить сессии по типу таймера
  Future<List<WorkoutSession>> getWorkoutSessionsByType(String timerType) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'workout_sessions',
        where: 'timer_type = ?',
        whereArgs: [timerType],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToWorkoutSession(map)).toList();
    } catch (e) {
      print('❌ Error loading sessions by type: $e');
      return [];
    }
  }

  /// Получить сессии конкретной тренировки (по коду или названию)
  Future<List<WorkoutSession>> getWorkoutSessionsByKey(String workoutKey) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'workout_sessions',
        where: 'workout_code = ? OR workout_title = ?',
        whereArgs: [workoutKey, workoutKey],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToWorkoutSession(map)).toList();
    } catch (e) {
      print('❌ Error loading sessions by key: $e');
      return [];
    }
  }

  /// Получить сессию по ID
  Future<WorkoutSession?> getWorkoutSessionById(String id) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'workout_sessions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return _mapToWorkoutSession(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error loading session by ID: $e');
      return null;
    }
  }

  /// Обновить сессию тренировки
  Future<int> updateWorkoutSession(WorkoutSession session) async {
    final db = await database;

    try {
      final sessionMap = session.toJson();
      sessionMap['configuration'] = jsonEncode(sessionMap['configuration']);
      if (sessionMap['classic_stats'] != null) {
        sessionMap['classic_stats'] = jsonEncode(sessionMap['classic_stats']);
      }

      final result = await db.update(
        'workout_sessions',
        sessionMap,
        where: 'id = ?',
        whereArgs: [session.id],
      );

      print('✅ Workout session updated: ${session.id}');
      return result;
    } catch (e) {
      print('❌ Error updating workout session: $e');
      rethrow;
    }
  }

  /// Удалить сессию тренировки
  Future<int> deleteWorkoutSession(String id) async {
    final db = await database;

    try {
      final result = await db.delete(
        'workout_sessions',
        where: 'id = ?',
        whereArgs: [id],
      );

      print('✅ Workout session deleted: $id');
      return result;
    } catch (e) {
      print('❌ Error deleting workout session: $e');
      rethrow;
    }
  }

  /// Получить количество тренировок
  Future<int> getWorkoutSessionsCount() async {
    final db = await database;

    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM workout_sessions');
      final count = Sqflite.firstIntValue(result) ?? 0;
      print('🔍 Количество записей в БД: $count');
      return count;
    } catch (e) {
      print('❌ Error getting sessions count: $e');
      return 0;
    }
  }

  /// Получить общую статистику
  Future<Map<String, dynamic>> getOverallStats() async {
    final db = await database;

    try {
      // Общее количество тренировок
      final totalResult = await db.rawQuery('SELECT COUNT(*) as total FROM workout_sessions');
      final total = Sqflite.firstIntValue(totalResult) ?? 0;

      // Общее время тренировок
      final timeResult = await db.rawQuery('SELECT SUM(total_duration) as total_time FROM workout_sessions');
      final totalTime = Sqflite.firstIntValue(timeResult) ?? 0;

      // Количество по типам
      final typeResult = await db.rawQuery('''
        SELECT timer_type, COUNT(*) as count 
        FROM workout_sessions 
        GROUP BY timer_type
      ''');

      final typeStats = <String, int>{};
      for (final row in typeResult) {
        typeStats[row['timer_type'] as String] = row['count'] as int;
      }

      return {
        'totalSessions': total,
        'totalTimeMs': totalTime,
        'sessionsByType': typeStats,
      };
    } catch (e) {
      print('❌ Error getting overall stats: $e');
      return {
        'totalSessions': 0,
        'totalTimeMs': 0,
        'sessionsByType': <String, int>{},
      };
    }
  }

  /// Получить уникальные коды/названия тренировок для автодополнения
  Future<Map<String, String>> getWorkoutCodesMap() async {
    final db = await database;

    try {
      final result = await db.rawQuery('''
        SELECT DISTINCT workout_code, workout_title 
        FROM workout_sessions 
        WHERE workout_code IS NOT NULL AND workout_title IS NOT NULL
      ''');

      final codesMap = <String, String>{};
      for (final row in result) {
        final code = row['workout_code'] as String;
        final title = row['workout_title'] as String;
        codesMap[code.toUpperCase()] = title;
      }

      return codesMap;
    } catch (e) {
      print('❌ Error getting workout codes: $e');
      return {};
    }
  }

  /// Преобразовать Map из БД в WorkoutSession
  WorkoutSession _mapToWorkoutSession(Map<String, dynamic> map) {
    try {
      print('🔍 Преобразуем запись: ${map['id']}');

      // Создаем копию map для безопасного изменения
      final workingMap = Map<String, dynamic>.from(map);

      // Восстанавливаем JSON объекты
      final configurationJson = workingMap['configuration'] as String;
      try {
        workingMap['configuration'] = jsonDecode(configurationJson) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ Error decoding configuration: $e');
        workingMap['configuration'] = <String, dynamic>{};
      }

      // Обрабатываем classic_stats если есть
      final classicStatsJson = workingMap['classic_stats'] as String?;
      if (classicStatsJson != null && classicStatsJson.isNotEmpty && classicStatsJson != 'null') {
        try {
          workingMap['classic_stats'] = jsonDecode(classicStatsJson);
        } catch (e) {
          print('⚠️ Error decoding classic_stats: $e');
          workingMap['classic_stats'] = null;
        }
      } else {
        workingMap['classic_stats'] = null;
      }

      print('🔍 Создаем WorkoutSession: ${workingMap['id']}');
      final session = WorkoutSession.fromJson(workingMap);
      print('✅ WorkoutSession создан: ${session.displayName}');
      return session;
    } catch (e, stackTrace) {
      print('❌ Error mapping to WorkoutSession: $e');
      print('❌ Map data: $map');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Очистить все данные (для тестирования)
  Future<void> clearAllData() async {
    final db = await database;

    try {
      await db.delete('workout_sessions');
      print('✅ All workout data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// Закрыть базу данных
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      print('✅ Database closed');
    }
  }

  /// Получить информацию о базе данных (для отладки)
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;

    try {
      final version = await db.getVersion();
      final path = db.path;
      final isOpen = db.isOpen;

      return {
        'version': version,
        'path': path,
        'isOpen': isOpen,
        'tablesCount': 1, // Пока только одна таблица
      };
    } catch (e) {
      print('❌ Error getting database info: $e');
      return {};
    }
  }
}
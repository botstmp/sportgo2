// lib/debug/workout_debug_helper.dart
import 'package:uuid/uuid.dart';
import '../core/services/workout_history_service.dart';
import '../core/services/database_helper.dart';
import '../core/models/workout_session.dart';
import '../core/enums/timer_enums.dart';
import '../core/models/workout_enums.dart';

/// Диагностический помощник для отладки системы сохранения тренировок
class WorkoutDebugHelper {
  static final WorkoutHistoryService _historyService = WorkoutHistoryService();
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// 🔍 ПОЛНАЯ ДИАГНОСТИКА СИСТЕМЫ СОХРАНЕНИЯ
  static Future<void> fullDiagnostics() async {
    print('\n🔍========== ПОЛНАЯ ДИАГНОСТИКА НАЧАТА ==========');
    print('⏰ Время: ${DateTime.now()}');

    try {
      // 1. Проверка базы данных
      await _checkDatabase();

      // 2. Проверка сервиса
      await _checkService();

      // 3. Создание и сохранение тестовой тренировки
      await _testSaveWorkout();

      // 4. Проверка загрузки
      await _testLoadWorkouts();

      // 5. Проверка реальных провайдеров (если доступны)
      await _testWithMockProvider();

    } catch (e, stackTrace) {
      print('❌ КРИТИЧЕСКАЯ ОШИБКА ДИАГНОСТИКИ: $e');
      print('❌ StackTrace: $stackTrace');
    }

    print('🔍========== ДИАГНОСТИКА ЗАВЕРШЕНА ==========\n');
  }

  /// 📊 1. ПРОВЕРКА БАЗЫ ДАННЫХ
  static Future<void> _checkDatabase() async {
    print('\n📊 1. ПРОВЕРКА БАЗЫ ДАННЫХ:');
    print('├─ Подключение к БД...');

    try {
      // Информация о БД
      final dbInfo = await _databaseHelper.getDatabaseInfo();
      print('├─ ✅ DB Info: $dbInfo');

      // Проверка структуры таблицы
      final isStructureValid = await _databaseHelper.verifyTableStructure();
      print('├─ ✅ Table structure valid: $isStructureValid');

      // Количество записей
      final count = await _databaseHelper.getWorkoutSessionsCount();
      print('├─ ✅ Current record count: $count');

      // Образцы данных
      final samples = await _databaseHelper.getSampleData(limit: 2);
      print('└─ ✅ Sample records found: ${samples.length}');

      if (samples.isNotEmpty) {
        print('   📋 Sample data structure:');
        for (int i = 0; i < samples.length; i++) {
          final sample = samples[i];
          print('   Record ${i + 1}: ${sample.keys.take(5).join(', ')}...');
        }
      }

    } catch (e, stackTrace) {
      print('└─ ❌ Database check failed: $e');
      print('   StackTrace: $stackTrace');
    }
  }

  /// 🔧 2. ПРОВЕРКА СЕРВИСА
  static Future<void> _checkService() async {
    print('\n🔧 2. ПРОВЕРКА СЕРВИСА:');
    print('├─ Проверка состояния сервиса...');

    try {
      final serviceInfo = await _historyService.getServiceInfo();
      print('├─ ✅ Service info: $serviceInfo');

      final integrity = await _historyService.checkDatabaseIntegrity();
      print('└─ ✅ Database integrity: $integrity');

    } catch (e, stackTrace) {
      print('└─ ❌ Service check failed: $e');
      print('   StackTrace: $stackTrace');
    }
  }

  /// 💾 3. ТЕСТ СОХРАНЕНИЯ
  static Future<void> _testSaveWorkout() async {
    print('\n💾 3. ТЕСТ СОХРАНЕНИЯ ТРЕНИРОВКИ:');
    print('├─ Создание тестовой тренировки...');

    try {
      // Создаем тестовую тренировку вручную
      final testSession = _createTestSession();
      print('├─ ✅ Test session created:');
      print('│  ├─ ID: ${testSession.id}');
      print('│  ├─ Display name: ${testSession.displayName}');
      print('│  ├─ Timer type: ${testSession.timerType}');
      print('│  ├─ Status: ${testSession.status}');
      print('│  └─ Duration: ${testSession.formattedDuration}');

      // Проверяем toMap()
      print('├─ Проверка toMap()...');
      final sessionMap = testSession.toMap();
      print('│  ├─ Map keys: ${sessionMap.keys.toList()}');
      print('│  ├─ Configuration type: ${sessionMap['configuration'].runtimeType}');
      print('│  └─ Link type: ${sessionMap['link_type']}');

      // Пробуем сохранить
      print('├─ 💾 Attempting to save...');
      final countBefore = await _databaseHelper.getWorkoutSessionsCount();
      print('│  ├─ Records before save: $countBefore');

      final saveResult = await _historyService.saveWorkoutSession(testSession);
      print('│  ├─ ✅ Save result: $saveResult');

      if (saveResult) {
        // Проверяем что запись появилась
        final countAfter = await _databaseHelper.getWorkoutSessionsCount();
        print('│  ├─ Records after save: $countAfter');
        print('│  ├─ Records added: ${countAfter - countBefore}');

        // Пробуем найти нашу запись по ID
        final foundSession = await _historyService.getSessionById(testSession.id!);
        if (foundSession != null) {
          print('│  ├─ ✅ Session found by ID: ${foundSession.displayName}');
          print('│  └─ ✅ Round trip successful!');
        } else {
          print('│  └─ ❌ Session NOT found by ID after save');
        }
      } else {
        print('│  └─ ❌ Save returned false');
      }

    } catch (e, stackTrace) {
      print('└─ ❌ Save test failed: $e');
      print('   StackTrace: $stackTrace');
    }
  }

  /// 📖 4. ТЕСТ ЗАГРУЗКИ
  static Future<void> _testLoadWorkouts() async {
    print('\n📖 4. ТЕСТ ЗАГРУЗКИ ТРЕНИРОВОК:');
    print('├─ Загрузка всех тренировок...');

    try {
      // Загружаем все тренировки
      final allSessions = await _historyService.getAllSessions();
      print('├─ ✅ Loaded sessions count: ${allSessions.length}');

      if (allSessions.isNotEmpty) {
        print('├─ 📋 Session details:');
        for (int i = 0; i < allSessions.length && i < 3; i++) {
          final session = allSessions[i];
          print('│  Session ${i + 1}:');
          print('│  ├─ ID: ${session.id}');
          print('│  ├─ Name: ${session.displayName}');
          print('│  ├─ Type: ${session.timerType}');
          print('│  ├─ Duration: ${session.formattedDuration}');
          print('│  ├─ Status: ${session.status}');
          print('│  └─ Created: ${session.createdAt}');
        }

        if (allSessions.length > 3) {
          print('│  └─ ... and ${allSessions.length - 3} more sessions');
        }

        // Проверяем фильтрацию
        final completedSessions = await _historyService.getCompletedSessions();
        print('├─ ✅ Completed sessions: ${completedSessions.length}');

        final linkedSessions = await _historyService.getLinkedSessions();
        print('└─ ✅ Linked sessions: ${linkedSessions.length}');

      } else {
        print('└─ ⚠️ No sessions found in database');
      }

    } catch (e, stackTrace) {
      print('└─ ❌ Load test failed: $e');
      print('   StackTrace: $stackTrace');
    }
  }

  /// 🎯 5. ТЕСТ С MOCK ПРОВАЙДЕРОМ
  static Future<void> _testWithMockProvider() async {
    print('\n🎯 5. ТЕСТ С MOCK ПРОВАЙДЕРОМ:');
    print('├─ Создание mock провайдера...');

    try {
      final mockProvider = MockTimerProvider();

      // Создаем сессию как в реальном коде
      final sessionFromProvider = WorkoutSession.fromTimerProvider(
        mockProvider,
        workoutCode: 'MOCK',
        workoutTitle: 'Mock Workout',
        userNotes: 'Test from provider',
      );

      print('├─ ✅ Session from provider created:');
      print('│  ├─ ID: ${sessionFromProvider.id}');
      print('│  ├─ Name: ${sessionFromProvider.displayName}');
      print('│  └─ Type: ${sessionFromProvider.timerType}');

      // Сохраняем
      final saveResult = await _historyService.saveWorkoutSession(sessionFromProvider);
      print('└─ ✅ Save from provider result: $saveResult');

    } catch (e, stackTrace) {
      print('└─ ❌ Mock provider test failed: $e');
      print('   StackTrace: $stackTrace');
    }
  }

  /// Создание тестовой сессии
  static WorkoutSession _createTestSession() {
    final now = DateTime.now();
    final id = const Uuid().v4();

    return WorkoutSession(
      id: id,
      workoutCode: 'DEBUG',
      workoutTitle: 'Диагностическая тренировка',
      userNotes: 'Создано автоматически для отладки',
      timerType: TimerType.classic,
      status: WorkoutStatus.completed,
      startTime: now.subtract(const Duration(minutes: 30)),
      endTime: now,
      workTime: const Duration(minutes: 25),
      restTime: const Duration(minutes: 5),
      roundsCompleted: 5,
      configuration: {
        'workDuration': 300, // 5 минут
        'restDuration': 60,  // 1 минута
        'rounds': 5,
        'timerType': 'TimerType.classic',
      },
      version: 2,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 🧹 ОЧИСТКА ТЕСТОВЫХ ДАННЫХ
  static Future<void> clearTestData() async {
    print('\n🧹 ОЧИСТКА ТЕСТОВЫХ ДАННЫХ:');

    try {
      final sessions = await _historyService.getAllSessions();
      int deletedCount = 0;

      print('├─ Поиск тестовых записей...');
      for (final session in sessions) {
        if (session.workoutCode == 'DEBUG' ||
            session.workoutCode == 'TEST' ||
            session.workoutCode == 'MOCK' ||
            session.workoutTitle?.contains('тестовая') == true ||
            session.workoutTitle?.contains('диагностическая') == true) {

          print('│  ├─ Удаление: ${session.displayName}');
          final deleted = await _historyService.deleteWorkoutSession(session.id!);
          if (deleted) deletedCount++;
        }
      }

      print('└─ ✅ Deleted $deletedCount test sessions');

    } catch (e) {
      print('└─ ❌ Cleanup failed: $e');
    }
  }

  /// 🔄 ПРИНУДИТЕЛЬНАЯ ОЧИСТКА ВСЕЙ БД (ОСТОРОЖНО!)
  static Future<void> clearAllData() async {
    print('\n⚠️ ВНИМАНИЕ: ПОЛНАЯ ОЧИСТКА БАЗЫ ДАННЫХ');

    try {
      print('├─ Подтверждение очистки...');
      final countBefore = await _databaseHelper.getWorkoutSessionsCount();
      print('├─ Records before clear: $countBefore');

      final result = await _historyService.clearAllHistory();
      print('├─ Clear result: $result');

      final countAfter = await _databaseHelper.getWorkoutSessionsCount();
      print('└─ ✅ Records after clear: $countAfter');

    } catch (e) {
      print('└─ ❌ Clear all failed: $e');
    }
  }

  /// 📊 БЫСТРАЯ ПРОВЕРКА СОСТОЯНИЯ
  static Future<void> quickCheck() async {
    print('\n⚡ БЫСТРАЯ ПРОВЕРКА:');

    try {
      final count = await _databaseHelper.getWorkoutSessionsCount();
      final sessions = await _historyService.getAllSessions();

      print('├─ DB count: $count');
      print('├─ Service count: ${sessions.length}');
      print('└─ Status: ${count == sessions.length ? "✅ OK" : "❌ MISMATCH"}');

    } catch (e) {
      print('└─ ❌ Quick check failed: $e');
    }
  }
}

/// Mock провайдер для тестирования
class MockTimerProvider {
  TimerType get type => TimerType.classic;

  Map<String, dynamic> getWorkoutResults() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(minutes: 20));

    return {
      'isCompleted': true,
      'startTime': start.toIso8601String(),
      'endTime': now.toIso8601String(),
      'totalWorkTime': 900, // 15 минут
      'totalRestTime': 300, // 5 минут
      'completedRounds': 3,
      'workDuration': 300,
      'restDuration': 60,
      'rounds': 3,
      'lapStats': {
        'totalLaps': 3,
        'averageLapTime': 300.0,
        'fastestLap': 295,
        'consistency': 85.5,
        'lapDetails': [
          {'lapDuration': 300},
          {'lapDuration': 295},
          {'lapDuration': 305},
        ],
      },
    };
  }
}

// ===============================================
// ИНСТРУКЦИИ ПО ИСПОЛЬЗОВАНИЮ:
// ===============================================

/*
1. ДОБАВЬТЕ В PUBSPEC.YAML:
dependencies:
  uuid: ^4.0.0

2. СОЗДАЙТЕ ПАПКУ debug/ В lib/
mkdir lib/debug

3. СОХРАНИТЕ ЭТОТ ФАЙЛ КАК:
lib/debug/workout_debug_helper.dart

4. ДОБАВЬТЕ В ВАШ ЭКРАН ИСТОРИИ ТРЕНИРОВОК:

import '../debug/workout_debug_helper.dart';

// В виджете истории добавьте кнопки:
Row(
  children: [
    ElevatedButton(
      onPressed: () => WorkoutDebugHelper.fullDiagnostics(),
      child: Text('🔍 Полная диагностика'),
    ),
    SizedBox(width: 8),
    ElevatedButton(
      onPressed: () => WorkoutDebugHelper.quickCheck(),
      child: Text('⚡ Быстрая проверка'),
    ),
    SizedBox(width: 8),
    ElevatedButton(
      onPressed: () => WorkoutDebugHelper.clearTestData(),
      child: Text('🧹 Очистить тесты'),
    ),
  ],
)

5. ИЛИ ДОБАВЬТЕ В initState():
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    WorkoutDebugHelper.fullDiagnostics();
  });
}

6. ЗАПУСТИТЕ И СМОТРИТЕ ЛОГИ В КОНСОЛИ
*/
// lib/core/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для работы с локальным хранилищем SportOn
/// Обеспечивает сохранение и загрузку пользовательских настроек
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  // Singleton pattern
  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// Инициализация сервиса
  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Получить экземпляр SharedPreferences
  SharedPreferences get _prefs {
    if (_preferences == null) {
      throw Exception('StorageService не инициализирован. Вызовите StorageService.initialize() сначала.');
    }
    return _preferences!;
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ СО СТРОКАМИ ===

  /// Сохранить строку
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      print('Ошибка сохранения строки: $e');
      return false;
    }
  }

  /// Получить строку
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      print('Ошибка получения строки: $e');
      return null;
    }
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ С ЦЕЛЫМИ ЧИСЛАМИ ===

  /// Сохранить целое число
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      print('Ошибка сохранения числа: $e');
      return false;
    }
  }

  /// Получить целое число
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      print('Ошибка получения числа: $e');
      return null;
    }
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ С ЧИСЛАМИ С ПЛАВАЮЩЕЙ ТОЧКОЙ ===

  /// Сохранить число с плавающей точкой
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      print('Ошибка сохранения double: $e');
      return false;
    }
  }

  /// Получить число с плавающей точкой
  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      print('Ошибка получения double: $e');
      return null;
    }
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ С БУЛЕВЫМИ ЗНАЧЕНИЯМИ ===

  /// Сохранить булево значение
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      print('Ошибка сохранения bool: $e');
      return false;
    }
  }

  /// Получить булево значение
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      print('Ошибка получения bool: $e');
      return null;
    }
  }

  /// Получить булево значение с значением по умолчанию
  bool getBoolWithDefault(String key, bool defaultValue) {
    return getBool(key) ?? defaultValue;
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ СО СПИСКАМИ СТРОК ===

  /// Сохранить список строк
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      print('Ошибка сохранения списка строк: $e');
      return false;
    }
  }

  /// Получить список строк
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      print('Ошибка получения списка строк: $e');
      return null;
    }
  }

  // === УНИВЕРСАЛЬНЫЕ МЕТОДЫ ===

  /// Проверить существование ключа
  bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      print('Ошибка проверки ключа: $e');
      return false;
    }
  }

  /// Удалить значение по ключу
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      print('Ошибка удаления ключа: $e');
      return false;
    }
  }

  /// Очистить все данные
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      print('Ошибка очистки хранилища: $e');
      return false;
    }
  }

  /// Получить все ключи
  Set<String> getKeys() {
    try {
      return _prefs.getKeys();
    } catch (e) {
      print('Ошибка получения ключей: $e');
      return <String>{};
    }
  }

  /// Перезагрузить данные из хранилища
  Future<void> reload() async {
    try {
      await _prefs.reload();
    } catch (e) {
      print('Ошибка перезагрузки хранилища: $e');
    }
  }

  // === СПЕЦИАЛЬНЫЕ МЕТОДЫ ДЛЯ ПРИЛОЖЕНИЯ ===

  /// Сохранить настройки пользователя
  Future<bool> saveUserSettings(Map<String, dynamic> settings) async {
    try {
      bool allSaved = true;

      for (String key in settings.keys) {
        final value = settings[key];

        if (value is String) {
          allSaved &= await setString(key, value);
        } else if (value is int) {
          allSaved &= await setInt(key, value);
        } else if (value is double) {
          allSaved &= await setDouble(key, value);
        } else if (value is bool) {
          allSaved &= await setBool(key, value);
        } else if (value is List<String>) {
          allSaved &= await setStringList(key, value);
        }
      }

      return allSaved;
    } catch (e) {
      print('Ошибка сохранения настроек пользователя: $e');
      return false;
    }
  }

  /// Получить все настройки пользователя
  Map<String, dynamic> getUserSettings() {
    try {
      final Map<String, dynamic> settings = {};
      final keys = getKeys();

      for (String key in keys) {
        // Пытаемся получить значение в разных типах
        final stringValue = getString(key);
        final intValue = getInt(key);
        final doubleValue = getDouble(key);
        final boolValue = getBool(key);
        final listValue = getStringList(key);

        if (stringValue != null) {
          settings[key] = stringValue;
        } else if (intValue != null) {
          settings[key] = intValue;
        } else if (doubleValue != null) {
          settings[key] = doubleValue;
        } else if (boolValue != null) {
          settings[key] = boolValue;
        } else if (listValue != null) {
          settings[key] = listValue;
        }
      }

      return settings;
    } catch (e) {
      print('Ошибка получения настроек пользователя: $e');
      return {};
    }
  }

  // === СПЕЦИАЛИЗИРОВАННЫЕ МЕТОДЫ ДЛЯ SPORTON ===

  /// Сохранить настройки темы
  Future<bool> saveThemeSettings(int themeIndex) async {
    try {
      return await setInt('theme_index', themeIndex);
    } catch (e) {
      print('Ошибка сохранения настроек темы: $e');
      return false;
    }
  }

  /// Получить настройки темы
  int? getThemeSettings() {
    try {
      return getInt('theme_index');
    } catch (e) {
      print('Ошибка получения настроек темы: $e');
      return null;
    }
  }

  /// Сохранить настройки языка
  Future<bool> saveLanguageSettings(String languageCode) async {
    try {
      return await setString('language_code', languageCode);
    } catch (e) {
      print('Ошибка сохранения настроек языка: $e');
      return false;
    }
  }

  /// Получить настройки языка
  String? getLanguageSettings() {
    try {
      return getString('language_code');
    } catch (e) {
      print('Ошибка получения настроек языка: $e');
      return null;
    }
  }

  /// Сохранить настройки тренировки
  Future<bool> saveWorkoutSettings(Map<String, dynamic> settings) async {
    try {
      bool allSaved = true;

      for (String key in settings.keys) {
        final value = settings[key];
        String workoutKey = 'workout_$key';

        if (value is String) {
          allSaved &= await setString(workoutKey, value);
        } else if (value is int) {
          allSaved &= await setInt(workoutKey, value);
        } else if (value is double) {
          allSaved &= await setDouble(workoutKey, value);
        } else if (value is bool) {
          allSaved &= await setBool(workoutKey, value);
        }
      }

      return allSaved;
    } catch (e) {
      print('Ошибка сохранения настроек тренировки: $e');
      return false;
    }
  }

  /// Получить настройки тренировки
  Map<String, dynamic> getWorkoutSettings() {
    try {
      final Map<String, dynamic> workoutSettings = {};
      final keys = getKeys();

      for (String key in keys) {
        if (key.startsWith('workout_')) {
          String settingKey = key.substring(8); // Убираем 'workout_'

          final stringValue = getString(key);
          final intValue = getInt(key);
          final doubleValue = getDouble(key);
          final boolValue = getBool(key);

          if (stringValue != null) {
            workoutSettings[settingKey] = stringValue;
          } else if (intValue != null) {
            workoutSettings[settingKey] = intValue;
          } else if (doubleValue != null) {
            workoutSettings[settingKey] = doubleValue;
          } else if (boolValue != null) {
            workoutSettings[settingKey] = boolValue;
          }
        }
      }

      return workoutSettings;
    } catch (e) {
      print('Ошибка получения настроек тренировки: $e');
      return {};
    }
  }

  /// Сохранить результат тренировки
  Future<bool> saveWorkoutResult(String workoutId, Map<String, dynamic> result) async {
    try {
      bool allSaved = true;

      for (String key in result.keys) {
        final value = result[key];
        String resultKey = 'result_${workoutId}_$key';

        if (value is String) {
          allSaved &= await setString(resultKey, value);
        } else if (value is int) {
          allSaved &= await setInt(resultKey, value);
        } else if (value is double) {
          allSaved &= await setDouble(resultKey, value);
        } else if (value is bool) {
          allSaved &= await setBool(resultKey, value);
        }
      }

      // Сохраняем ID тренировки в список
      List<String> workoutIds = getStringList('workout_ids') ?? [];
      if (!workoutIds.contains(workoutId)) {
        workoutIds.add(workoutId);
        allSaved &= await setStringList('workout_ids', workoutIds);
      }

      return allSaved;
    } catch (e) {
      print('Ошибка сохранения результата тренировки: $e');
      return false;
    }
  }

  /// Получить результаты всех тренировок
  List<Map<String, dynamic>> getAllWorkoutResults() {
    try {
      List<String> workoutIds = getStringList('workout_ids') ?? [];
      List<Map<String, dynamic>> results = [];

      for (String workoutId in workoutIds) {
        Map<String, dynamic> workoutResult = {'id': workoutId};
        final keys = getKeys();

        for (String key in keys) {
          if (key.startsWith('result_${workoutId}_')) {
            String resultKey = key.substring('result_${workoutId}_'.length);

            final stringValue = getString(key);
            final intValue = getInt(key);
            final doubleValue = getDouble(key);
            final boolValue = getBool(key);

            if (stringValue != null) {
              workoutResult[resultKey] = stringValue;
            } else if (intValue != null) {
              workoutResult[resultKey] = intValue;
            } else if (doubleValue != null) {
              workoutResult[resultKey] = doubleValue;
            } else if (boolValue != null) {
              workoutResult[resultKey] = boolValue;
            }
          }
        }

        if (workoutResult.length > 1) { // Больше чем просто ID
          results.add(workoutResult);
        }
      }

      return results;
    } catch (e) {
      print('Ошибка получения результатов тренировок: $e');
      return [];
    }
  }

  /// Удалить результат тренировки
  Future<bool> removeWorkoutResult(String workoutId) async {
    try {
      bool allRemoved = true;
      final keys = getKeys();

      // Удаляем все ключи связанные с тренировкой
      for (String key in keys) {
        if (key.startsWith('result_${workoutId}_')) {
          allRemoved &= await remove(key);
        }
      }

      // Удаляем ID из списка
      List<String> workoutIds = getStringList('workout_ids') ?? [];
      workoutIds.remove(workoutId);
      allRemoved &= await setStringList('workout_ids', workoutIds);

      return allRemoved;
    } catch (e) {
      print('Ошибка удаления результата тренировки: $e');
      return false;
    }
  }

  // === МЕТОДЫ ДЛЯ ОТЛАДКИ ===

  /// Вывести все данные в консоль (для отладки)
  void debugPrintAll() {
    try {
      final keys = getKeys();
      print('=== StorageService Debug ===');
      print('Всего ключей: ${keys.length}');

      for (String key in keys) {
        final value = getString(key) ??
            getInt(key)?.toString() ??
            getDouble(key)?.toString() ??
            getBool(key)?.toString() ??
            getStringList(key)?.toString() ??
            'unknown';
        print('$key: $value');
      }
      print('===========================');
    } catch (e) {
      print('Ошибка отладочного вывода: $e');
    }
  }

  /// Получить статистику хранилища
  Map<String, dynamic> getStorageStats() {
    try {
      final keys = getKeys();
      int stringCount = 0;
      int intCount = 0;
      int doubleCount = 0;
      int boolCount = 0;
      int listCount = 0;

      for (String key in keys) {
        if (getString(key) != null) stringCount++;
        else if (getInt(key) != null) intCount++;
        else if (getDouble(key) != null) doubleCount++;
        else if (getBool(key) != null) boolCount++;
        else if (getStringList(key) != null) listCount++;
      }

      return {
        'totalKeys': keys.length,
        'stringValues': stringCount,
        'intValues': intCount,
        'doubleValues': doubleCount,
        'boolValues': boolCount,
        'listValues': listCount,
      };
    } catch (e) {
      print('Ошибка получения статистики: $e');
      return {};
    }
  }
}
// lib/core/providers/timer_provider.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/ui_config.dart';
import '../enums/timer_enums.dart';
import '../../l10n/generated/app_localizations.dart';
// ДОБАВЛЕННЫЕ ИМПОРТЫ:
import '../models/workout_session.dart';
import '../services/workout_history_service.dart';

/// Класс для хранения данных об отсечке времени
class LapTime {
  final int lapNumber;
  final int time; // Время с начала тренировки в секундах
  final String formattedTime;
  final DateTime timestamp;
  final int lapDuration; // ДОБАВЛЕНО: Продолжительность конкретного раунда

  LapTime({
    required this.lapNumber,
    required this.time,
    required this.formattedTime,
    required this.timestamp,
    required this.lapDuration,
  });

  // Форматированная продолжительность раунда
  String get formattedLapDuration {
    final minutes = lapDuration ~/ 60;
    final seconds = lapDuration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'lapNumber': lapNumber,
      'time': time,
      'formattedTime': formattedTime,
      'timestamp': timestamp.toIso8601String(),
      'lapDuration': lapDuration,
    };
  }

  factory LapTime.fromMap(Map<String, dynamic> map) {
    return LapTime(
      lapNumber: map['lapNumber'],
      time: map['time'],
      formattedTime: map['formattedTime'],
      timestamp: DateTime.parse(map['timestamp']),
      lapDuration: map['lapDuration'] ?? 0,
    );
  }
}

/// Провайдер для управления таймерами SportOn
class TimerProvider with ChangeNotifier {
  // === ПРИВАТНЫЕ ПОЛЯ ===
  Timer? _timer;
  TimerState _state = TimerState.stopped;
  TimerType _type = TimerType.classic;
  AppLocalizations? _localizations;

  // ДОБАВЛЕННЫЕ ПОЛЯ ДЛЯ ИСТОРИИ:
  final WorkoutHistoryService _historyService = WorkoutHistoryService();

  // Данные для привязки к тренировке (опционально)
  String? _linkedWorkoutCode;
  String? _linkedWorkoutTitle;
  String? _userNotes;

  // Настройки таймера
  int _workDuration = 60;     // Время работы в секундах
  int _restDuration = 30;     // Время отдыха в секундах
  int _rounds = 1;            // Количество раундов
  int _currentRound = 1;      // Текущий раунд

  // Текущее состояние
  int _currentTime = 0;       // Текущее время в секундах
  int _totalTime = 0;         // Общее время для текущего периода

  // Статистика тренировки
  DateTime? _startTime;       // Время начала тренировки
  DateTime? _endTime;         // Время окончания тренировки
  int _totalWorkTime = 0;     // Общее время работы
  int _totalRestTime = 0;     // Общее время отдыха

  // Отсечки времени для классического таймера
  List<LapTime> _lapTimes = []; // Промежуточные результаты

  // Переменная для отслеживания состояния до паузы
  TimerState? _stateBeforePause;

  // === ГЕТТЕРЫ ===

  /// Текущее состояние таймера
  TimerState get state => _state;

  /// Тип таймера
  TimerType get type => _type;

  /// Время работы в секундах
  int get workDuration => _workDuration;

  /// Время отдыха в секундах
  int get restDuration => _restDuration;

  /// Количество раундов
  int get rounds => _rounds;

  /// Текущий раунд
  int get currentRound => _currentRound;

  /// Текущее время в секундах
  int get currentTime => _currentTime;

  /// Общее время для текущего периода
  int get totalTime => _totalTime;

  /// Прогресс текущего периода (0.0 - 1.0)
  double get progress {
    if (_type == TimerType.classic && _state == TimerState.working) {
      // Для секундомера прогресс циклический каждую минуту
      return (_currentTime % 60) / 60.0;
    }

    // Для всех остальных случаев (включая подготовку) - обратный отсчет
    if (_totalTime <= 0) return 0.0;

    // Прогресс от 1.0 (полный круг) до 0.0 (пустой)
    return (_totalTime - _currentTime) / _totalTime;
  }

  /// Прогресс всей тренировки (0.0 - 1.0)
  double get totalProgress {
    if (_type == TimerType.classic) {
      // Для секундомера показываем прогресс времени в часе
      return (_currentTime % 3600) / 3600.0;
    }

    if (_rounds == 0) return 0.0;

    double roundProgress = (_currentRound - 1) / _rounds;
    double currentRoundProgress = 0.0;

    if (_state == TimerState.working) {
      currentRoundProgress = progress / (_rounds * 2); // Работа и отдых
    } else if (_state == TimerState.resting) {
      currentRoundProgress = (1 + progress) / (_rounds * 2);
    }

    return (roundProgress + currentRoundProgress).clamp(0.0, 1.0);
  }

  /// Время начала тренировки
  DateTime? get startTime => _startTime;

  /// Время окончания тренировки
  DateTime? get endTime => _endTime;

  /// Общее время работы
  int get totalWorkTime => _totalWorkTime;

  /// Общее время отдыха
  int get totalRestTime => _totalRestTime;

  /// Список отсечек времени
  List<LapTime> get lapTimes => List.unmodifiable(_lapTimes);

  /// Общая продолжительность тренировки
  Duration? get totalDuration {
    if (_startTime == null) return null;
    final endTime = _endTime ?? DateTime.now();
    return endTime.difference(_startTime!);
  }

  /// Форматированное время (MM:SS)
  String get formattedTime {
    final minutes = _currentTime ~/ 60;
    final seconds = _currentTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Название текущего периода
  String getCurrentPeriodName(AppLocalizations l10n) {
    switch (_state) {
      case TimerState.preparation:
        return l10n.preparation;
      case TimerState.working:
        return l10n.work;
      case TimerState.resting:
        return l10n.rest;
      case TimerState.paused:
        return l10n.paused;
      case TimerState.finished:
        return l10n.finished;
      default:
        return l10n.stopped;
    }
  }

  /// Получить название типа таймера
  String getTimerTypeName(AppLocalizations l10n) {
    switch (_type) {
      case TimerType.classic:
        return l10n.stopwatchTitle;
      case TimerType.interval1:
        return l10n.interval1Title;
      case TimerType.interval2:
        return l10n.interval2Title;
      case TimerType.intensive:
        return l10n.intensiveTitle;
      case TimerType.norest:
        return l10n.noRestTitle;
      case TimerType.countdown:
        return l10n.countdownTitle;
    }
  }

  /// Получить описание типа таймера
  String getTimerTypeDescription(AppLocalizations l10n) {
    switch (_type) {
      case TimerType.classic:
        return l10n.stopwatchDescription;
      case TimerType.interval1:
        return l10n.interval1Description;
      case TimerType.interval2:
        return l10n.interval2Description;
      case TimerType.intensive:
        return l10n.intensiveDescription;
      case TimerType.norest:
        return l10n.noRestDescription;
      case TimerType.countdown:
        return l10n.countdownDescription;
    }
  }

  /// Проверка, запущен ли таймер
  bool get isRunning => _state == TimerState.working || _state == TimerState.resting || _state == TimerState.preparation;

  /// Проверка, на паузе ли таймер
  bool get isPaused => _state == TimerState.paused;

  /// Проверка, завершен ли таймер
  bool get isFinished => _state == TimerState.finished;

  // === МЕТОДЫ ДЛЯ ПРИВЯЗКИ К ТРЕНИРОВКЕ ===

  /// Установить привязку к тренировке
  void setWorkoutLink({
    String? workoutCode,
    String? workoutTitle,
    String? userNotes,
  }) {
    if (_state == TimerState.stopped) {
      _linkedWorkoutCode = workoutCode;
      _linkedWorkoutTitle = workoutTitle;
      _userNotes = userNotes;
      print('🏷 TimerProvider: Workout linked - Code: $workoutCode, Title: $workoutTitle');
      notifyListeners();
    }
  }

  /// Очистить привязку к тренировке
  void clearWorkoutLink() {
    _linkedWorkoutCode = null;
    _linkedWorkoutTitle = null;
    _userNotes = null;
    print('🏷 TimerProvider: Workout link cleared');
    notifyListeners();
  }

  /// Получить информацию о привязанной тренировке
  Map<String, String?> getWorkoutLinkInfo() {
    return {
      'workoutCode': _linkedWorkoutCode,
      'workoutTitle': _linkedWorkoutTitle,
      'userNotes': _userNotes,
    };
  }

  /// Проверить есть ли привязка к тренировке
  bool get hasWorkoutLink => _linkedWorkoutCode != null || _linkedWorkoutTitle != null;

  /// Получить отображаемое название привязанной тренировки
  String? get linkedWorkoutDisplayName {
    if (_linkedWorkoutCode != null && _linkedWorkoutTitle != null) {
      return '$_linkedWorkoutCode "$_linkedWorkoutTitle"';
    } else if (_linkedWorkoutCode != null) {
      return _linkedWorkoutCode;
    } else if (_linkedWorkoutTitle != null) {
      return _linkedWorkoutTitle;
    }
    return null;
  }

  // === МЕТОДЫ НАСТРОЙКИ ===

  /// Установить локализацию
  void setLocalizations(AppLocalizations localizations) {
    _localizations = localizations;
    notifyListeners();
  }

  /// Установить тип таймера
  void setTimerType(TimerType type) {
    if (_state == TimerState.stopped) {
      _type = type;
      _applyTimerTypeDefaults();
      notifyListeners();
    }
  }

  /// Установить время работы
  void setWorkDuration(int seconds) {
    if (_state == TimerState.stopped && seconds > 0) {
      _workDuration = seconds;
      notifyListeners();
    }
  }

  /// Установить время отдыха
  void setRestDuration(int seconds) {
    if (_state == TimerState.stopped && seconds >= 0) {
      _restDuration = seconds;
      notifyListeners();
    }
  }

  /// Установить количество раундов
  void setRounds(int rounds) {
    if (_state == TimerState.stopped && rounds > 0) {
      _rounds = rounds;
      notifyListeners();
    }
  }

  /// Применить настройки по умолчанию для типа таймера
  void _applyTimerTypeDefaults() {
    switch (_type) {
      case TimerType.classic:
        _workDuration = 0;      // Для секундомера время не ограничено
        _restDuration = 0;      // Без отдыха
        _rounds = 1;            // Один "раунд"
        break;
      case TimerType.interval1:
        _workDuration = 45;
        _restDuration = 15;
        _rounds = 8;
        break;
      case TimerType.interval2:
        _workDuration = 30;
        _restDuration = 30;
        _rounds = 6;
        break;
      case TimerType.intensive:
        _workDuration = 20;
        _restDuration = 10;
        _rounds = 12;
        break;
      case TimerType.norest:
        _workDuration = 300;
        _restDuration = 0;
        _rounds = 1;
        break;
      case TimerType.countdown:
        _workDuration = 300;
        _restDuration = 0;
        _rounds = 1;
        break;
    }
  }

  // === МЕТОДЫ УПРАВЛЕНИЯ ===

  /// Запустить таймер
  void start() {
    if (_state == TimerState.stopped) {
      _startTime = DateTime.now();
      _totalWorkTime = 0;
      _totalRestTime = 0;
      _currentRound = 1;
      _lapTimes.clear(); // Очищаем предыдущие отсечки

      // Всегда начинаем с подготовки
      _startPreparation();
    } else if (_state == TimerState.paused) {
      _resume();
    }
  }

  /// Запустить подготовительный период
  void _startPreparation() {
    _state = TimerState.preparation;
    _currentTime = UIConfig.preparationDuration;
    _totalTime = UIConfig.preparationDuration;
    _startTimer();
    notifyListeners();
  }

  /// Запустить рабочий период
  void _startWorking() {
    _state = TimerState.working;

    if (_type == TimerType.classic) {
      // Для классического таймера (секундомер) - считаем вперед
      _currentTime = 0;
      _totalTime = 0; // Бесконечный отсчет
    } else {
      // Для интервальных таймеров - обратный отсчет
      _currentTime = _workDuration;
      _totalTime = _workDuration;
    }

    _startTimer();
    notifyListeners();
  }

  /// Запустить период отдыха
  void _startResting() {
    if (_restDuration > 0) {
      _state = TimerState.resting;
      _currentTime = _restDuration;
      _totalTime = _restDuration;
      _startTimer();
    } else {
      _nextRound();
    }
    notifyListeners();
  }

  /// Запустить системный таймер
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  /// Тик таймера
  void _tick() {
    if (_type == TimerType.classic && _state == TimerState.working) {
      // Для классического таймера - считаем вперед
      _currentTime++;
      _totalWorkTime++;
      notifyListeners();
    } else {
      // Для интервальных таймеров И подготовки - обратный отсчет
      if (_currentTime > 0) {
        _currentTime--;

        // Обновляем статистику
        if (_state == TimerState.working) {
          _totalWorkTime++;
        } else if (_state == TimerState.resting) {
          _totalRestTime++;
        }

        notifyListeners();
      } else {
        _onPeriodComplete();
      }
    }
  }

  /// Обработка завершения периода
  void _onPeriodComplete() {
    switch (_state) {
      case TimerState.preparation:
        _startWorking();
        break;
      case TimerState.working:
        if (_restDuration > 0) {
          _startResting();
        } else {
          _nextRound();
        }
        break;
      case TimerState.resting:
        _nextRound();
        break;
      default:
        break;
    }
  }

  /// Переход к следующему раунду
  void _nextRound() {
    if (_currentRound < _rounds) {
      _currentRound++;
      _startWorking();
    } else {
      _finish();
    }
  }

  /// Поставить на паузу
  void pause() {
    if (isRunning) {
      _timer?.cancel();
      _stateBeforePause = _state;
      _state = TimerState.paused;
      notifyListeners();
    }
  }

  /// Возобновить
  void _resume() {
    if (_state == TimerState.paused) {
      if (_stateBeforePause != null) {
        _state = _stateBeforePause!;
        _stateBeforePause = null;
      } else {
        _state = _currentTime > 0 ? TimerState.working : TimerState.resting;
      }

      _startTimer();
      notifyListeners();
    }
  }

  /// Остановить таймер
  void stop() {
    _timer?.cancel();
    _state = TimerState.stopped;
    _currentTime = 0;
    _totalTime = 0;
    _currentRound = 1;
    _endTime = null;
    _stateBeforePause = null;
    notifyListeners();
  }

  /// Завершить тренировку
  void _finish() {
    _timer?.cancel();
    _state = TimerState.finished;
    _endTime = DateTime.now();
    _currentTime = 0;
    _stateBeforePause = null;

    // Автоматическое сохранение
    _saveWorkoutSession();

    notifyListeners();
  }

  /// Автоматическое сохранение завершенной тренировки
  Future<void> _saveWorkoutSession() async {
    try {
      // Создаем сессию из текущего состояния
      final session = WorkoutSession.fromTimerProvider(
        this,
        workoutCode: _linkedWorkoutCode,
        workoutTitle: _linkedWorkoutTitle,
        userNotes: _userNotes,
      );

      // Сохраняем в историю
      final success = await _historyService.saveWorkoutSession(session);

      if (success) {
        print('✅ TimerProvider: Workout session auto-saved - ${session.displayName}');

        // Проверяем на рекорд (только для привязанных тренировок)
        if (session.isLinkedWorkout) {
          final recordResult = await _historyService.checkForRecord(session);
          if (recordResult.isRecord) {
            print('🏆 TimerProvider: NEW RECORD! ${recordResult.message}');
          } else if (recordResult.isFirstAttempt) {
            print('🎯 TimerProvider: First attempt for this workout!');
          }
        }
      } else {
        print('❌ TimerProvider: Failed to auto-save workout session');
      }
    } catch (e) {
      print('❌ TimerProvider: Error during auto-save - $e');
    }
  }

  /// Сбросить таймер
  void reset() {
    stop();
    _startTime = null;
    _endTime = null;
    _totalWorkTime = 0;
    _totalRestTime = 0;
    _lapTimes.clear();

    // Очистка привязки
    clearWorkoutLink();

    notifyListeners();
  }

  /// Добавить отсечку времени (для классического таймера)
  void addLapTime() {
    if (_type == TimerType.classic && _state == TimerState.working) {
      // ИСПРАВЛЕНО: Правильно вычисляем продолжительность раунда
      final lapDuration = _lapTimes.isEmpty
          ? _currentTime  // Первый раунд - от начала
          : _currentTime - _lapTimes.last.time; // Последующие - разница

      final lapTime = LapTime(
        lapNumber: _lapTimes.length + 1,
        time: _currentTime,
        formattedTime: formattedTime,
        timestamp: DateTime.now(),
        lapDuration: lapDuration,
      );

      _lapTimes.add(lapTime);
      print('🏃 TimerProvider: Lap ${lapTime.lapNumber} added - Duration: ${lapTime.formattedLapDuration}, Total: ${lapTime.formattedTime}');
      notifyListeners();
    }
  }

  /// Получить статистику раундов для классического таймера
  Map<String, dynamic> getLapStats() {
    if (_lapTimes.isEmpty) {
      return {
        'totalLaps': 0,
        'averageLapTime': 0,
        'fastestLap': 0,
        'slowestLap': 0,
        'consistency': 0.0,
      };
    }

    final lapDurations = _lapTimes.map((lap) => lap.lapDuration).toList();
    final total = lapDurations.reduce((a, b) => a + b);
    final average = total / lapDurations.length;
    final fastest = lapDurations.reduce((a, b) => a < b ? a : b);
    final slowest = lapDurations.reduce((a, b) => a > b ? a : b);

    // Вычисляем стабильность (коэффициент вариации)
    final variance = lapDurations
        .map((duration) => (duration - average) * (duration - average))
        .reduce((a, b) => a + b) / lapDurations.length;
    final standardDeviation = variance > 0 ? math.sqrt(variance) : 0;
    final consistency = average > 0 ? (1 - (standardDeviation / average)) * 100 : 0;

    return {
      'totalLaps': _lapTimes.length,
      'averageLapTime': average,
      'fastestLap': fastest,
      'slowestLap': slowest,
      'consistency': consistency.clamp(0.0, 100.0),
      'lapDetails': _lapTimes.map((lap) => lap.toMap()).toList(),
    };
  }

  /// Получить результаты тренировки
  Map<String, dynamic> getWorkoutResults() {
    final baseResults = {
      'type': _type.toString(),
      'workDuration': _workDuration,
      'restDuration': _restDuration,
      'rounds': _rounds,
      'completedRounds': _currentRound,
      'totalWorkTime': _totalWorkTime,
      'totalRestTime': _totalRestTime,
      'startTime': _startTime?.toIso8601String(),
      'endTime': _endTime?.toIso8601String(),
      'totalDuration': totalDuration?.inSeconds,
      'isCompleted': _state == TimerState.finished,
      // Информация о привязке
      'linkedWorkoutCode': _linkedWorkoutCode,
      'linkedWorkoutTitle': _linkedWorkoutTitle,
      'userNotes': _userNotes,
      'hasWorkoutLink': hasWorkoutLink,
    };

    // Детальная статистика для классического таймера
    if (_type == TimerType.classic) {
      final lapStats = getLapStats();
      baseResults['lapStats'] = lapStats;
      baseResults['lapTimes'] = _lapTimes.map((lap) => lap.toMap()).toList();
    } else {
      baseResults['lapTimes'] = _lapTimes.map((lap) => lap.time).toList();
    }

    return baseResults;
  }

  /// Получить настройки таймера
  Map<String, dynamic> getTimerSettings() {
    return {
      'type': _type.toString(),
      'workDuration': _workDuration,
      'restDuration': _restDuration,
      'rounds': _rounds,
    };
  }

  // === ОСВОБОЖДЕНИЕ РЕСУРСОВ ===

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
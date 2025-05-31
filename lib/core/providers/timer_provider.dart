// lib/core/providers/timer_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/ui_config.dart';

/// Состояния таймера
enum TimerState {
  stopped,     // Остановлен
  preparation, // Подготовка (обратный отсчет)
  working,     // Рабочий период
  resting,     // Период отдыха
  paused,      // Пауза
  finished,    // Завершен
}

/// Типы таймеров
enum TimerType {
  classic,     // Классический таймер
  interval1,   // Интервальный 1
  interval2,   // Интервальный 2
  intensive,   // Интенсивный
  norest,      // Без отдыха
  countdown,   // Обратный отсчет
}

/// Провайдер для управления таймерами SportOn
class TimerProvider with ChangeNotifier {
  // === ПРИВАТНЫЕ ПОЛЯ ===
  Timer? _timer;
  TimerState _state = TimerState.stopped;
  TimerType _type = TimerType.classic;

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
  double get progress => _totalTime > 0 ? (_totalTime - _currentTime) / _totalTime : 0.0;

  /// Прогресс всей тренировки (0.0 - 1.0)
  double get totalProgress {
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
  String get currentPeriodName {
    switch (_state) {
      case TimerState.preparation:
        return 'Подготовка';
      case TimerState.working:
        return 'Работа';
      case TimerState.resting:
        return 'Отдых';
      case TimerState.paused:
        return 'Пауза';
      case TimerState.finished:
        return 'Завершено';
      default:
        return 'Остановлен';
    }
  }

  /// Проверка, запущен ли таймер
  bool get isRunning => _state == TimerState.working || _state == TimerState.resting || _state == TimerState.preparation;

  /// Проверка, на паузе ли таймер
  bool get isPaused => _state == TimerState.paused;

  /// Проверка, завершен ли таймер
  bool get isFinished => _state == TimerState.finished;

  // === МЕТОДЫ НАСТРОЙКИ ===

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
        _workDuration = 60;
        _restDuration = 30;
        _rounds = 1;
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
    _currentTime = _workDuration;
    _totalTime = _workDuration;
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
      _state = TimerState.paused;
      notifyListeners();
    }
  }

  /// Возобновить
  void _resume() {
    if (_state == TimerState.paused) {
      _state = _currentTime > 0 ? TimerState.working : TimerState.resting;
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
    notifyListeners();
  }

  /// Завершить тренировку
  void _finish() {
    _timer?.cancel();
    _state = TimerState.finished;
    _endTime = DateTime.now();
    _currentTime = 0;
    notifyListeners();
  }

  /// Сбросить таймер
  void reset() {
    stop();
    _startTime = null;
    _endTime = null;
    _totalWorkTime = 0;
    _totalRestTime = 0;
    notifyListeners();
  }

  // === МЕТОДЫ ДАННЫХ ===

  /// Получить результаты тренировки
  Map<String, dynamic> getWorkoutResults() {
    return {
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
    };
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
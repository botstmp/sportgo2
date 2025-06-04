// lib/core/providers/timer_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/ui_config.dart';
import '../enums/timer_enums.dart';
import '../../l10n/generated/app_localizations.dart';

/// Провайдер для управления таймерами SportOn
class TimerProvider with ChangeNotifier {
  // === ПРИВАТНЫЕ ПОЛЯ ===
  Timer? _timer;
  TimerState _state = TimerState.stopped;
  TimerType _type = TimerType.classic;
  AppLocalizations? _localizations;

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

  // ДОБАВЛЕНО: Переменная для отслеживания состояния до паузы
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
      // ДОБАВЛЕНО: Запоминаем состояние до паузы
      _stateBeforePause = _state;
      _state = TimerState.paused;
      notifyListeners();
    }
  }

  /// ИСПРАВЛЕННЫЙ МЕТОД: Возобновить
  void _resume() {
    if (_state == TimerState.paused) {
      // ИСПРАВЛЕНО: Восстанавливаем состояние, которое было до паузы
      if (_stateBeforePause != null) {
        _state = _stateBeforePause!;
        _stateBeforePause = null; // Очищаем после использования
      } else {
        // Fallback на старую логику (если что-то пошло не так)
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
    _stateBeforePause = null; // ДОБАВЛЕНО: Очищаем состояние до паузы
    notifyListeners();
  }

  /// Завершить тренировку
  void _finish() {
    _timer?.cancel();
    _state = TimerState.finished;
    _endTime = DateTime.now();
    _currentTime = 0;
    _stateBeforePause = null; // ДОБАВЛЕНО: Очищаем состояние до паузы
    notifyListeners();
  }

  /// Сбросить таймер
  void reset() {
    stop();
    _startTime = null;
    _endTime = null;
    _totalWorkTime = 0;
    _totalRestTime = 0;
    _lapTimes.clear();
    notifyListeners();
  }

  /// Добавить отсечку времени (для классического таймера)
  void addLapTime() {
    if (_type == TimerType.classic && _state == TimerState.working) {
      final lapTime = LapTime(
        lapNumber: _lapTimes.length + 1,
        time: _currentTime,
        formattedTime: formattedTime,
        timestamp: DateTime.now(),
      );
      _lapTimes.add(lapTime);
      notifyListeners();
    }
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
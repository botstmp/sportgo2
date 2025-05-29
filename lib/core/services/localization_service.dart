// lib/core/services/localization_service.dart
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

/// Оптимизированный сервис локализации без switch-case
class LocalizationService {
  LocalizationService._(); // Приватный конструктор для статического класса

  // Карта переводов для замены огромного switch-case
  static final Map<String, String Function(AppLocalizations)> _translationMap = {
    // Interval Timer 1
    'interval1Title': (l10n) => l10n.interval1Title,
    'interval1Subtitle': (l10n) => l10n.interval1Subtitle,
    'interval1Description': (l10n) => l10n.interval1Description,

    // Interval Timer 2
    'interval2Title': (l10n) => l10n.interval2Title,
    'interval2Subtitle': (l10n) => l10n.interval2Subtitle,
    'interval2Description': (l10n) => l10n.interval2Description,

    // Intensive Timer
    'intensiveTitle': (l10n) => l10n.intensiveTitle,
    'intensiveSubtitle': (l10n) => l10n.intensiveSubtitle,
    'intensiveDescription': (l10n) => l10n.intensiveDescription,

    // No Rest Timer
    'noRestTitle': (l10n) => l10n.noRestTitle,
    'noRestSubtitle': (l10n) => l10n.noRestSubtitle,
    'noRestDescription': (l10n) => l10n.noRestDescription,

    // Classic Timer
    'classicTitle': (l10n) => l10n.classicTitle,
    'classicSubtitle': (l10n) => l10n.classicSubtitle,
    'classicDescription': (l10n) => l10n.classicDescription,

    // Countdown Timer
    'countdownTitle': (l10n) => l10n.countdownTitle,
    'countdownSubtitle': (l10n) => l10n.countdownSubtitle,
    'countdownDescription': (l10n) => l10n.countdownDescription,
  };

  /// Получить перевод по ключу
  static String getTranslation(AppLocalizations l10n, String key) {
    final translator = _translationMap[key];
    return translator?.call(l10n) ?? key;
  }

  /// Получить название темы
  static String getThemeName(AppLocalizations l10n, String themeName) {
    switch (themeName) {
      case 'Dark':
        return 'Темная'; // Пока захардкодим, потом добавим в локализацию
      case 'Classic':
        return 'Классическая';
      case 'Ocean':
        return 'Океанская';
      case 'Forest':
        return 'Лесная';
      case 'Desert':
        return 'Пустынная';
      case 'Mocha Mousse':
        return 'Мокко Мусс';
      default:
        return themeName;
    }
  }

  /// Получить список доступных языков
  static List<LocaleInfo> getSupportedLocales() {
    return const [
      LocaleInfo(
        locale: Locale('en', ''),
        name: 'English',
        nativeName: 'English',
        flag: '🇺🇸',
      ),
      LocaleInfo(
        locale: Locale('ru', ''),
        name: 'Russian',
        nativeName: 'Русский',
        flag: '🇷🇺',
      ),
    ];
  }

  /// Форматирование времени для отображения
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  /// Форматирование времени в читаемый вид (часы:минуты:секунды)
  static String formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Форматирование даты для отображения
  static String formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Сегодня ${_formatTimeOnly(date)}'; // Добавим в локализацию
    } else if (targetDate == yesterday) {
      return 'Вчера ${_formatTimeOnly(date)}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}.'
          '${date.month.toString().padLeft(2, '0')}.'
          '${date.year} ${_formatTimeOnly(date)}';
    }
  }

  /// Форматирование только времени
  static String _formatTimeOnly(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Получение локализованного названия типа таймера
  static String getTimerTypeName(AppLocalizations l10n, String timerType) {
    switch (timerType) {
      case 'Classic':
        return l10n.classicTitle;
      case 'WithRest':
      case 'IntervalWithRest':
        return l10n.interval1Title;
      case 'FixRoundRest':
      case 'FixedRounds':
        return l10n.interval2Title;
      case 'Intensive':
        return l10n.intensiveTitle;
      case 'NoRest':
        return l10n.noRestTitle;
      case 'ReverseCountdown':
      case 'Countdown':
        return l10n.countdownTitle;
      default:
        return timerType;
    }
  }

  /// Получение сокращенного названия единиц времени
  static String getTimeUnitShort(AppLocalizations l10n, String unit) {
    switch (unit.toLowerCase()) {
      case 'hours':
        return 'ч';
      case 'minutes':
        return 'м';
      case 'seconds':
        return 'с';
      default:
        return unit;
    }
  }

  /// Плюрализация для русского языка
  static String pluralize(int count, List<String> forms) {
    if (forms.length != 3) {
      throw ArgumentError('Forms list must contain exactly 3 elements: [one, few, many]');
    }

    final absCount = count.abs();
    final lastDigit = absCount % 10;
    final lastTwoDigits = absCount % 100;

    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return forms[2]; // many
    }

    switch (lastDigit) {
      case 1:
        return forms[0]; // one
      case 2:
      case 3:
      case 4:
        return forms[1]; // few
      default:
        return forms[2]; // many
    }
  }

  /// Получение локализованного текста с плюрализацией
  static String getLocalizedCount(AppLocalizations l10n, int count, String type) {
    final currentLocale = l10n.localeName;

    if (currentLocale == 'ru') {
      switch (type) {
        case 'rounds':
          return '$count ${pluralize(count, ['раунд', 'раунда', 'раундов'])}';
        case 'minutes':
          return '$count ${pluralize(count, ['минута', 'минуты', 'минут'])}';
        case 'seconds':
          return '$count ${pluralize(count, ['секунда', 'секунды', 'секунд'])}';
        case 'workouts':
          return '$count ${pluralize(count, ['тренировка', 'тренировки', 'тренировок'])}';
        default:
          return '$count $type';
      }
    } else {
      // Английская плюрализация
      switch (type) {
        case 'rounds':
          return '$count ${count == 1 ? 'round' : 'rounds'}';
        case 'minutes':
          return '$count ${count == 1 ? 'minute' : 'minutes'}';
        case 'seconds':
          return '$count ${count == 1 ? 'second' : 'seconds'}';
        case 'workouts':
          return '$count ${count == 1 ? 'workout' : 'workouts'}';
        default:
          return '$count $type${count == 1 ? '' : 's'}';
      }
    }
  }

  /// Валидация временных значений с локализованными сообщениями
  static String? validateTimeInput(
      AppLocalizations l10n,
      String? value,
      int min,
      int max, {
        required String fieldName,
      }) {
    if (value == null || value.isEmpty) {
      return 'Поле обязательно для заполнения'; // Добавить в локализацию
    }

    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Введите корректное число';
    }

    if (intValue < min || intValue > max) {
      return '$fieldName должно быть от $min до $max';
    }

    return null;
  }
}

/// Информация о локали
class LocaleInfo {
  final Locale locale;
  final String name;
  final String nativeName;
  final String flag;

  const LocaleInfo({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  @override
  String toString() => '$flag $nativeName';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LocaleInfo &&
              runtimeType == other.runtimeType &&
              locale == other.locale;

  @override
  int get hashCode => locale.hashCode;
}
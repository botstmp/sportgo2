import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'SportOn';

  @override
  String get selectTimer => 'Выберите тип тренировки';

  @override
  String get start => 'СТАРТ';

  @override
  String get startWorkout => 'Начать тренировку';

  @override
  String get stop => 'СТОП';

  @override
  String get pause => 'ПАУЗА';

  @override
  String get resume => 'ПРОДОЛЖИТЬ';

  @override
  String get finish => 'ФИНИШ';

  @override
  String get complete => 'ЗАВЕРШИТЬ';

  @override
  String get done => 'ГОТОВО';

  @override
  String get back => 'Назад';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get select => 'Выбрать';

  @override
  String get minutes => 'Минуты';

  @override
  String get seconds => 'Секунды';

  @override
  String get hours => 'Часы';

  @override
  String get round => 'Раунд';

  @override
  String get lap => 'Отсечка';

  @override
  String get lapTime => 'Время отсечки';

  @override
  String get totalTime => 'Общее время';

  @override
  String get remainingTime => 'Осталось времени';

  @override
  String get restTime => 'Время отдыха';

  @override
  String get rest => 'ОТДЫХ';

  @override
  String get roundDuration => 'Длительность раунда';

  @override
  String get roundsCount => 'Количество раундов';

  @override
  String get timeFormatHint => 'часы : минуты : секунды';

  @override
  String get classicTitle => 'Классический секундомер';

  @override
  String get classicSubtitle => 'Произвольная тренировка';

  @override
  String get classicDescription => 'Простой секундомер с отсечками времени. Идеально подходит для свободных тренировок, где вы сами контролируете темп.';

  @override
  String get interval1Title => 'Интервальный таймер';

  @override
  String get interval1Subtitle => 'Раунды с отдыхом';

  @override
  String get interval1Description => 'Установите количество раундов и время отдыха. Отлично подходит для круговых тренировок и интервальных занятий.';

  @override
  String get interval2Title => 'Таймер с фиксированными раундами';

  @override
  String get interval2Subtitle => 'Время работы + отдых';

  @override
  String get interval2Description => 'Установите точную продолжительность для периодов работы и отдыха. Идеально для структурированных тренировок типа Табата.';

  @override
  String get intensiveTitle => 'Интенсивный таймер';

  @override
  String get intensiveSubtitle => 'На пределе возможностей';

  @override
  String get intensiveDescription => 'Установите временной лимит и посмотрите, сколько раундов вы сможете выполнить. Отлично для проверки своих границ.';

  @override
  String get intensiveWorkout => 'Интенсивная тренировка';

  @override
  String get noRestTitle => 'Раунды без отдыха';

  @override
  String get noRestSubtitle => 'Непрерывные раунды';

  @override
  String get noRestDescription => 'Установите количество раундов без периодов отдыха. Вы сами контролируете, когда заканчивается каждый раунд.';

  @override
  String get noRestRounds => 'Раунды без отдыха';

  @override
  String get countdownTitle => 'Обратный отсчет';

  @override
  String get countdownSubtitle => 'Отсчет до нуля';

  @override
  String get countdownDescription => 'Установите конкретное время и ведите обратный отсчет до нуля. Идеально для временных вызовов.';

  @override
  String get enterData => 'Введите данные';

  @override
  String get invalidTime => 'Введите корректное время';

  @override
  String get confirmEnd => 'Вы уверены? Данные не будут сохранены.';

  @override
  String get saveWorkoutPrompt => 'Сохранить эту тренировку в историю?';

  @override
  String get workoutSaved => 'Тренировка сохранена!';

  @override
  String get workoutAlreadySaved => 'Тренировка уже сохранена';

  @override
  String get saveWorkout => 'Сохранить тренировку';

  @override
  String get shareReport => 'Поделиться отчетом';

  @override
  String get viewHistory => 'Посмотреть историю';

  @override
  String get workoutReport => 'Отчет о тренировке';

  @override
  String get report => 'Отчет';

  @override
  String get summaryReport => 'Сводный отчет';

  @override
  String get myWorkoutReport => 'Мой отчет о тренировке';

  @override
  String get stopwatch => 'Секундомер';

  @override
  String get pauseWorkout => 'Приостановить тренировку';

  @override
  String get resumeWorkout => 'Возобновить тренировку';

  @override
  String get finishWorkout => 'Завершить тренировку';

  @override
  String get finishRound => 'Завершить раунд';

  @override
  String get waitingRest => 'Ожидание отдыха';

  @override
  String roundNumber(int number) {
    return 'Раунд $number';
  }

  @override
  String roundProgress(int current, int total) {
    return 'Раунд $current из $total';
  }

  @override
  String get version => 'Версия';

  @override
  String get developer => 'Разработчик';

  @override
  String get description => 'Описание';

  @override
  String get contacts => 'Контакты';

  @override
  String get aboutDescription => 'SportOn - современное приложение для кроссфит тренировок с множественными режимами таймера. Включи режим тренировки и достигай своих целей!';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get switchTheme => 'Сменить тему';

  @override
  String get switchLanguage => 'Сменить язык';

  @override
  String currentTheme(String themeName) {
    return 'Текущая тема: $themeName';
  }

  @override
  String get classicTheme => 'Классическая';

  @override
  String get darkTheme => 'Темная';

  @override
  String get oceanTheme => 'Океанская';

  @override
  String get forrestTheme => 'Лесная';

  @override
  String get desertTheme => 'Пустынная';

  @override
  String get mochaMousseTheme => 'Мокко Мусс';

  @override
  String get unknownTheme => 'Неизвестная тема';
}

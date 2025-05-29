// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SportGo2';

  @override
  String get selectTimer => 'Select Workout Timer';

  @override
  String get start => 'START';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String get stop => 'STOP';

  @override
  String get pause => 'PAUSE';

  @override
  String get resume => 'RESUME';

  @override
  String get finish => 'FINISH';

  @override
  String get complete => 'COMPLETE';

  @override
  String get done => 'DONE';

  @override
  String get back => 'Back';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get select => 'Select';

  @override
  String get minutes => 'Minutes';

  @override
  String get seconds => 'Seconds';

  @override
  String get hours => 'Hours';

  @override
  String get round => 'Round';

  @override
  String get lap => 'Lap';

  @override
  String get lapTime => 'Lap Time';

  @override
  String get totalTime => 'Total Time';

  @override
  String get remainingTime => 'Remaining Time';

  @override
  String get restTime => 'Rest Time';

  @override
  String get rest => 'REST';

  @override
  String get roundDuration => 'Round Duration';

  @override
  String get roundsCount => 'Number of Rounds';

  @override
  String get timeFormatHint => 'hours : minutes : seconds';

  @override
  String get classicTitle => 'Classic Stopwatch';

  @override
  String get classicSubtitle => 'Free-form timing';

  @override
  String get classicDescription => 'Simple stopwatch with lap times. Perfect for free-form workouts where you control the pace.';

  @override
  String get interval1Title => 'Interval Timer';

  @override
  String get interval1Subtitle => 'Rounds with rest';

  @override
  String get interval1Description => 'Set the number of rounds and rest time. Perfect for circuit training and interval workouts.';

  @override
  String get interval2Title => 'Fixed Round Timer';

  @override
  String get interval2Subtitle => 'Timed rounds + rest';

  @override
  String get interval2Description => 'Set exact duration for both work and rest periods. Ideal for structured workouts like Tabata.';

  @override
  String get intensiveTitle => 'Intensive Timer';

  @override
  String get intensiveSubtitle => 'Push to your limit';

  @override
  String get intensiveDescription => 'Set a time limit and see how many rounds you can complete. Great for testing your limits.';

  @override
  String get intensiveWorkout => 'Intensive Workout';

  @override
  String get noRestTitle => 'No Rest Rounds';

  @override
  String get noRestSubtitle => 'Continuous rounds';

  @override
  String get noRestDescription => 'Set the number of rounds without rest periods. You control when each round ends.';

  @override
  String get noRestRounds => 'Rounds without Rest';

  @override
  String get countdownTitle => 'Countdown Timer';

  @override
  String get countdownSubtitle => 'Count down to zero';

  @override
  String get countdownDescription => 'Set a specific time and count down to zero. Perfect for timed challenges.';

  @override
  String get enterData => 'Enter Data';

  @override
  String get invalidTime => 'Please enter a valid time';

  @override
  String get confirmEnd => 'Are you sure? Data will not be saved.';

  @override
  String get saveWorkoutPrompt => 'Save this workout to history?';

  @override
  String get workoutSaved => 'Workout saved!';

  @override
  String get workoutAlreadySaved => 'Workout already saved';

  @override
  String get saveWorkout => 'Save Workout';

  @override
  String get shareReport => 'Share Report';

  @override
  String get viewHistory => 'View History';

  @override
  String get workoutReport => 'Workout Report';

  @override
  String get report => 'Report';

  @override
  String get summaryReport => 'Summary Report';

  @override
  String get myWorkoutReport => 'My Workout Report';

  @override
  String get stopwatch => 'Stopwatch';

  @override
  String get pauseWorkout => 'Pause Workout';

  @override
  String get resumeWorkout => 'Resume Workout';

  @override
  String get finishWorkout => 'Finish Workout';

  @override
  String get finishRound => 'Finish Round';

  @override
  String get waitingRest => 'Waiting for Rest';

  @override
  String roundNumber(int number) {
    return 'Round $number';
  }

  @override
  String roundProgress(int current, int total) {
    return 'Round $current of $total';
  }

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get description => 'Description';

  @override
  String get contacts => 'Contacts';

  @override
  String get aboutDescription => 'Modern CrossFit timer app with multiple workout modes. Designed for athletes who want to efficiently track their workouts.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get switchTheme => 'Switch Theme';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String currentTheme(String themeName) {
    return 'Current Theme: $themeName';
  }

  @override
  String get classicTheme => 'Classic';

  @override
  String get darkTheme => 'Dark';

  @override
  String get oceanTheme => 'Ocean';

  @override
  String get forrestTheme => 'Forest';

  @override
  String get desertTheme => 'Desert';

  @override
  String get mochaMousseTheme => 'Mocha Mousse';

  @override
  String get unknownTheme => 'Unknown Theme';
}

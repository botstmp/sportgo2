import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'SportOn'**
  String get appTitle;

  /// Main screen title for selecting workout type
  ///
  /// In en, this message translates to:
  /// **'Select Workout Timer'**
  String get selectTimer;

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// Start workout button text
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// Stop button text
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get stop;

  /// Pause button text
  ///
  /// In en, this message translates to:
  /// **'PAUSE'**
  String get pause;

  /// Resume button text
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resume;

  /// Finish button text
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get finish;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'COMPLETE'**
  String get complete;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Minutes label
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// Seconds label
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// Hours label
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// Round label
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// Lap time label
  ///
  /// In en, this message translates to:
  /// **'Lap'**
  String get lap;

  /// Lap time button
  ///
  /// In en, this message translates to:
  /// **'Lap'**
  String get lapTime;

  /// Total time label
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// Remaining time label
  ///
  /// In en, this message translates to:
  /// **'Remaining Time'**
  String get remainingTime;

  /// Rest time label
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get restTime;

  /// Rest state label
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get rest;

  /// Round duration label
  ///
  /// In en, this message translates to:
  /// **'Round Duration'**
  String get roundDuration;

  /// Number of rounds label
  ///
  /// In en, this message translates to:
  /// **'Number of Rounds'**
  String get roundsCount;

  /// Time format hint text
  ///
  /// In en, this message translates to:
  /// **'hours : minutes : seconds'**
  String get timeFormatHint;

  /// Classic timer title
  ///
  /// In en, this message translates to:
  /// **'Classic Stopwatch'**
  String get classicTitle;

  /// Classic timer subtitle
  ///
  /// In en, this message translates to:
  /// **'Free-form timing'**
  String get classicSubtitle;

  /// Classic timer description
  ///
  /// In en, this message translates to:
  /// **'Simple stopwatch with lap times. Perfect for free-form workouts where you control the pace.'**
  String get classicDescription;

  /// Interval timer title
  ///
  /// In en, this message translates to:
  /// **'Interval Timer'**
  String get interval1Title;

  /// Interval timer subtitle
  ///
  /// In en, this message translates to:
  /// **'Rounds with rest'**
  String get interval1Subtitle;

  /// Interval timer description
  ///
  /// In en, this message translates to:
  /// **'Set the number of rounds and rest time. Perfect for circuit training and interval workouts.'**
  String get interval1Description;

  /// Fixed round timer title
  ///
  /// In en, this message translates to:
  /// **'Fixed Round Timer'**
  String get interval2Title;

  /// Fixed round timer subtitle
  ///
  /// In en, this message translates to:
  /// **'Timed rounds + rest'**
  String get interval2Subtitle;

  /// Fixed round timer description
  ///
  /// In en, this message translates to:
  /// **'Set exact duration for both work and rest periods. Ideal for structured workouts like Tabata.'**
  String get interval2Description;

  /// Intensive timer title
  ///
  /// In en, this message translates to:
  /// **'Intensive Timer'**
  String get intensiveTitle;

  /// Intensive timer subtitle
  ///
  /// In en, this message translates to:
  /// **'Push to your limit'**
  String get intensiveSubtitle;

  /// Intensive timer description
  ///
  /// In en, this message translates to:
  /// **'Set a time limit and see how many rounds you can complete. Great for testing your limits.'**
  String get intensiveDescription;

  /// Intensive workout label
  ///
  /// In en, this message translates to:
  /// **'Intensive Workout'**
  String get intensiveWorkout;

  /// No rest timer title
  ///
  /// In en, this message translates to:
  /// **'No Rest Rounds'**
  String get noRestTitle;

  /// No rest timer subtitle
  ///
  /// In en, this message translates to:
  /// **'Continuous rounds'**
  String get noRestSubtitle;

  /// No rest timer description
  ///
  /// In en, this message translates to:
  /// **'Set the number of rounds without rest periods. You control when each round ends.'**
  String get noRestDescription;

  /// Rounds without rest label
  ///
  /// In en, this message translates to:
  /// **'Rounds without Rest'**
  String get noRestRounds;

  /// Countdown timer title
  ///
  /// In en, this message translates to:
  /// **'Countdown Timer'**
  String get countdownTitle;

  /// Countdown timer subtitle
  ///
  /// In en, this message translates to:
  /// **'Count down to zero'**
  String get countdownSubtitle;

  /// Countdown timer description
  ///
  /// In en, this message translates to:
  /// **'Set a specific time and count down to zero. Perfect for timed challenges.'**
  String get countdownDescription;

  /// Enter data label
  ///
  /// In en, this message translates to:
  /// **'Enter Data'**
  String get enterData;

  /// Invalid time error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid time'**
  String get invalidTime;

  /// Confirm end without saving
  ///
  /// In en, this message translates to:
  /// **'Are you sure? Data will not be saved.'**
  String get confirmEnd;

  /// Save workout dialog prompt
  ///
  /// In en, this message translates to:
  /// **'Save this workout to history?'**
  String get saveWorkoutPrompt;

  /// Workout saved confirmation
  ///
  /// In en, this message translates to:
  /// **'Workout saved!'**
  String get workoutSaved;

  /// Workout already saved message
  ///
  /// In en, this message translates to:
  /// **'Workout already saved'**
  String get workoutAlreadySaved;

  /// Save workout button text
  ///
  /// In en, this message translates to:
  /// **'Save Workout'**
  String get saveWorkout;

  /// Share report button text
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareReport;

  /// View history button text
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// Workout report title
  ///
  /// In en, this message translates to:
  /// **'Workout Report'**
  String get workoutReport;

  /// Report label
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// Summary report title
  ///
  /// In en, this message translates to:
  /// **'Summary Report'**
  String get summaryReport;

  /// My workout report title for sharing
  ///
  /// In en, this message translates to:
  /// **'My Workout Report'**
  String get myWorkoutReport;

  /// Stopwatch label
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get stopwatch;

  /// Pause workout tooltip
  ///
  /// In en, this message translates to:
  /// **'Pause Workout'**
  String get pauseWorkout;

  /// Resume workout tooltip
  ///
  /// In en, this message translates to:
  /// **'Resume Workout'**
  String get resumeWorkout;

  /// Finish workout button text
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// Finish round button text
  ///
  /// In en, this message translates to:
  /// **'Finish Round'**
  String get finishRound;

  /// Waiting for rest state
  ///
  /// In en, this message translates to:
  /// **'Waiting for Rest'**
  String get waitingRest;

  /// Round number display
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String roundNumber(int number);

  /// Round progress display
  ///
  /// In en, this message translates to:
  /// **'Round {current} of {total}'**
  String roundProgress(int current, int total);

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Developer label
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Contacts label
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// About app description
  ///
  /// In en, this message translates to:
  /// **'SportOn - modern CrossFit timer app with multiple workout modes. Turn your workout ON and achieve your fitness goals!'**
  String get aboutDescription;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Switch theme button text
  ///
  /// In en, this message translates to:
  /// **'Switch Theme'**
  String get switchTheme;

  /// Switch language button text
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// Current theme display
  ///
  /// In en, this message translates to:
  /// **'Current Theme: {themeName}'**
  String currentTheme(String themeName);

  /// Classic theme name
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classicTheme;

  /// Dark theme name
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Ocean theme name
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get oceanTheme;

  /// Forest theme name
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forrestTheme;

  /// Desert theme name
  ///
  /// In en, this message translates to:
  /// **'Desert'**
  String get desertTheme;

  /// Mocha Mousse theme name
  ///
  /// In en, this message translates to:
  /// **'Mocha Mousse'**
  String get mochaMousseTheme;

  /// Unknown theme fallback
  ///
  /// In en, this message translates to:
  /// **'Unknown Theme'**
  String get unknownTheme;

  /// Stopwatch timer title
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get stopwatchTitle;

  /// Stopwatch timer description
  ///
  /// In en, this message translates to:
  /// **'Free-form timing with lap recording. Perfect for unrestricted workouts.'**
  String get stopwatchDescription;

  /// Work time label
  ///
  /// In en, this message translates to:
  /// **'Work Time'**
  String get workTime;

  /// Work state
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// Total workout time label
  ///
  /// In en, this message translates to:
  /// **'Total Workout Time'**
  String get totalWorkoutTime;

  /// Singular form of round
  ///
  /// In en, this message translates to:
  /// **'round'**
  String get roundSingular;

  /// Plural form of round
  ///
  /// In en, this message translates to:
  /// **'rounds'**
  String get roundPlural;

  /// Many plural form of round
  ///
  /// In en, this message translates to:
  /// **'rounds'**
  String get roundPluralMany;

  /// Preparation state
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get preparation;

  /// Paused state
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// Finished state
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// Stopped state
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stopped;

  /// Confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Stop workout?'**
  String get stopWorkoutQuestion;

  /// Confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'All progress will be lost'**
  String get stopWorkoutMessage;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// Total workout progress label
  ///
  /// In en, this message translates to:
  /// **'Total workout progress'**
  String get totalWorkoutProgress;

  /// Information button text
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Hint when timer is running
  ///
  /// In en, this message translates to:
  /// **'Tap to pause'**
  String get tapToPause;

  /// Hint when timer is paused
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get tapToContinue;

  /// Hint when timer is stopped
  ///
  /// In en, this message translates to:
  /// **'Ready to start'**
  String get readyToStart;

  /// Workout completion dialog title
  ///
  /// In en, this message translates to:
  /// **'🎉 Workout completed!'**
  String get workoutCompleted;

  /// Workout completion message
  ///
  /// In en, this message translates to:
  /// **'Great job! You have successfully completed the workout.'**
  String get greatJob;

  /// Timer info dialog title
  ///
  /// In en, this message translates to:
  /// **'Workout Information'**
  String get workoutInformation;

  /// Current round label
  ///
  /// In en, this message translates to:
  /// **'Current round'**
  String get currentRound;

  /// Elapsed time label
  ///
  /// In en, this message translates to:
  /// **'Elapsed time'**
  String get elapsedTime;

  /// Rounds label
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get roundsLabel;

  /// Stopwatch mode label
  ///
  /// In en, this message translates to:
  /// **'Stopwatch Mode'**
  String get stopwatchMode;

  /// Lap times dialog title
  ///
  /// In en, this message translates to:
  /// **'Lap Times'**
  String get lapTimes;

  /// Split time column header
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get splitTime;

  /// Empty state message for lap times
  ///
  /// In en, this message translates to:
  /// **'No lap times recorded yet.\nTap the flag button to record lap times.'**
  String get noLapTimes;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

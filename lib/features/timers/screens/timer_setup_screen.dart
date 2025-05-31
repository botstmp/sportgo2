// lib/features/timers/screens/timer_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/timer_provider.dart';
import '../../../core/constants/ui_config.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../shared/widgets/inputs/custom_inputs.dart';
import '../../../shared/widgets/animations/animated_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'classic_timer_screen.dart';

/// Экран настройки классического таймера
class TimerSetupScreen extends StatefulWidget {
  final TimerType timerType;

  const TimerSetupScreen({
    super.key,
    required this.timerType,
  });

  @override
  State<TimerSetupScreen> createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> {
  late Duration _workDuration;
  late Duration _restDuration;
  late int _rounds;

  @override
  void initState() {
    super.initState();

    // Устанавливаем значения по умолчанию в зависимости от типа таймера
    switch (widget.timerType) {
      case TimerType.classic:
        _workDuration = const Duration(minutes: 1);
        _restDuration = const Duration(seconds: 30);
        _rounds = 1;
        break;
      case TimerType.interval1:
        _workDuration = const Duration(seconds: 45);
        _restDuration = const Duration(seconds: 15);
        _rounds = 8;
        break;
      case TimerType.interval2:
        _workDuration = const Duration(seconds: 30);
        _restDuration = const Duration(seconds: 30);
        _rounds = 6;
        break;
      case TimerType.intensive:
        _workDuration = const Duration(seconds: 20);
        _restDuration = const Duration(seconds: 10);
        _rounds = 12;
        break;
      case TimerType.norest:
        _workDuration = const Duration(minutes: 5);
        _restDuration = Duration.zero;
        _rounds = 1;
        break;
      case TimerType.countdown:
        _workDuration = const Duration(minutes: 5);
        _restDuration = Duration.zero;
        _rounds = 1;
        break;
    }
  }

  String _getTimerTypeName() {
    switch (widget.timerType) {
      case TimerType.classic:
        return 'Классический таймер';
      case TimerType.interval1:
        return 'Интервальный 1';
      case TimerType.interval2:
        return 'Интервальный 2';
      case TimerType.intensive:
        return 'Интенсивный';
      case TimerType.norest:
        return 'Без отдыха';
      case TimerType.countdown:
        return 'Обратный отсчет';
    }
  }

  String _getTimerTypeDescription() {
    switch (widget.timerType) {
      case TimerType.classic:
        return 'Простой таймер с настраиваемым временем работы и отдыха';
      case TimerType.interval1:
        return 'Короткие интервалы высокой интенсивности';
      case TimerType.interval2:
        return 'Равные интервалы работы и отдыха';
      case TimerType.intensive:
        return 'Максимальная интенсивность с короткими перерывами';
      case TimerType.norest:
        return 'Непрерывная тренировка без перерывов';
      case TimerType.countdown:
        return 'Простой обратный отсчет времени';
    }
  }

  void _startTimer() {
    final timerProvider = context.read<TimerProvider>();

    // Настраиваем таймер
    timerProvider.setTimerType(widget.timerType);
    timerProvider.setWorkDuration(_workDuration.inSeconds);
    timerProvider.setRestDuration(_restDuration.inSeconds);
    timerProvider.setRounds(_rounds);

    // Переходим к экрану таймера
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ClassicTimerScreen(),
      ),
    );
  }

  int _calculateTotalTime() {
    int totalSeconds = 0;
    for (int i = 0; i < _rounds; i++) {
      totalSeconds += _workDuration.inSeconds;
      if (_restDuration.inSeconds > 0 && i < _rounds - 1) {
        totalSeconds += _restDuration.inSeconds;
      }
    }
    return totalSeconds;
  }

  String _formatTotalTime() {
    final totalSeconds = _calculateTotalTime();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    if (minutes > 0) {
      return seconds > 0 ? '${minutes}м ${seconds}с' : '${minutes}м';
    } else {
      return '${seconds}с';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: customTheme.scaffoldBackgroundColor,

      // AppBar
      appBar: AppBar(
        toolbarHeight: screenHeight * UIConfig.toolbarHeightFactor,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: customTheme.textPrimaryColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Настройка таймера',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: customTheme.textPrimaryColor,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Основной контент
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
                child: StaggeredListAnimation(
                  children: [
                    // Заголовок и описание
                    SlideUpAnimation(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
                        decoration: BoxDecoration(
                          color: customTheme.cardColor,
                          borderRadius: BorderRadius.circular(
                            screenWidth * UIConfig.containerBorderRadiusFactor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTimerTypeName(),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: screenHeight * UIConfig.titleFontSizeFactor,
                                fontWeight: FontWeight.bold,
                                color: customTheme.textPrimaryColor,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              _getTimerTypeDescription(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: screenHeight * UIConfig.bodyFontSizeFactor,
                                color: customTheme.textSecondaryColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Настройки времени работы
                    SlideUpAnimation(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
                        decoration: BoxDecoration(
                          color: customTheme.cardColor,
                          borderRadius: BorderRadius.circular(
                            screenWidth * UIConfig.containerBorderRadiusFactor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  color: customTheme.buttonPrimaryColor,
                                  size: screenWidth * 0.06,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  'Время работы',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.8,
                                    fontWeight: FontWeight.bold,
                                    color: customTheme.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            TimePicker(
                              initialMinutes: _workDuration.inMinutes,
                              initialSeconds: _workDuration.inSeconds % 60,
                              onChanged: (duration) {
                                setState(() {
                                  _workDuration = duration;
                                });
                              },
                              maxMinutes: 99,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Настройки времени отдыха (если применимо)
                    if (widget.timerType != TimerType.norest && widget.timerType != TimerType.countdown) ...[
                      SizedBox(height: screenHeight * 0.03),

                      SlideUpAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
                          decoration: BoxDecoration(
                            color: customTheme.cardColor,
                            borderRadius: BorderRadius.circular(
                              screenWidth * UIConfig.containerBorderRadiusFactor,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.pause_circle_outline,
                                    color: customTheme.successColor,
                                    size: screenWidth * 0.06,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Text(
                                    'Время отдыха',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.8,
                                      fontWeight: FontWeight.bold,
                                      color: customTheme.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              TimePicker(
                                initialMinutes: _restDuration.inMinutes,
                                initialSeconds: _restDuration.inSeconds % 60,
                                onChanged: (duration) {
                                  setState(() {
                                    _restDuration = duration;
                                  });
                                },
                                maxMinutes: 99,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Настройки количества раундов
                    SizedBox(height: screenHeight * 0.03),

                    SlideUpAnimation(
                      delay: const Duration(milliseconds: 300),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
                        decoration: BoxDecoration(
                          color: customTheme.cardColor,
                          borderRadius: BorderRadius.circular(
                            screenWidth * UIConfig.containerBorderRadiusFactor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  color: customTheme.warningColor,
                                  size: screenWidth * 0.06,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  'Количество раундов',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.8,
                                    fontWeight: FontWeight.bold,
                                    color: customTheme.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            NumberInput(
                              initialValue: _rounds,
                              minValue: 1,
                              maxValue: 50,
                              onChanged: (value) {
                                setState(() {
                                  _rounds = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Информация об общем времени
                    SizedBox(height: screenHeight * 0.03),

                    SlideUpAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
                        decoration: BoxDecoration(
                          color: customTheme.buttonPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            screenWidth * UIConfig.containerBorderRadiusFactor,
                          ),
                          border: Border.all(
                            color: customTheme.buttonPrimaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: customTheme.buttonPrimaryColor,
                              size: screenWidth * 0.08,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Общее время тренировки',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: customTheme.buttonPrimaryColor,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Text(
                                    _formatTotalTime(),
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontSize: screenHeight * UIConfig.titleFontSizeFactor,
                                      fontWeight: FontWeight.bold,
                                      color: customTheme.buttonPrimaryColor,
                                      fontFamily: AppThemes.timerFontFamily,
                                    ),
                                  ),
                                  if (_rounds > 1) ...[
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(
                                      '$_rounds ${_rounds == 1 ? 'раунд' : _rounds < 5 ? 'раунда' : 'раундов'}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: customTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),

            // Нижняя панель с кнопкой запуска
            Container(
              padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
              decoration: BoxDecoration(
                color: customTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Предварительный просмотр настроек
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    decoration: BoxDecoration(
                      color: customTheme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(
                        screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Время работы
                        Column(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: customTheme.buttonPrimaryColor,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              '${_workDuration.inMinutes}:${(_workDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: customTheme.textPrimaryColor,
                                fontFamily: AppThemes.timerFontFamily,
                              ),
                            ),
                            Text(
                              'Работа',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: customTheme.textSecondaryColor,
                                fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.8,
                              ),
                            ),
                          ],
                        ),

                        // Разделитель
                        if (widget.timerType != TimerType.norest && widget.timerType != TimerType.countdown)
                          Container(
                            width: 1,
                            height: screenHeight * 0.05,
                            color: customTheme.dividerColor,
                          ),

                        // Время отдыха
                        if (widget.timerType != TimerType.norest && widget.timerType != TimerType.countdown)
                          Column(
                            children: [
                              Icon(
                                Icons.pause_circle_outline,
                                color: customTheme.successColor,
                                size: screenWidth * 0.05,
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                '${_restDuration.inMinutes}:${(_restDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: customTheme.textPrimaryColor,
                                  fontFamily: AppThemes.timerFontFamily,
                                ),
                              ),
                              Text(
                                'Отдых',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: customTheme.textSecondaryColor,
                                  fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.8,
                                ),
                              ),
                            ],
                          ),

                        // Разделитель
                        Container(
                          width: 1,
                          height: screenHeight * 0.05,
                          color: customTheme.dividerColor,
                        ),

                        // Количество раундов
                        Column(
                          children: [
                            Icon(
                              Icons.repeat,
                              color: customTheme.warningColor,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              _rounds.toString(),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: customTheme.textPrimaryColor,
                                fontFamily: AppThemes.timerFontFamily,
                              ),
                            ),
                            Text(
                              _rounds == 1 ? 'Раунд' : 'Раунды',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: customTheme.textSecondaryColor,
                                fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Кнопка запуска
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: l10n.start,
                      icon: Icons.play_arrow,
                      onPressed: _startTimer,
                      gradientColors: [
                        customTheme.buttonPrimaryColor,
                        customTheme.successColor,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
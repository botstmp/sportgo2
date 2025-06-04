// lib/features/timers/screens/classic_timer_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/providers/timer_provider.dart';
import '../../../core/enums/timer_enums.dart';
import '../../../core/constants/ui_config.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../shared/widgets/displays/circular_timer_widget.dart';
import '../../../shared/widgets/displays/workout_progress_widget.dart';
import '../../../shared/widgets/dialogs/lap_times_dialog.dart';
import '../../../shared/themes/timer_colors.dart';
import '../../../shared/widgets/animations/animated_widgets.dart';
import '../../../shared/widgets/dialogs/custom_dialogs.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Экран работающего таймера
class ClassicTimerScreen extends StatefulWidget {
  const ClassicTimerScreen({super.key});

  @override
  State<ClassicTimerScreen> createState() => _ClassicTimerScreenState();
}

class _ClassicTimerScreenState extends State<ClassicTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // Анимация пульса для активного состояния
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Анимация прогресса
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Запускаем таймер
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().start();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onPlayPausePressed(TimerProvider timerProvider) {
    if (timerProvider.isRunning) {
      timerProvider.pause();
      _pulseController.stop();
    } else if (timerProvider.isPaused) {
      timerProvider.start();
      _startPulseAnimation();
    }

    // Тактильная обратная связь
    HapticFeedback.selectionClick();
  }

  void _onStopPressed(TimerProvider timerProvider, AppLocalizations l10n) async {
    final shouldStop = await ConfirmationDialog.show(
      context,
      title: l10n.stopWorkoutQuestion,
      message: l10n.stopWorkoutMessage,
      confirmText: l10n.stop,
      cancelText: l10n.continue_,
      icon: Icons.stop,
      iconColor: Theme.of(context).extension<CustomThemeExtension>()!.errorColor,
      isDangerous: true,
    );

    if (shouldStop == true) {
      timerProvider.stop();
      _pulseController.stop();
      Navigator.of(context).pop();
    }
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  Color _getCurrentColor(TimerProvider timerProvider, CustomThemeExtension customTheme) {
    // Используем специальные цвета для таймера
    return TimerColors.getPrimaryColorForState(timerProvider.state);
  }

  /// НОВЫЙ МЕТОД: Определяем какие кнопки показывать в зависимости от состояния
  Widget _buildControlButtons(TimerProvider timerProvider, Color currentColor,
      CustomThemeExtension customTheme, double screenWidth, AppLocalizations l10n) {

    // Для состояния подготовки показываем только кнопку паузы/старта
    if (timerProvider.state == TimerState.preparation) {
      return _buildPreparationControls(timerProvider, currentColor, screenWidth);
    }

    // ДОБАВЛЕНО: Если на паузе И еще не начинали работать (только что было состояние подготовки)
    // то тоже показываем упрощенные кнопки
    if (timerProvider.state == TimerState.paused && timerProvider.totalWorkTime == 0) {
      return _buildPreparationControls(timerProvider, currentColor, screenWidth);
    }

    // Для остальных состояний показываем полный набор кнопок
    return _buildFullControls(timerProvider, currentColor, customTheme, screenWidth, l10n);
  }

  /// Упрощенное управление для состояния подготовки
  Widget _buildPreparationControls(TimerProvider timerProvider, Color currentColor, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Только основная кнопка (Play/Pause)
        ScaleAnimation(
          delay: const Duration(milliseconds: 100),
          fromScale: 0.8,
          child: Container(
            width: screenWidth * 0.2,
            height: screenWidth * 0.2,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: currentColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onPlayPausePressed(timerProvider),
                borderRadius: BorderRadius.circular(screenWidth * 0.1),
                child: Icon(
                  timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: screenWidth * 0.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Полное управление для рабочих состояний (оригинальное)
  Widget _buildFullControls(TimerProvider timerProvider, Color currentColor,
      CustomThemeExtension customTheme, double screenWidth, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Кнопка паузы (теперь маленькая, слева)
        ScaleAnimation(
          delay: const Duration(milliseconds: 200),
          fromScale: 0.8,
          child: CircularActionButton(
            icon: timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
            backgroundColor: currentColor,
            size: screenWidth * 0.15,
            onPressed: () => _onPlayPausePressed(timerProvider),
            tooltip: timerProvider.isRunning ? l10n.pause : l10n.start,
          ),
        ),

        // Основная кнопка СТОП (теперь большая, в центре)
        ScaleAnimation(
          delay: const Duration(milliseconds: 100),
          fromScale: 0.8,
          child: Container(
            width: screenWidth * 0.2,
            height: screenWidth * 0.2,
            decoration: BoxDecoration(
              color: customTheme.errorColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: customTheme.errorColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onStopPressed(timerProvider, l10n),
                borderRadius: BorderRadius.circular(screenWidth * 0.1),
                child: Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: screenWidth * 0.1,
                ),
              ),
            ),
          ),
        ),

        // Кнопка отсечки времени (для классического) или информации
        ScaleAnimation(
          delay: const Duration(milliseconds: 300),
          fromScale: 0.8,
          child: CircularActionButton(
            icon: timerProvider.type == TimerType.classic && timerProvider.state == TimerState.working
                ? Icons.flag_outlined
                : Icons.info_outline,
            backgroundColor: customTheme.textSecondaryColor,
            size: screenWidth * 0.15,
            onPressed: timerProvider.type == TimerType.classic && timerProvider.state == TimerState.working
                ? () => _addLapTime(timerProvider)
                : () => _showTimerInfo(timerProvider, l10n),
            tooltip: timerProvider.type == TimerType.classic && timerProvider.state == TimerState.working
                ? l10n.lapTime
                : l10n.information,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;

    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        // Устанавливаем локализацию в провайдер
        timerProvider.setLocalizations(l10n);

        final currentColor = _getCurrentColor(timerProvider, customTheme);

        // Управляем анимацией пульса
        if (timerProvider.isRunning && !_pulseController.isAnimating) {
          _startPulseAnimation();
        } else if (!timerProvider.isRunning && _pulseController.isAnimating) {
          _pulseController.stop();
        }

        // Показываем диалог завершения
        if (timerProvider.isFinished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCompletionDialog(timerProvider, l10n);
          });
        }

        return Scaffold(
          backgroundColor: customTheme.scaffoldBackgroundColor,

          // AppBar
          appBar: AppBar(
            toolbarHeight: screenHeight * UIConfig.toolbarHeightFactor,
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: customTheme.textPrimaryColor,
              ),
              onPressed: () => _onStopPressed(timerProvider, l10n),
            ),
            title: Text(
              timerProvider.getCurrentPeriodName(l10n),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: currentColor,
              ),
            ),
            centerTitle: true,
            actions: [
              // Информация о раунде (только для интервальных таймеров)
              if (timerProvider.rounds > 1 && timerProvider.type != TimerType.classic)
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.04),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: currentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          screenWidth * UIConfig.containerBorderRadiusFactor * 0.5,
                        ),
                        border: Border.all(
                          color: currentColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${timerProvider.currentRound}/${timerProvider.rounds}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: currentColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppThemes.timerFontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          body: SafeArea(
            child: Column(
              children: [
                // Основная область с таймером
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Круговой прогресс с временем
                        FadeInAnimation(
                          child: timerProvider.isRunning
                              ? PulseAnimation(
                            minScale: 0.98,
                            maxScale: 1.02,
                            duration: const Duration(milliseconds: 1000),
                            child: _buildCircularTimer(timerProvider, currentColor),
                          )
                              : _buildCircularTimer(timerProvider, currentColor),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Статус и дополнительная информация
                        SlideUpAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              // Текущий статус
                              Text(
                                timerProvider.getCurrentPeriodName(l10n).toUpperCase(),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.8,
                                  fontWeight: FontWeight.bold,
                                  color: currentColor,
                                  letterSpacing: 2,
                                ),
                              ),

                              // ДОБАВЛЕНО: Информация о последней отсечке (только для классического таймера в рабочем состоянии)
                              if (timerProvider.type == TimerType.classic &&
                                  timerProvider.state == TimerState.working &&
                                  timerProvider.lapTimes.isNotEmpty) ...[
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  '${l10n.lapTime} ${timerProvider.lapTimes.last.lapNumber}: ${timerProvider.lapTimes.last.formattedTime}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: screenHeight * UIConfig.subtitleFontSizeFactor * 0.9,
                                    color: currentColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],

                              SizedBox(height: screenHeight * 0.02),

                              // Общий прогресс тренировки (только для интервальных таймеров)
                              if (timerProvider.rounds > 1 && timerProvider.type != TimerType.classic) ...[
                                Text(
                                  l10n.totalWorkoutProgress,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: customTheme.textSecondaryColor,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                WorkoutProgressWidget(
                                  progress: timerProvider.totalProgress,
                                  color: currentColor,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Область управления
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
                    decoration: BoxDecoration(
                      color: customTheme.cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ИЗМЕНЕННАЯ ЧАСТЬ: Адаптивные кнопки управления
                        _buildControlButtons(timerProvider, currentColor, customTheme, screenWidth, l10n),

                        SizedBox(height: screenHeight * 0.02),

                        // Подсказка
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            _getStatusHint(timerProvider, l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: customTheme.textSecondaryColor,
                              fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusHint(TimerProvider timerProvider, AppLocalizations l10n) {
    if (timerProvider.isRunning) {
      return l10n.tapToPause;
    } else if (timerProvider.isPaused) {
      return l10n.tapToContinue;
    } else {
      return l10n.readyToStart;
    }
  }

  Widget _buildCircularTimer(TimerProvider timerProvider, Color currentColor) {
    final screenWidth = MediaQuery.of(context).size.width;

    return CircularTimerWidget(
      progress: timerProvider.progress,
      centerText: timerProvider.formattedTime,
      subtitle: timerProvider.type == TimerType.classic
          ? null // Для секундомера не показываем общее время
          : timerProvider.totalTime > 0
          ? '/ ${(timerProvider.totalTime ~/ 60).toString().padLeft(2, '0')}:${(timerProvider.totalTime % 60).toString().padLeft(2, '0')}'
          : null,
      activeColor: currentColor,
      size: screenWidth * UIConfig.circularTimerSizeFactor,
      strokeWidth: 16,
      animate: true,
      animationDuration: const Duration(milliseconds: 500),
    );
  }

  void _addLapTime(TimerProvider timerProvider) {
    timerProvider.addLapTime();
    HapticFeedback.selectionClick();

    // УБРАНО: Черное информационное окно (SnackBar)
    // Теперь информация показывается прямо в интерфейсе
  }

  void _showCompletionDialog(TimerProvider timerProvider, AppLocalizations l10n) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    String message = '${l10n.greatJob}\n\n';

    if (timerProvider.type == TimerType.classic) {
      // Для классического таймера показываем общее время и отсечки
      message += '${l10n.totalTime}: ${timerProvider.formattedTime}\n';
      if (timerProvider.lapTimes.isNotEmpty) {
        message += '${l10n.lapTimes}: ${timerProvider.lapTimes.length}\n';
      }
    } else {
      // Для интервальных таймеров показываем статистику
      message += '${l10n.workTime}: ${(timerProvider.totalWorkTime ~/ 60)}:${(timerProvider.totalWorkTime % 60).toString().padLeft(2, '0')}\n'
          '${l10n.restTime}: ${(timerProvider.totalRestTime ~/ 60)}:${(timerProvider.totalRestTime % 60).toString().padLeft(2, '0')}\n'
          '${l10n.roundsLabel}: ${timerProvider.currentRound}/${timerProvider.rounds}';
    }

    InfoDialog.show(
      context,
      title: l10n.workoutCompleted,
      message: message,
      buttonText: l10n.finish,
      icon: Icons.emoji_events,
      iconColor: customTheme.successColor,
      onPressed: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  void _showTimerInfo(TimerProvider timerProvider, AppLocalizations l10n) {
    if (timerProvider.type == TimerType.classic) {
      // Для классического таймера показываем отсечки времени
      LapTimesDialog.show(
        context,
        lapTimes: timerProvider.lapTimes,
        totalTime: timerProvider.formattedTime,
      );
    } else {
      // Для интервальных таймеров показываем обычную информацию
      final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

      InfoDialog.show(
        context,
        title: l10n.workoutInformation,
        message: '${l10n.workTime}: ${timerProvider.workDuration ~/ 60}:${(timerProvider.workDuration % 60).toString().padLeft(2, '0')}\n'
            '${l10n.restTime}: ${timerProvider.restDuration ~/ 60}:${(timerProvider.restDuration % 60).toString().padLeft(2, '0')}\n'
            '${l10n.roundsLabel}: ${timerProvider.rounds}\n'
            '${l10n.currentRound}: ${timerProvider.currentRound}\n\n'
            '${l10n.elapsedTime}:\n'
            '${l10n.work}: ${(timerProvider.totalWorkTime ~/ 60)}:${(timerProvider.totalWorkTime % 60).toString().padLeft(2, '0')}\n'
            '${l10n.rest}: ${(timerProvider.totalRestTime ~/ 60)}:${(timerProvider.totalRestTime % 60).toString().padLeft(2, '0')}',
        icon: Icons.info_outline,
        iconColor: customTheme.buttonPrimaryColor,
      );
    }
  }
}
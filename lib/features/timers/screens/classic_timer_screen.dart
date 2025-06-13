// lib/features/timers/screens/classic_timer_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/providers/timer_provider.dart';
import '../../../core/enums/timer_enums.dart';
import '../../../core/constants/ui_config.dart';
import '../../../core/services/workout_history_service.dart';
import '../../../core/models/workout_session.dart';
import '../../../core/models/workout_enums.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../shared/widgets/displays/circular_timer_widget.dart';
import '../../../shared/widgets/displays/workout_progress_widget.dart';
import '../../../shared/widgets/dialogs/lap_times_dialog.dart';
import '../../../shared/themes/timer_colors.dart';
import '../../../shared/widgets/animations/animated_widgets.dart';
import '../../../shared/widgets/dialogs/custom_dialogs.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../history/screens/history_screen.dart';

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
  final WorkoutHistoryService _historyService = WorkoutHistoryService();

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
    // Останавливаем таймер сначала
    timerProvider.pause();
    _pulseController.stop();

    // Показываем диалог выбора завершения
    final result = await _showFinishDialog();

    if (result != null) {
      // Останавливаем таймер окончательно
      timerProvider.stop();

      if (result == 'save') {
        // Сохраняем данные тренировки
        await _saveWorkoutSession(timerProvider);
      }

      // Показываем сводный отчет
      _showWorkoutSummary(timerProvider, l10n, result == 'save');
    } else {
      // Пользователь отменил - возобновляем таймер
      timerProvider.start();
      _startPulseAnimation();
    }
  }

  /// Показать диалог выбора завершения тренировки
  Future<String?> _showFinishDialog() async {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: customTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.stop_circle_outlined,
                color: customTheme.errorColor,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Завершить тренировку?',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: customTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Выберите, что сделать с результатами тренировки:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: customTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 24),

              // Кнопка "Закончить и сохранить"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop('save'),
                  icon: Icon(Icons.save_outlined),
                  label: Text('Закончить и сохранить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              // Кнопка "Закончить без сохранения"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop('no_save'),
                  icon: Icon(Icons.close_outlined),
                  label: Text('Закончить без сохранения'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Сохранить сессию тренировки
  Future<void> _saveWorkoutSession(TimerProvider timerProvider) async {
    try {
      final session = WorkoutSession.fromTimerProvider(
        timerProvider,
        workoutCode: null, // TODO: Добавить поддержку кодов тренировок
        workoutTitle: _getWorkoutTitle(timerProvider),
        userNotes: null, // TODO: Добавить поле для заметок пользователя
      );

      // Сохраняем в базу данных
      final success = await _historyService.saveWorkoutSession(session);

      if (success) {
        print('Тренировка успешно сохранена');
      } else {
        print('Ошибка сохранения тренировки');
      }
    } catch (e) {
      print('Ошибка при сохранении тренировки: $e');
    }
  }

  /// Получить название тренировки
  String _getWorkoutTitle(TimerProvider timerProvider) {
    switch (timerProvider.type) {
      case TimerType.classic:
        return 'Классический секундомер';
      case TimerType.interval1:
        return 'Интервальная тренировка 1';
      case TimerType.interval2:
        return 'Интервальная тренировка 2';
      case TimerType.intensive:
        return 'Интенсивная тренировка';
      case TimerType.norest:
        return 'Тренировка без отдыха';
      case TimerType.countdown:
        return 'Обратный отсчет';
    }
  }

  /// Показать сводный отчет о тренировке
  void _showWorkoutSummary(TimerProvider timerProvider, AppLocalizations l10n, bool wasSaved) async {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    String summaryText = '';
    if (timerProvider.type == TimerType.classic) {
      summaryText = 'Общее время: ${timerProvider.formattedTime}\n';
      if (timerProvider.lapTimes.isNotEmpty) {
        summaryText += 'Раунды: ${timerProvider.lapTimes.length}\n';
      }
    } else {
      summaryText = 'Время работы: ${(timerProvider.totalWorkTime ~/ 60)}:${(timerProvider.totalWorkTime % 60).toString().padLeft(2, '0')}\n'
          'Время отдыха: ${(timerProvider.totalRestTime ~/ 60)}:${(timerProvider.totalRestTime % 60).toString().padLeft(2, '0')}\n'
          'Раунды: ${timerProvider.currentRound}/${timerProvider.rounds}';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: customTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: customTheme.successColor,
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Тренировка завершена!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: customTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (wasSaved) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: customTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: customTheme.successColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: customTheme.successColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Результаты сохранены в истории',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: customTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              Text(
                'Отличная работа! Вот краткий отчет:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: customTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 12),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: customTheme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  summaryText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: customTheme.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Кнопки действий
              Row(
                children: [
                  // Кнопка "Поделиться отчетом"
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareWorkoutReport(timerProvider),
                      icon: Icon(Icons.share),
                      label: Text('Поделиться'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customTheme.buttonPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Кнопка "Сохранить" (неактивна если уже сохранено)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: wasSaved ? null : () async {
                        // Сохраняем тренировку если еще не сохранена
                        Navigator.of(context).pop(); // Закрываем текущий диалог
                        await _saveWorkoutSession(timerProvider);
                        // Показываем диалог снова, но уже с пометкой о сохранении
                        _showWorkoutSummary(timerProvider, l10n, true);
                      },
                      icon: Icon(wasSaved ? Icons.check : Icons.save),
                      label: Text(wasSaved ? 'Сохранено' : 'Сохранить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: wasSaved ? customTheme.textSecondaryColor : customTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Кнопка "История тренировок"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToHistory(),
                  icon: Icon(Icons.history),
                  label: Text('История тренировок'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customTheme.textSecondaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              // Кнопка "Закрыть"
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Закрываем диалог
                    Navigator.of(context).popUntil((route) => route.isFirst); // Возвращаемся на главную
                  },
                  child: Text(
                    'Закрыть',
                    style: TextStyle(
                      color: customTheme.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Поделиться отчетом о тренировке
  void _shareWorkoutReport(TimerProvider timerProvider) {
    final now = DateTime.now();
    final date = '${now.day}.${now.month}.${now.year}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    String reportText = '🏃‍♂️ Отчет о тренировке SportGo\n';
    reportText += '📅 $date в $time\n\n';

    // Тип тренировки
    reportText += '⚡️ Тип: ${_getWorkoutTitle(timerProvider)}\n';

    if (timerProvider.type == TimerType.classic) {
      // Для классического таймера
      reportText += '⏱️ Общее время: ${timerProvider.formattedTime}\n';

      if (timerProvider.lapTimes.isNotEmpty) {
        reportText += '🔄 Раунды: ${timerProvider.lapTimes.length}\n\n';

        // Добавляем информацию о раундах
        reportText += '📊 Подробности по раундам:\n';
        for (int i = 0; i < timerProvider.lapTimes.length && i < 10; i++) {
          final lap = timerProvider.lapTimes[i];
          reportText += '   ${lap.lapNumber}. ${lap.formattedLapDuration}\n';
        }

        if (timerProvider.lapTimes.length > 10) {
          reportText += '   ... и еще ${timerProvider.lapTimes.length - 10} раундов\n';
        }
      }
    } else {
      // Для интервальных таймеров
      final workMinutes = timerProvider.totalWorkTime ~/ 60;
      final workSeconds = timerProvider.totalWorkTime % 60;
      final restMinutes = timerProvider.totalRestTime ~/ 60;
      final restSeconds = timerProvider.totalRestTime % 60;

      reportText += '💪 Время работы: ${workMinutes}:${workSeconds.toString().padLeft(2, '0')}\n';
      reportText += '😌 Время отдыха: ${restMinutes}:${restSeconds.toString().padLeft(2, '0')}\n';
      reportText += '🔄 Раунды: ${timerProvider.currentRound}/${timerProvider.rounds}\n';
    }

    reportText += '\n🎯 Отлично поработал! 💪\n';
    reportText += '\n#SportGo #Тренировка #Фитнес';

    // Делимся отчетом
    Share.share(
      reportText,
      subject: 'Отчет о тренировке SportGo',
    );
  }

  /// Навигация к экрану истории тренировок
  void _navigateToHistory() {
    Navigator.of(context).pop(); // Закрываем диалог
    Navigator.of(context).popUntil((route) => route.isFirst); // Возвращаемся на главную

    // Переходим к экрану истории
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  Color _getCurrentColor(TimerProvider timerProvider, CustomThemeExtension customTheme) {
    // Используем специальные цвета для таймера
    return TimerColors.getPrimaryColorForState(timerProvider.state);
  }

  /// Определяем какие кнопки показывать в зависимости от состояния
  Widget _buildControlButtons(TimerProvider timerProvider, Color currentColor,
      CustomThemeExtension customTheme, double screenWidth, AppLocalizations l10n) {

    // Для состояния подготовки показываем только кнопку паузы/старта
    if (timerProvider.state == TimerState.preparation) {
      return _buildPreparationControls(timerProvider, currentColor, screenWidth);
    }

    // Если на паузе И еще не начинали работать (только что было состояние подготовки)
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

  /// Полное управление для рабочих состояний
  Widget _buildFullControls(TimerProvider timerProvider, Color currentColor,
      CustomThemeExtension customTheme, double screenWidth, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Кнопка паузы (маленькая, слева)
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

        // Основная кнопка СТОП (большая, в центре)
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

                              // Информация о последнем раунде
                              if (timerProvider.type == TimerType.classic &&
                                  timerProvider.state == TimerState.working &&
                                  timerProvider.lapTimes.isNotEmpty) ...[
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  'Раунд ${timerProvider.lapTimes.last.lapNumber}: ${timerProvider.lapTimes.last.formattedLapDuration}',
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
                        // Адаптивные кнопки управления
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
    if (timerProvider.state == TimerState.preparation ||
        (timerProvider.state == TimerState.paused && timerProvider.totalWorkTime == 0)) {
      return timerProvider.isRunning ? l10n.tapToPause : l10n.readyToStart;
    }

    // Для основных кнопок во время работы показываем их назначение
    if (timerProvider.isRunning || timerProvider.isPaused) {
      return 'Пауза                 Закончить                 Раунд';
    }

    return l10n.readyToStart;
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
  }

  void _showTimerInfo(TimerProvider timerProvider, AppLocalizations l10n) {
    if (timerProvider.type == TimerType.classic) {
      // ИСПРАВЛЕНО: Для классического таймера показываем раунды
      // Используем LapTime из timer_provider.dart напрямую
      LapTimesDialog.show(
        context,
        lapTimes: timerProvider.lapTimes, // Используем данные напрямую из provider
        title: 'Времена раундов',
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
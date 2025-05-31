// lib/features/timers/screens/classic_timer_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/providers/timer_provider.dart';
import '../../../core/constants/ui_config.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../shared/widgets/displays/time_display.dart';
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

  void _onStopPressed(TimerProvider timerProvider) async {
    final shouldStop = await ConfirmationDialog.show(
      context,
      title: 'Остановить тренировку?',
      message: 'Весь прогресс будет потерян',
      confirmText: 'Остановить',
      cancelText: 'Продолжить',
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
    switch (timerProvider.state) {
      case TimerState.preparation:
        return customTheme.warningColor;
      case TimerState.working:
        return customTheme.buttonPrimaryColor;
      case TimerState.resting:
        return customTheme.successColor;
      case TimerState.paused:
        return customTheme.textSecondaryColor;
      case TimerState.finished:
        return customTheme.successColor;
      default:
        return customTheme.textPrimaryColor;
    }
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
        _showCompletionDialog(timerProvider);
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
        onPressed: () => _onStopPressed(timerProvider),
        ),
        title: Text(
        timerProvider.currentPeriodName,
        style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: currentColor,
        ),
        ),
        centerTitle: true,
        actions: [
        // Информация о раунде
        if (timerProvider.rounds > 1)
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
        timerProvider.currentPeriodName.toUpperCase(),
        style: theme.textTheme.titleLarge?.copyWith(
        fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.8,
        fontWeight: FontWeight.bold,
        color: currentColor,
        letterSpacing: 2,
        ),
        ),

        SizedBox(height: screenHeight * 0.02),

        // Общий прогресс тренировки
        if (timerProvider.rounds > 1) ...[
        Text(
        'Прогресс тренировки',
        style: theme.textTheme.bodyMedium?.copyWith(
        color: customTheme.textSecondaryColor,
        ),
        ),
        SizedBox(height: screenHeight * 0.01),
        LinearProgressDisplay(
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
        // Кнопки управления
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        // Кнопка остановки
        ScaleAnimation(
        delay: const Duration(milliseconds: 200),
        fromScale: 0.8,
        child: CircularActionButton(
        icon: Icons.stop,
        backgroundColor: customTheme.errorColor,
        size: screenWidth * 0.15,
        onPressed: () => _onStopPressed(timerProvider),
        tooltip: 'Остановить',
        ),
        ),

        // Основная кнопка (Play/Pause)
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

        // Кнопка информации
        ScaleAnimation(
        delay: const Duration(milliseconds: 300),
        fromScale: 0.8,
        child: CircularActionButton(
        icon: Icons.info_outline,
        backgroundColor: customTheme.textSecondaryColor,
        size: screenWidth * 0.15,
        onPressed: () => _showTimerInfo(timerProvider),
        tooltip: 'Информация',
        ),
        ),
        ],
        ),

        SizedBox(height: screenHeight * 0.02),

        // Подсказка
        FadeInAnimation(
        delay: const Duration(milliseconds: 500),
        child: Text(
        timerProvider.isRunning
        ? 'Нажмите для паузы'
            : timerProvider.isPaused
        ? 'Нажмите для продолжения'
            : 'Готов к старту',
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

  Widget _buildCircularTimer(TimerProvider timerProvider, Color currentColor) {
    final screenWidth = MediaQuery.of(context).size.width;

    return CircularProgressDisplay(
      progress: timerProvider.progress,
      centerText: timerProvider.formattedTime,
      subtitle: timerProvider.totalTime > 0
          ? '/ ${(timerProvider.totalTime ~/ 60).toString().padLeft(2, '0')}:${(timerProvider.totalTime % 60).toString().padLeft(2, '0')}'
          : null,
      color: currentColor,
      size: screenWidth * UIConfig.circularTimerSizeFactor,
      strokeWidth: 12,
    );
  }

  void _showCompletionDialog(TimerProvider timerProvider) {


    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    InfoDialog.show(
    context,
    title: '🎉 Тренировка завершена!',
    message: 'Отличная работа! Вы успешно завершили тренировку.\n\n'
    'Время работы: ${(timerProvider.totalWorkTime ~/ 60)}:${(timerProvider.totalWorkTime % 60).toString().padLeft(2, '0')}\n'
    'Время отдыха: ${(timerProvider.totalRestTime ~/ 60)}:${(timerProvider.totalRestTime % 60).toString().padLeft(2, '0')}\n'
    'Раундов: ${timerProvider.currentRound}/${timerProvider.rounds}',
    buttonText: 'Завершить',
    icon: Icons.emoji_events,
    iconColor: customTheme.successColor,
    onPressed: () {
    Navigator.of(context).popUntil((route) => route.isFirst);
    },
    );
  }

  void _showTimerInfo(TimerProvider timerProvider) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    InfoDialog.show(
      context,
      title: 'Информация о тренировке',
      message: 'Время работы: ${timerProvider.workDuration ~/ 60}:${(timerProvider.workDuration % 60).toString().padLeft(2, '0')}\n'
          'Время отдыха: ${timerProvider.restDuration ~/ 60}:${(timerProvider.restDuration % 60).toString().padLeft(2, '0')}\n'
          'Раундов: ${timerProvider.rounds}\n'
          'Текущий раунд: ${timerProvider.currentRound}\n\n'
          'Прошло времени:\n'
          'Работа: ${(timerProvider.totalWorkTime ~/ 60)}:${(timerProvider.totalWorkTime % 60).toString().padLeft(2, '0')}\n'
          'Отдых: ${(timerProvider.totalRestTime ~/ 60)}:${(timerProvider.totalRestTime % 60).toString().padLeft(2, '0')}',
      icon: Icons.info_outline,
      iconColor: customTheme.buttonPrimaryColor,
    );
  }
}
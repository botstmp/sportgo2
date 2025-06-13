// lib/features/history/screens/session_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/workout_session.dart';
import '../../../core/models/workout_enums.dart';
import '../../../core/enums/timer_enums.dart';
import '../../../core/constants/ui_config.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../shared/widgets/animations/animated_widgets.dart';
import '../../../shared/widgets/dialogs/custom_dialogs.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Экран детального просмотра тренировки
class SessionDetailScreen extends StatefulWidget {
  final WorkoutSession session;

  const SessionDetailScreen({
    super.key,
    required this.session,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Поделиться результатом тренировки
  void _shareSession() {
    final session = widget.session;
    final date = '${session.startTime.day}.${session.startTime.month}.${session.startTime.year}';
    final time = '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}';

    String reportText = '🏃‍♂️ Отчет о тренировке SportOn\n';
    reportText += '📅 $date в $time\n\n';

    // Информация о тренировке
    reportText += '⚡ Тип: ${_getTimerTypeName(session.timerType)}\n';
    reportText += '📝 Название: ${session.displayName}\n';
    reportText += '⏱️ Продолжительность: ${session.formattedDuration}\n';
    reportText += '🎯 Статус: ${session.status.displayName}\n';

    if (session.timerType == TimerType.classic && session.classicStats != null) {
      final stats = session.classicStats!;
      reportText += '🔄 Раунды: ${stats.totalLaps}\n';
      if (stats.totalLaps > 0) {
        reportText += '📊 Среднее время раунда: ${stats.formattedAverageRound}\n';
        reportText += '⚡ Лучший раунд: ${stats.formattedFastestRound}\n';
        reportText += '🎯 Стабильность: ${stats.consistencyPercent.toStringAsFixed(1)}%\n';
      }
    } else {
      reportText += '💪 Время работы: ${_formatDuration(session.workTime)}\n';
      reportText += '😌 Время отдыха: ${_formatDuration(session.restTime)}\n';
      reportText += '🔄 Раунды: ${session.roundsCompleted}\n';
    }

    if (session.userNotes != null && session.userNotes!.isNotEmpty) {
      reportText += '\n📋 Заметки: ${session.userNotes}\n';
    }

    reportText += '\n🎯 Отличная работа! 💪\n';
    reportText += '\n#SportOn #Тренировка #Фитнес';

    Share.share(
      reportText,
      subject: 'Отчет о тренировке SportOn',
    );
  }

  /// Получить название типа таймера
  String _getTimerTypeName(TimerType timerType) {
    switch (timerType) {
      case TimerType.classic:
        return 'Классический секундомер';
      case TimerType.interval1:
        return 'Интервальный таймер 1';
      case TimerType.interval2:
        return 'Интервальный таймер 2';
      case TimerType.intensive:
        return 'Интенсивный таймер';
      case TimerType.norest:
        return 'Без отдыха';
      case TimerType.countdown:
        return 'Обратный отсчет';
    }
  }

  /// Получить цвет для типа таймера
  Color _getTimerTypeColor(TimerType timerType) {
    switch (timerType) {
      case TimerType.classic:
        return const Color(0xFF2196F3);
      case TimerType.interval1:
        return const Color(0xFF4CAF50);
      case TimerType.interval2:
        return const Color(0xFFFF9800);
      case TimerType.intensive:
        return const Color(0xFFE91E63);
      case TimerType.norest:
        return const Color(0xFFFF5722);
      case TimerType.countdown:
        return const Color(0xFF9C27B0);
    }
  }

  /// Получить иконку для типа таймера
  IconData _getTimerTypeIcon(TimerType timerType) {
    switch (timerType) {
      case TimerType.classic:
        return Icons.timer_outlined;
      case TimerType.interval1:
        return Icons.repeat;
      case TimerType.interval2:
        return Icons.schedule;
      case TimerType.intensive:
        return Icons.fitness_center;
      case TimerType.norest:
        return Icons.flash_on;
      case TimerType.countdown:
        return Icons.hourglass_bottom;
    }
  }

  /// Форматировать продолжительность
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}ч ${minutes}м ${seconds}с';
    } else if (minutes > 0) {
      return '${minutes}м ${seconds}с';
    } else {
      return '${seconds}с';
    }
  }

  /// Форматировать дату и время
  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date в $time';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final session = widget.session;
    final timerColor = _getTimerTypeColor(session.timerType);
    final timerIcon = _getTimerTypeIcon(session.timerType);

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
          'Детали тренировки',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: customTheme.textPrimaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: customTheme.textPrimaryColor,
            ),
            onPressed: _shareSession,
            tooltip: 'Поделиться',
          ),
        ],
      ),

      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            )),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок тренировки
                  _buildHeaderCard(session, timerColor, timerIcon),

                  SizedBox(height: screenHeight * 0.02),

                  // Основная статистика
                  _buildMainStatsCard(session),

                  SizedBox(height: screenHeight * 0.02),

                  // Детальная статистика для классического таймера
                  if (session.timerType == TimerType.classic && session.classicStats != null) ...[
                    _buildClassicStatsCard(session.classicStats!),
                    SizedBox(height: screenHeight * 0.02),
                    _buildLapDetailsCard(session),
                  ],

                  // Детальная статистика для интервальных таймеров
                  if (session.timerType != TimerType.classic)
                    _buildIntervalStatsCard(session),

                  SizedBox(height: screenHeight * 0.02),

                  // Информация о времени
                  _buildTimeInfoCard(session),

                  SizedBox(height: screenHeight * 0.02),

                  // Заметки (если есть)
                  if (session.userNotes != null && session.userNotes!.isNotEmpty) ...[
                    _buildNotesCard(session.userNotes!),
                    SizedBox(height: screenHeight * 0.02),
                  ],

                  // Отступ внизу
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Построить карточку заголовка
  Widget _buildHeaderCard(WorkoutSession session, Color timerColor, IconData timerIcon) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
          // Заголовок с иконкой и типом
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: timerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  timerIcon,
                  color: timerColor,
                  size: screenWidth * 0.07,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Индикатор типа тренировки
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenWidth * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: session.isLinkedWorkout
                                ? timerColor.withOpacity(0.1)
                                : customTheme.textSecondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: session.isLinkedWorkout
                                  ? timerColor.withOpacity(0.3)
                                  : customTheme.textSecondaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            session.isLinkedWorkout ? 'Привязанная' : 'Свободная',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: session.isLinkedWorkout
                                  ? timerColor
                                  : customTheme.textSecondaryColor,
                              fontSize: screenWidth * 0.025,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenWidth * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: session.status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                session.status.icon,
                                size: screenWidth * 0.03,
                                color: session.status.color,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                session.status.displayName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: session.status.color,
                                  fontSize: screenWidth * 0.025,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Text(
                      session.displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: customTheme.textPrimaryColor,
                        fontSize: screenHeight * UIConfig.titleFontSizeFactor,
                      ),
                    ),
                    Text(
                      _getTimerTypeName(session.timerType),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: timerColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Основные показатели
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.schedule,
                  label: 'Время',
                  value: session.formattedDuration,
                  color: customTheme.buttonPrimaryColor,
                ),
              ),
              Container(
                width: 1,
                height: screenHeight * 0.05,
                color: customTheme.dividerColor,
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_today,
                  label: 'Дата',
                  value: _formatDateTime(session.startTime),
                  color: customTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Построить элемент статистики
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: screenWidth * 0.05,
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: AppThemes.timerFontFamily,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.7),
            fontSize: screenWidth * 0.025,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Построить карточку основной статистики
  Widget _buildMainStatsCard(WorkoutSession session) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Основные показатели',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: customTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.fitness_center,
                  label: 'Работа',
                  value: _formatDuration(session.workTime),
                  color: customTheme.successColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.pause_circle_outline,
                  label: 'Отдых',
                  value: _formatDuration(session.restTime),
                  color: customTheme.warningColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.repeat,
                  label: 'Раунды',
                  value: session.roundsCompleted.toString(),
                  color: customTheme.buttonPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Построить карточку статистики классического таймера
  Widget _buildClassicStatsCard(dynamic classicStats) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⏱️ Статистика раундов',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: customTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.flag,
                  label: 'Всего раундов',
                  value: classicStats.totalLaps.toString(),
                  color: customTheme.buttonPrimaryColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.speed,
                  label: 'Лучший раунд',
                  value: classicStats.formattedFastestRound,
                  color: customTheme.successColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Стабильность',
                  value: '${classicStats.consistencyPercent.toStringAsFixed(1)}%',
                  color: customTheme.warningColor,
                ),
              ),
            ],
          ),
          if (classicStats.totalLaps > 0) ...[
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: customTheme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Среднее время раунда: ${classicStats.formattedAverageRound}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: customTheme.textPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  LinearProgressIndicator(
                    value: classicStats.consistencyPercent / 100,
                    backgroundColor: customTheme.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      classicStats.consistencyPercent > 80
                          ? customTheme.successColor
                          : classicStats.consistencyPercent > 60
                          ? customTheme.warningColor
                          : customTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Построить карточку статистики интервальных таймеров
  Widget _buildIntervalStatsCard(WorkoutSession session) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Получаем настройки из конфигурации
    final config = session.configuration;
    final plannedRounds = config['rounds'] ?? 1;
    final workDuration = config['workDuration'] ?? 0;
    final restDuration = config['restDuration'] ?? 0;

    return Container(
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Прогресс тренировки',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: customTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),

          // Прогресс раундов
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: customTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Раунды выполнено',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: customTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      '${session.roundsCompleted}/$plannedRounds',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: customTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                LinearProgressIndicator(
                  value: plannedRounds > 0 ? session.roundsCompleted / plannedRounds : 0,
                  backgroundColor: customTheme.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    session.roundsCompleted >= plannedRounds
                        ? customTheme.successColor
                        : customTheme.buttonPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenWidth * 0.04),

          // Планируемые vs фактические показатели
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Планировалось',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'Работа: ${Duration(seconds: workDuration).inMinutes}:${(Duration(seconds: workDuration).inSeconds % 60).toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Отдых: ${Duration(seconds: restDuration).inMinutes}:${(Duration(seconds: restDuration).inSeconds % 60).toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Раунды: $plannedRounds',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: customTheme.dividerColor,
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ Фактически',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'Работа: ${_formatDuration(session.workTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Отдых: ${_formatDuration(session.restTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Раунды: ${session.roundsCompleted}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Построить карточку информации о времени
  Widget _buildTimeInfoCard(WorkoutSession session) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🕒 Временные метки',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: customTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),

          // Время начала
          _buildTimeInfoRow(
            icon: Icons.play_circle_outline,
            label: 'Начало',
            value: _formatDateTime(session.startTime),
            color: customTheme.successColor,
          ),

          SizedBox(height: screenWidth * 0.02),

          // Время окончания
          _buildTimeInfoRow(
            icon: Icons.stop_circle,
            label: 'Окончание',
            value: _formatDateTime(session.endTime),
            color: customTheme.errorColor,
          ),

          SizedBox(height: screenWidth * 0.02),

          // Общая продолжительность
          _buildTimeInfoRow(
            icon: Icons.timer,
            label: 'Продолжительность',
            value: session.formattedDuration,
            color: customTheme.buttonPrimaryColor,
          ),

          // Версия данных (для отладки)
          if (session.version > 1) ...[
            SizedBox(height: screenWidth * 0.02),
            _buildTimeInfoRow(
              icon: Icons.info_outline,
              label: 'Версия данных',
              value: 'v${session.version}',
              color: customTheme.textSecondaryColor,
            ),
          ],
        ],
      ),
    );
  }

  /// Построить строку информации о времени
  Widget _buildTimeInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: screenWidth * 0.05,
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: AppThemes.timerFontFamily,
          ),
        ),
      ],
    );
  }

  /// Построить карточку заметок
  Widget _buildNotesCard(String notes) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note,
                color: customTheme.warningColor,
                size: screenWidth * 0.05,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                '📝 Заметки',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: customTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: customTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: customTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Text(
              notes,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: customTheme.textPrimaryColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Построить карточку детальной информации о раундах
  Widget _buildLapDetailsCard(WorkoutSession session) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Получаем статистику раундов из конфигурации сессии
    final lapStats = session.configuration['lapStats'] as Map<String, dynamic>?;
    final lapDetails = session.configuration['lapTimes'] as List<dynamic>?;

    if (lapStats == null || lapDetails == null || lapDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏃‍♂️ Детали раундов',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: customTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),

          // Заголовки колонок
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenWidth * 0.01,
            ),
            decoration: BoxDecoration(
              color: customTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.12,
                  child: Text(
                    '№',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: customTheme.textSecondaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.25,
                  child: Text(
                    'Время раунда',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: customTheme.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Общее время',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: customTheme.textSecondaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.15,
                  child: Text(
                    'Темп',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: customTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          // Список раундов
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lapDetails.length,
            itemBuilder: (context, index) {
              final lap = lapDetails[index] as Map<String, dynamic>;
              final lapNumber = lap['lapNumber'] as int? ?? 0;
              final lapDuration = lap['lapDuration'] as int? ?? 0;
              final totalTime = lap['time'] as int? ?? 0;

              // Определяем темп относительно среднего
              final averageLapTime = lapStats['averageLapTime'] as double? ?? 0.0;
              final fastestLap = lapStats['fastestLap'] as int? ?? 0;
              final isFastest = lapDuration == fastestLap;

              Color lapColor = customTheme.textPrimaryColor;
              IconData lapIcon = Icons.timer;

              if (isFastest) {
                lapColor = customTheme.successColor;
                lapIcon = Icons.speed;
              } else if (lapDuration > averageLapTime * 1.1) {
                lapColor = customTheme.errorColor;
                lapIcon = Icons.trending_down;
              } else if (lapDuration < averageLapTime * 0.9) {
                lapColor = customTheme.warningColor;
                lapIcon = Icons.trending_up;
              }

              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenWidth * 0.015,
                ),
                margin: EdgeInsets.only(bottom: screenHeight * 0.008),
                decoration: BoxDecoration(
                  color: isFastest
                      ? customTheme.successColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: isFastest
                      ? Border.all(color: customTheme.successColor.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    // Номер раунда
                    SizedBox(
                      width: screenWidth * 0.12,
                      child: Text(
                        '$lapNumber',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: lapColor,
                          fontFamily: AppThemes.timerFontFamily,
                        ),
                      ),
                    ),

                    // Время раунда
                    SizedBox(
                      width: screenWidth * 0.25,
                      child: Text(
                        _formatLapDuration(lapDuration),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: lapColor,
                          fontFamily: AppThemes.timerFontFamily,
                          fontWeight: isFastest ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),

                    // Общее время
                    Expanded(
                      child: Text(
                        _formatLapDuration(totalTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: customTheme.textSecondaryColor,
                          fontFamily: AppThemes.timerFontFamily,
                        ),
                      ),
                    ),

                    // Индикатор темпа
                    SizedBox(
                      width: screenWidth * 0.15,
                      child: Icon(
                        lapIcon,
                        color: lapColor,
                        size: screenWidth * 0.04,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: screenHeight * 0.02),

          // Итоговая статистика
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: customTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Лучший раунд:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: customTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      _formatLapDuration(lapStats['fastestLap'] as int? ?? 0),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: customTheme.successColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppThemes.timerFontFamily,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.008),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Средний раунд:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: customTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      _formatLapDuration((lapStats['averageLapTime'] as double? ?? 0.0).round()),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: customTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppThemes.timerFontFamily,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.008),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Худший раунд:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: customTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      _formatLapDuration(lapStats['slowestLap'] as int? ?? 0),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: customTheme.errorColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppThemes.timerFontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Форматировать время раунда
  String _formatLapDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
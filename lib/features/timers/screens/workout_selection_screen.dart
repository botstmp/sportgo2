// lib/features/timers/screens/workout_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/timer_provider.dart';
import '../../../core/services/workout_history_service.dart';
import '../../../core/enums/timer_enums.dart';
import '../../../core/constants/ui_config.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../shared/widgets/animations/animated_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'timer_setup_screen.dart';
import 'classic_timer_screen.dart';

/// Экран выбора тренировки перед запуском таймера
class WorkoutSelectionScreen extends StatefulWidget {
  final TimerType timerType;

  const WorkoutSelectionScreen({
    super.key,
    required this.timerType,
  });

  @override
  State<WorkoutSelectionScreen> createState() => _WorkoutSelectionScreenState();
}

class _WorkoutSelectionScreenState extends State<WorkoutSelectionScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();

  final WorkoutHistoryService _historyService = WorkoutHistoryService();

  bool _isLoading = false;
  Map<String, String> _workoutCodes = {}; // код -> название
  List<String> _recentWorkouts = []; // недавние тренировки
  String? _selectedWorkoutKey;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    _codeFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  /// Загрузить данные о тренировках из истории
  Future<void> _loadWorkoutData() async {
    setState(() => _isLoading = true);

    try {
      // Загружаем карту кодов для автодополнения
      final codes = await _historyService.getWorkoutCodesMap();

      // Загружаем недавние тренировки этого типа
      final recentSessions = await _historyService.getSessionsByTimerType(widget.timerType);
      final recentWorkouts = recentSessions
          .where((session) => session.isLinkedWorkout)
          .map((session) => session.workoutKey)
          .toSet()
          .take(5)
          .toList();

      setState(() {
        _workoutCodes = codes;
        _recentWorkouts = recentWorkouts;
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки данных о тренировках: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Обработка изменения кода тренировки
  void _onCodeChanged() {
    final code = _codeController.text.toUpperCase();

    // Автодополнение названия если код найден
    if (_workoutCodes.containsKey(code)) {
      final title = _workoutCodes[code]!;
      if (_titleController.text.isEmpty || _titleController.text != title) {
        _titleController.text = title;
      }
    }

    setState(() {
      _selectedWorkoutKey = code.isNotEmpty ? code : null;
    });
  }

  /// Выбрать недавнюю тренировку
  void _selectRecentWorkout(String workoutKey) {
    // Пытаемся разобрать ключ на код и название
    final sessions = _recentWorkouts.where((key) => key == workoutKey);
    if (sessions.isNotEmpty) {
      setState(() {
        _selectedWorkoutKey = workoutKey;
        if (_workoutCodes.containsKey(workoutKey)) {
          _codeController.text = workoutKey;
          _titleController.text = _workoutCodes[workoutKey]!;
        } else {
          _codeController.clear();
          _titleController.text = workoutKey;
        }
      });
    }
  }

  /// Продолжить с выбранной тренировкой
  void _continueWithWorkout() {
    final timerProvider = context.read<TimerProvider>();

    // Устанавливаем привязку к тренировке
    timerProvider.setWorkoutLink(
      workoutCode: _codeController.text.isNotEmpty ? _codeController.text.toUpperCase() : null,
      workoutTitle: _titleController.text.isNotEmpty ? _titleController.text : null,
      userNotes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    // Переходим к настройке таймера
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TimerSetupScreen(timerType: widget.timerType),
      ),
    );
  }

  /// Продолжить без привязки к тренировке
  void _continueWithoutWorkout() {
    final timerProvider = context.read<TimerProvider>();
    timerProvider.clearWorkoutLink();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TimerSetupScreen(timerType: widget.timerType),
      ),
    );
  }

  /// Быстрый старт с настройками по умолчанию
  void _quickStart() {
    final timerProvider = context.read<TimerProvider>();

    // Устанавливаем привязку к тренировке
    timerProvider.setWorkoutLink(
      workoutCode: _codeController.text.isNotEmpty ? _codeController.text.toUpperCase() : null,
      workoutTitle: _titleController.text.isNotEmpty ? _titleController.text : null,
      userNotes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    // Настраиваем таймер с настройками по умолчанию
    timerProvider.setTimerType(widget.timerType);

    // Переходим сразу к таймеру
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ClassicTimerScreen(),
      ),
    );
  }

  /// Получить название типа таймера
  String _getTimerTypeName() {
    switch (widget.timerType) {
      case TimerType.classic:
        return 'Классический секундомер';
      case TimerType.interval1:
        return 'Интервальный таймер';
      case TimerType.interval2:
        return 'Фиксированные раунды';
      case TimerType.intensive:
        return 'Интенсивный таймер';
      case TimerType.norest:
        return 'Без отдыха';
      case TimerType.countdown:
        return 'Обратный отсчет';
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
          'Выбор тренировки',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: customTheme.textPrimaryColor,
          ),
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(customTheme.buttonPrimaryColor),
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            // Основной контент
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
                child: StaggeredListAnimation(
                  children: [
                    // Информация о выбранном типе таймера
                    SlideUpAnimation(
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
                              Icons.timer,
                              color: customTheme.buttonPrimaryColor,
                              size: screenWidth * 0.08,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Выбранный тип:',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: customTheme.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    _getTimerTypeName(),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.8,
                                      fontWeight: FontWeight.bold,
                                      color: customTheme.buttonPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Поля ввода тренировки
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
                            Text(
                              '🏷️ Привязать к тренировке (опционально)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.8,
                                fontWeight: FontWeight.bold,
                                color: customTheme.textPrimaryColor,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.01),

                            Text(
                              'Укажите код или название для отслеживания прогресса',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: customTheme.textSecondaryColor,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Поле кода тренировки
                            TextField(
                              controller: _codeController,
                              focusNode: _codeFocusNode,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                labelText: 'Код тренировки (например: TB-001)',
                                hintText: 'Введите код...',
                                prefixIcon: Icon(Icons.qr_code, color: customTheme.buttonPrimaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                                  ),
                                  borderSide: BorderSide(
                                    color: customTheme.buttonPrimaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Поле названия тренировки
                            TextField(
                              controller: _titleController,
                              focusNode: _titleFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Название тренировки',
                                hintText: 'Введите название...',
                                prefixIcon: Icon(Icons.fitness_center, color: customTheme.successColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                                  ),
                                  borderSide: BorderSide(
                                    color: customTheme.successColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Поле заметок
                            TextField(
                              controller: _notesController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Заметки (опционально)',
                                hintText: 'Цель тренировки, особенности...',
                                prefixIcon: Icon(Icons.note_add, color: customTheme.textSecondaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Недавние тренировки
                    if (_recentWorkouts.isNotEmpty) ...[
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
                              Text(
                                '⏱️ Недавние тренировки',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.8,
                                  fontWeight: FontWeight.bold,
                                  color: customTheme.textPrimaryColor,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.015),

                              ...(_recentWorkouts.map((workoutKey) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _selectRecentWorkout(workoutKey),
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * UIConfig.containerBorderRadiusFactor * 0.5,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.03,
                                          vertical: screenHeight * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _selectedWorkoutKey == workoutKey
                                              ? customTheme.buttonPrimaryColor.withOpacity(0.1)
                                              : customTheme.scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            screenWidth * UIConfig.containerBorderRadiusFactor * 0.5,
                                          ),
                                          border: Border.all(
                                            color: _selectedWorkoutKey == workoutKey
                                                ? customTheme.buttonPrimaryColor
                                                : customTheme.dividerColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.history,
                                              size: screenWidth * 0.04,
                                              color: _selectedWorkoutKey == workoutKey
                                                  ? customTheme.buttonPrimaryColor
                                                  : customTheme.textSecondaryColor,
                                            ),
                                            SizedBox(width: screenWidth * 0.02),
                                            Expanded(
                                              child: Text(
                                                workoutKey,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: _selectedWorkoutKey == workoutKey
                                                      ? customTheme.buttonPrimaryColor
                                                      : customTheme.textPrimaryColor,
                                                  fontWeight: _selectedWorkoutKey == workoutKey
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            if (_selectedWorkoutKey == workoutKey)
                                              Icon(
                                                Icons.check_circle,
                                                size: screenWidth * 0.04,
                                                color: customTheme.buttonPrimaryColor,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList()),
                            ],
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),

            // Нижняя панель с кнопками
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
                  // Кнопка продолжить с тренировкой
                  if (_codeController.text.isNotEmpty || _titleController.text.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: 'Продолжить с тренировкой',
                        icon: Icons.play_arrow,
                        onPressed: _continueWithWorkout,
                        gradientColors: [
                          customTheme.buttonPrimaryColor,
                          customTheme.successColor,
                        ],
                      ),
                    ),

                  // Кнопка быстрого старта (если есть привязка к тренировке)
                  if (_codeController.text.isNotEmpty || _titleController.text.isNotEmpty) ...[
                    SizedBox(height: screenHeight * 0.01),
                    SizedBox(
                      width: double.infinity,
                      child: CustomTextButton(
                        text: '⚡ Быстрый старт (настройки по умолчанию)',
                        icon: Icons.flash_on,
                        onPressed: _quickStart,
                        color: customTheme.warningColor,
                      ),
                    ),
                  ],

                  SizedBox(height: screenHeight * 0.015),

                  // Кнопка продолжить без привязки
                  SizedBox(
                    width: double.infinity,
                    child: SecondaryButton(
                      text: 'Продолжить без привязки',
                      icon: Icons.timer,
                      onPressed: _continueWithoutWorkout,
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
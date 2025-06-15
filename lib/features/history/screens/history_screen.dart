// lib/features/history/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../../../core/services/workout_history_service.dart';
import '../../../core/models/workout_session.dart';
import '../../../core/models/workout_enums.dart';
import '../../../core/enums/timer_enums.dart';
import '../../../core/constants/ui_config.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../shared/widgets/animations/animated_widgets.dart';
import '../../../shared/widgets/dialogs/custom_dialogs.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'session_detail_screen.dart'; // ДОБАВЛЕНО: Импорт экрана деталей
import '../../../debug/workout_debug_helper.dart';

/// Экран истории тренировок
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();

  List<WorkoutSession> _allSessions = [];
  List<WorkoutSession> _filteredSessions = [];
  bool _isLoading = false;

  // Фильтры
  TimerType? _selectedTimerType;
  String _searchQuery = '';

  // Сортировка
  _SortType _sortType = _SortType.dateDesc;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ПОЛНОСТЬЮ ОТКЛЮЧЕНО: Все отладочные функции
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   WorkoutDebugHelper.fullDiagnostics();
    // });
    _loadHistory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Загрузить историю тренировок
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      print('🔍 Загружаем историю тренировок...');

      // Сначала проверим количество записей в БД
      final count = await _historyService.getTotalSessionsCount();
      print('🔍 Общее количество записей в БД: $count');

      // Получаем информацию о БД
      final dbInfo = await _historyService.getServiceInfo();
      print('🔍 Информация о сервисе: $dbInfo');

      final sessions = await _historyService.getAllSessions();
      print('🔍 Загружено сессий из сервиса: ${sessions.length}');

      for (var session in sessions) {
        print('🔍 Сессия: ${session.id} - ${session.displayName} - ${session.formattedDuration} - ${session.status}');
      }

      setState(() {
        _allSessions = sessions;
        _applyFilters();
        _isLoading = false;
      });

      print('🔍 Финальное состояние - всего: ${_allSessions.length}, отфильтровано: ${_filteredSessions.length}');
    } catch (e, stackTrace) {
      print('❌ Ошибка загрузки истории: $e');
      print('❌ StackTrace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  /// Применить фильтры и сортировку
  void _applyFilters() {
    print('🔍 Применяем фильтры. Исходных сессий: ${_allSessions.length}');
    List<WorkoutSession> filtered = List.from(_allSessions);

    // Фильтр по типу таймера
    if (_selectedTimerType != null) {
      print('🔍 Фильтруем по типу: $_selectedTimerType');
      filtered = filtered.where((session) => session.timerType == _selectedTimerType).toList();
      print('🔍 После фильтра по типу: ${filtered.length}');
    }

    // Фильтр по поиску
    if (_searchQuery.isNotEmpty) {
      print('🔍 Фильтруем по запросу: "$_searchQuery"');
      filtered = filtered.where((session) {
        final query = _searchQuery.toLowerCase();
        return (session.workoutCode?.toLowerCase().contains(query) ?? false) ||
            (session.workoutTitle?.toLowerCase().contains(query) ?? false) ||
            (session.userNotes?.toLowerCase().contains(query) ?? false);
      }).toList();
      print('🔍 После фильтра по поиску: ${filtered.length}');
    }

    // Применяем сортировку
    _applySorting(filtered);

    setState(() {
      _filteredSessions = filtered;
    });

    print('🔍 Финальное количество отфильтрованных сессий: ${_filteredSessions.length}');
  }

  /// Применить сортировку
  void _applySorting(List<WorkoutSession> sessions) {
    switch (_sortType) {
      case _SortType.dateDesc:
        sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
        break;
      case _SortType.dateAsc:
        sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
        break;
      case _SortType.durationDesc:
        sessions.sort((a, b) => b.totalDuration.compareTo(a.totalDuration));
        break;
      case _SortType.durationAsc:
        sessions.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
        break;
      case _SortType.workoutName:
        sessions.sort((a, b) => a.displayName.compareTo(b.displayName));
        break;
    }
  }

  /// Обработка изменения поиска
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _applyFilters();
  }

  /// ИСПРАВЛЕННАЯ версия удаления с правильным диалогом
  Future<void> _deleteSession(WorkoutSession session) async {
    if (session.id == null || session.id!.isEmpty) {
      print('❌ Попытка удалить сессию с пустым ID');
      return;
    }

    print('🗑 Attempting to delete session: ${session.id} - ${session.displayName}');

    try {
      final shouldDelete = await ConfirmationDialog.show(
        context,
        title: 'Удалить тренировку?',
        message: 'Тренировка "${session.displayName}" будет удалена навсегда',
        confirmText: 'Удалить',
        cancelText: 'Отмена',
        icon: Icons.delete_forever,
        isDangerous: true,
      );

      print('🔍 Dialog result: $shouldDelete (type: ${shouldDelete.runtimeType})');

      if (shouldDelete != true) {
        print('🚫 User cancelled deletion (result was: $shouldDelete)');
        return;
      }

      print('✅ User confirmed deletion, proceeding...');

      final success = await _historyService.deleteWorkoutSession(session.id!);

      if (!mounted) return;

      if (success) {
        print('✅ Session deleted successfully from database');
        setState(() {
          _allSessions.removeWhere((s) => s.id == session.id);
          _applyFilters();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Тренировка удалена'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('❌ Failed to delete session from database');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка удаления'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Exception during deletion: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Произошла ошибка'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
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

  /// Получить название типа таймера
  String _getTimerTypeName(TimerType timerType) {
    switch (timerType) {
      case TimerType.classic:
        return 'Классический';
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
          'История тренировок',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: customTheme.textPrimaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          // Кнопка фильтров
          PopupMenuButton<TimerType?>(
            icon: Icon(
              Icons.filter_list,
              color: customTheme.textPrimaryColor,
            ),
            onSelected: (timerType) {
              setState(() {
                _selectedTimerType = timerType;
              });
              _applyFilters();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Все типы'),
              ),
              const PopupMenuDivider(),
              ...TimerType.values.map((type) => PopupMenuItem(
                value: type,
                child: Text(_getTimerTypeName(type)),
              )),
            ],
          ),
        ],
      ),

      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(customTheme.buttonPrimaryColor),
        ),
      )
          : Column(
        children: [
          // Поисковая строка
          Container(
            padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по названию, коду или заметкам...',
                prefixIcon: Icon(Icons.search, color: customTheme.textSecondaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: customTheme.textSecondaryColor),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    screenWidth * UIConfig.containerBorderRadiusFactor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    screenWidth * UIConfig.containerBorderRadiusFactor,
                  ),
                  borderSide: BorderSide(
                    color: customTheme.buttonPrimaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Информация о результатах
          if (_filteredSessions.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * UIConfig.containerOuterPaddingFactor,
              ),
              child: Row(
                children: [
                  Text(
                    'Найдено: ${_filteredSessions.length} из ${_allSessions.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: customTheme.textSecondaryColor,
                    ),
                  ),
                  const Spacer(),
                  DropdownButton<_SortType>(
                    value: _sortType,
                    underline: const SizedBox(),
                    items: _SortType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.displayName,
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortType = value;
                        });
                        _applyFilters();
                      }
                    },
                  ),
                ],
              ),
            ),

          // Список тренировок
          Expanded(
            child: _filteredSessions.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.builder(
                padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
                itemCount: _filteredSessions.length,
                itemBuilder: (context, index) {
                  final session = _filteredSessions[index];
                  return SlideUpAnimation(
                    delay: Duration(milliseconds: index * 50),
                    child: _buildSessionCard(session, index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Построить карточку тренировки
  Widget _buildSessionCard(WorkoutSession session, int index) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final timerColor = _getTimerTypeColor(session.timerType);
    final timerIcon = _getTimerTypeIcon(session.timerType);

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            screenWidth * UIConfig.containerBorderRadiusFactor,
          ),
          onTap: () {
            // ИСПРАВЛЕНО: Навигация к детальному просмотру
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SessionDetailScreen(session: session),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок с типом и действиями
                Row(
                  children: [
                    // Иконка типа таймера
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: timerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        timerIcon,
                        color: timerColor,
                        size: screenWidth * 0.05,
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.03),

                    // Название тренировки
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ДОБАВЛЕНО: Индикатор типа тренировки
                          Row(
                            children: [
                              // Индикатор привязанной/свободной тренировки
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.015,
                                  vertical: screenWidth * 0.003,
                                ),
                                decoration: BoxDecoration(
                                  color: session.isLinkedWorkout
                                      ? timerColor.withOpacity(0.1)
                                      : customTheme.textSecondaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: session.isLinkedWorkout
                                        ? timerColor.withOpacity(0.3)
                                        : customTheme.textSecondaryColor.withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  session.isLinkedWorkout ? 'Привязанная' : 'Свободная',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: session.isLinkedWorkout
                                        ? timerColor
                                        : customTheme.textSecondaryColor,
                                    fontSize: screenWidth * 0.022,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            session.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: customTheme.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getTimerTypeName(session.timerType),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: timerColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Кнопка удаления
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: customTheme.errorColor,
                        size: screenWidth * 0.05,
                      ),
                      onPressed: () => _deleteSession(session),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.015),

                // Основная информация
                Row(
                  children: [
                    // Время тренировки
                    _buildInfoChip(
                      icon: Icons.schedule,
                      label: _formatDuration(session.totalDuration),
                      color: customTheme.buttonPrimaryColor,
                    ),

                    SizedBox(width: screenWidth * 0.02),

                    // Дата
                    _buildInfoChip(
                      icon: Icons.calendar_today,
                      label: _formatDate(session.startTime),
                      color: customTheme.textSecondaryColor,
                    ),

                    SizedBox(width: screenWidth * 0.02),

                    // Статус
                    _buildInfoChip(
                      icon: session.status.icon,
                      label: session.status.displayName,
                      color: session.status.color,
                    ),
                  ],
                ),

                // Заметки (если есть)
                if (session.userNotes != null && session.userNotes!.isNotEmpty) ...[
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: customTheme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: screenWidth * 0.04,
                          color: customTheme.textSecondaryColor,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            session.userNotes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: customTheme.textSecondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Построить информационный чип
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: screenWidth * 0.03,
            color: color,
          ),
          SizedBox(width: screenWidth * 0.01),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.025,
            ),
          ),
        ],
      ),
    );
  }

  /// Построить состояние пустого списка
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _allSessions.isEmpty ? Icons.fitness_center : Icons.search_off,
            size: screenWidth * 0.2,
            color: customTheme.textSecondaryColor.withOpacity(0.5),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            _allSessions.isEmpty
                ? 'Пока нет тренировок'
                : 'Тренировки не найдены',
            style: theme.textTheme.titleMedium?.copyWith(
              color: customTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            _allSessions.isEmpty
                ? 'Выполните первую тренировку и она появится здесь'
                : 'Попробуйте изменить фильтры или поисковый запрос',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: customTheme.textSecondaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          if (_selectedTimerType != null || _searchQuery.isNotEmpty) ...[
            SizedBox(height: screenHeight * 0.03),
            SecondaryButton(
              text: 'Сбросить фильтры',
              icon: Icons.clear,
              onPressed: () {
                setState(() {
                  _selectedTimerType = null;
                  _searchQuery = '';
                  _searchController.clear();
                });
                _applyFilters();
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Форматировать продолжительность
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}ч ${minutes}м';
    } else if (minutes > 0) {
      return '${minutes}м ${seconds}с';
    } else {
      return '${seconds}с';
    }
  }

  /// Форматировать дату
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return 'Сегодня';
    } else if (sessionDate == yesterday) {
      return 'Вчера';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}

/// Типы сортировки
enum _SortType {
  dateDesc('По дате (новые)'),
  dateAsc('По дате (старые)'),
  durationDesc('По времени (долгие)'),
  durationAsc('По времени (короткие)'),
  workoutName('По названию');

  const _SortType(this.displayName);
  final String displayName;
}
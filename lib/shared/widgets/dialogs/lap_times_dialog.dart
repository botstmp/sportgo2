// lib/shared/widgets/dialogs/lap_times_dialog.dart
import 'package:flutter/material.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../core/providers/timer_provider.dart'; // ИСПРАВЛЕНО: Импортируем правильный LapTime

/// Диалог для отображения времен раундов (отсечек времени)
class LapTimesDialog extends StatelessWidget {
  final List<LapTime> lapTimes; // ИСПРАВЛЕНО: Используем LapTime из timer_provider.dart
  final String title;

  const LapTimesDialog({
    super.key,
    required this.lapTimes,
    required this.title,
  });

  /// Показать диалог с временами раундов
  static Future<void> show(
      BuildContext context, {
        required List<LapTime> lapTimes, // ИСПРАВЛЕНО: Используем правильный тип
        required String title,
      }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return LapTimesDialog(
          lapTimes: lapTimes,
          title: title,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      backgroundColor: customTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            color: customTheme.buttonPrimaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: customTheme.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: screenHeight * 0.4,
        child: lapTimes.isEmpty
            ? _buildEmptyState(theme, customTheme)
            : _buildLapTimesList(theme, customTheme),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Закрыть',
            style: TextStyle(
              color: customTheme.buttonPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Пустое состояние когда нет раундов
  Widget _buildEmptyState(ThemeData theme, CustomThemeExtension customTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_off_outlined,
            size: 48,
            color: customTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Раунды еще не зафиксированы',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: customTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите кнопку с флагом во время тренировки, чтобы зафиксировать раунды',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: customTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Список раундов
  Widget _buildLapTimesList(ThemeData theme, CustomThemeExtension customTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок таблицы
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: customTheme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '№',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: customTheme.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Время раунда',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: customTheme.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Общее время',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: customTheme.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Список раундов
        Expanded(
          child: ListView.builder(
            itemCount: lapTimes.length,
            itemBuilder: (context, index) {
              final lapTime = lapTimes[index];
              final isEven = index % 2 == 0;

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isEven
                      ? customTheme.scaffoldBackgroundColor.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Номер раунда
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${lapTime.lapNumber}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: customTheme.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppThemes.timerFontFamily,
                        ),
                      ),
                    ),

                    // Время раунда
                    Expanded(
                      flex: 2,
                      child: Text(
                        lapTime.formattedLapDuration,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: customTheme.buttonPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppThemes.timerFontFamily,
                        ),
                      ),
                    ),

                    // Общее время на момент раунда
                    Expanded(
                      flex: 2,
                      child: Text(
                        lapTime.formattedTime,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: customTheme.textSecondaryColor,
                          fontFamily: AppThemes.timerFontFamily,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Статистика
        _buildStatistics(theme, customTheme),
      ],
    );
  }

  /// Статистика по раундам
  Widget _buildStatistics(ThemeData theme, CustomThemeExtension customTheme) {
    if (lapTimes.isEmpty) return const SizedBox.shrink();

    // Вычисляем статистику только по длительности раундов
    final durations = lapTimes.map((lap) => lap.lapDuration.toDouble()).toList();
    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
    final minDuration = durations.reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customTheme.buttonPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: customTheme.buttonPrimaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика раундов',
            style: theme.textTheme.labelMedium?.copyWith(
              color: customTheme.buttonPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Всего раундов',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: customTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lapTimes.length}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: customTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppThemes.timerFontFamily,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Средний раунд',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: customTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(avgDuration),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: customTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppThemes.timerFontFamily,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Лучший раунд',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: customTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(minDuration),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: customTheme.successColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppThemes.timerFontFamily,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Форматирование длительности в секундах
  String _formatDuration(double seconds) {
    final minutes = seconds ~/ 60;
    final secs = (seconds % 60).round();
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }
}
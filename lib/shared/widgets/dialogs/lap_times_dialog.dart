// lib/shared/widgets/dialogs/lap_times_dialog.dart
import 'package:flutter/material.dart';
import '../../../core/enums/timer_enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../themes/app_themes.dart';

/// Диалог для отображения отсечек времени
class LapTimesDialog {
  static Future<void> show(
      BuildContext context, {
        required List<LapTime> lapTimes,
        required String totalTime,
      }) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return showDialog<void>(
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
                Icons.flag_outlined,
                color: customTheme.buttonPrimaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.lapTimes,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: customTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Общее время
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: customTheme.buttonPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalTime,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: customTheme.textPrimaryColor,
                        ),
                      ),
                      Text(
                        totalTime,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: customTheme.buttonPrimaryColor,
                          fontFamily: AppThemes.timerFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Заголовки таблицы
                if (lapTimes.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '#',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: customTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          l10n.lapTime,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: customTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          l10n.splitTime,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: customTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Divider(color: customTheme.textSecondaryColor.withOpacity(0.3)),

                  // Список отсечек
                  Expanded(
                    child: ListView.builder(
                      itemCount: lapTimes.length,
                      itemBuilder: (context, index) {
                        final lap = lapTimes[index];
                        final previousLap = index > 0 ? lapTimes[index - 1] : null;
                        final isLast = index == lapTimes.length - 1;

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isLast
                                ? customTheme.successColor.withOpacity(0.1)
                                : null,
                            borderRadius: isLast
                                ? BorderRadius.circular(8)
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Номер отсечки
                              Expanded(
                                flex: 1,
                                child: Text(
                                  lap.lapNumber.toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isLast
                                        ? customTheme.successColor
                                        : customTheme.textPrimaryColor,
                                  ),
                                ),
                              ),

                              // Общее время
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lap.formattedTime,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: AppThemes.timerFontFamily,
                                    color: isLast
                                        ? customTheme.successColor
                                        : customTheme.textPrimaryColor,
                                  ),
                                ),
                              ),

                              // Время сплита
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lap.getFormattedDeltaTime(previousLap),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: AppThemes.timerFontFamily,
                                    color: customTheme.textSecondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  // Пустое состояние
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 48,
                            color: customTheme.textSecondaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noLapTimes,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: customTheme.textSecondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.close,
                style: TextStyle(
                  color: customTheme.buttonPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
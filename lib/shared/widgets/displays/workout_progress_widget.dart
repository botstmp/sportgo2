// lib/shared/widgets/displays/workout_progress_widget.dart
import 'package:flutter/material.dart';
import '../../themes/app_themes.dart';

/// Виджет отображения общего прогресса тренировки
class WorkoutProgressWidget extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;
  final double width;

  const WorkoutProgressWidget({
    super.key,
    required this.progress,
    required this.color,
    this.height = 6,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: customTheme.textSecondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: width * progress.clamp(0.0, 1.0),
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
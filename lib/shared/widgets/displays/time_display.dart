// lib/shared/widgets/displays/time_display.dart
import 'package:flutter/material.dart';
import '../../themes/app_themes.dart';
import '../../../core/constants/ui_config.dart';

/// Большой дисплей времени для основного таймера
class PrimaryTimeDisplay extends StatelessWidget {
  final String time;
  final String? label;
  final Color? color;
  final bool isAnimated;
  final VoidCallback? onTap;

  const PrimaryTimeDisplay({
    super.key,
    required this.time,
    this.label,
    this.color,
    this.isAnimated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final displayColor = color ?? customTheme.textPrimaryColor;

    // Адаптивные размеры шрифта
    final timeSize = screenHeight * UIConfig.timerDisplayFontSizeFactor;
    final labelSize = screenHeight * UIConfig.subtitleFontSizeFactor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * UIConfig.containerInnerPaddingFactor,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: customTheme.cardColor,
          borderRadius: BorderRadius.circular(
            screenWidth * UIConfig.containerBorderRadiusFactor,
          ),
          border: Border.all(
            color: displayColor.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: displayColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Время
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: timeSize,
                fontWeight: FontWeight.bold,
                color: displayColor,
                fontFamily: AppThemes.timerFontFamily,
                letterSpacing: screenWidth * 0.01,
                shadows: [
                  Shadow(
                    color: displayColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                time,
                textAlign: TextAlign.center,
              ),
            ),

            // Лейбл (если есть)
            if (label != null) ...[
              SizedBox(height: screenHeight * 0.01),
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: labelSize,
                  color: displayColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Компактный дисплей времени для вторичных таймеров
class SecondaryTimeDisplay extends StatelessWidget {
  final String time;
  final String? label;
  final Color? color;
  final VoidCallback? onTap;

  const SecondaryTimeDisplay({
    super.key,
    required this.time,
    this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final displayColor = color ?? customTheme.textSecondaryColor;
    final timeSize = screenHeight * UIConfig.timerDisplayFontSizeFactor * 0.6;
    final labelSize = screenHeight * UIConfig.subtitleFontSizeFactor * 0.8;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * UIConfig.containerInnerPaddingFactor * 0.8,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          color: displayColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(
            screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
          ),
          border: Border.all(
            color: displayColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Время
            Text(
              time,
              style: TextStyle(
                fontSize: timeSize,
                fontWeight: FontWeight.bold,
                color: displayColor,
                fontFamily: AppThemes.timerFontFamily,
              ),
              textAlign: TextAlign.center,
            ),

            // Лейбл (если есть)
            if (label != null) ...[
              SizedBox(height: screenHeight * 0.005),
              Text(
                label!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: labelSize,
                  color: displayColor.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Круговой индикатор прогресса с текстом
class CircularProgressDisplay extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String centerText;
  final String? subtitle;
  final Color? color;
  final double? size;
  final double strokeWidth;

  const CircularProgressDisplay({
    super.key,
    required this.progress,
    required this.centerText,
    this.subtitle,
    this.color,
    this.size,
    this.strokeWidth = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final progressColor = color ?? customTheme.buttonPrimaryColor;
    final displaySize = size ?? screenWidth * UIConfig.circularTimerSizeFactor;
    final textSize = screenHeight * UIConfig.timerDisplayFontSizeFactor;
    final subtitleSize = screenHeight * UIConfig.timerHintFontSizeFactor;

    return SizedBox(
      width: displaySize,
      height: displaySize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Фоновый круг
          SizedBox(
            width: displaySize,
            height: displaySize,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: progressColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor.withOpacity(0.2),
              ),
            ),
          ),

          // Прогресс
          SizedBox(
            width: displaySize,
            height: displaySize,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          // Центральный текст
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerText,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  color: customTheme.textPrimaryColor,
                  fontFamily: AppThemes.timerFontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                SizedBox(height: screenHeight * 0.005),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: subtitleSize,
                    color: customTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Линейный индикатор прогресса
class LinearProgressDisplay extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String? label;
  final Color? color;
  final double? height;

  const LinearProgressDisplay({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final progressColor = color ?? customTheme.buttonPrimaryColor;
    final progressHeight = height ?? screenHeight * 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Лейбл (если есть)
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: customTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
        ],

        // Прогресс бар
        Container(
          width: double.infinity,
          height: progressHeight,
          decoration: BoxDecoration(
            color: progressColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(progressHeight / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(progressHeight / 2),
              ),
            ),
          ),
        ),

        // Процент (если нужен)
        SizedBox(height: screenHeight * 0.005),
        Text(
          '${(progress * 100).toInt()}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: customTheme.textSecondaryColor,
            fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.8,
          ),
        ),
      ],
    );
  }
}
// lib/shared/widgets/indicators/progress_indicators.dart
import 'package:flutter/material.dart';
import '../../themes/app_themes.dart';
import '../../../core/constants/ui_config.dart';
import 'dart:math';

/// Анимированный линейный прогресс-бар
class AnimatedProgressBar extends StatefulWidget {
  final double progress; // от 0.0 до 1.0
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final String? label;
  final bool showPercentage;
  final Duration animationDuration;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.progressColor,
    this.backgroundColor,
    this.height = 8.0,
    this.label,
    this.showPercentage = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final progressColor = widget.progressColor ?? customTheme.buttonPrimaryColor;
    final bgColor = widget.backgroundColor ?? customTheme.textSecondaryColor.withOpacity(0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Лейбл и процент (если нужно)
        if (widget.label != null || widget.showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.8,
                    color: customTheme.textSecondaryColor,
                  ),
                ),
              if (widget.showPercentage)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.8,
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
            ],
          ),
          SizedBox(height: screenHeight * 0.008),
        ],

        // Прогресс-бар
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Фон
                  Container(
                    width: double.infinity,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                  ),

                  // Прогресс
                  FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor,
                            progressColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Сегментированный круговой индикатор раундов
class RoundProgressIndicator extends StatefulWidget {
  final int currentRound;
  final int totalRounds;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;
  final double size;
  final double strokeWidth;

  const RoundProgressIndicator({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.size = 120,
    this.strokeWidth = 6,
  });

  @override
  State<RoundProgressIndicator> createState() => _RoundProgressIndicatorState();
}

class _RoundProgressIndicatorState extends State<RoundProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(RoundProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRound != widget.currentRound) {
      _animationController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final activeColor = widget.activeColor ?? customTheme.buttonPrimaryColor;
    final inactiveColor = widget.inactiveColor ?? customTheme.textSecondaryColor.withOpacity(0.3);
    final completedColor = widget.completedColor ?? customTheme.successColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Кастомная отрисовка сегментов
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: RoundProgressPainter(
                  currentRound: widget.currentRound,
                  totalRounds: widget.totalRounds,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  completedColor: completedColor,
                  strokeWidth: widget.strokeWidth,
                  animationValue: _animationController.value,
                ),
              );
            },
          ),

          // Центральный текст
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.currentRound}',
                style: TextStyle(
                  fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.8,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                  fontFamily: AppThemes.timerFontFamily,
                ),
              ),
              Text(
                'of ${widget.totalRounds}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.7,
                  color: customTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Кастомный художник для сегментированного прогресса
class RoundProgressPainter extends CustomPainter {
  final int currentRound;
  final int totalRounds;
  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;
  final double strokeWidth;
  final double animationValue;

  RoundProgressPainter({
    required this.currentRound,
    required this.totalRounds,
    required this.activeColor,
    required this.inactiveColor,
    required this.completedColor,
    required this.strokeWidth,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Угол между сегментами
    final segmentAngle = (2 * pi) / totalRounds;
    final gapAngle = segmentAngle * 0.1; // 10% промежуток между сегментами
    final roundAngle = segmentAngle - gapAngle;

    for (int i = 0; i < totalRounds; i++) {
      final startAngle = -pi / 2 + i * segmentAngle;

      Color segmentColor;
      if (i < currentRound - 1) {
        segmentColor = completedColor;
      } else if (i == currentRound - 1) {
        segmentColor = activeColor;
      } else {
        segmentColor = inactiveColor;
      }

      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Анимация для текущего сегмента
      double sweepAngle = roundAngle;
      if (i == currentRound - 1) {
        sweepAngle = roundAngle * animationValue;
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RoundProgressPainter oldDelegate) {
    return oldDelegate.currentRound != currentRound ||
        oldDelegate.animationValue != animationValue;
  }
}

/// Пульсирующий индикатор активности
class PulsingIndicator extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const PulsingIndicator({
    super.key,
    this.color,
    this.size = 20,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final indicatorColor = widget.color ?? customTheme.buttonPrimaryColor;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
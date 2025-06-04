// lib/shared/widgets/displays/circular_timer_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../themes/app_themes.dart';

/// Улучшенный виджет кругового таймера с секторным заполнением
class CircularTimerWidget extends StatefulWidget {
  /// Прогресс от 0.0 до 1.0
  final double progress;

  /// Основной текст в центре (время)
  final String centerText;

  /// Дополнительный текст под основным
  final String? subtitle;

  /// Цвет активного сектора
  final Color activeColor;

  /// Размер виджета
  final double size;

  /// Толщина кольца
  final double strokeWidth;

  /// Включить анимацию
  final bool animate;

  /// Длительность анимации
  final Duration animationDuration;

  const CircularTimerWidget({
    super.key,
    required this.progress,
    required this.centerText,
    this.subtitle,
    required this.activeColor,
    this.size = 280,
    this.strokeWidth = 12,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

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

    if (widget.animate) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CircularTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress && widget.animate) {
      _animateToNewProgress();
    }
  }

  void _animateToNewProgress() {
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _previousProgress = widget.progress;
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final currentProgress = widget.animate
            ? _progressAnimation.value
            : widget.progress;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Фоновое кольцо
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularTimerPainter(
                  progress: currentProgress,
                  activeColor: widget.activeColor,
                  backgroundColor: customTheme.cardColor,
                  strokeWidth: widget.strokeWidth,
                  backgroundStrokeColor: customTheme.textSecondaryColor.withOpacity(0.1),
                ),
              ),

              // Центральный контент
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Основное время
                  Text(
                    widget.centerText,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: widget.size * 0.15,
                      fontWeight: FontWeight.bold,
                      color: customTheme.textPrimaryColor,
                      fontFamily: AppThemes.timerFontFamily,
                      letterSpacing: -1,
                    ),
                  ),

                  // Дополнительный текст
                  if (widget.subtitle != null) ...[
                    SizedBox(height: widget.size * 0.02),
                    Text(
                      widget.subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: widget.size * 0.06,
                        color: customTheme.textSecondaryColor,
                        fontFamily: AppThemes.timerFontFamily,
                      ),
                    ),
                  ],
                ],
              ),

              // Декоративные элементы (точки на окружности)
              ..._buildDecorationDots(customTheme),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDecorationDots(CustomThemeExtension customTheme) {
    final dots = <Widget>[];
    const dotCount = 12; // Количество точек (как на часах)

    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * math.pi) / dotCount - math.pi / 2;
      final radius = (widget.size / 2) - (widget.strokeWidth / 2);

      dots.add(
        Positioned(
          left: (widget.size / 2) + (radius * math.cos(angle)) - 2,
          top: (widget.size / 2) + (radius * math.sin(angle)) - 2,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: customTheme.textSecondaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return dots;
  }
}

/// Кастомный painter для рисования секторного таймера
class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color backgroundColor;
  final Color backgroundStrokeColor;
  final double strokeWidth;

  _CircularTimerPainter({
    required this.progress,
    required this.activeColor,
    required this.backgroundColor,
    required this.backgroundStrokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Фоновое кольцо (всегда полный круг)
    final backgroundPaint = Paint()
      ..color = backgroundStrokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Активный сектор
    if (progress > 0) {
      final activePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            activeColor,
            activeColor.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Рисуем прогресс от верхней точки по часовой стрелке
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Начинаем сверху (12 часов)
        sweepAngle,   // Заполняем по часовой стрелке
        false,
        activePaint,
      );

      // Добавляем свечение для активного сектора
      final glowPaint = Paint()
        ..color = activeColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // Центральный круг (фон для текста)
    final centerPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - strokeWidth - 8, centerPaint);

    // Тень для центрального круга
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius - strokeWidth - 8, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Виджет линейного прогресса для общего прогресса тренировки
class LinearProgressDisplay extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;
  final double width;

  const LinearProgressDisplay({
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
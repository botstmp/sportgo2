// lib/shared/widgets/cards/timer_card.dart
import 'package:flutter/material.dart';
import '../../themes/app_themes.dart';
import '../../../core/constants/ui_config.dart';

/// Карточка для выбора типа таймера
class TimerCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool isSelected;
  final String? imagePath;

  const TimerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.onTap,
    this.accentColor,
    this.isSelected = false,
    this.imagePath,
  });

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    // Уменьшенная высота карточки
    final cardHeight = screenHeight * 0.10; // Было 0.16, стало 0.10
    final borderRadius = screenWidth * UIConfig.containerBorderRadiusFactor;
    final accentColor = widget.accentColor ?? customTheme.buttonPrimaryColor;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: cardHeight,
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * UIConfig.containerOuterPaddingFactor * 0.5,
                vertical: screenHeight * 0.006, // Уменьшены отступы между карточками
              ),
              decoration: BoxDecoration(
                color: customTheme.cardColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: widget.isSelected
                    ? Border.all(
                  color: accentColor,
                  width: 2,
                )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? accentColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: _isPressed ? 15 : 10,
                    offset: Offset(0, _isPressed ? 5 : 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Stack(
                  children: [
                    // Фоновое изображение (если есть)
                    if (widget.imagePath != null)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(widget.imagePath!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Градиентный оверлей
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accentColor.withOpacity(0.1),
                              accentColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Контент
                    Padding(
                      padding: EdgeInsets.all(
                        screenWidth * UIConfig.containerInnerPaddingFactor * 0.8, // Уменьшены внутренние отступы
                      ),
                      child: Row(
                        children: [
                          // Иконка (уменьшена)
                          Container(
                            width: screenWidth * 0.12, // Было 0.15
                            height: screenWidth * 0.12, // Было 0.15
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.025, // Уменьшен радиус
                              ),
                              border: Border.all(
                                color: accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              widget.icon,
                              size: screenWidth * 0.06, // Было 0.08
                              color: accentColor,
                            ),
                          ),

                          SizedBox(width: screenWidth * 0.03),

                          // Текстовая информация
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Заголовок
                                Text(
                                  widget.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.65, // Уменьшен шрифт
                                    fontWeight: FontWeight.bold,
                                    color: customTheme.textPrimaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: screenHeight * 0.002), // Уменьшен отступ

                                // Подзаголовок
                                Text(
                                  widget.subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: screenHeight * UIConfig.subtitleFontSizeFactor * 0.75, // Уменьшен шрифт
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Убираем описание совсем, так как оно теперь показывается внизу экрана
                                // и места в компактной карточке для него нет
                              ],
                            ),
                          ),

                          // Стрелка или индикатор выбора (уменьшен)
                          Container(
                            width: screenWidth * 0.07, // Было 0.08
                            height: screenWidth * 0.07, // Было 0.08
                            decoration: BoxDecoration(
                              color: widget.isSelected
                                  ? accentColor
                                  : accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isSelected
                                  ? Icons.check
                                  : Icons.arrow_forward_ios,
                              size: screenWidth * 0.035, // Было 0.04
                              color: widget.isSelected
                                  ? Colors.white
                                  : accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Анимированная подсветка при нажатии
                    if (_isPressed)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Компактная карточка для результатов или истории
class CompactCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? value;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? accentColor;
  final Widget? trailing;

  const CompactCard({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.icon,
    this.onTap,
    this.accentColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final accentColor = this.accentColor ?? customTheme.buttonPrimaryColor;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * UIConfig.containerOuterPaddingFactor * 0.5,
        vertical: screenHeight * 0.005,
      ),
      decoration: BoxDecoration(
        color: customTheme.cardColor,
        borderRadius: BorderRadius.circular(
          screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              screenWidth * UIConfig.containerInnerPaddingFactor * 0.8,
            ),
            child: Row(
              children: [
                // Иконка (если есть)
                if (icon != null) ...[
                  Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: screenWidth * 0.05,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                ],

                // Текстовая информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.6,
                          fontWeight: FontWeight.w600,
                          color: customTheme.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: screenHeight * 0.002),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.7,
                            color: customTheme.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Значение или trailing виджет
                if (value != null)
                  Text(
                    value!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: screenHeight * UIConfig.titleFontSizeFactor * 0.6,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),

                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
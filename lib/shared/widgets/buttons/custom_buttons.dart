// lib/shared/widgets/buttons/custom_buttons.dart
import 'package:flutter/material.dart';
import '../../themes/app_themes.dart';
import '../../../core/constants/ui_config.dart';

/// Основная кнопка SportOn с адаптивным размером
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final bool isExpanded;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    // Адаптивные размеры
    final buttonHeight = height ?? screenHeight * UIConfig.primaryButtonHeightFactor;
    final buttonWidth = isExpanded ? double.infinity : width;
    final fontSize = screenHeight * UIConfig.buttonTextSizeFactor;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: customTheme.buttonPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: customTheme.buttonPrimaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              screenWidth * UIConfig.buttonBorderRadiusFactor,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * UIConfig.buttonHorizontalPaddingFactor,
            vertical: screenHeight * 0.015,
          ),
        ),
        child: isLoading
            ? SizedBox(
          height: fontSize,
          width: fontSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: fontSize * 1.2,
              ),
              SizedBox(width: screenWidth * UIConfig.buttonIconTextSpacingFactor),
            ],
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Вторичная кнопка SportOn
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;
  final double? width;
  final double? height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isExpanded = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final buttonHeight = height ?? screenHeight * UIConfig.primaryButtonHeightFactor * 0.85;
    final buttonWidth = isExpanded ? double.infinity : width;
    final fontSize = screenHeight * UIConfig.buttonTextSizeFactor * 0.9;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: customTheme.buttonSecondaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: customTheme.buttonSecondaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              screenWidth * UIConfig.buttonBorderRadiusFactor,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * UIConfig.buttonHorizontalPaddingFactor,
            vertical: screenHeight * 0.012,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: fontSize * 1.1,
              ),
              SizedBox(width: screenWidth * UIConfig.buttonIconTextSpacingFactor),
            ],
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Текстовая кнопка SportOn
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final buttonColor = color ?? customTheme.buttonPrimaryColor;
    final fontSize = screenHeight * UIConfig.buttonTextSizeFactor * 0.8;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: buttonColor,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * UIConfig.buttonHorizontalPaddingFactor * 0.7,
          vertical: screenHeight * 0.01,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize * 1.1,
            ),
            SizedBox(width: screenWidth * UIConfig.buttonIconTextSpacingFactor * 0.7),
          ],
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: buttonColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Круглая кнопка действия (FloatingActionButton аналог)
class CircularActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const CircularActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final buttonSize = size ?? screenWidth * 0.15;
    final bgColor = backgroundColor ?? customTheme.buttonPrimaryColor;
    final icColor = iconColor ?? Colors.white;

    Widget button = Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Icon(
            icon,
            color: icColor,
            size: buttonSize * 0.5,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Кнопка с градиентом для особых действий
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final List<Color>? gradientColors;
  final bool isExpanded;
  final double? width;
  final double? height;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.gradientColors,
    this.isExpanded = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final buttonHeight = height ?? screenHeight * UIConfig.primaryButtonHeightFactor;
    final buttonWidth = isExpanded ? double.infinity : width;
    final fontSize = screenHeight * UIConfig.buttonTextSizeFactor;

    final gradColors = gradientColors ?? [
      customTheme.buttonPrimaryColor,
      customTheme.buttonSecondaryColor,
    ];

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(
            screenWidth * UIConfig.buttonBorderRadiusFactor,
          ),
          boxShadow: [
            BoxShadow(
              color: gradColors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(
              screenWidth * UIConfig.buttonBorderRadiusFactor,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * UIConfig.buttonHorizontalPaddingFactor,
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: fontSize * 1.2,
                      color: Colors.white,
                    ),
                    SizedBox(width: screenWidth * UIConfig.buttonIconTextSpacingFactor),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
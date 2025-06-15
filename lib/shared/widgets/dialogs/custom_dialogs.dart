// lib/shared/widgets/dialogs/custom_dialogs.dart
import 'package:flutter/material.dart';
import '../../themes/app_themes.dart';
import '../../../core/constants/ui_config.dart';
import '../buttons/custom_buttons.dart';

/// Диалог подтверждения действия
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final bool isDangerous;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Подтвердить',
    this.cancelText = 'Отмена',
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final dialogWidth = screenWidth * UIConfig.dialogWidthFactor;
    final effectiveIconColor = iconColor ??
        (isDangerous ? customTheme.errorColor : customTheme.buttonPrimaryColor);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
        decoration: BoxDecoration(
          color: customTheme.cardColor,
          borderRadius: BorderRadius.circular(
            screenWidth * UIConfig.containerBorderRadiusFactor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка (если есть)
            if (icon != null) ...[
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: screenWidth * 0.08,
                  color: effectiveIconColor,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],

            // Заголовок
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: screenHeight * UIConfig.titleFontSizeFactor,
                fontWeight: FontWeight.bold,
                color: customTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.015),

            // Сообщение
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: screenHeight * UIConfig.bodyFontSizeFactor,
                color: customTheme.textSecondaryColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.025),

            // Кнопки
            Row(
              children: [
                // Кнопка отмены
                Expanded(
                  child: SecondaryButton(
                    text: cancelText,
                    onPressed: () {
                      print('🚫 ConfirmationDialog: Cancel button pressed');
                      Navigator.of(context).pop(false); // ИСПРАВЛЕНО: возвращаем false
                      onCancel?.call();
                    },
                  ),
                ),

                SizedBox(width: screenWidth * 0.03),

                // Кнопка подтверждения
                Expanded(
                  child: PrimaryButton(
                    text: confirmText,
                    onPressed: () {
                      print('✅ ConfirmationDialog: Confirm button pressed');
                      Navigator.of(context).pop(true); // ИСПРАВЛЕНО: возвращаем true
                      onConfirm?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Показать диалог подтверждения
  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Подтвердить',
        String cancelText = 'Отмена',
        IconData? icon,
        Color? iconColor,
        bool isDangerous = false,
      }) {
    print('🔍 ConfirmationDialog.show() called with:');
    print('🔍 - title: $title');
    print('🔍 - message: $message');
    print('🔍 - isDangerous: $isDangerous');

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        isDangerous: isDangerous,
        // ИСПРАВЛЕНО: убираем дублирующие колбэки
      ),
    );
  }
}

/// Информационный диалог
class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? iconColor;

  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'ОК',
    this.onPressed,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final dialogWidth = screenWidth * UIConfig.dialogWidthFactor;
    final effectiveIconColor = iconColor ?? customTheme.buttonPrimaryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
        decoration: BoxDecoration(
          color: customTheme.cardColor,
          borderRadius: BorderRadius.circular(
            screenWidth * UIConfig.containerBorderRadiusFactor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка (если есть)
            if (icon != null) ...[
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: screenWidth * 0.08,
                  color: effectiveIconColor,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],

            // Заголовок
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: screenHeight * UIConfig.titleFontSizeFactor,
                fontWeight: FontWeight.bold,
                color: customTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.015),

            // Сообщение
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: screenHeight * UIConfig.bodyFontSizeFactor,
                color: customTheme.textSecondaryColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.025),

            // Кнопка
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: buttonText,
                onPressed: () {
                  Navigator.of(context).pop();
                  onPressed?.call();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Показать информационный диалог
  static Future<void> show(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'ОК',
        IconData? icon,
        Color? iconColor,
        VoidCallback? onPressed,
      }) {
    return showDialog<void>(
      context: context,
      builder: (context) => InfoDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        icon: icon,
        iconColor: iconColor,
        onPressed: onPressed,
      ),
    );
  }
}

/// Диалог с пользовательским содержимым
class CustomContentDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final bool barrierDismissible;

  const CustomContentDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final dialogWidth = screenWidth * UIConfig.dialogWidthFactor;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
        ),
        padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
        decoration: BoxDecoration(
          color: customTheme.cardColor,
          borderRadius: BorderRadius.circular(
            screenWidth * UIConfig.containerBorderRadiusFactor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок (если есть)
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: screenHeight * UIConfig.titleFontSizeFactor,
                  fontWeight: FontWeight.bold,
                  color: customTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02),
            ],

            // Контент
            Flexible(
              child: SingleChildScrollView(
                child: content,
              ),
            ),

            // Действия (если есть)
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Показать диалог с пользовательским содержимым
  static Future<T?> show<T>(
      BuildContext context, {
        String? title,
        required Widget content,
        List<Widget>? actions,
        bool barrierDismissible = true,
      }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomContentDialog(
        title: title,
        content: content,
        actions: actions,
        barrierDismissible: barrierDismissible,
      ),
    );
  }
}

/// Диалог загрузки
class LoadingDialog extends StatelessWidget {
  final String message;
  final bool canCancel;

  const LoadingDialog({
    super.key,
    this.message = 'Загрузка...',
    this.canCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
        decoration: BoxDecoration(
          color: customTheme.cardColor,
          borderRadius: BorderRadius.circular(
            screenWidth * UIConfig.containerBorderRadiusFactor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Индикатор загрузки
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                customTheme.buttonPrimaryColor,
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Сообщение
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: customTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Кнопка отмены (если разрешено)
            if (canCancel) ...[
              SizedBox(height: screenHeight * 0.02),
              CustomTextButton(
                text: 'Отмена',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Показать диалог загрузки
  static Future<T?> show<T>(
      BuildContext context, {
        String message = 'Загрузка...',
        bool canCancel = false,
      }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: canCancel,
      builder: (context) => LoadingDialog(
        message: message,
        canCancel: canCancel,
      ),
    );
  }
}
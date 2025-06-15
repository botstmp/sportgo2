// lib/shared/widgets/dialogs/confirmation_dialog.dart
import 'package:flutter/material.dart';

/// Диалог подтверждения действий
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData? icon;
  final bool isDangerous;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Подтвердить',
    this.cancelText = 'Отмена',
    this.icon,
    this.isDangerous = false,
  });

  /// Статический метод для показа диалога
  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Подтвердить',
        String cancelText = 'Отмена',
        IconData? icon,
        bool isDangerous = false,
      }) {
    print('🔍 ConfirmationDialog.show() called with:');
    print('🔍 - title: $title');
    print('🔍 - message: $message');
    print('🔍 - isDangerous: $isDangerous');

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        isDangerous: isDangerous,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDangerous ? Colors.red : theme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            print('🚫 ConfirmationDialog: Cancel button pressed');
            Navigator.of(context).pop(false); // ЯВНО возвращаем false
          },
          child: Text(
            cancelText,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            print('✅ ConfirmationDialog: Confirm button pressed');
            Navigator.of(context).pop(true); // ЯВНО возвращаем true
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDangerous ? Colors.red : theme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
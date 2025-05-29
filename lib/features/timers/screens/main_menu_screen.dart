// lib/features/timers/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/constants/ui_config.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Временный главный экран для проверки базовой архитектуры
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: customTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: screenHeight * UIConfig.toolbarHeightFactor,
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          l10n.appTitle,
          style: theme.textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
        child: Container(
          decoration: BoxDecoration(
            color: customTheme.cardColor,
            borderRadius: BorderRadius.circular(
              screenWidth * UIConfig.containerBorderRadiusFactor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * UIConfig.containerInnerPaddingFactor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Заголовок
                Text(
                  '🎉 SportGo2 базовая архитектура готова!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: screenHeight * UIConfig.titleFontSizeFactor,
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // Информация о теме
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: customTheme.buttonPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Текущая тема: ${customTheme.name}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Язык: ${context.watch<ThemeProvider>().currentLocale.languageCode.toUpperCase()}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // Кнопки для тестирования
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ThemeProvider>().nextTheme();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customTheme.buttonPrimaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(
                            0,
                            screenHeight * UIConfig.primaryButtonHeightFactor * 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.palette, size: 20),
                            const SizedBox(width: 8),
                            Text('Сменить тему'),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: screenWidth * UIConfig.buttonIconTextSpacingFactor),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ThemeProvider>().toggleLanguage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customTheme.buttonSecondaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(
                            0,
                            screenHeight * UIConfig.primaryButtonHeightFactor * 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.language, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.switchLanguage),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.04),

                // Информация о следующих шагах
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: customTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: customTheme.successColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: customTheme.successColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Готово к следующему этапу:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: customTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Базовая архитектура создана\n'
                            '• Система тем работает\n'
                            '• Локализация настроена\n'
                            '• Сервисы инициализированы\n'
                            '• Готов к добавлению таймеров',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: customTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
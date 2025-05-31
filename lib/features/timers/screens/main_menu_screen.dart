// lib/features/timers/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/constants/ui_config.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/buttons/custom_buttons.dart' as CustomButtons;
import '../../../shared/widgets/cards/timer_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/services/localization_service.dart';
import '../../../features/timers/screens/timer_setup_screen.dart';
import '../../../core/providers/timer_provider.dart';

/// Главный экран выбора таймеров SportOn
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String? _selectedTimerType;

  // Список доступных таймеров с их параметрами
  final List<TimerConfig> _timerTypes = [
    TimerConfig(
      id: 'classic',
      titleKey: 'classicTitle',
      subtitleKey: 'classicSubtitle',
      descriptionKey: 'classicDescription',
      icon: Icons.timer_outlined,
      color: const Color(0xFF2196F3), // Синий
    ),
    TimerConfig(
      id: 'interval1',
      titleKey: 'interval1Title',
      subtitleKey: 'interval1Subtitle',
      descriptionKey: 'interval1Description',
      icon: Icons.repeat,
      color: const Color(0xFF4CAF50), // Зеленый
    ),
    TimerConfig(
      id: 'interval2',
      titleKey: 'interval2Title',
      subtitleKey: 'interval2Subtitle',
      descriptionKey: 'interval2Description',
      icon: Icons.schedule,
      color: const Color(0xFFFF9800), // Оранжевый
    ),
    TimerConfig(
      id: 'intensive',
      titleKey: 'intensiveTitle',
      subtitleKey: 'intensiveSubtitle',
      descriptionKey: 'intensiveDescription',
      icon: Icons.fitness_center,
      color: const Color(0xFFE91E63), // Розовый
    ),
    TimerConfig(
      id: 'norest',
      titleKey: 'noRestTitle',
      subtitleKey: 'noRestSubtitle',
      descriptionKey: 'noRestDescription',
      icon: Icons.flash_on,
      color: const Color(0xFFFF5722), // Красно-оранжевый
    ),
    TimerConfig(
      id: 'countdown',
      titleKey: 'countdownTitle',
      subtitleKey: 'countdownSubtitle',
      descriptionKey: 'countdownDescription',
      icon: Icons.hourglass_bottom,
      color: const Color(0xFF9C27B0), // Фиолетовый
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: customTheme.scaffoldBackgroundColor,

      // AppBar
      appBar: AppBar(
        toolbarHeight: screenHeight * UIConfig.toolbarHeightFactor,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.appTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Кнопка настроек тем
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.02),
            child: CustomButtons.CircularActionButton(
              icon: Icons.settings,
              size: screenWidth * 0.12,
              tooltip: 'Настройки',
              onPressed: () => _showSettingsBottomSheet(context),
            ),
          ),
        ],
      ),

      // Основной контент
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок секции
            Padding(
              padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selectTimer,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: screenHeight * UIConfig.titleFontSizeFactor,
                      fontWeight: FontWeight.bold,
                      color: customTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Выберите тип тренировки и настройте параметры',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: screenHeight * UIConfig.subtitleFontSizeFactor,
                      color: customTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Список таймеров
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * UIConfig.containerOuterPaddingFactor * 0.5,
                ),
                itemCount: _timerTypes.length,
                itemBuilder: (context, index) {
                  final timerConfig = _timerTypes[index];

                  return TimerCard(
                    title: LocalizationService.getTranslation(l10n, timerConfig.titleKey),
                    subtitle: LocalizationService.getTranslation(l10n, timerConfig.subtitleKey),
                    description: LocalizationService.getTranslation(l10n, timerConfig.descriptionKey),
                    icon: timerConfig.icon,
                    accentColor: timerConfig.color,
                    isSelected: _selectedTimerType == timerConfig.id,
                    onTap: () => _selectTimer(timerConfig.id),
                  );
                },
              ),
            ),

            // Нижняя панель с кнопкой старта
            Container(
              padding: EdgeInsets.all(screenWidth * UIConfig.containerOuterPaddingFactor),
              decoration: BoxDecoration(
                color: customTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Информация о выбранном таймере
                  if (_selectedTimerType != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: customTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                        ),
                        border: Border.all(
                          color: customTheme.successColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: customTheme.successColor,
                            size: screenWidth * 0.05,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Text(
                              'Выбрано: ${_getSelectedTimerName(l10n)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: customTheme.successColor,
                                fontWeight: FontWeight.w600,
                                fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.9,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Кнопка запуска таймера
                  SizedBox(
                    width: double.infinity,
                    child: CustomButtons.GradientButton(
                      text: _selectedTimerType != null ? l10n.start : 'Выбрать таймер',
                      icon: _selectedTimerType != null ? Icons.play_arrow : Icons.timer,
                      onPressed: _selectedTimerType != null ? _startTimer : null,
                      gradientColors: _selectedTimerType != null
                          ? [customTheme.buttonPrimaryColor, customTheme.successColor]
                          : [Colors.grey.shade400, Colors.grey.shade500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Выбор таймера
  void _selectTimer(String timerId) {
    setState(() {
      _selectedTimerType = _selectedTimerType == timerId ? null : timerId;
    });

    // Тактильная обратная связь
    if (_selectedTimerType != null) {
      // HapticFeedback.selectionClick(); // Раскомментировать при необходимости
    }
  }

  /// Получить название выбранного таймера
  String _getSelectedTimerName(AppLocalizations l10n) {
    if (_selectedTimerType == null) return '';

    final config = _timerTypes.firstWhere((t) => t.id == _selectedTimerType);
    return LocalizationService.getTranslation(l10n, config.titleKey);
  }

  /// Запуск выбранного таймера
  void _startTimer() {
    if (_selectedTimerType == null) return;

    // Определяем тип таймера
    TimerType timerType;
    switch (_selectedTimerType) {
      case 'classic':
        timerType = TimerType.classic;
        break;
      case 'interval1':
        timerType = TimerType.interval1;
        break;
      case 'interval2':
        timerType = TimerType.interval2;
        break;
      case 'intensive':
        timerType = TimerType.intensive;
        break;
      case 'norest':
        timerType = TimerType.norest;
        break;
      case 'countdown':
        timerType = TimerType.countdown;
        break;
      default:
        timerType = TimerType.classic;
    }

    // Переходим к экрану настройки таймера
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimerSetupScreen(timerType: timerType),
      ),
    );
  }

  /// Показать панель настроек
  void _showSettingsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: screenHeight * 0.4,
        decoration: BoxDecoration(
          color: customTheme.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: customTheme.buttonPrimaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.settingsTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: customTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Настройки
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Текущая тема
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: customTheme.buttonPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette,
                            color: customTheme.buttonPrimaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Текущая тема',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  customTheme.name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: customTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Кнопки управления
                    Row(
                      children: [
                        Expanded(
                          child: CustomButtons.PrimaryButton(
                            text: l10n.switchTheme,
                            icon: Icons.palette_outlined,
                            onPressed: () {
                              context.read<ThemeProvider>().nextTheme();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButtons.SecondaryButton(
                            text: l10n.switchLanguage,
                            icon: Icons.language,
                            onPressed: () {
                              context.read<ThemeProvider>().toggleLanguage();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Информация
                    Text(
                      'SportOn v1.0.0\nСовременный таймер для кроссфит тренировок',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Кнопка закрытия
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: CustomButtons.CustomTextButton(
                  text: 'Закрыть',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Конфигурация таймера
class TimerConfig {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;

  const TimerConfig({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
  });
}
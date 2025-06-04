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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../../core/providers/settings_provider.dart';
import '../../../core/enums/timer_enums.dart';
import '../../../shared/themes/app_themes.dart';

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
        title: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            final isRussian = themeProvider.currentLocale.languageCode == 'ru';

            return Text(
              isRussian ? '#НаСпорте' : '#SportOn',
              style: TextStyle(
                fontFamily: 'Gamestation',
                fontSize: screenHeight * UIConfig.toolbarHeightFactor * 0.5,
                fontWeight: FontWeight.bold,
                color: customTheme.textPrimaryColor,
                letterSpacing: 1.2,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          // Кнопка настроек тем
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.02),
            child: CustomButtons.CircularActionButton(
              icon: Icons.settings,
              size: screenWidth * 0.08,
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
                    description: '', // Оставляем пустым - описание теперь показывается внизу
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
                  // Подробная информация о выбранном таймере
                  if (_selectedTimerType != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: customTheme.buttonPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(
                          screenWidth * UIConfig.containerBorderRadiusFactor,
                        ),
                        border: Border.all(
                          color: customTheme.buttonPrimaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Заголовок с иконкой
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                decoration: BoxDecoration(
                                  color: _getSelectedTimerColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getSelectedTimerIcon(),
                                  color: _getSelectedTimerColor(),
                                  size: screenWidth * 0.05,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Text(
                                  _getSelectedTimerName(l10n),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: customTheme.textPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Подробное описание
                          Text(
                            _getSelectedTimerDescription(l10n),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: customTheme.textSecondaryColor,
                              height: 1.4,
                              fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.95,
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

  /// Получить подробное описание выбранного таймера
  String _getSelectedTimerDescription(AppLocalizations l10n) {
    if (_selectedTimerType == null) return '';

    final config = _timerTypes.firstWhere((t) => t.id == _selectedTimerType);
    return LocalizationService.getTranslation(l10n, config.descriptionKey);
  }

  /// Получить иконку выбранного таймера
  IconData _getSelectedTimerIcon() {
    if (_selectedTimerType == null) return Icons.timer;

    final config = _timerTypes.firstWhere((t) => t.id == _selectedTimerType);
    return config.icon;
  }

  /// Получить цвет выбранного таймера
  Color _getSelectedTimerColor() {
    if (_selectedTimerType == null) return Colors.blue;

    final config = _timerTypes.firstWhere((t) => t.id == _selectedTimerType);
    return config.color;
  }

  /// Проверить, является ли провайдер темным (для совместимости)
  bool _isDarkTheme(ThemeProvider themeProvider) {
    return themeProvider.isDarkTheme;
  }

  /// Получить тип текущей темы из ThemeProvider
  AppThemeType _getCurrentThemeType(ThemeProvider themeProvider) {
    // Используем геттер currentThemeType из вашего ThemeProvider
    return themeProvider.currentThemeType;
  }

  /// Получить расширение темы по типу
  CustomThemeExtension _getThemeExtensionByType(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return const CustomThemeExtension(
          name: 'Классическая',
          scaffoldBackgroundColor: Color(0xFFF8FAFC),
          cardColor: Colors.white,
          dividerColor: Color(0xFFE2E8F0),
          shadowColor: Colors.black12,
          textPrimaryColor: Color(0xFF1E293B),
          textSecondaryColor: Color(0xFF64748B),
          textDisabledColor: Color(0xFFCBD5E1),
          buttonPrimaryColor: Color(0xFF3B82F6),
          buttonSecondaryColor: Color(0xFF6B7280),
          buttonDisabledColor: Color(0xFFD1D5DB),
          successColor: Color(0xFF10B981),
          warningColor: Color(0xFFF59E0B),
          errorColor: Color(0xFFEF4444),
        );
      case AppThemeType.dark:
        return const CustomThemeExtension(
          name: 'Темная',
          scaffoldBackgroundColor: Color(0xFF0F172A),
          cardColor: Color(0xFF1E293B),
          dividerColor: Color(0xFF334155),
          shadowColor: Colors.black26,
          textPrimaryColor: Color(0xFFF1F5F9),
          textSecondaryColor: Color(0xFF94A3B8),
          textDisabledColor: Color(0xFF475569),
          buttonPrimaryColor: Color(0xFF3B82F6),
          buttonSecondaryColor: Color(0xFF64748B),
          buttonDisabledColor: Color(0xFF374151),
          successColor: Color(0xFF10B981),
          warningColor: Color(0xFFF59E0B),
          errorColor: Color(0xFFEF4444),
        );
      case AppThemeType.forest:
        return const CustomThemeExtension(
          name: 'Лес',
          scaffoldBackgroundColor: Color(0xFFF0F4F0),
          cardColor: Colors.white,
          dividerColor: Color(0xFFD4E6D4),
          shadowColor: Color(0x33059669),
          textPrimaryColor: Color(0xFF064E3B),
          textSecondaryColor: Color(0xFF047857),
          textDisabledColor: Color(0xFFA7C3A7),
          buttonPrimaryColor: Color(0xFF059669),
          buttonSecondaryColor: Color(0xFF10B981),
          buttonDisabledColor: Color(0xFFBBE5D1),
          successColor: Color(0xFF22C55E),
          warningColor: Color(0xFFF59E0B),
          errorColor: Color(0xFFEF4444),
        );
      case AppThemeType.ocean:
        return const CustomThemeExtension(
          name: 'Океан',
          scaffoldBackgroundColor: Color(0xFFF0F9FF),
          cardColor: Colors.white,
          dividerColor: Color(0xFFBAE6FD),
          shadowColor: Color(0x330EA5E9),
          textPrimaryColor: Color(0xFF0C4A6E),
          textSecondaryColor: Color(0xFF0284C7),
          textDisabledColor: Color(0xFF7DD3FC),
          buttonPrimaryColor: Color(0xFF0EA5E9),
          buttonSecondaryColor: Color(0xFF38BDF8),
          buttonDisabledColor: Color(0xFFBFDBFE),
          successColor: Color(0xFF10B981),
          warningColor: Color(0xFFF59E0B),
          errorColor: Color(0xFFEF4444),
        );
      case AppThemeType.desert:
        return const CustomThemeExtension(
          name: 'Пустыня',
          scaffoldBackgroundColor: Color(0xFFFEF3E2),
          cardColor: Colors.white,
          dividerColor: Color(0xFFFED7AA),
          shadowColor: Color(0x33EA580C),
          textPrimaryColor: Color(0xFF9A3412),
          textSecondaryColor: Color(0xFFEA580C),
          textDisabledColor: Color(0xFFFEDBB6),
          buttonPrimaryColor: Color(0xFFEA580C),
          buttonSecondaryColor: Color(0xFFF97316),
          buttonDisabledColor: Color(0xFFFED7AA),
          successColor: Color(0xFF10B981),
          warningColor: Color(0xFFF59E0B),
          errorColor: Color(0xFFEF4444),
        );
      case AppThemeType.mochaMousse:
        return const CustomThemeExtension(
          name: 'Мокко Мусс',
          scaffoldBackgroundColor: Color(0xFFF7F3F0),
          cardColor: Colors.white,
          dividerColor: Color(0xFFE7D7CC),
          shadowColor: Color(0x338B4513),
          textPrimaryColor: Color(0xFF5D4037),
          textSecondaryColor: Color(0xFF8D6E63),
          textDisabledColor: Color(0xFFD7CCC8),
          buttonPrimaryColor: Color(0xFF8B4513),
          buttonSecondaryColor: Color(0xFFA0522D),
          buttonDisabledColor: Color(0xFFE6C2B3),
          successColor: Color(0xFF10B981),
          warningColor: Color(0xFFF59E0B),
          errorColor: Color(0xFFEF4444),
        );
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
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final themeProvider = context.read<ThemeProvider>();

          return Container(
            height: screenHeight * 0.5,
            decoration: BoxDecoration(
              color: customTheme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Ручка для перетаскивания
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: customTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Заголовок
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: customTheme.buttonPrimaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Настройки',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: customTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

// Контент настроек
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Секция выбора темы
                        _buildThemeSection(context, themeProvider, setModalState),

                        const SizedBox(height: 24),

                        // Секция выбора языка
                        _buildLanguageSection(context, themeProvider, setModalState),

                        // Дополнительный отступ снизу для прокрутки
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                      ],
                    ),
                  ),
                ),

                // Отступ снизу (убираем, так как теперь в SingleChildScrollView)
              ],
            ),
          );
        },
      ),
    );
  }

  /// Секция выбора темы с цветными кружками
  Widget _buildThemeSection(BuildContext context, ThemeProvider themeProvider, StateSetter setModalState) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette,
              color: customTheme.textSecondaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Тема',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: customTheme.textPrimaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Цветные кружки тем
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: AppThemes.availableThemes.map((themeType) {
            final themeExtension = _getThemeExtensionByType(themeType);
            final isSelected = themeProvider.currentThemeType == themeType;

            return GestureDetector(
              onTap: () async {
                await themeProvider.setTheme(themeType);
                setModalState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 28 : 24,
                height: isSelected ? 28 : 24,
                decoration: BoxDecoration(
                  color: themeExtension.buttonPrimaryColor,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(
                    color: customTheme.textPrimaryColor,
                    width: 2,
                  ) : null,
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: themeExtension.buttonPrimaryColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Название выбранной темы
        Center(
          child: Text(
            customTheme.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: customTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Секция выбора языка с флагами
  Widget _buildLanguageSection(BuildContext context, ThemeProvider themeProvider, StateSetter setModalState) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.language,
              color: customTheme.textSecondaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Языки',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: customTheme.textPrimaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Русский язык
        _buildLanguageOption(
          context,
          flag: '🇷🇺',
          language: 'Русский',
          languageCode: 'ru',
          isSelected: themeProvider.currentLocale.languageCode == 'ru',
          onTap: () async {
            await themeProvider.setLanguage('ru');
            setModalState(() {});
          },
        ),

        const SizedBox(height: 12),

        // Английский язык
        _buildLanguageOption(
          context,
          flag: '🇺🇸',
          language: 'English',
          languageCode: 'en',
          isSelected: themeProvider.currentLocale.languageCode == 'en',
          onTap: () async {
            await themeProvider.setLanguage('en');
            setModalState(() {});
          },
        ),
      ],
    );
  }

  /// Опция выбора языка
  Widget _buildLanguageOption(
      BuildContext context, {
        required String flag,
        required String language,
        required String languageCode,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? customTheme.buttonPrimaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? customTheme.buttonPrimaryColor.withOpacity(0.3)
                : customTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: customTheme.textPrimaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            // Переключатель
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? customTheme.buttonPrimaryColor
                    : customTheme.dividerColor,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
                  : null,
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
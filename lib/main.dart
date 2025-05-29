// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

// Core imports
import 'core/services/storage_service.dart';
import 'core/providers/theme_provider.dart';

// Feature imports
import 'features/timers/screens/main_menu_screen.dart';

// Localization imports
import 'l10n/generated/app_localizations.dart';

/// Главная функция приложения
void main() async {
  // Инициализация Flutter framework
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка ориентации экрана (только портретная)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Настройка системного UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Инициализация сервисов
  try {
    await StorageService.init();
    developer.log('SportGo2 services initialized successfully');
  } catch (e) {
    developer.log('Failed to initialize services: $e', level: 900);
  }

  // Запуск приложения
  runApp(const SportGoApp());
}

/// Главный виджет приложения
class SportGoApp extends StatelessWidget {
  const SportGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Провайдер тем и локализации
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        // Здесь будут добавлены другие провайдеры:
        // - WorkoutProvider для управления тренировками
        // - HistoryProvider для истории тренировок
        // - SettingsProvider для настроек приложения
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // === ОСНОВНЫЕ НАСТРОЙКИ ===
            title: 'SportGo2',
            debugShowCheckedModeBanner: false,

            // === ТЕМЫ ===
            theme: themeProvider.currentTheme,
            darkTheme: themeProvider.isDarkTheme
                ? themeProvider.currentTheme
                : null,
            themeMode: themeProvider.themeMode,

            // === ЛОКАЛИЗАЦИЯ ===
            locale: themeProvider.currentLocale,
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ru', ''), // Русский
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              // Если язык устройства поддерживается, используем его
              if (deviceLocale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (deviceLocale.languageCode == supportedLocale.languageCode) {
                    return supportedLocale;
                  }
                }
              }

              // Иначе используем английский по умолчанию
              return supportedLocales.first;
            },

            // === НАВИГАЦИЯ ===
            home: const MainMenuScreen(),

            // === ОБРАБОТКА ОШИБОК ===
            builder: (context, child) {
              // Обработка ошибок рендеринга
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return _buildErrorWidget(context, errorDetails);
              };

              return child ?? const SizedBox.shrink();
            },

            // === ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ ===
            // Отключаем баннер режима отладки
            debugShowMaterialGrid: false,

            // Настройки для web-версии (если планируется)
            // useInheritedMediaQuery: true,
          );
        },
      ),
    );
  }

  /// Виджет для отображения ошибок
  Widget _buildErrorWidget(BuildContext context, FlutterErrorDetails errorDetails) {
    developer.log(
      'UI Error: ${errorDetails.exception}',
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
      level: 1000,
    );

    return Material(
      child: Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please restart the app or contact support if the problem persists.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (kDebugMode) ...[
              Text(
                'Debug Info:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                errorDetails.exception.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade500,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Константа для проверки режима отладки
const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;
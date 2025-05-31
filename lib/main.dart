// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Импорты сервисов
import 'core/services/storage_service.dart';

// Импорты провайдеров
import 'core/providers/theme_provider.dart';
import 'core/providers/timer_provider.dart';

// Импорты локализации
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';

// Импорты экранов
import 'features/timers/screens/main_menu_screen.dart';

void main() async {
  // Убеждаемся, что Flutter инициализирован
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация сервисов перед запуском приложения
  await StorageService.initialize();

  // Настройка системных UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Настройка системной панели
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SportOnApp());
}

/// Главный виджет приложения SportOn
class SportOnApp extends StatelessWidget {
  const SportOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Провайдер тем и языка
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..initialize(),
        ),

        // Провайдер таймеров
        ChangeNotifierProvider(
          create: (context) => TimerProvider(),
        ),

        // Здесь будут добавлены другие провайдеры:
        // - WorkoutProvider (управление тренировками)
        // - HistoryProvider (управление историей)
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // === ОСНОВНЫЕ НАСТРОЙКИ ПРИЛОЖЕНИЯ ===
            title: 'SportOn',
            debugShowCheckedModeBanner: false,

            // === НАСТРОЙКИ ЛОКАЛИЗАЦИИ ===
            locale: themeProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // Английский
              Locale('ru'), // Русский
            ],

            // === НАСТРОЙКИ ТЕМЫ ===
            // Настройка темы на основе текущих настроек
            theme: themeProvider.currentTheme,
            darkTheme: themeProvider.currentTheme, // Используем ту же тему
            themeMode: themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,

            // === НАВИГАЦИЯ ===
            home: const MainMenuScreen(),

            // Настройки роутов (будут добавлены позже)
            routes: {
              '/main': (context) => const MainMenuScreen(),
              // Здесь будут добавлены другие маршруты:
              // '/timer_setup': (context) => const TimerSetupScreen(),
              // '/classic_timer': (context) => const ClassicTimerScreen(),
              // '/history': (context) => const HistoryScreen(),
              // '/settings': (context) => const SettingsScreen(),
            },

            // === ОБРАБОТКА НАВИГАЦИИ ===
            onGenerateRoute: (settings) {
              // Кастомная обработка маршрутов (при необходимости)
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (context) => const MainMenuScreen(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (context) => const MainMenuScreen(),
                  );
              }
            },

            // === ОБРАБОТКА НЕИЗВЕСТНЫХ МАРШРУТОВ ===
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const MainMenuScreen(),
              );
            },

            // === НАСТРОЙКИ ПРОИЗВОДИТЕЛЬНОСТИ ===
            builder: (context, child) {
              // Можно добавить обертки для всего приложения
              return MediaQuery(
                // Отключаем масштабирование текста системой
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
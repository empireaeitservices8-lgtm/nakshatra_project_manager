import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'login_screen.dart';
import 'services/services.dart';
import 'viewmodels/viewmodels.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Core API Services
  final apiService = ApiService();
  final taskManagerApi = TaskManagerApiService(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        // ─── Network & API Services ──────────────────────────────────────────
        Provider<ApiService>.value(value: apiService),
        Provider<TaskManagerApiService>.value(value: taskManagerApi),

        // ─── ViewModels (ChangeNotifier) ─────────────────────────────────────
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(api: taskManagerApi),
        ),
        ChangeNotifierProvider<BoardViewModel>(
          create: (_) => BoardViewModel(api: taskManagerApi),
        ),
        ChangeNotifierProvider<TaskViewModel>(
          create: (_) => TaskViewModel(api: taskManagerApi),
        ),
        ChangeNotifierProvider<NotificationViewModel>(
          create: (_) => NotificationViewModel(api: taskManagerApi),
        ),

        // ─── Legacy AppState (Maintains backwards UI compatibility) ──────────
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
        ),
      ],
      child: const NakshatraApp(),
    ),
  );
}

class NakshatraApp extends StatelessWidget {
  const NakshatraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Both context.watch<AppState>() or context.watch<AuthViewModel>() can be consumed here
    final appState = context.watch<AppState>();

    return MaterialApp(
      title: 'Nakshthra task',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: LoginScreen(state: appState),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: NGColors.gold,
        brightness: Brightness.dark,
        surface: const Color(0xFF141414),
      ).copyWith(
        primary: NGColors.gold,
        onPrimary: Colors.white,
        surface: const Color(0xFF141414),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: NGColors.obsidian,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NGColors.gold,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NGColors.gold,
          side: const BorderSide(color: NGColors.gold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: NGColors.gold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NGColors.gold, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        fillColor: const Color(0xFF1C1C1C),
        filled: true,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NGColors.gold;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF141414),
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF222222),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: NGColors.gold,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }
}

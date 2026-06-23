import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'app_state.dart' show NGColors;
import 'login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const NakshatraApp());
}

class NakshatraApp extends StatefulWidget {
  const NakshatraApp({super.key});

  @override
  State<NakshatraApp> createState() => _NakshatraAppState();
}

class _NakshatraAppState extends State<NakshatraApp> {
  final AppState _state = AppState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        return MaterialApp(
          title: 'Nakshatra Gold & Diamonds',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          home: LoginScreen(state: _state),
        );
      },
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
        background: NGColors.obsidian,
      ).copyWith(
        primary: NGColors.gold,
        onPrimary: Colors.white,
        surface: const Color(0xFF141414),
        onSurface: Colors.white,
        background: NGColors.obsidian,
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
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return NGColors.gold;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF141414),
        modalBackgroundColor: Color(0xFF141414),
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

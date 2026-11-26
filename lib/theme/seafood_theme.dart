import 'package:flutter/material.dart';

abstract final class SeafoodColors {
  static const green = Color(0xFF079B35);
  static const deepGreen = Color(0xFF155D32);
  static const lime = Color(0xFFB8E51B);
  static const paleMint = Color(0xFFF2FBF4);
  static const ink = Color(0xFF332C27);
  static const muted = Color(0xFF718078);
  static const white = Colors.white;
}

ThemeData buildSeafoodTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: SeafoodColors.green,
    primary: SeafoodColors.green,
    secondary: SeafoodColors.lime,
    surface: SeafoodColors.white,
    onSurface: SeafoodColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: SeafoodColors.paleMint,
    appBarTheme: const AppBarTheme(
      backgroundColor: SeafoodColors.paleMint,
      foregroundColor: SeafoodColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: SeafoodColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: SeafoodColors.white,
      elevation: 1,
      shadowColor: SeafoodColors.deepGreen.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SeafoodColors.paleMint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: SeafoodColors.deepGreen.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: SeafoodColors.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: SeafoodColors.muted),
      prefixIconColor: SeafoodColors.deepGreen,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SeafoodColors.deepGreen,
        foregroundColor: SeafoodColors.white,
        disabledBackgroundColor: SeafoodColors.deepGreen.withValues(alpha: 0.45),
        disabledForegroundColor: SeafoodColors.white,
        minimumSize: const Size(0, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SeafoodColors.deepGreen,
        side: BorderSide(color: SeafoodColors.deepGreen.withValues(alpha: 0.18)),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SeafoodColors.deepGreen,
      foregroundColor: SeafoodColors.white,
      elevation: 3,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SeafoodColors.deepGreen,
      contentTextStyle: const TextStyle(color: SeafoodColors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SeafoodColors.white,
      indicatorColor: SeafoodColors.lime.withValues(alpha: 0.34),
      elevation: 8,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? SeafoodColors.deepGreen
              : SeafoodColors.muted,
        );
      }),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: SeafoodColors.deepGreen,
      unselectedLabelColor: SeafoodColors.muted,
      indicatorColor: SeafoodColors.green,
      labelStyle: TextStyle(fontWeight: FontWeight.w800),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

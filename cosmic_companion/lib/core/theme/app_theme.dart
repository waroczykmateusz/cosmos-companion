import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color oledBlack = Color(0xFF000000);
  static const Color starWhite = Color(0xFFE8E8F0);
  static const Color cosmicPurple = Color(0xFF9C7FFF);
  static const Color nebulaTeal = Color(0xFF03DAC6);
  static const Color redFilter = Color(0xFFFF1A00);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: oledBlack,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cosmicPurple,
          brightness: Brightness.dark,
          surface: const Color(0xFF0A0A0F),
          onSurface: starWhite,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF0D0D1A),
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: oledBlack,
          foregroundColor: starWhite,
          elevation: 0,
        ),
      );

  static ThemeData get nightDark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: oledBlack,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cosmicPurple,
          brightness: Brightness.dark,
          surface: oledBlack,
          onSurface: const Color(0xFFAAAAAA),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF050508),
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: oledBlack,
          foregroundColor: Color(0xFFAAAAAA),
          elevation: 0,
        ),
      );
}

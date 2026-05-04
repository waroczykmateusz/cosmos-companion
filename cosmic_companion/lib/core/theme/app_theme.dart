import 'package:flutter/material.dart';

abstract final class AppTheme {
  // ── Space design tokens ──────────────────────────────────────────────────
  static const Color bgMain = Color(0xFF030A1A);
  static const Color bgCard = Color(0xBF0A1632);   // rgba(10,22,50,0.75)
  static const Color border = Color(0xFF1A2D50);
  static const Color textMuted = Color(0xFF3D5A80);
  static const Color textAccent = Color(0xFF4A6FA5);
  static const Color textMain = Color(0xFFC8DFF5);
  static const Color accentBlue = Color(0xFF7BA7E0);
  static const Color scoreGreen = Color(0xFF1D9E75);
  static const Color scoreOrange = Color(0xFFBA7517);
  static const Color scoreRed = Color(0xFFE24B4A);

  // ── Legacy tokens ────────────────────────────────────────────────────────
  static const Color oledBlack = Color(0xFF000000);
  static const Color starWhite = Color(0xFFE8E8F0);
  static const Color cosmicPurple = Color(0xFF9C7FFF);
  static const Color nebulaTeal = Color(0xFF03DAC6);
  static const Color redFilter = Color(0xFFFF1A00);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgMain,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cosmicPurple,
          brightness: Brightness.dark,
          surface: const Color(0xFF0A0E1A),
          onSurface: textMain,
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgMain,
          foregroundColor: textMain,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgMain,
          selectedItemColor: accentBlue,
          unselectedItemColor: textMuted,
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

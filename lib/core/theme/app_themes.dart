import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

enum GymTheme { rpg, military, minimal, medieval }

/// Genera il [ThemeData] Flutter completo per ogni tema.
/// Usato da [ThemeProvider] per aggiornare MaterialApp.
class AppThemes {
  AppThemes._();

  static ThemeData of(GymTheme theme) {
    return switch (theme) {
      GymTheme.rpg      => _build(AppColors.rpg,      Brightness.dark),
      GymTheme.military => _build(AppColors.military,  Brightness.dark),
      GymTheme.minimal  => _build(AppColors.minimal,   Brightness.light),
      GymTheme.medieval => _build(AppColors.medieval,  Brightness.dark),
    };
  }

  static ThemeData _build(ThemeColors c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary:          c.accent,
        onPrimary:        c.background,
        secondary:        c.accentLight,
        onSecondary:      c.background,
        surface:          c.surface,
        onSurface:        c.textPrimary,
        background:       c.background,
        onBackground:     c.textPrimary,
        error:            const Color(0xFFFF4444),
        onError:          Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: c.textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.background,
        selectedItemColor: c.accent,
        unselectedItemColor: c.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: c.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: c.glass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.glassBorder, width: 1),
        ),
      ),
      iconTheme: IconThemeData(color: c.textSecondary, size: 20),
      splashColor: c.accentGlow,
      highlightColor: Colors.transparent,
      useMaterial3: true,
    );
  }
}
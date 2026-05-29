import 'package:flutter/material.dart';

/// Palette centralizzata per The Big Gym.
/// Ogni tema ha la sua istanza di [ThemeColors].
/// Tutti i widget leggono i colori da qui — mai hardcoded.
class AppColors {
  AppColors._();

  // ─── Helper ────────────────────────────────────────────
  static Color alpha(Color color, double opacity) =>
      color.withOpacity(opacity);

  // ─── Tier muscoli (condivisi tra tutti i temi) ─────────
  static const Color tierUnranked  = Color(0xFF2A2A2A);
  static const Color tierIron      = Color(0xFF6B6B6B);
  static const Color tierBronze    = Color(0xFFCD7F32);
  static const Color tierSilver    = Color(0xFFC0C0C0);
  static const Color tierGold      = Color(0xFFFFD700);
  static const Color tierPlatinum  = Color(0xFF00C2FF);
  static const Color tierDiamond   = Color(0xFFB9F2FF);
  static const Color tierRuby      = Color(0xFFFF4060);
  static const Color tierCrystal   = Color(0xFFE040FB);
  static const Color tierElite     = Color(0xFFFF9800);
  static const Color tierChampion  = Color(0xFFFF6B35);
  static const Color tierCelestial = Color(0xFFFFFFFF);
  static const Color tierTitan     = Color(0xFFFF6B35);

  // ─── TEMA: Solo Leveling (RPG dark) ───────────────────
  static const rpg = ThemeColors(
    background:      Color(0xFF0B0B0F),
    surface:         Color(0xFF141418),
    surfaceVariant:  Color(0xFF1A1A20),
    glass:           Color(0x0FFFFFFF),
    glassBorder:     Color(0x1AFFFFFF),
    accent:          Color(0xFFC9A84C),
    accentLight:     Color(0xFFE8C96A),
    accentGlow:      Color(0x26C9A84C),
    textPrimary:     Color(0xFFF0EDE6),
    textSecondary:   Color(0xFF7A7670),
    textTertiary:    Color(0xFF3A3632),
    divider:         Color(0xFF1E1E24),
  );

  // ─── TEMA: Militare ────────────────────────────────────
  static const military = ThemeColors(
    background:      Color(0xFF080C05),
    surface:         Color(0xFF10140A),
    surfaceVariant:  Color(0xFF181D0E),
    glass:           Color(0x116AAA2A),
    glassBorder:     Color(0x266AAA2A),
    accent:          Color(0xFF6AAA2A),
    accentLight:     Color(0xFF8FD43A),
    accentGlow:      Color(0x266AAA2A),
    textPrimary:     Color(0xFFDDE8C4),
    textSecondary:   Color(0xFF6A7A4A),
    textTertiary:    Color(0xFF3A4A2A),
    divider:         Color(0xFF1A2010),
  );

  // ─── TEMA: Minimal (light) ─────────────────────────────
  static const minimal = ThemeColors(
    background:      Color(0xFFF5F4F0),
    surface:         Color(0xFFFFFFFF),
    surfaceVariant:  Color(0xFFEFEEEA),
    glass:           Color(0x0A000000),
    glassBorder:     Color(0x18000000),
    accent:          Color(0xFF1A1A1A),
    accentLight:     Color(0xFF333333),
    accentGlow:      Color(0x0D000000),
    textPrimary:     Color(0xFF111111),
    textSecondary:   Color(0xFF666666),
    textTertiary:    Color(0xFFBBBBBB),
    divider:         Color(0xFFE0E0E0),
  );

  // ─── TEMA: Medievale ───────────────────────────────────
  static const medieval = ThemeColors(
    background:      Color(0xFF1A1208),
    surface:         Color(0xFF221A0C),
    surfaceVariant:  Color(0xFF2A2010),
    glass:           Color(0x14B48C3C),
    glassBorder:     Color(0x33B48C3C),
    accent:          Color(0xFFD4A843),
    accentLight:     Color(0xFFF0C96A),
    accentGlow:      Color(0x2ED4A843),
    textPrimary:     Color(0xFFF2E8D0),
    textSecondary:   Color(0xFF8A7A54),
    textTertiary:    Color(0xFF4A3E28),
    divider:         Color(0xFF2E2418),
  );
}

/// Raccoglie tutti i colori di un singolo tema.
/// Pubblica così può essere importata dagli altri file.
class ThemeColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color glass;
  final Color glassBorder;
  final Color accent;
  final Color accentLight;
  final Color accentGlow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color divider;

  const ThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.glass,
    required this.glassBorder,
    required this.accent,
    required this.accentLight,
    required this.accentGlow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
  });
}
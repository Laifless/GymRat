import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_themes.dart';
import '../theme/app_colors.dart';

/// Gestisce il tema attivo dell'app.
/// Persiste la scelta su [SharedPreferences] e notifica i listener.
class ThemeProvider extends ChangeNotifier {
  static const _key = 'gym_theme';

  GymTheme _current = GymTheme.rpg;

  GymTheme get current => _current;
  ThemeData get themeData => AppThemes.of(_current);

  /// Colori del tema corrente — usato dai widget per colori custom
  /// che non rientrano nel ThemeData standard (glassBorder, accentGlow…).
  ThemeColors get colors => switch (_current) {
    GymTheme.rpg      => AppColors.rpg,
    GymTheme.military => AppColors.military,
    GymTheme.minimal  => AppColors.minimal,
    GymTheme.medieval => AppColors.medieval,
  };

  /// Carica il tema salvato all'avvio.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      _current = GymTheme.values.firstWhere(
        (t) => t.name == saved,
        orElse: () => GymTheme.rpg,
      );
      notifyListeners();
    }
  }

  /// Cambia tema e salva la scelta.
  Future<void> setTheme(GymTheme theme) async {
    if (_current == theme) return;
    _current = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme.name);
  }

  /// Nome leggibile del tema corrente.
  String get displayName => switch (_current) {
    GymTheme.rpg      => 'Solo Leveling',
    GymTheme.military => 'Militare',
    GymTheme.minimal  => 'Minimal',
    GymTheme.medieval => 'Medievale',
  };

  /// Descrizione breve per la settings screen.
  String get themeDescription => switch (_current) {
    GymTheme.rpg      => 'Dark · Oro · Glitch',
    GymTheme.military => 'Verde oliva · Tattico',
    GymTheme.minimal  => 'Light mode · Pulito',
    GymTheme.medieval => 'Pergamena · Rune · Bronzo',
  };
}
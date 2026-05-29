import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/hunter.dart';
import '../../models/muscle_data.dart';
import '../constants/rank_constants.dart';

class HunterProvider extends ChangeNotifier {
  static const _hunterKey  = 'hunter_data';
  static const _musclesKey = 'muscle_data';

  Hunter _hunter = Hunter.initial;
  Map<String, MuscleData> _muscles = {};
  bool _loading = true;

  // ─── Getters ───────────────────────────────────────────
  Hunter get hunter   => _hunter;
  bool   get loading  => _loading;

  MuscleData muscleData(String group) =>
      _muscles[group] ?? MuscleData.empty(group);

  Map<String, MuscleData> get allMuscles => Map.unmodifiable(_muscles);

  /// Volume totale cumulativo su tutti i muscoli.
  int get totalVolume =>
      _muscles.values.fold(0, (sum, m) => sum + m.totalVolume);

  // ─── Init ──────────────────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Carica hunter
    final hunterJson = prefs.getString(_hunterKey);
    if (hunterJson != null) {
      _hunter = Hunter.fromJson(
        jsonDecode(hunterJson) as Map<String, dynamic>,
      );
    }

    // Carica muscoli
    final musclesJson = prefs.getString(_musclesKey);
    if (musclesJson != null) {
      final raw = jsonDecode(musclesJson) as Map<String, dynamic>;
      _muscles = raw.map(
        (k, v) => MapEntry(k, MuscleData.fromJson(v as Map<String, dynamic>)),
      );
    } else {
      // Prima volta: inizializza tutti i muscoli a 0
      _muscles = {
        for (final g in kMuscleGroups) g: MuscleData.empty(g),
      };
    }

    _loading = false;
    notifyListeners();
  }

  // ─── Aggiorna dopo una sessione completata ─────────────
  Future<void> onSessionCompleted({
    required int xpGained,
    required Map<String, int> volumeByMuscle,
    required DateTime sessionDate,
  }) async {
    // Calcola streak
    final last = _hunter.lastSessionDate;
    int newStreak = _hunter.currentStreak;

    if (last == null) {
      newStreak = 1;
    } else {
      final diff = sessionDate.difference(last).inDays;
      if (diff == 1) {
        newStreak += 1;           // giorno consecutivo
      } else if (diff == 0) {
        // stessa giornata, streak invariato
      } else {
        newStreak = 1;            // streak rotto
      }
    }

    _hunter = _hunter.copyWith(
      totalXp:         _hunter.totalXp + xpGained,
      totalSessions:   _hunter.totalSessions + 1,
      currentStreak:   newStreak,
      bestStreak:      newStreak > _hunter.bestStreak
                           ? newStreak
                           : _hunter.bestStreak,
      lastSessionDate: sessionDate,
    );

    // Aggiorna volume muscoli
    for (final entry in volumeByMuscle.entries) {
      final current = _muscles[entry.key] ?? MuscleData.empty(entry.key);
      _muscles[entry.key] = current.copyWith(
        totalVolume: current.totalVolume + entry.value,
        lastTrained: sessionDate,
      );
    }

    await _save();
    notifyListeners();
  }

  /// Aggiorna solo il nome del hunter.
  Future<void> setName(String name) async {
    _hunter = _hunter.copyWith(name: name.trim().isEmpty ? 'Hunter' : name.trim());
    await _save();
    notifyListeners();
  }

  // ─── Persistenza ───────────────────────────────────────
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hunterKey, jsonEncode(_hunter.toJson()));
    await prefs.setString(
      _musclesKey,
      jsonEncode(_muscles.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  /// Reset completo (debug / onboarding).
  Future<void> reset() async {
    _hunter  = Hunter.initial;
    _muscles = {for (final g in kMuscleGroups) g: MuscleData.empty(g)};
    await _save();
    notifyListeners();
  }
}